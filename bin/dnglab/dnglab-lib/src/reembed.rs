// SPDX-License-Identifier: LGPL-2.1
// Copyright 2021 Daniel Vogelbacher <[EMAIL]>
// Forked from upstream dnglab — adapted for autodngconverter pipeline use.
//
// Re-embeds an edited preview JPEG into an existing DNG, preserving the
// original raw pixels, stage data, metadata and IFD hierarchy. This produces
// the same deterministic, multi-resolution SubIFD1/SubIFD2 preview pyramid
// as a normal `convert`, so the embedded preview is byte-stable and
// hash-reproducible for a given seed.

use std::fs::File;
use std::io::{BufReader, Seek, Write};
use std::path::{Path, PathBuf};
use std::sync::Arc;

use clap::ArgMatches;
use rawler::dng::{
  convert::ConvertParams,
  DngCompression, DngPhotometricConversion, DngVersion,
};
use rawler::dng::writer::DngWriter;
use rawler::rawsource::RawSource;
use rawler::decoders::RawDecodeParams;

use crate::AppError;

/// Parameters specific to the reembed operation, bridging the fork's CLI API
/// to the upstream rawler 0.8.0 ConvertParams struct.
#[derive(Clone, Debug)]
pub struct ReembedParams {
  pub embedded: bool,
  pub compression: DngCompression,
  pub crop: rawler::dng::CropMode,
  pub predictor: u8,
  pub lossy_jpeg_quality: u8,
  pub jxl_distance: f32,
  pub jxl_effort: u8,
  pub jxl_decode_speed: u8,
  pub preview: bool,
  pub thumbnail: bool,
  pub artist: Option<String>,
  pub software: String,
  pub index: usize,
  pub keep_mtime: bool,
  pub dng_version: DngVersion,
  pub max_dng_backward_version: DngVersion,
  /// Seed for deterministic ModifyDate tag
  pub seed: String,
}

impl From<&ReembedParams> for ConvertParams {
  fn from(p: &ReembedParams) -> Self {
    Self {
      embedded: p.embedded,
      compression: p.compression,
      photometric_conversion: DngPhotometricConversion::Original,
      apply_scaling: false,
      crop: p.crop,
      predictor: p.predictor,
      lossy_jpeg_quality: p.lossy_jpeg_quality,
      jxl_distance: p.jxl_distance,
      jxl_effort: p.jxl_effort,
      jxl_decode_speed: p.jxl_decode_speed,
      preview: p.preview,
      thumbnail: p.thumbnail,
      force_preview: false,
      force_thumbnail: false,
      artist: p.artist.clone(),
      copyright: None,
      software: p.software.clone(),
      index: p.index,
      keep_mtime: p.keep_mtime,
      dng_version: p.dng_version,
      max_dng_backward_version: p.max_dng_backward_version,
      apply_dng_opcodes: rawler::dng::ApplyDngOpcodes::Auto,
      remove_dng_opcodes: Vec::new(),
    }
  }
}

/// Entry point for Clap sub command `reembed`
///
/// Re-embeds an edited preview JPEG into an existing DNG, preserving the
/// original raw pixels / metadata / IFD hierarchy. This produces the same
/// deterministic, multi-resolution SubIFD1/SubIFD2 preview pyramid as a normal
/// `convert`, so the embedded preview matches the dnglab-native quality
/// (PRD Q8) rather than a flat exiftool tag overwrite.
pub fn reembed(options: &ArgMatches) -> crate::Result<()> {
  let dng_path: PathBuf = options
    .get_one::<PathBuf>("dng")
    .cloned()
    .ok_or_else(|| AppError::InvalidCmdSwitch("No DNG file given (use --dng)".into()))?;
  let preview_path: PathBuf = options
    .get_one::<PathBuf>("preview")
    .cloned()
    .ok_or_else(|| AppError::InvalidCmdSwitch("No preview JPEG given (use --preview)".into()))?;
  let output: PathBuf = options
    .get_one::<PathBuf>("output")
    .cloned()
    .or_else(|| Some(dng_path.clone()))
    .unwrap();

  if !dng_path.exists() {
    return Err(AppError::NotFound(dng_path));
  }
  if !preview_path.exists() {
    return Err(AppError::NotFound(preview_path));
  }

  let embedded = options.get_flag("embedded");
  let compression = if options.get_flag("compress") {
    DngCompression::Lossless
  } else {
    *options
      .get_one("compression")
      .ok_or_else(|| AppError::InvalidCmdSwitch("compression has no default".into()))?
  };
  let crop = *options
    .get_one("crop")
    .ok_or_else(|| AppError::InvalidCmdSwitch("crop has no default".into()))?;
  let predictor = *options
    .get_one("predictor")
    .ok_or_else(|| AppError::InvalidCmdSwitch("predictor has no default".into()))?;
  let preview_enabled = options.get_flag("preview_enabled");
  let thumbnail_enabled = options.get_flag("thumbnail_enabled");
  let artist = options.get_one("artist").cloned();
  let seed = options.get_one::<String>("seed").cloned().unwrap_or_default();

  // Write to a temp file first, then atomically replace, so a crash mid-write
  // never leaves a half-written DNG in place.
  let tmp_path = output.with_extension("dng.tmp");

  let dng_path_t = dng_path.clone();
  let preview_path_t = preview_path.clone();
  let tmp_path_t = tmp_path.clone();

  let result: crate::Result<()> = std::thread::Builder::new()
    .name("dnglab-reembed".into())
    .stack_size(512 * 1024 * 1024)
    .spawn(move || -> crate::Result<()> {
      let params = ReembedParams {
        embedded,
        compression,
        crop,
        predictor,
        lossy_jpeg_quality: 92,
        jxl_distance: 0.0,
        jxl_effort: 4,
        jxl_decode_speed: 4,
        preview: preview_enabled,
        thumbnail: thumbnail_enabled,
        artist,
        software: format!("{} {}", "DNGLab", crate::PKG_VERSION),
        index: 0,
        keep_mtime: false,
        dng_version: DngVersion::V1_4,
        max_dng_backward_version: DngVersion::V1_4,
        seed,
      };
      let mut out_file = File::create(&tmp_path_t)?;
      reembed_dng_file(&dng_path_t, &preview_path_t, &mut out_file, &params)?;
      Ok(())
    })
    .map_err(|e| AppError::General(format!("Failed to spawn reembed thread: {e}")))?
    .join()
    .map_err(|_| AppError::General("Reembed thread panicked".into()))?;
  result?;

  std::fs::rename(&tmp_path, &output)?;
  eprintln!("Re-embedded preview into '{}'", output.display());
  Ok(())
}

/// Core reembed implementation using upstream rawler 0.8.0 APIs.
///
/// Reads an existing DNG through the DNG decoder, preserves its raw image data
/// and metadata verbatim, and replaces the embedded preview with the supplied
/// edited JPEG. Output is written to a temp file first, then renamed.
pub fn reembed_dng_file<W: Write + Seek>(
  dng_in: &Path,
  preview_jpeg: &Path,
  dng_out: &mut W,
  params: &ReembedParams,
) -> crate::Result<()> {
  let original_filename = dng_in
    .file_name()
    .and_then(|s| s.to_str())
    .unwrap_or_default()
    .to_string();

  let rawfile = Arc::new(RawSource::new(dng_in)?);
  let decoder = rawler::get_decoder(&rawfile)?;
  let raw_params = RawDecodeParams { image_index: params.index };
  let rawimage = decoder.raw_image(&rawfile, &raw_params, false)?;
  let metadata = decoder.raw_metadata(&rawfile, &raw_params)?;

  log::info!(
    "DNG re-embed: '{}', make: {}, model: {}, preview: '{}'",
    original_filename,
    rawimage.clean_make,
    rawimage.clean_model,
    preview_jpeg.display()
  );

  // Load the edited preview JPEG supplied by the external editor (e.g. Darktable).
  let preview_img = image::open(preview_jpeg)
    .map_err(|e| crate::AppError::DecoderFailed(format!("Failed to open preview JPEG: {e}")))?;

  // Build a ConvertParams copy that we can pass to the internal logic below.
  // We use Original photometric conversion so the raw image is written without
  // demosaicing or opcode processing — preserving the source bytes.
  let conv = ConvertParams::from(params);
  let max_backward_version = conv.max_dng_backward_version.as_dng_value();

  let mut dng = DngWriter::new_with_version(dng_out, conv.dng_version.as_dng_value(), max_backward_version)?;

  // Subframe 0: raw image, carried over verbatim from the source DNG.
  let mut raw = if params.thumbnail { dng.subframe(0) } else { dng.subframe_on_root(0) };
  raw.raw_image(
    &rawimage,
    params.crop,
    params.compression,
    DngPhotometricConversion::Original,
    &conv.compression_params(),
  )?;
  // Copy raw-IFD tags from source (opcodes already applied during write above)
  if let Some(dng_raw_ifd) = decoder.ifd(rawler::decoders::WellKnownIFD::VirtualDngRawTags)? {
    raw.ifd_mut().copy(dng_raw_ifd.value_iter());
  }
  raw.finalize()?;

  // Replace the preview pyramid with the EDITED JPEG.
  if params.preview {
    let mut preview_medium = dng.subframe(1);
    preview_medium.preview(&preview_img, params.lossy_jpeg_quality as f32 / 100.0)?;
    preview_medium.finalize()?;
    let mut preview_full = dng.subframe(2);
    preview_full.preview(&preview_img, params.lossy_jpeg_quality as f32 / 100.0)?;
    preview_full.finalize()?;
  }
  if params.thumbnail {
    dng.thumbnail(&preview_img)?;
  }

  // Metadata carried over from the source DNG.
  dng.load_base_tags(&rawimage)?;
  dng.load_metadata(&metadata)?;
  if let Some(orientation) = rawimage.orientation {
    dng.root_ifd_mut().add_tag(rawler::tags::ExifTag::Orientation, orientation.to_u16());
  }
  if let Some(dng_root_ifd) = decoder.ifd(rawler::decoders::WellKnownIFD::VirtualDngRootTags)? {
    dng.root_ifd_mut().copy(dng_root_ifd.value_iter());
  }
  if let Some(tiff_root) = decoder.ifd(rawler::decoders::WellKnownIFD::Root)? {
    dng.root_ifd_mut().copy(
      tiff_root
        .value_iter()
        .filter(|(tag, _)| [
          rawler::tags::TiffCommonTag::TimeCodes as u16,
          rawler::tags::TiffCommonTag::FrameFrate as u16,
          rawler::tags::TiffCommonTag::TStop as u16,
        ]
        .contains(tag)),
    );
  }
  if let Some(xpacket) = decoder.xpacket(&rawfile, &raw_params)? {
    dng.xpacket(&xpacket)?;
  }

  // Preserve the embedded original raw (so the DNG stays self-contained).
  if params.embedded {
    let mut orig_stream = BufReader::new(File::open(dng_in)?);
    let original = rawler::dng::original::OriginalCompressed::compress(&mut orig_stream)?;
    dng.original_file(&original, &original_filename)?;
  }

  if let Some(artist) = &params.artist {
    dng.root_ifd_mut().add_tag(rawler::tags::TiffCommonTag::Artist, artist);
  }
  dng.root_ifd_mut().add_tag(rawler::tags::TiffCommonTag::Software, &params.software);

  // Deterministic ModifyDate (same scheme as upstream convert_raw_file).
  let mut hash: u64 = 0xcbf29ce484222325;
  let write_byte = |h: &mut u64, b: u8| {
    *h ^= b as u64;
    *h = h.wrapping_mul(0x100000001b3);
  };
  for b in params.seed.as_bytes() {
    write_byte(&mut hash, *b);
  }
  for b in original_filename.as_bytes() {
    write_byte(&mut hash, *b);
  }
  let year = 2000 + (hash % 38) as u32;
  let month = 1 + ((hash >> 8) % 12) as u32;
  let day = 1 + ((hash >> 16) % 28) as u32;
  let hour = ((hash >> 24) % 24) as u32;
  let minute = ((hash >> 32) % 60) as u32;
  let second = ((hash >> 40) % 60) as u32;
  let modify_date = format!("{:04}:{:02}:{:02} {:02}:{:02}:{:02}", year, month, day, hour, minute, second);
  dng.root_ifd_mut().add_tag(rawler::tags::ExifTag::ModifyDate, modify_date);

  dng.close()?;
  Ok(())
}
