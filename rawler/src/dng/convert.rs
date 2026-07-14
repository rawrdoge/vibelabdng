use std::{
  ffi::OsStr,
  fs::File,
  io::{BufReader, Cursor, Seek, Write},
  path::Path,
  sync::Arc,
  thread::JoinHandle,
  time::SystemTime,
};

use image::DynamicImage;

use crate::{
  RawImage, RawImageData, RawlerError,
  decoders::{Decoder, RawDecodeParams, RawPhotometricInterpretation, WellKnownIFD, WhiteLevel},
  dng::{DNG_VERSION_V1_4, original::OriginalCompressed, writer::DngWriter},
  formats::tiff::Entry,
  imgop::{
    develop::RawDevelop,
    fuji_rotate::fuji_normalize_rotation,
    sensor::{Demosaic, bayer::ppg::PPGDemosaic},
  },
  pixarray::PixF32,
  rawsource::RawSource,
  tags::{DngTag, ExifTag, TiffCommonTag},
  imgop::Dim2,
};

use super::{CropMode, DngCompression, DngPhotometricConversion};

/// Parameters for DNG conversion
#[derive(Clone, Debug)]
pub struct ConvertParams {
  pub embedded: bool,
  pub compression: DngCompression,
  pub photometric_conversion: DngPhotometricConversion,
  pub apply_scaling: bool,
  pub crop: CropMode,
  pub predictor: u8,
  pub preview: bool,
  pub thumbnail: bool,
  pub artist: Option<String>,
  pub software: String,
  pub index: usize,
  pub keep_mtime: bool,
  /// DNG specification version written into the file (e.g. [1,4,0,0] for 1.4).
  pub dng_version: [u8; 4],
  /// Bounding box (width, height) for the medium preview (SubIFD1).
  pub preview_medium: Dim2,
  /// Bounding box (width, height) for the full preview (SubIFD2).
  pub preview_full: Dim2,
  /// JPEG quality (0..=100) used for embedded previews.
  pub jpeg_quality: u8,
  /// Deterministic seed. Used to derive any output bytes that are not a pure
  /// function of the input (e.g. the ModifyDate tag), so identical
  /// input + settings produce byte-identical output.
  pub seed: String,
  /// Emit a linear (demosaiced) DNG when supported by the decoder.
  pub linear: bool,
}

/// Information surfaced from a completed conversion.
///
/// Lets callers reuse work the converter already performed (such as the
/// metadata pass) instead of re-running the decoder.
#[derive(Clone, Debug, Default)]
pub struct ConvertInfo {
  /// Embedded "last modified" timestamp recovered from the input's metadata,
  /// if the decoder was able to find one.
  pub last_modified: Option<SystemTime>,
}

impl Default for ConvertParams {
  fn default() -> Self {
    Self {
      embedded: true,
      compression: DngCompression::Lossless,
      photometric_conversion: DngPhotometricConversion::Original,
      apply_scaling: false,
      crop: CropMode::Best,
      predictor: 1,
      preview: true,
      thumbnail: true,
      artist: None,
      software: "DNGLab".into(),
      index: 0,
      keep_mtime: false,
      dng_version: DNG_VERSION_V1_4,
      preview_medium: Dim2::new(1024, 1024),
      preview_full: Dim2::new(4000, 3000),
      jpeg_quality: 92,
      seed: String::new(),
      linear: false,
    }
  }
}

/// Convert a raw input file into DNG
///
/// We don't accept a DNG file path here, because we don't know
/// how to handle existing target files, buffering, etc.
/// This is up to the caller.
pub fn convert_raw_file<W: Write + Seek + Send>(raw: &Path, dng: &mut W, params: &ConvertParams) -> crate::Result<ConvertInfo> {
  let original_filename = raw.file_name().and_then(OsStr::to_str).unwrap_or_default();
  //let raw_stream = BufReader::new(File::open(raw)?); // TODO: add path hint to error?
  //let rawfile = RawFile::new(PathBuf::from(raw), raw_stream);

  let rawfile = Arc::new(RawSource::new(raw)?);

  let original_compress_thread = if params.embedded {
    let orig_source = rawfile.clone();
    Some(std::thread::spawn(move || OriginalCompressed::compress(&mut orig_source.reader())))
  } else {
    None
  };

  internal_convert(&rawfile, dng, original_filename, original_compress_thread, params)
}

/// Convert a raw input file into DNG
pub fn convert_raw_source<W>(raw_source: &RawSource, dng: &mut W, original_filename: impl AsRef<str>, params: &ConvertParams) -> crate::Result<ConvertInfo>
where
  W: Write + Seek + Send,
{
  let original_compress_thread = if params.embedded {
    let mut original_stream = Cursor::new(raw_source.as_vec()?);
    Some(std::thread::spawn(move || OriginalCompressed::compress(&mut original_stream)))
  } else {
    None
  };

  internal_convert(raw_source, dng, original_filename, original_compress_thread, params)
}

fn internal_convert<W>(
  rawfile: &RawSource,
  dng: &mut W,
  original_filename: impl AsRef<str>,
  original_compress_thread: Option<JoinHandle<Result<OriginalCompressed, std::io::Error>>>,
  params: &ConvertParams,
) -> crate::Result<ConvertInfo>
where
  W: Write + Seek + Send,
{
  let decoder = crate::get_decoder(rawfile)?;
  let raw_params = RawDecodeParams { image_index: params.index };
  let mut rawimage = decoder.raw_image(rawfile, &raw_params, false)?;
  let metadata = decoder.raw_metadata(rawfile, &raw_params)?;

  log::info!(
    "DNG conversion: '{}', make: {}, model: {}, raw-image-count: {}",
    original_filename.as_ref(),
    rawimage.clean_make,
    rawimage.clean_model,
    decoder.raw_image_count()?
  );
  log::debug!("Raw image WB coeff: {:?}", rawimage.wb_coeffs);

  if rawimage.camera.find_hint("fuji_rotation") || rawimage.camera.find_hint("fuji_rotation_alt") {
    // if the raw image needs to be rotated, we do this before
    // writing the image to DNG. This requires scaling and debayer
    // to be applied.
    rawimage.apply_scaling()?;
    log::debug!("Raw image requires fuji_rotation before writing to DNG");
    let pixels = PixF32::new_with(rawimage.data.as_f32().into_owned(), rawimage.width, rawimage.height);
    let roi = rawimage.active_area.unwrap_or(pixels.rect());
    let demosaic = PPGDemosaic::new();
    let mut rgb = demosaic.demosaic(&pixels, &rawimage.camera.cfa, &rawimage.camera.plane_color, roi);
    let fuji_rotation_width = rawimage.fuji_rotation_width.expect("fuji_rotate: no rotation width found");
    let extra_rotate = rawimage.camera.find_hint("fuji_rotate_90cw");
    rgb = fuji_normalize_rotation(&rgb, fuji_rotation_width, extra_rotate);
    rawimage.width = rgb.width;
    rawimage.height = rgb.height;
    rawimage.active_area = None;
    rawimage.cpp = 3;
    rawimage.whitelevel = WhiteLevel::new([1, 1, 1]); // Already scaled up to 0.0 .. 1.0
    rawimage.photometric = RawPhotometricInterpretation::LinearRaw;
    rawimage.data = RawImageData::Float(rgb.into_flatten());
  } else if params.apply_scaling {
    rawimage.apply_scaling()?;
  }

  let mut dng = DngWriter::new(dng, params.dng_version)?;

  // Write RAW image for subframe type 0
  // If no thumbnail should be written to root IFD, we need to put the raw image into
  // root IFD instead.
  let mut raw = if params.thumbnail { dng.subframe(0) } else { dng.subframe_on_root(0) };
  // A linear (demosaiced) DNG can only be emitted when the decoder already
  // produced linear data (cpp == 3 / LinearRaw). If the user requested
  // `--linear` but the decoder does not support it (e.g. a CFA Bayer NRW),
  // fall back to the original (mosaic) representation instead of panicking in
  // `RawImage::linearize()` (which is still unimplemented upstream).
  let photometric_conversion = match params.photometric_conversion {
    DngPhotometricConversion::Linear if !matches!(rawimage.photometric, RawPhotometricInterpretation::LinearRaw) => {
      log::warn!("Linear DNG requested but decoder does not support it; falling back to original (mosaic) DNG");
      DngPhotometricConversion::Original
    }
    other => other,
  };
  raw.raw_image(&rawimage, params.crop, params.compression, photometric_conversion, params.predictor)?;
  // Check for DNG raw IFD related tags
  if let Some(dng_raw_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRawTags)? {
    raw.ifd_mut().copy(dng_raw_ifd.value_iter());
  }
  raw.finalize()?;

  // Write preview and thumbnail if requested
  if params.preview || params.thumbnail {
    match generate_preview(rawfile, decoder.as_ref(), &rawimage, &raw_params) {
      Ok(image) => {
        if params.preview {
          // SubIFD1: medium preview, sized to the requested bounding box.
          let mut preview_medium = dng.subframe(1);
          preview_medium.preview(&image, params.jpeg_quality as f32 / 100.0, params.preview_medium.w, params.preview_medium.h)?;
          preview_medium.finalize()?;
          // SubIFD2: full preview, sized to the requested bounding box.
          let mut preview_full = dng.subframe(2);
          preview_full.preview(&image, params.jpeg_quality as f32 / 100.0, params.preview_full.w, params.preview_full.h)?;
          preview_full.finalize()?;
        }
        if params.thumbnail {
          dng.thumbnail(&image)?;
        }
      }
      Err(err) => log::warn!("Failed to get review image, continue anyway: {:?}", err),
    }
  }
  // Write metadata
  dng.load_base_tags(&rawimage)?;
  dng.load_metadata(&metadata)?;
  if !dng.root_ifd().contains(ExifTag::Orientation) {
    dng.root_ifd_mut().add_tag(ExifTag::Orientation, rawimage.orientation.to_u16());
  }

  // Check for DNG root IFD related tags
  if let Some(dng_root_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRootTags)? {
    dng.root_ifd_mut().copy(dng_root_ifd.value_iter());
  }

  // Check for TIFF root IFD related tags
  if let Some(tiff_root) = decoder.ifd(WellKnownIFD::Root)? {
    dng.root_ifd_mut().copy(tiff_root.value_iter().filter(|(tag, _)| {
      [
        // Tags from CinemaDNG files
        TiffCommonTag::TimeCodes as u16,
        TiffCommonTag::FrameFrate as u16,
        TiffCommonTag::TStop as u16,
      ]
      .contains(tag)
    }));
  }

  // Remove makernotes from EXIF if MakerNoteSafety is not 1 (safe)
  if let Some(Entry {
    value: crate::formats::tiff::Value::Short(v),
    ..
  }) = decoder
    .ifd(WellKnownIFD::VirtualDngRootTags)?
    .and_then(|ifd| ifd.get_entry(DngTag::MakerNoteSafety).cloned())
  {
    if v.get(0).copied().unwrap_or(0) == 0 {
      dng.exif_ifd_mut().remove_tag(ExifTag::MakerNotes);
    }
  }

  if let Some(xpacket) = decoder.xpacket(rawfile, &raw_params)? {
    dng.xpacket(&xpacket)?;
  }

  if let Some(handle) = original_compress_thread {
    let original = handle
      .join()
      .map_err(|err| std::io::Error::new(std::io::ErrorKind::Other, format!("Failed to join compression thread: {:?}", err)))??;
    dng.original_file(&original, &original_filename)?;
  }

  if let Some(artist) = &params.artist {
    dng.root_ifd_mut().add_tag(TiffCommonTag::Artist, artist);
  }
  dng.root_ifd_mut().add_tag(TiffCommonTag::Software, &params.software);

  // Deterministic ModifyDate. The upstream code stamped `chrono::Local::now()`
  // here, which made every output byte-different and broke reproducible DNG
  // hashing. We instead derive a fixed timestamp from the seed + input name so
  // that identical input + settings always produce byte-identical output.
  // When no seed is provided we still emit a stable, input-derived value
  // (FNV-1a over seed+filename) rather than a wall-clock time.
  let mut hash: u64 = 0xcbf29ce484222325; // FNV-1a 64-bit offset basis
  let write_byte = |h: &mut u64, b: u8| {
    *h ^= b as u64;
    *h = h.wrapping_mul(0x100000001b3); // FNV prime
  };
  for b in params.seed.as_bytes() {
    write_byte(&mut hash, *b);
  }
  for b in original_filename.as_ref().as_bytes() {
    write_byte(&mut hash, *b);
  }
  // Map the hash into a plausible, fixed date in the 2000..2038 range.
  let year = 2000 + (hash % 38) as u32;
  let month = 1 + ((hash >> 8) % 12) as u32;
  let day = 1 + ((hash >> 16) % 28) as u32;
  let hour = ((hash >> 24) % 24) as u32;
  let minute = ((hash >> 32) % 60) as u32;
  let second = ((hash >> 40) % 60) as u32;
  let modify_date = format!("{:04}:{:02}:{:02} {:02}:{:02}:{:02}", year, month, day, hour, minute, second);
  dng.root_ifd_mut().add_tag(ExifTag::ModifyDate, modify_date);

  dng.close()?;

  let last_modified = match metadata.last_modified() {
    Ok(Some(last_modified)) => Some(last_modified),
    Err(err) => {
      log::warn!("Failed to get last-modified: {:?}", err);
      None
    }
    _ => None,
  };
  Ok(ConvertInfo { last_modified })
}

fn generate_preview(rawfile: &RawSource, decoder: &dyn Decoder, rawimage: &RawImage, params: &RawDecodeParams) -> crate::Result<DynamicImage> {
  match decoder.preview_image(rawfile, params)? {
    Some(image) => Ok(image),
    None => {
      log::warn!("Preview image not found, try to generate sRGB from RAW");
      let dev = RawDevelop::default();
      let image = dev.develop_intermediate(rawimage)?;
      /*
      let params = rawimage.develop_params()?;
      let (srgbf, dim) = develop_raw_srgb(&rawimage.data, &params)?;
      let output = convert_from_f32_scaled_u16(&srgbf, 0, u16::MAX);
      let image = if srgbf.len() == dim.w * dim.h {
        DynamicImage::ImageLuma16(ImageBuffer::from_raw(dim.w as u32, dim.h as u32, output).expect("Invalid ImageBuffer size"))
      } else {
        DynamicImage::ImageRgb16(ImageBuffer::from_raw(dim.w as u32, dim.h as u32, output).expect("Invalid ImageBuffer size"))
      };
       */
      Ok(image.to_dynamic_image().ok_or("failed to convert to dynamic image")?)
    }
  }
}

/// Re-embed an edited preview JPEG into an *existing* DNG, preserving the
/// original raw pixels, stage data, metadata and IFD hierarchy.
///
/// This is the dnglab-native equivalent of the `betterembeds.lua` workflow:
/// instead of blindly overwriting preview tags with exiftool (which produces
/// a flat, non-Adobe-hierarchy preview), we re-read the DNG through the
/// `DngDecoder`, keep its raw/metadata intact, and re-emit the file with the
/// *edited* JPEG as the preview source. The result keeps the same
/// deterministic, multi-resolution SubIFD1/SubIFD2 preview pyramid that the
/// normal conversion produces (PRD Q8), so the embedded preview is
/// byte-stable and hash-reproducible for a given seed.
///
/// Only the preview/thumbnail JPEGs change; the raw image and all other tags
/// are carried over unchanged. The `seed` should match the one used at
/// conversion time so the (untouched) raw bytes and ModifyDate stay
/// byte-identical — otherwise the whole-file SHA-256 will change, which is
/// expected and the caller (RawImport pipeline) re-hashes after re-embed.
pub fn reembed_dng_file<W: Write + Seek + Send>(dng_in: &Path, preview_jpeg: &Path, dng_out: &mut W, params: &ConvertParams) -> crate::Result<()> {
  let original_filename = dng_in
    .file_name()
    .and_then(OsStr::to_str)
    .unwrap_or_default()
    .to_string();

  let rawfile = Arc::new(RawSource::new(dng_in)?);
  let decoder = crate::get_decoder(&rawfile)?;
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
  let preview_img = image::open(preview_jpeg).map_err(|e| RawlerError::DecoderFailed(format!("Failed to open preview JPEG: {e}")))?;

  let mut dng = DngWriter::new(dng_out, params.dng_version)?;

  // Subframe 0: raw image, carried over verbatim from the source DNG.
  let mut raw = if params.thumbnail { dng.subframe(0) } else { dng.subframe_on_root(0) };
  let photometric_conversion = match params.photometric_conversion {
    DngPhotometricConversion::Linear if !matches!(rawimage.photometric, RawPhotometricInterpretation::LinearRaw) => {
      log::warn!("Linear DNG requested but decoder does not support it; falling back to original (mosaic) DNG");
      DngPhotometricConversion::Original
    }
    other => other,
  };
  raw.raw_image(&rawimage, params.crop, params.compression, photometric_conversion, params.predictor)?;
  if let Some(dng_raw_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRawTags)? {
    raw.ifd_mut().copy(dng_raw_ifd.value_iter());
  }
  raw.finalize()?;

  // Re-emit the multi-resolution preview pyramid from the EDITED JPEG.
  if params.preview {
    let mut preview_medium = dng.subframe(1);
    preview_medium.preview(&preview_img, params.jpeg_quality as f32 / 100.0, params.preview_medium.w, params.preview_medium.h)?;
    preview_medium.finalize()?;
    let mut preview_full = dng.subframe(2);
    preview_full.preview(&preview_img, params.jpeg_quality as f32 / 100.0, params.preview_full.w, params.preview_full.h)?;
    preview_full.finalize()?;
  }
  if params.thumbnail {
    dng.thumbnail(&preview_img)?;
  }

  // Metadata carried over from the source DNG.
  dng.load_base_tags(&rawimage)?;
  dng.load_metadata(&metadata)?;
  if !dng.root_ifd().contains(ExifTag::Orientation) {
    dng.root_ifd_mut().add_tag(ExifTag::Orientation, rawimage.orientation.to_u16());
  }
  if let Some(dng_root_ifd) = decoder.ifd(WellKnownIFD::VirtualDngRootTags)? {
    dng.root_ifd_mut().copy(dng_root_ifd.value_iter());
  }
  if let Some(tiff_root) = decoder.ifd(WellKnownIFD::Root)? {
    dng.root_ifd_mut().copy(tiff_root.value_iter().filter(|(tag, _)| {
      [TiffCommonTag::TimeCodes as u16, TiffCommonTag::FrameFrate as u16, TiffCommonTag::TStop as u16].contains(tag)
    }));
  }
  if let Some(xpacket) = decoder.xpacket(&rawfile, &raw_params)? {
    dng.xpacket(&xpacket)?;
  }

  // Preserve the embedded original raw (so the DNG stays self-contained).
  if params.embedded {
    let mut orig_stream = BufReader::new(File::open(dng_in)?);
    let original = OriginalCompressed::compress(&mut orig_stream)?;
    dng.original_file(&original, &original_filename)?;
  }

  if let Some(artist) = &params.artist {
    dng.root_ifd_mut().add_tag(TiffCommonTag::Artist, artist);
  }
  dng.root_ifd_mut().add_tag(TiffCommonTag::Software, &params.software);

  // Deterministic ModifyDate (same scheme as convert_raw_file).
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
  dng.root_ifd_mut().add_tag(ExifTag::ModifyDate, modify_date);

  dng.close()?;
  Ok(())
}
