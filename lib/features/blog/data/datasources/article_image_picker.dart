import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class PickedArticleImage {
  final Uint8List bytes;
  final String fileExtension;

  const PickedArticleImage({
    required this.bytes,
    required this.fileExtension,
  });
}

abstract class ArticleImagePicker {
  Future<PickedArticleImage?> pickImage();
}

class ArticleImagePickerImpl implements ArticleImagePicker {
  ArticleImagePickerImpl({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedArticleImage?> pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    final extension = _getExtension(file.name);

    return PickedArticleImage(
      bytes: bytes,
      fileExtension: extension,
    );
  }

  String _getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return 'jpg';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}