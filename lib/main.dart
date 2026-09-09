import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/blog/data/datasources/article_remote_data_source.dart';
import 'features/blog/data/repositories/article_repository_impl.dart';
import 'features/blog/domain/usecases/get_articles.dart';
import 'features/blog/domain/usecases/create_article.dart';
import 'features/blog/domain/usecases/update_article.dart';
import 'features/blog/domain/usecases/delete_article.dart';
import 'features/blog/presentation/providers/article_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  final remoteDataSource = ArticleRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
  );

  final repository = ArticleRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  
  final getArticles = GetArticles(repository);
  final createArticle = CreateArticle(repository);
  final updateArticle = UpdateArticle(repository);
  final deleteArticle = DeleteArticle(repository);

  
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(
            create: (_) => ArticleProvider(
              getArticlesUseCase: getArticles,
              createArticleUseCase: createArticle,
              updateArticleUseCase: updateArticle,
              deleteArticleUseCase: deleteArticle,
            )..fetchArticles(), 
          ),
        ],
        child: const MiniBlogApp(),
      ),
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