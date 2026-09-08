import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class CreateArticle {
  const CreateArticle(this._repository);

  final ArticleRepository _repository;

  Future<(String?, Failure?)> call(Article article) {
    return _repository.createArticle(article);
  }
}
