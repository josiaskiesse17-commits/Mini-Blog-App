import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/article_image_picker.dart';
import '../services/article_image_service.dart';
import 'article_image_local_data_source_provider.dart';

final articleImagePickerProvider = Provider<ArticleImagePicker>((ref) {
  return ArticleImagePickerImpl();
});

final articleImageServiceProvider = Provider<ArticleImageService>((ref) {
  return ArticleImageService(
    picker: ref.watch(articleImagePickerProvider),
    localDataSource: ref.watch(articleImageLocalDataSourceProvider),
  );
});