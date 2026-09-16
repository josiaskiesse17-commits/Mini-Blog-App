import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_provider.dart';
import '../providers/article_notifier.dart';
import '../widgets/article_card.dart';

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

  Future<void> _refresh() async {
    await ref.read(articleNotifierProvider.notifier).fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleNotifierProvider);
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text('MiniBlog'),
        actions: [
          IconButton(
            tooltip: themeMode == ThemeMode.dark
                ? 'Mode clair'
                : 'Mode sombre',
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Mon compte',
            onPressed: () {
              context.push('/account');
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/create');

          if (created == true && mounted) {
            await _refresh();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(
          context,
          state,
          theme,
          colors,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ArticleState state,
    ThemeData theme,
    ColorScheme colors,
  ) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.cloud_off_outlined,
            size: 52,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ),
        ],
      );
    }

    if (state.articles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.article_outlined,
            size: 56,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun article disponible.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int crossAxisCount;
        double horizontalPadding;
        double spacing;

        if (width >= 1200) {
          crossAxisCount = 3;
          horizontalPadding = 32;
          spacing = 20;
        } else if (width >= 700) {
          crossAxisCount = 2;
          horizontalPadding = 24;
          spacing = 16;
        } else {
          crossAxisCount = 1;
          horizontalPadding = 16;
          spacing = 14;
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1400,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      18,
                    ),
                    child: Text(
                      'Dernières publications',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                100,
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final article = state.articles[index];

                    return ArticleCard(
                      article: article,
                      onTap: () {
                        context.push('/article/${article.id}');
                      },
                    );
                  },
                  childCount: state.articles.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  mainAxisExtent: width >= 1200
                      ? 285
                      : width >= 700
                          ? 290
                          : 295,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}