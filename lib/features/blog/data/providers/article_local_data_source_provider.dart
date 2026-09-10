import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/article_local_data_source.dart';

final articleLocalDataSourceProvider =
    Provider<ArticleLocalDataSource>((ref) {
  throw UnimplementedError(
    'ArticleLocalDataSource must be provided by the Hive implementation.',
  );
});