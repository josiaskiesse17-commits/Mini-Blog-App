import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/blog/data/providers/article_repository_provider.dart';
import '../../features/blog/presentation/pages/article_detail_page.dart';
import '../../features/blog/presentation/pages/create_article_page.dart';
import '../../features/blog/presentation/pages/edit_article_page.dart';
import '../../features/blog/presentation/pages/home_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) {
        return null;
      }

      final isAuthenticated = authState.value != null;

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ArticleDetailPage(articleId: id);
        },
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateArticlePage(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _EditArticleLoader(articleId: id);
        },
      ),
    ],
  );

  ref.listen(
    authStateProvider,
    (_, _) {
      router.refresh();
    },
  );

  ref.onDispose(router.dispose);

  return router;
});

class _EditArticleLoader extends ConsumerWidget {
  final String articleId;

  const _EditArticleLoader({
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(articleRepositoryProvider);

    return FutureBuilder(
      future: repository.getArticle(articleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Erreur lors du chargement de l\'article.',
              ),
            ),
          );
        }

        final result = snapshot.data;

        if (result == null) {
          return const Scaffold(
            body: Center(
              child: Text('Article introuvable.'),
            ),
          );
        }

        final (article, failure) = result;

        if (failure != null || article == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Modifier l\'article'),
            ),
            body: Center(
              child: Text(
                failure?.message ?? 'Article introuvable.',
              ),
            ),
          );
        }

        return EditArticlePage(article: article);
      },
    );
  }
}