// SPDX-License-Identifier: LGPL-2.1
// Copyright 2021 Daniel Vogelbacher <daniel@chaospixel.com>
// Forked and minified for autodngconverter — retains convert, reembed, cameras, lenses only

use std::path::PathBuf;

use clap::{
  Arg, ArgAction, Command, arg,
  builder::{NonEmptyStringValueParser, ValueParser},
  command, value_parser,
};
use log::debug;
use rawler::dng::{ApplyDngOpcodes, CropMode, DngCompression, DngVersion, MAX_JXL_DISTANCE, opcodes::OpcodeSelector};
use rawler::imgop::{
  color::OutputSpace,
  develop::ProcessingStep,
  sharpen::DEFAULT_SHARPEN,
};

#[derive(Clone, Debug, Copy, Eq, PartialEq, PartialOrd, Ord)]
pub enum LogLevel {
  Error,
  Warn,
  Info,
  Debug,
  Trace,
}

impl clap::ValueEnum for LogLevel {
  fn value_variants<'a>() -> &'a [Self] {
    &[Self::Error, Self::Warn, Self::Info, Self::Debug, Self::Trace]
  }

  fn to_possible_value(&self) -> Option<clap::builder::PossibleValue> {
    Some(match self {
      Self::Error => clap::builder::PossibleValue::new("error"),
      Self::Warn => clap::builder::PossibleValue::new("warn"),
      Self::Info => clap::builder::PossibleValue::new("info"),
      Self::Debug => clap::builder::PossibleValue::new("debug"),
      Self::Trace => clap::builder::PossibleValue::new("trace"),
    })
  }
}

/// Largest strength of the noise reduction
const MAX_DENOISE_STRENGTH: f32 = 4.0;

/// Parser for the strength of the noise reduction
fn denoise_strength_parser(value: &str) -> std::result::Result<f32, String> {
  let strength: f32 = value.parse().map_err(|err| format!("{}", err))?;
  if (0.0..=MAX_DENOISE_STRENGTH).contains(&strength) {
    Ok(strength)
  } else {
    Err(format!("{} is not in 0..={}", value, MAX_DENOISE_STRENGTH))
  }
}

/// Largest strength of the sharpening
const MAX_SHARPEN_STRENGTH: f32 = 2.0;

/// Parser for the strength of the sharpening
fn sharpen_strength_parser(value: &str) -> std::result::Result<f32, String> {
  let strength: f32 = value.parse().map_err(|err| format!("{}", err))?;
  if (0.0..=MAX_SHARPEN_STRENGTH).contains(&strength) {
    Ok(strength)
  } else {
    Err(format!("{} is not in 0..={}", value, MAX_SHARPEN_STRENGTH))
  }
}

/// Parser for an exposure in EV, any finite number
fn exposure_parser(value: &str) -> std::result::Result<f32, String> {
  let exposure: f32 = value.parse().map_err(|err| format!("{}", err))?;
  if exposure.is_finite() {
    Ok(exposure)
  } else {
    Err(format!("{} is not a finite number", value))
  }
}

/// Parse a JPEG XL distance in the range 0 to 25
fn jxl_distance_parser(value: &str) -> std::result::Result<f32, String> {
  let distance: f32 = value.parse().map_err(|err| format!("{}", err))?;
  if (0.0..=MAX_JXL_DISTANCE).contains(&distance) {
    Ok(distance)
  } else {
    Err(format!("{} is not in 0..={}", value, MAX_JXL_DISTANCE))
  }
}

/// Argument to remove DNG opcodes, shared by convert and process-raw
fn remove_dng_opcodes_arg() -> Arg {
  arg!(remove_dng_opcodes: --"remove-dng-opcodes" <opcodes> "Remove DNG opcodes, as comma separated [<list>:]<opcode> (e.g. WarpRectilinear,2:GainMap)")
    .required(false)
    .value_parser(value_parser!(OpcodeSelector))
    .value_delimiter(',')
    .action(ArgAction::Append)
}

/// Argument with a comma separated list of processing steps of the rendering
fn steps_arg(id: &'static str, long: &'static str, help: &'static str) -> Arg {
  Arg::new(id)
    .long(long)
    .value_name("steps")
    .help(help)
    .required(false)
    .value_parser(value_parser!(ProcessingStep))
    .value_delimiter(',')
    .ignore_case(true)
    .action(ArgAction::Append)
}

// The subcommands are built in separate functions. A single builder chain for the whole app
// needs a huge stack frame in debug builds, which overflows the 1 MB main thread stack on Windows.
pub fn create_app() -> Command {
  debug!("Creating CLAP app configuration");

  command!()
    .about("DNGLab - A camera raw utility and DNG converter")
    .subcommand_required(true)
    .arg_required_else_help(true)
    .arg(
      arg!(loglevel: -d --loglevel <level> "Log level")
        .global(true)
        .required(false)
        .value_parser(value_parser!(LogLevel))
        .default_value("warn"),
    )
    .arg(arg!(verbose: -v "Print status for every file").global(true).action(ArgAction::SetTrue))
    .arg(
      arg!(profile_path: --"profile-path" <dir> "Directory with profile TOML files")
        .global(true)
        .required(false)
        .value_parser(clap::value_parser!(PathBuf))
        .long_help(
          "Directory with profile TOML files. All *.toml files in this directory are loaded.\nIf not given, 'profile_path' from the dnglab configuration file is used. Otherwise profiles are loaded\nfrom the 'rawler/profiles' and 'dnglab/profiles' directories in the user configuration directory\n(e.g. ~/.config on Linux, ~/Library/Application Support on macOS, %APPDATA% on Windows).",
        ),
    )
    .arg(
      arg!(config: --config <file> "dnglab configuration file")
        .global(true)
        .required(false)
        .value_parser(clap::value_parser!(PathBuf))
        .long_help(
          "dnglab configuration file. If not given, 'dnglab/config.toml' in the user configuration directory\n(e.g. ~/.config on Linux, ~/Library/Application Support on macOS, %APPDATA% on Windows) is used if it exists.\nExample:\n\n  version = 1\n  profile_path = \"profiles\"   # relative to the configuration file\n\n  [convert]\n  default_profile = \"builtin_latest\"",
        ),
    )
    .subcommand(convert_command())
    .subcommand(reembed_command())
    .subcommand(
      Command::new("cameras")
        .about("List supported cameras")
        .arg_required_else_help(false)
        .arg(arg!(markdown: --md "Markdown format output").action(ArgAction::SetTrue)),
    )
    .subcommand(
      Command::new("lenses")
        .about("List supported lenses")
        .arg_required_else_help(false)
        .arg(arg!(markdown: --md "Markdown format output").action(ArgAction::SetTrue)),
    )
}

/// Arguments shared by convert
fn convert_base_command() -> Command {
  Command::new("convert")
    .about("Convert raw image(s) into dng format")
    .arg(
      arg!(profile: -p --"profile" <name> "Convert profile name")
        .required(false)
        .value_parser(NonEmptyStringValueParser::new())
        .long_help(
          "Convert profile to use for conversion. Built-in profiles are 'builtin_compat' (DNG 1.4.0), 'builtin_latest' (DNG 1.6.0),\n'builtin_jxl' (JPEG XL lossless, DNG 1.7.1) and 'builtin_archive'.\nIf not given, 'convert.default_profile' from the dnglab configuration file is used.\nOtherwise no profile is used and the command line switches with their defaults apply.\nCommand line switches override the values of the profile.",
        ),
    )
    .arg(
      arg!(compression: -c --"compression" <compression> "Compression for raw image")
        .required(false)
        .value_parser(value_parser!(DngCompression))
        .default_value("lossless")
        .long_help("Compression for raw image. Deflate: floating point input only (DNG 1.4), half floats where they fit."),
    )
    .arg(
      arg!(predictor: --"ljpeg92-predictor" <predictor> "LJPEG-92 predictor")
        .required(false)
        .value_parser(clap::value_parser!(u8).range(1..=7))
        .default_value("1"),
    )
    .arg(
      arg!(lossy_jpeg_quality: --"lossy-jpeg-quality" <quality> "JPEG quality for lossy compression (1-100)")
        .required(false)
        .value_parser(clap::value_parser!(u8).range(1..=100))
        .default_value("94"),
    )
    .arg(
      arg!(jxl_distance: --"jxl-distance" <distance> "JPEG XL distance (0-25), 0 is lossless")
        .required(false)
        .value_parser(jxl_distance_parser)
        .default_value("0")
        .long_help(
          "JPEG XL distance (0-25). 0 is lossless, larger values are lossy and give smaller files.\nLossy compression applies OpcodeList1 to the image data.",
        ),
    )
    .arg(
      arg!(jxl_effort: --"jxl-effort" <effort> "JPEG XL encoder effort (1-9)")
        .required(false)
        .value_parser(clap::value_parser!(u8).range(1..=9))
        .default_value("7"),
    )
    .arg(
      arg!(jxl_decode_speed: --"jxl-decode-speed" <speed> "JPEG XL decoding speed for lossy compression (1-4)")
        .required(false)
        .value_parser(clap::value_parser!(u8).range(1..=4))
        .default_value("4"),
    )
    .arg(
      arg!(preview: --"dng-preview" <preview> "DNG include preview image")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("true")
        .default_missing_value("true"),
    )
    .arg(
      arg!(thumbnail: --"dng-thumbnail" <thumbnail> "DNG include thumbnail image")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("true")
        .default_missing_value("true"),
    )
    .arg(
      arg!(force_preview: --"dng-force-preview" <force_preview> "Generate DNG preview image from raw data")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("false")
        .default_missing_value("true"),
    )
    .arg(
      arg!(force_thumbnail: --"dng-force-thumbnail" <force_thumbnail> "Generate DNG thumbnail image from raw data")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("false")
        .default_missing_value("true"),
    )
    .arg(
      arg!(max_dng_backward_version: --"max-dng-backward-version" <version> "Maximum DNG backward version")
        .required(false)
        .value_parser(value_parser!(DngVersion))
        .default_value("1.4"),
    )
    .arg(
      arg!(embedded: --"embed-raw" <embedded> "Embed the raw file into DNG")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("true")
        .default_missing_value("true"),
    )
    .arg(
      arg!(apply_dng_opcodes: --"apply-dng-opcodes" <mode> "Apply DNG opcode lists to the image data instead of writing them to the DNG")
        .required(false)
        .value_parser(value_parser!(ApplyDngOpcodes))
        .default_value("auto"),
    )
    .arg(remove_dng_opcodes_arg())
    .arg(
      arg!(--"artist" <artist> "Set the artist tag")
        .required(false)
        .value_parser(NonEmptyStringValueParser::new()),
    )
    .arg(
      arg!(--"copyright" <copyright> "Set the copyright tag")
        .required(false)
        .value_parser(NonEmptyStringValueParser::new()),
    )
    .arg(
      arg!(keep_mtime: --"keep-mtime" <keepmtime> "Keep mtime, read from EXIF with fallback to original file mtime")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("false")
        .default_missing_value("false"),
    )
    .arg(
      arg!(index: --"image-index" <index> "Select a specific image index (or 'all') if file is a image container")
        .required(false)
        .default_value("0"),
    )
    .arg(
      arg!(--"crop" <crop> "DNG default crop")
        .required(false)
        .value_parser(value_parser!(CropMode))
        .default_value("best"),
    )
    .arg(arg!(-f --override "Override existing files").action(ArgAction::SetTrue))
}

/// Subcommand convert
fn convert_command() -> Command {
  convert_base_command()
    .subcommand(Command::new("raw")
      .about("Convert raw images to DNG (deprecated: same as convert)")
      .visible_alias("r")
      .arg(arg!(<INPUT> "Input file or directory").value_parser(clap::value_parser!(PathBuf)))
      .arg(arg!(<OUTPUT> "Output file or existing directory").value_parser(clap::value_parser!(PathBuf))))
    .arg(arg!(<INPUT> "Input file or directory").value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(<OUTPUT> "Output file or existing directory").value_parser(clap::value_parser!(PathBuf)))
    .arg(
      arg!(output_colorspace: --"colorspace" <COLORSPACE> "Colorspace of resulting DNG image")
        .value_parser(value_parser!(OutputSpace))
        .default_value("srgb")
        .long_help("The colorspace the resulting DNG file will have. This includes setting the color matrices if not done in the profile."),
    )
    .arg(steps_arg("render_steps", "render-steps", "Render pipeline steps"))
    .arg(steps_arg("hide_steps", "hide-steps", "Hide render pipeline steps"))
    .arg(
      arg!(denoise: --denoise <strength> "Amount of denoising applied to rendered image (0.00..=4.00)")
        .required(false)
        .value_parser(denoise_strength_parser),
    )
    .arg(
      arg!(sharpen: --sharpen <strength> "Amount of sharpening applied to rendered image (0.00..=2.00)")
        .required(false)
        .default_value(&format!("{}", DEFAULT_SHARPEN))
        .value_parser(sharpen_strength_parser),
    )
    .arg(
      arg!(sharpness_radius: --"sharpness-radius" <radius> "Radius in px of sharpening mask")
        .required(false)
        .value_parser(clap::value_parser!(f32))
        .default_value("0.5"),
    )
    .arg(
      arg!(--hue --saturation <hue_saturation> "Change hue and saturation of the rendered image")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(--exposure --contrast <exposure_contrast> "Change the exposure (+EV) and contrast of the rendered image")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(highlight: --highlight <highlight> "Recover highlights (0.00..=1.00)")
        .required(false)
        .value_parser(clap::value_parser!(f32)),
    )
    .arg(
      arg!(blackpoint: --blackpoint <blackpoint> "Adjust blackpoint (0.0..=1.0)")
        .required(false)
        .value_parser(clap::value_parser!(f32)),
    )
    .arg(
      arg!(--tint --gradient <tint_gradient> "Tint the gradient along a certain axis (x y)")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(--temperature --tint <temperature_tint> "Set white balance via temperature/tint")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(wb_rgb: --"whitebalance-rgb" <rgb> "Manual whitebalance RGB values")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(exposure: --exposure <exposure> "Additional manual exposure adjustment in EV")
        .required(false)
        .value_parser(exposure_parser),
    )
    .arg(
      arg!(chromatic_aberration: --"chromatic-aberration" <correction> "Correct chromatic aberration (0.00..=1.00)")
        .required(false)
        .value_parser(clap::value_parser!(f32)),
    )
    .arg(
      arg!(vignette: --vignetting <amount> "Correct vignetting (0.00..=1.00)")
        .required(false)
        .value_parser(clap::value_parser!(f32)),
    )
    .arg(
      arg!(distortion: --distorting <amount> "Correct distortion (0.00..=1.00)")
        .required(false)
        .value_parser(clap::value_parser!(f32)),
    )
    .arg(
      arg!(camera_profile: --"camera-profile" <PROFILE> "Set custom camera profile")
        .required(false)
        .value_parser(NonEmptyStringValueParser::new()),
    )
    .arg(
      arg!(--linearization-table <path> "Linearization table")
        .required(false)
        .value_parser(clap::value_parser!(PathBuf)),
    )
    .arg(
      arg!(as_shot_neutral: --wb <"R,G,B"> "Whitebalance as-shot")
        .required(false)
        .conflicts_with("as_shot_white_xy")
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(
      arg!(as_shot_white_xy: --"white-xy" <"x,y"> "Whitebalance as-shot encoded as xy chromaticity coordinates")
        .required(false)
        .value_parser(clap::value_parser!(String))
        .num_args(1..)
        .action(ArgAction::Set),
    )
    .arg(arg!(-f --override "Override existing files"))
}

/// Subcommand reembed — re-embed edited preview JPEG into existing DNG
fn reembed_command() -> Command {
  Command::new("reembed")
    .about("Re-embed edited preview into an existing DNG")
    .arg_required_else_help(true)
    .arg(arg!(dng: --"dng" <DNG> "Input DNG file").value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(preview: --"preview" <JPEG> "Edited preview JPEG").value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(output: --"output" <OUTPUT> "Output DNG (default: overwrite input)").value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(embedded: --"embed-raw" <embedded> "Embed original raw file").value_parser(ValueParser::bool()).default_value("true").default_missing_value("true"))
    .arg(arg!(compress: --compress "Use lossless compression").action(ArgAction::SetTrue))
    .arg(
      arg!(compression: --"compression" <compression> "Compression method for raw image")
        .required(false)
        .value_parser(value_parser!(DngCompression)),
    )
    .arg(
      arg!(crop: --"crop" <crop> "Crop mode: best, activearea, none")
        .required(false)
        .value_parser(value_parser!(CropMode))
        .default_value("best"),
    )
    .arg(
      arg!(predictor: --"predictor" <predictor> "LJPEG92 predictor (1-7)")
        .required(false)
        .value_parser(clap::value_parser!(u8))
        .default_value("1"),
    )
    .arg(arg!(preview_enabled: --"preview-enabled" <enabled> "Include preview in output DNG").value_parser(ValueParser::bool()).default_value("true").default_missing_value("true"))
    .arg(arg!(thumbnail_enabled: --"thumbnail-enabled" <enabled> "Include thumbnail in output DNG").value_parser(ValueParser::bool()).default_value("false").default_missing_value("false"))
    .arg(
      arg!(artist: --"artist" <artist> "Set artist tag")
        .required(false)
        .value_parser(NonEmptyStringValueParser::new()),
    )
    .arg(
      arg!(seed: --"seed" <seed> "Deterministic seed for output bytes")
        .required(false)
        .default_value(""),
    )
}
