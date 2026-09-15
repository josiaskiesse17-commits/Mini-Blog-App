import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../datasources/article_local_data_source.dart';
import '../datasources/article_local_data_source_impl.dart';

final articlesBoxProvider = Provider<Box<Map>>((ref) {
  throw UnimplementedError(
    'Articles Hive box must be provided by main.dart.',
  );
});

final articleLocalDataSourceProvider =
    Provider<ArticleLocalDataSource>((ref) {
  final box = ref.watch(articlesBoxProvider);

  return HiveArticleLocalDataSource(box);
});