import 'dart:typed_data';

abstract class ArticleImageLocalDataSource {
  Future<void> saveImage({
    required String imageId,
    required Uint8List bytes,
  });

  Future<Uint8List?> getImage(String imageId);

  Future<void> deleteImage(String imageId);
}