import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mini_blog_app/core/errors/failures.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<(User?, Failure?)> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return (
          null,
          const AuthFailure('Utilisateur introuvable'),
        );
      }

      return (
        UserModel.fromFirebaseUser(firebaseUser),
        null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return (
        null,
        AuthFailure(_getAuthErrorMessage(e.code)),
      );
    } catch (e) {
      return (
        null,
        ServerFailure(e.toString()),
      );
    }
  }

  @override
  Future<(User?, Failure?)> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return (
          null,
          const AuthFailure('Impossible de créer l’utilisateur'),
        );
      }

      return (
        UserModel.fromFirebaseUser(firebaseUser),
        null,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return (
        null,
        AuthFailure(_getAuthErrorMessage(e.code)),
      );
    } catch (e) {
      return (
        null,
        ServerFailure(e.toString()),
      );
    }
  }

  @override
  Future<Failure?> signOut() async {
    try {
      await remoteDataSource.signOut();
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthFailure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (firebaseUser) {
        if (firebaseUser == null) {
          return null;
        }

        return UserModel.fromFirebaseUser(firebaseUser);
      },
    );
  }

  String _getAuthErrorMessage(String code) {
    return switch (code) {
      'invalid-email' => 'E-mail invalide',
      'user-not-found' => 'Le compte n’existe pas',
      'wrong-password' => 'Le mot de passe est incorrect',
      'invalid-credential' => 'E-mail ou mot de passe incorrect',
      'email-already-in-use' => 'Cet e-mail est déjà utilisé',
      'weak-password' => 'Le mot de passe est trop faible',
      'user-disabled' => 'Le compte est désactivé',
      'too-many-requests' => 'Trop de tentatives. Réessayez plus tard',
      _ => 'Une erreur d’authentification est survenue',
    };
  }
}