import '../../../../core/errors/failures.dart';
import '../repositories/article_repository.dart';

class DeleteArticle {
  const DeleteArticle(this._repository);

  final ArticleRepository _repository;

  Future<Failure?> call(String id) {
    return _repository.deleteArticle(id);
  }
}