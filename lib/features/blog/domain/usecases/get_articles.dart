import 'package:mini_blog_app/core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticles {
  final ArticleRepository repository;

  GetArticles(this.repository);

  Future<(List<Article>?, Failure?)> call() async {
    return await repository.getArticles();
  }
}