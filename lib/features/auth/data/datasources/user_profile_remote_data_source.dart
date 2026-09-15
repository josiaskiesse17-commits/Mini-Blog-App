import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getProfile(String uid);

  Stream<UserProfileModel?> watchProfile(String uid);

  Future<void> upsertProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  });
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  UserProfileRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(AppConstants.usersCollection);

  @override
  Future<UserProfileModel> getProfile(String uid) async {
    try {
      final snap = await _users.doc(uid).get();
      if (!snap.exists) {
        throw const NotFoundException('Profil introuvable');
      }
      return UserProfileModel.fromFirestore(snap);
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Stream<UserProfileModel?> watchProfile(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists) {
            return null;
          }
          return UserProfileModel.fromFirestore(snap);
        })
        .handleError((Object error, StackTrace _) {
          if (error is FirebaseException) {
            throw _mapFirebaseException(error);
          }
          throw error;
        });
  }

  @override
  Future<void> upsertProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final doc = _users.doc(uid);

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(doc);

        if (snap.exists) {
          transaction.update(
            doc,
            {
              'displayName': displayName,
              'photoUrl': photoUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
          return;
        }

        transaction.set(
          doc,
          {
            'displayName': displayName,
            'photoUrl': photoUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      });
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }
}

Exception _mapFirebaseException(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return PermissionDeniedException(error.message ?? 'Permission refusée');
    case 'not-found':
      return NotFoundException(error.message ?? 'Document introuvable');
    default:
      return ServerException(error.message ?? error.code);
  }
}
