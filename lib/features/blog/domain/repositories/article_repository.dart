import 'package:mini_blog_app/core/errors/failures.dart';

import '../entities/article.dart';
import '../entities/article_page.dart';

abstract class ArticleRepository {
  /// Crée un article. [article.status] vaut en général [ArticleStatus.draft].
  /// Retourne l'id du document créé.
  Future<(String?, Failure?)> createArticle(Article article);

  Future<(Article?, Failure?)> getArticle(String id);

  Stream<(Article?, Failure?)> watchArticle(String id);

  /// Feed public : `status == published`, du plus récent au plus ancien.
  /// [authorId] filtre optionnellement un auteur (toujours des publiés).
  Future<(ArticlePage?, Failure?)> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    int limit = 20,
  });

  /// Articles de l'utilisateur [authorId] (doit être le uid connecté).
  /// Passe [status] pour limiter aux brouillons ou aux publiés.
  Future<(ArticlePage?, Failure?)> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    int limit = 20,
  });

  Future<(ArticlePage?, Failure?)> getMyDrafts({
    required String authorId,
    ArticlePageCursor? cursor,
    int limit = 20,
  });

  /// Met à jour titre / contenu / nom d'auteur. Ne change pas [authorId].
  Future<Failure?> updateArticle(Article article);

  /// Enregistre un brouillon. Si [article.id] est vide, crée le document
  /// et retourne le nouvel id.
  Future<(String?, Failure?)> saveDraft(Article article);

  Future<Failure?> publishArticle(String id);

  Future<Failure?> deleteArticle(String id);
}
