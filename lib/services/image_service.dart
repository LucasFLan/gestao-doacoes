import 'dart:io';

import 'package:image_picker/image_picker.dart';

final class ImageService {
  ImageService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromCamera() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
    );
    return file != null ? File(file.path) : null;
  }

  static Future<File?> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    return file != null ? File(file.path) : null;
  }

  static Future<File?> pickImage({required ImageSource source}) async {
    if (source == ImageSource.camera) {
      return pickFromCamera();
    }
    return pickFromGallery();
  }
}
