import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<(List<Article>?, Failure?)> getArticles();

  Future<(Article?, Failure?)> getArticle(String id);

  Future<Failure?> createArticle(Article article);

  Future<Failure?> updateArticle(Article article);

  Future<Failure?> deleteArticle(String id);
}