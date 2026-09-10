import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/logout_user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(
    ref.watch(authRepositoryProvider),
  );
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(
    ref.watch(authRepositoryProvider),
  );
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(
    ref.watch(authRepositoryProvider),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final result = await ref.read(loginUserProvider)(
      email: email,
      password: password,
    );

    final (_, failure) = result;

    if (failure != null) {
      state = AsyncError(
        failure.message,
        StackTrace.current,
      );
      return;
    }

    state = const AsyncData(null);
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();

    final result = await ref.read(registerUserProvider)(
      email: email,
      password: password,
      displayName: displayName,
    );

    final (_, failure) = result;

    if (failure != null) {
      state = AsyncError(
        failure.message,
        StackTrace.current,
      );
      return;
    }

    state = const AsyncData(null);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    final failure = await ref.read(logoutUserProvider)();

    if (failure != null) {
      state = AsyncError(
        failure.message,
        StackTrace.current,
      );
      return;
    }

    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(
  AuthNotifier.new,
);