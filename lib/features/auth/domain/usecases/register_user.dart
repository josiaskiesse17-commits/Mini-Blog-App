import 'package:mini_blog_app/core/errors/failures.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<(User?, Failure?)> call({
    required String email,
    required String password,
    String? displayName,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}