import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class UpdateArticle {
  final ArticleRepository repository;

  UpdateArticle(this.repository);

  Future<Failure?> call(Article article) async {
    return await repository.updateArticle(article);
  }
}