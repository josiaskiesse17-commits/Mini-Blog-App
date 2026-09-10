import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Active l'émulateur Firestore local.
///
/// ```
/// flutter run --dart-define=USE_FIRESTORE_EMULATOR=true
/// ```
const bool kUseFirestoreEmulator = bool.fromEnvironment(
  'USE_FIRESTORE_EMULATOR',
);

Future<void> connectFirestoreEmulatorIfEnabled() async {
  if (!kUseFirestoreEmulator) {
    return;
  }

  final host = defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : '127.0.0.1';

  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
}
