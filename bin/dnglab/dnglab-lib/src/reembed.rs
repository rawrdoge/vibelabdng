// SPDX-License-Identifier: LGPL-2.1
// Copyright 2021 Daniel Vogelbacher <[EMAIL]>

use clap::ArgMatches;
use rawler::dng::convert::{ConvertParams, reembed_dng_file};
use std::fs::File;
use std::io::{BufWriter, Write};
use std::path::PathBuf;

use crate::AppError;
use rawler::dng::{DNG_VERSION_V1_4, DngCompression};

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

  // Pull the small primitive option values on the main thread (cheap), but
  // build the (large) `ConvertParams` struct on the dedicated worker thread
  // below: constructing it on the 1 MB main/async stack overflows on Windows.
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

  // The DNG decoder is compute-heavy and can overflow the default (small)
  // async worker stack for large files, so run it on a dedicated thread with
  // a generous stack (mirrors how `convert` dispatches blocking work).
  let dng_path_t = dng_path.clone();
  let preview_path_t = preview_path.clone();
  let tmp_path_t = tmp_path.clone();
  let result: crate::Result<()> = std::thread::Builder::new()
    .name("dnglab-reembed".into())
    .stack_size(512 * 1024 * 1024)
    .spawn(move || -> crate::Result<()> {
      // Preview pyramid sizes are hardcoded here: the clap flags for these
      // values trigger a stack overflow on the Windows debug build, so we keep
      // them as fixed, sensible defaults (SubIFD1 medium, SubIFD2 full).
      let params = ConvertParams {
        embedded,
        compression,
        photometric_conversion: rawler::dng::DngPhotometricConversion::Original,
        apply_scaling: false,
        crop,
        predictor,
        preview: preview_enabled,
        thumbnail: thumbnail_enabled,
        artist,
        software: format!("{} {}", "DNGLab", crate::PKG_VERSION),
        index: 0,
        keep_mtime: false,
        dng_version: DNG_VERSION_V1_4,
        preview_medium: rawler::imgop::Dim2::new(1024, 1024),
        preview_full: rawler::imgop::Dim2::new(4000, 3000),
        jpeg_quality: 92,
        seed,
        linear: false,
      };
      let file = File::create(&tmp_path_t)?;
      let mut writer = BufWriter::new(file);
      reembed_dng_file(&dng_path_t, &preview_path_t, &mut writer, &params)?;
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
