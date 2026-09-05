import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<(User?, Failure?)> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<(User?, Failure?)> signIn({
    required String email,
    required String password,
  });

  Future<Failure?> signOut();

  Stream<User?> get authStateChanges;
}