import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class CreateArticle {
  final ArticleRepository repository;

  CreateArticle(this.repository);

  Future<Failure?> call(Article article) async {
    return await repository.createArticle(article);
  }
}