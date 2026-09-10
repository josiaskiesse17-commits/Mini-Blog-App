import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/firebase/firestore_emulator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/user_profile_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await connectFirestoreEmulatorIfEnabled();
  startUserProfileSync();

  runApp(
    const ProviderScope(
      child: MiniBlogApp(),
    ),
  );
}

class MiniBlogApp extends StatelessWidget {
  const MiniBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MiniBlog',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}