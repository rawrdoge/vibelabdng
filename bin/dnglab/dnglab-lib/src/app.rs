// SPDX-License-Identifier: LGPL-2.1
// Copyright 2021 Daniel Vogelbacher <daniel@chaospixel.com>

use std::path::PathBuf;

use clap::{
  ArgAction, Command, arg,
  builder::{NonEmptyStringValueParser, ValueParser},
  command, value_parser,
};
use log::debug;
use rawler::dng::{CropMode, DngCompression};

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, clap::ValueEnum)]
pub enum DngVersion {
    #[default]
    #[value(name = "1.4")]
    V1_4,
    #[value(name = "1.5")]
    V1_5,
    #[value(name = "1.6")]
    V1_6,
}

impl DngVersion {
    pub fn as_dng_value(self) -> [u8; 4] {
        match self {
            DngVersion::V1_4 => rawler::dng::DNG_VERSION_V1_4,
            DngVersion::V1_5 => rawler::dng::DNG_VERSION_V1_5,
            DngVersion::V1_6 => rawler::dng::DNG_VERSION_V1_6,
        }
    }
}

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

pub fn create_app() -> Command {
  debug!("Creating CLAP app configuration");

  let convert_base = Command::new("dnglab")
    .about("Convert raw image(s) into dng format")
    .arg(
      arg!(compression: -c --"compression" <compression> "Compression for raw image")
        .required(false)
        .value_parser(value_parser!(DngCompression))
        .default_value("lossless"),
    )
    .arg(
      arg!(predictor: --"ljpeg92-predictor" <predictor> "LJPEG-92 predictor")
        .required(false)
        .value_parser(clap::value_parser!(u8).range(1..=7))
        .default_value("1"),
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
      arg!(embedded: --"embed-raw" <embedded> "Embed the raw file into DNG")
        .value_parser(ValueParser::bool())
        .required(false)
        .default_value("true")
        .default_missing_value("true"),
    )
    .arg(
      arg!(--"artist" <artist> "Set the artist tag")
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
    .arg(arg!(-f --override "Override existing files").action(ArgAction::SetTrue));

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
    .subcommand(
      convert_base
        .clone()
        .name("convert")
        .arg(arg!(-r --recursive "Process input directory recursive").action(ArgAction::SetTrue))
        .arg(
          arg!(jobs: -j --jobs <N> "Number of files to convert in parallel (0 = auto)")
            .required(false)
            .value_parser(clap::value_parser!(usize))
            .default_value("0"),
        )
        // DNG output flags that convert.rs actually consumes. Until these are
        // registered here, convert.rs silently falls back to its built-in
        // defaults and any settings passed by the Go service never reach the
        // rendered DNG.
        .arg(
          arg!(dng_version: --"dng-version" <VERSION> "DNG specification version")
            .required(false)
            .default_value("1.4")
            .value_parser(value_parser!(DngVersion)),
        )
        .arg(
          arg!(preview_medium: --"preview-medium" <WxH> "Medium preview size WxH (e.g. 1024x1024)")
            .required(false)
            .default_value("1024x1024"),
        )
        .arg(
          arg!(preview_full: --"preview-full" <WxH> "Full preview size WxH (e.g. 4000x3000)")
            .required(false)
            .default_value("4000x3000"),
        )
        .arg(
          arg!(jpeg_quality: --"jpeg-quality" <QUALITY> "JPEG preview quality (0-100)")
            .required(false)
            .value_parser(clap::value_parser!(u8).range(0..=100))
            .default_value("92"),
        )
        .arg(
          arg!(linear: --"linear" <linear> "Write a linear (demosaiced) DNG")
            .value_parser(ValueParser::bool())
            .required(false)
            .default_value("false")
            .default_missing_value("false"),
        )
        .arg(
          arg!(seed: --"seed" <seed> "Deterministic seed for reproducible output")
            .required(false)
            .default_value(""),
        )
        // Named flags consumed by convert.rs (get_one("input")/get_one("output")).
        .arg(arg!(input: --"input" <input> "Input file or directory").required(false).value_parser(clap::value_parser!(PathBuf)))
        .arg(arg!(output: --"output" <output> "Output file or existing directory").required(false).value_parser(clap::value_parser!(PathBuf)))
        // Positional fallbacks (convert.rs reads INPUT_POS/OUTPUT_POS).
        .arg(arg!(INPUT_POS: <INPUT> "Input file or directory").required(false).value_parser(clap::value_parser!(PathBuf)))
        .arg(arg!(OUTPUT_POS: <OUTPUT> "Output file or existing directory").required(false).value_parser(clap::value_parser!(PathBuf))),
    )
    .subcommand(reembed_command())
}

/// Build the `reembed` subcommand. Defined as a free function (rather than a
/// `let` binding inside `create_app`) so the `Command` is constructed as a
/// temporary and moved into `.subcommand(...)`, keeping `create_app`'s stack
/// frame small enough for the default Windows main-thread stack.
fn reembed_command() -> Command {
  Command::new("reembed")
    .about("Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)")
    .arg_required_else_help(true)
    .arg(arg!(dng: --"dng" <dng> "Existing DNG file to re-embed preview into").required(true).value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(preview: --"preview" <preview> "Edited preview JPEG to embed").required(true).value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(output: --"output" <output> "Output DNG path (defaults to overwriting --dng)").required(false).value_parser(clap::value_parser!(PathBuf)))
    .arg(arg!(compression: -c --"compression" <compression> "Compression for raw image").required(false).value_parser(value_parser!(DngCompression)).default_value("lossless"))
    .arg(arg!(predictor: --"ljpeg92-predictor" <predictor> "LJPEG-92 predictor").required(false).value_parser(clap::value_parser!(u8).range(1..=7)).default_value("1"))
    .arg(arg!(--"artist" <artist> "Set the artist tag").required(false).value_parser(NonEmptyStringValueParser::new()))
    .arg(arg!(--"crop" <crop> "DNG default crop").required(false).value_parser(value_parser!(CropMode)).default_value("best"))
    .arg(arg!(preview_enabled: --"dng-preview" <preview> "DNG include preview image").value_parser(ValueParser::bool()).required(false).default_value("true").default_missing_value("true"))
    .arg(arg!(thumbnail_enabled: --"dng-thumbnail" <thumbnail> "DNG include thumbnail image").value_parser(ValueParser::bool()).required(false).default_value("true").default_missing_value("true"))
    .arg(arg!(embedded: --"embed-raw" <embedded> "Re-embed the original raw file into DNG").value_parser(ValueParser::bool()).required(false).default_value("true").default_missing_value("true"))
    .arg(arg!(compress: --"compress" "Enable lossless compression (equivalent to -c)").action(ArgAction::SetTrue).default_value("false"))
    .arg(arg!(-f --override "Override existing files").action(ArgAction::SetTrue))
    .arg(arg!(seed: --"seed" <seed> "Deterministic seed for reproducible output (use the same seed as the original conversion)").required(false).default_value(""))
}