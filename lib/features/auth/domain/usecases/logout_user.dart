import 'package:mini_blog_app/core/errors/failures.dart';

import '../repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<Failure?> call() {
    return repository.signOut();
  }
}