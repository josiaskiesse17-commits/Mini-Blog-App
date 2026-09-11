import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../datasources/article_local_data_source.dart';
import '../datasources/article_local_data_source_impl.dart';

final articlesBoxProvider = Provider<Box<Map>>((ref) {
  throw UnimplementedError(
    'articlesBoxProvider must be overridden with the box opened in main().',
  );
});

final articleLocalDataSourceProvider =
    Provider<ArticleLocalDataSource>((ref) {
  return HiveArticleLocalDataSource(ref.watch(articlesBoxProvider));
});
