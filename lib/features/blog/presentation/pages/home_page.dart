import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/article_notifier.dart';
import '../widgets/article_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(articleNotifierProvider.notifier).fetchArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MiniBlog'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(articleNotifierProvider.notifier).fetchArticles();
        },
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.articles.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.errorMessage != null && state.articles.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state.articles.isEmpty) {
  return ListView(
    children: [
      const SizedBox(height: 140),
      Icon(
        Icons.article_outlined,
        size: 72,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 20),
      Text(
        'Aucun article publié',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        'Soyez le premier à partager un article avec la communauté.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ],
  );
}

            return ArticleList(
  articles: state.articles,
  onArticleTap: (article) {
    context.go('/article/${article.id}');
  },
);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
