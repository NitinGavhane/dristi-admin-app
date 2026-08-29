import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';

import 'admin_service.dart';

/// Image upload rules, shown to the admin and enforced before uploading.
///
/// These mirror the server rules in backend/app/core/storage.py — the backend
/// re-validates every upload, so treat these as a fast local check, not the
/// source of truth. Keep both sides in step when changing a limit.
const int kImageMaxBytes = 5 * 1024 * 1024; // 5 MB
const Set<String> kImageAllowedExts = {'jpg', 'jpeg', 'png', 'webp'};
const int kImageMinWidth = 600;
const int kImageMinHeight = 400;

/// S3 folder an image is stored under. Must match storage.IMAGE_PREFIXES.
class ImageFolder {
  static const banners = 'banners';
  static const products = 'products';
  static const categories = 'categories';
}

/// Per-entity guidance shown in the specs box. Only the recommendation varies;
/// the hard limits above apply everywhere.
class ImageSpecs {
  final int recWidth;
  final int recHeight;
  final String ratioLabel;
  final String folder;

  const ImageSpecs({
    required this.recWidth,
    required this.recHeight,
    required this.ratioLabel,
    required this.folder,
  });

  static const banner = ImageSpecs(
    recWidth: 1920, recHeight: 1080, ratioLabel: '16:9', folder: ImageFolder.banners);
  static const product = ImageSpecs(
    recWidth: 1200, recHeight: 1600, ratioLabel: '3:4', folder: ImageFolder.products);
  static const category = ImageSpecs(
    recWidth: 800, recHeight: 800, ratioLabel: '1:1', folder: ImageFolder.categories);
}

/// A rule violation or upload failure, carrying a message fit to show an admin.
class ImageUploadException implements Exception {
  final String message;
  ImageUploadException(this.message);

  @override
  String toString() => message;
}

/// Prompts for an image, validates it, and uploads it to [specs.folder].
///
/// Returns the public URL, or null if the admin cancelled the picker. Throws
/// [ImageUploadException] with a readable message on any rule violation.
Future<String?> pickValidateAndUploadImage({
  required AdminService admin,
  required ImageSpecs specs,
}) async {
  final XFile? file =
      await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
  if (file == null) return null;

  final name = file.name;
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  if (!kImageAllowedExts.contains(ext)) {
    throw ImageUploadException('Unsupported format. Allowed: JPG, PNG, WebP.');
  }

  final bytes = await file.readAsBytes();
  if (bytes.lengthInBytes > kImageMaxBytes) {
    final mb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
    throw ImageUploadException('Image is too large ($mb MB). Maximum size is 5 MB.');
  }

  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final w = frame.image.width, h = frame.image.height;
  frame.image.dispose();
  if (w < kImageMinWidth || h < kImageMinHeight) {
    throw ImageUploadException(
        'Image too small ($w×$h). Minimum is $kImageMinWidth×$kImageMinHeight px.');
  }

  try {
    return await admin.uploadImageBytes(bytes, name, folder: specs.folder);
  } catch (e) {
    throw ImageUploadException('Upload failed: $e');
  }
}
