import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/user.dart';
import 'providers/user_profile_repository_provider.dart';

/// Synchronise `users/{uid}` dès qu'Auth émet un utilisateur.
///
/// N'implémente pas login / signup : lit seulement le uid Auth existant.
/// Les dépendances sont fournies par Riverpod.
final userProfileSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(
    authStateProvider,
    (_, next) {
      next.whenData((user) {
        if (user == null) {
          return;
        }

        ref.read(userProfileRepositoryProvider).upsertProfile(
              uid: user.uid,
              displayName: user.displayName,
              photoUrl: user.photoUrl,
            );
      });
    },
    fireImmediately: true,
  );
});
