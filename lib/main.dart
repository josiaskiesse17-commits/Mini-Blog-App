import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/firebase/firestore_emulator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/data/user_profile_sync.dart';
import 'features/blog/data/datasources/article_image_local_data_source_impl.dart';
import 'features/blog/data/datasources/article_local_data_source_impl.dart';
import 'features/blog/data/providers/article_image_local_data_source_provider.dart';
import 'features/blog/data/providers/article_local_data_source_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await connectFirestoreEmulatorIfEnabled();

  await Hive.initFlutter();

  final articlesBox = await Hive.openBox<Map>(
    HiveArticleLocalDataSource.boxName,
  );

  final articleImagesBox = await Hive.openBox<Uint8List>(
    HiveArticleImageLocalDataSource.boxName,
  );

  runApp(
    ProviderScope(
      overrides: [
        articlesBoxProvider.overrideWithValue(articlesBox),
        articleImagesBoxProvider.overrideWithValue(articleImagesBox),
      ],
      child: const MiniBlogApp(),
    ),
  );
}

class MiniBlogApp extends ConsumerWidget {
  const MiniBlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userProfileSyncProvider);

    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MiniBlog',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}