import 'package:mini_blog_app/core/errors/failures.dart';

import '../entities/user_profile.dart';

/// Profil Firestore `users/{uid}`. Ce n'est pas Firebase Auth.
abstract class UserProfileRepository {
  Future<(UserProfile?, Failure?)> getProfile(String uid);

  Stream<(UserProfile?, Failure?)> watchProfile(String uid);

  /// Crée ou met à jour le document du uid connecté (appelé par l'équipe Auth
  /// après inscription / édition de profil).
  Future<Failure?> upsertProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  });
}
