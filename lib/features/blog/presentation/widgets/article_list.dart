import 'package:flutter/material.dart';

import '../../domain/entities/article.dart';
import 'article_card.dart';

class ArticleList extends StatelessWidget {
  final List<Article> articles;
  final void Function(Article article)? onArticleTap;

  const ArticleList({
    super.key,
    required this.articles,
    this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];

        return ArticleCard(
          article: article,
          onTap: () => onArticleTap?.call(article),
        );
      },
    );
  }
}