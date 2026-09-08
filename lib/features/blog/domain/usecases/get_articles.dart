import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article_page.dart';
import '../repositories/article_repository.dart';

class GetArticles {
  const GetArticles(this._repository);

  final ArticleRepository _repository;

  Future<(ArticlePage?, Failure?)> call({
    String? authorId,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return _repository.getPublishedArticles(
      authorId: authorId,
      cursor: cursor,
      limit: limit,
    );
  }
}
