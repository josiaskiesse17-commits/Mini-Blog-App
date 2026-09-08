import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class UpdateArticle {
  const UpdateArticle(this._repository);

  final ArticleRepository _repository;

  Future<Failure?> call(Article article) {
    return _repository.updateArticle(article);
  }
}
