import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../datasources/article_image_local_data_source.dart';
import '../datasources/article_image_local_data_source_impl.dart';

final articleImagesBoxProvider = Provider<Box<Uint8List>>((ref) {
  throw UnimplementedError(
    'articleImagesBoxProvider must be overridden with the box opened in main().',
  );
});

final articleImageLocalDataSourceProvider =
    Provider<ArticleImageLocalDataSource>((ref) {
  return HiveArticleImageLocalDataSource(
    ref.watch(articleImagesBoxProvider),
  );
});