import '../../../../core/errors/failures.dart';
import '../repositories/article_repository.dart';

class PublishArticle {
  const PublishArticle(this._repository);

  final ArticleRepository _repository;

  Future<Failure?> call(String id) {
    return _repository.publishArticle(id);
  }
}
