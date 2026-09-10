import 'package:mini_blog_app/core/errors/failures.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<(User?, Failure?)> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(
      email: email,
      password: password,
    );
  }
}