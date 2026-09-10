import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../blog/data/providers/article_repository_provider.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';
import '../repositories/user_profile_repository_impl.dart';

final userProfileRemoteDataSourceProvider =
    Provider<UserProfileRemoteDataSource>((ref) {
      return UserProfileRemoteDataSourceImpl(
        firestore: ref.watch(firebaseFirestoreProvider),
      );
    });

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(
    ref.watch(userProfileRemoteDataSourceProvider),
  );
});
