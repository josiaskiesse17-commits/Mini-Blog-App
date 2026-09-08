import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article.dart';
import '../entities/article_page.dart';
import '../repositories/article_repository.dart';

class GetMyArticles {
  const GetMyArticles(this._repository);

  final ArticleRepository _repository;

  Future<(ArticlePage?, Failure?)> call({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return _repository.getMyArticles(
      authorId: authorId,
      status: status,
      cursor: cursor,
      limit: limit,
    );
  }
}
