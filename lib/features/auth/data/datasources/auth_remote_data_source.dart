import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource({
    required this.firebaseAuth,
  });

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
    }

    if (credential.user != null) {
      await credential.user!.sendEmailVerification();
    }

    return credential;
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Stream<User?> get authStateChanges {
    return firebaseAuth.authStateChanges();
  }
}