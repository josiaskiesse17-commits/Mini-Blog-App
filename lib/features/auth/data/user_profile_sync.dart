import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';
import '../repositories/user_profile_repository_impl.dart';

/// Synchronise `users/{uid}` dès qu'Auth émet un utilisateur.
/// N'implémente pas login / signup : lit seulement le uid Auth existant.
void startUserProfileSync({UserProfileRepository? repository}) {
  final repo =
      repository ??
      UserProfileRepositoryImpl(UserProfileRemoteDataSourceImpl());

  firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      return;
    }
    repo.upsertProfile(
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  });
}
