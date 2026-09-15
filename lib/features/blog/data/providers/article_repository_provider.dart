import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firebase_providers.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';
import '../repositories/article_repository_impl.dart';

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((
  ref,
) {
  return ArticleRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

/// Point d'entrée pour l'équipe UI / Auth : ne pas appeler Firestore ailleurs.
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepositoryImpl(ref.watch(articleRemoteDataSourceProvider));
});