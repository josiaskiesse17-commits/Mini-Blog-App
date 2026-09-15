import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import 'article_image_local_data_source.dart';

class HiveArticleImageLocalDataSource
    implements ArticleImageLocalDataSource {
  HiveArticleImageLocalDataSource(this._box);

  static const String boxName = 'article_images';

  final Box<Uint8List> _box;

  @override
  Future<void> saveImage({
    required String imageId,
    required Uint8List bytes,
  }) async {
    try {
      await _box.put(imageId, bytes);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<Uint8List?> getImage(String imageId) async {
    try {
      return _box.get(imageId);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> deleteImage(String imageId) async {
    try {
      await _box.delete(imageId);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }
}