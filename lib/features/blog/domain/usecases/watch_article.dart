import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class WatchArticle {
  const WatchArticle(this._repository);

  final ArticleRepository _repository;

  Stream<(Article?, Failure?)> call(String id) {
    return _repository.watchArticle(id);
  }
}
