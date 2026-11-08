// SPDX-License-Identifier: LGPL-2.1
// Copyright 2021 Daniel Vogelbacher <daniel@chaospixel.com>
// Re-added for autodngconverter: re-embeds an edited preview JPEG into an
// existing DNG while preserving raw pixels, metadata and IFD hierarchy.

use clap::ArgMatches;
use rawler::dng::{
  CropMode,
  DngCompression,
  DngVersion,
  writer::DngWriter,
};
use rawler::decoders::{Decoder, RawDecodeParams, WellKnownIFD};
use rawler::formats::tiff::TiffCommonTag;
use rawler::tags::ExifTag;
use std::fs::File;
use std::io::{BufReader, BufWriter, Seek, Write};
use std::path::PathBuf;
use std::sync::Arc;

use crate::AppError;

/// Entry point for Clap sub command `reembed`.
///
/// Re-embeds an edited preview JPEG into an existing DNG, preserving the
/// original raw pixels / metadata / IFD hierarchy. Produces the same
/// deterministic multi-resolution SubIFD1/SubIFD2 preview pyramid as a normal
/// `convert`, so the embedded preview matches dnglab-native quality rather
/// than a flat exiftool tag overwrite.
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

  // Pull small primitive option values on the main thread (cheap), but build
  // the (large) writer on the dedicated worker thread below: constructing it
  // on the 1 MB main/async stack overflows on Windows.
  let embedded = options.get_flag("embedded");
  let compress_flag = options.get_flag("compress");
  let compression = if compress_flag {
    DngCompression::Lossless
  } else {
    *options
      .get_one("compression")
      .ok_or_else(|| AppError::InvalidCmdSwitch("compression has no default".into()))?
  };
  let crop = *options
    .get_one("crop")
    .ok_or_else(|| AppError::InvalidCmdSwitch("crop has no default".into()))?;
  let predictor = options
    .get_one::<u8>("predictor")
    .copied()
    .unwrap_or(1);
  let preview_enabled = options.get_flag("preview_enabled");
  let thumbnail_enabled = options.get_flag("thumbnail_enabled");
  let artist = options.get_one("artist").cloned();
  let dng_version = *options
    .get_one("dng_version")
    .ok_or_else(|| AppError::InvalidCmdSwitch("dng-version has no default".into()))?;
  let max_dng_backward_version = *options
    .get_one("max_dng_backward")
    .unwrap_or(&DngVersion::V1_4);

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
      let file = File::create(&tmp_path_t)?;
      let mut writer = BufWriter::new(file);
      do_reembed(&dng_path_t, &preview_path_t, &mut writer, ReembedOpts {
        embedded,
        compression,
        crop,
        predictor,
        preview_enabled,
        thumbnail_enabled,
        artist,
        dng_version,
        max_dng_backward_version,
      })?;
      writer.flush()?;
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

struct ReembedOpts {
  embedded: bool,
  compression: DngCompression,
  crop: CropMode,
  predictor: u8,
  preview_enabled: bool,
  thumbnail_enabled: bool,
  artist: Option<String>,
  dng_version: DngVersion,
  max_dng_backward_version: DngVersion,
}

fn do_reembed<W: Write + Seek + Send>(
  dng_in: &std::path::Path,
  preview_jpeg: &std::path::Path,
  dng_out: &mut W,
  opts: ReembedOpts,
) -> crate::Result<()> {
  use image::DynamicImage;
  use rawler::dng::DNG_VERSION_V1_4;
  use rawler::rawsource::RawSource;

  let original_filename = dng_in
    .file_name()
    .and_then(std::ffi::OsStr::to_str)
    .unwrap_or_default()
    .to_string();

  let rawfile = Arc::new(RawSource::new(dng_in)?);
  let decoder = rawler::get_decoder(&rawfile)?;
  let raw_params = RawDecodeParams { image_index: 0 };
  let rawimage = decoder.raw_image(&rawfile, &raw_params, false)?;
  let metadata = decoder.raw_metadata(&rawfile, &raw_params)?;

  log::info!(
    "DNG re-embed: '{}', make: {}, model: {}, preview: '{}'",
    original_filename,
    rawimage.clean_make,
    rawimage.clean_model,
    preview_jpeg.display()
  );

  // Load the edited preview JPEG supplied by the external editor.
  let preview_img = image::open(preview_jpeg)
    .map_err(|e| AppError::DecoderFailed(format!("Failed to open preview JPEG: {e}")))?;

  let max_backward = opts.max_dng_backward_version.as_dng_value();
  let mut dng = DngWriter::new_with_version(dng_out, opts.dng_version.as_dng_value(), max_backward)?;

  // ── Subframe 0: raw image, carried over verbatim from source DNG ────────
  let mut raw = if opts.thumbnail_enabled {
    dng.subframe(0)
  } else {
    dng.subframe_on_root(0)
  };
  raw.raw_image(
    &rawimage,
    opts.crop,
    opts.compression,
    rawler::dng::DngPhotometricConversion::Original,
    &rawler::dng::CompressionParams {
      ljpeg92_predictor: opts.predictor,
      ..Default::default()
    },
  )?;
  if let Some(dng_raw_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRawTags)? {
    raw.ifd_mut().copy(dng_raw_ifd.value_iter());
  }
  raw.finalize()?;

  // ── Preview pyramid from the EDITED JPEG ─────────────────────────────────
  if opts.preview_enabled {
    let mut preview_medium = dng.subframe(1);
    preview_medium.preview(&preview_img, 0.92)?;
    preview_medium.finalize()?;
    let mut preview_full = dng.subframe(2);
    preview_full.preview(&preview_img, 0.92)?;
    preview_full.finalize()?;
  }
  if opts.thumbnail_enabled {
    dng.thumbnail(&preview_img)?;
  }

  // ── Metadata carried over from source DNG ─────────────────────────────────
  dng.load_base_tags(&rawimage)?;
  dng.load_metadata(&metadata)?;
  if let Some(orientation) = rawimage.orientation {
    dng.root_ifd_mut().add_tag(ExifTag::Orientation, orientation.to_u16());
  }
  if let Some(dng_root_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRootTags)? {
    dng.root_ifd_mut().copy(dng_root_ifd.value_iter());
  }
  if let Some(tiff_root) = decoder.ifd(WellKnownIFD::Root)? {
    dng.root_ifd_mut().copy(tiff_root.value_iter().filter(|(tag, _)| {
      [
        TiffCommonTag::TimeCodes as u16,
        TiffCommonTag::FrameFrate as u16,
        TiffCommonTag::TStop as u16,
      ]
      .contains(tag)
    }));
  }
  if let Some(xpacket) = decoder.xpacket(&rawfile, &raw_params)? {
    dng.xpacket(&xpacket)?;
  }

  // Preserve embedded original raw so the DNG stays self-contained.
  if opts.embedded {
    let mut orig_stream = BufReader::new(File::open(dng_in)?);
    let original = rawler::dng::original::OriginalCompressed::compress(&mut orig_stream)?;
    dng.original_file(&original, &original_filename)?;
  }

  if let Some(artist) = &opts.artist {
    dng.root_ifd_mut().add_tag(TiffCommonTag::Artist, artist);
  }
  dng.root_ifd_mut().add_tag(TiffCommonTag::Software, format!("{} {}", "DNGLab", crate::PKG_VERSION));

  dng.close()?;
  Ok(())
}
