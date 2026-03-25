import 'image_service.dart';

/// Implementação para plataformas com suporte a dart:io (mobile, desktop).
Future<String?> pickImagePathFromGallery() async {
  final file = await ImageService.pickFromGallery();
  return file?.path;
}
