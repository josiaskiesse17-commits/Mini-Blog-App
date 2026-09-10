import 'article.dart';

/// Curseur opaque pour la page suivante. Le frontend passe l'objet tel quel
/// sans inspecter Firestore.
class ArticlePageCursor {
  const ArticlePageCursor(this.documentId);

  final String documentId;
}

class ArticlePage {
  const ArticlePage({required this.items, this.nextCursor});

  final List<Article> items;
  final ArticlePageCursor? nextCursor;

  bool get hasMore => nextCursor != null;
  bool get isEmpty => items.isEmpty;
}
