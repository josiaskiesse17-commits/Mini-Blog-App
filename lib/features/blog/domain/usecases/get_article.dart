import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticle {
  final ArticleRepository repository;

  GetArticle(this.repository);

  Future<(Article?, Failure?)> call(String id) async {
    return await repository.getArticle(id);
  }
}