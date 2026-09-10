import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';
import '../repositories/comment_repository_impl.dart';
import 'article_repository_provider.dart';

final commentRemoteDataSourceProvider = Provider<CommentRemoteDataSource>((
  ref,
) {
  return CommentRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(ref.watch(commentRemoteDataSourceProvider));
});
