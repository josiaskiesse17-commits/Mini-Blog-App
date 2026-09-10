import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetComments {
  const GetComments(this._repository);

  final CommentRepository _repository;

  Future<(CommentPage?, Failure?)> call({
    required String articleId,
    CommentPageCursor? cursor,
    int limit = AppConstants.commentPageSize,
  }) {
    return _repository.getComments(
      articleId: articleId,
      cursor: cursor,
      limit: limit,
    );
  }
}
