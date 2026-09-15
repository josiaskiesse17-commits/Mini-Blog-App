import 'dart:math';

import '../datasources/article_image_local_data_source.dart';
import '../datasources/article_image_picker.dart';

class ArticleImageService {
  ArticleImageService({
    required this._picker,
    required this._localDataSource,
  });

  final ArticleImagePicker _picker;
  final ArticleImageLocalDataSource _localDataSource;

  Future<String?> pickAndSaveImage() async {
    final pickedImage = await _picker.pickImage();

    if (pickedImage == null) {
      return null;
    }

    final imageId = _generateImageId();

    await _localDataSource.saveImage(
      imageId: imageId,
      bytes: pickedImage.bytes,
    );

    return imageId;
  }

  Future<void> deleteImage(String imageId) {
    return _localDataSource.deleteImage(imageId);
  }

  String _generateImageId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(1000000);

    return 'article_image_${timestamp}_$random';
  }
}
