import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticle {
  const GetArticle(this._repository);

  final ArticleRepository _repository;

  Future<(Article?, Failure?)> call(String id) {
    return _repository.getArticle(id);
  }
}
