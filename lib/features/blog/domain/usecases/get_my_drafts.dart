import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/article_page.dart';
import '../repositories/article_repository.dart';

class GetMyDrafts {
  const GetMyDrafts(this._repository);

  final ArticleRepository _repository;

  Future<(ArticlePage?, Failure?)> call({
    required String authorId,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return _repository.getMyDrafts(
      authorId: authorId,
      cursor: cursor,
      limit: limit,
    );
  }
}
