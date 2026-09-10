import '../../../../core/errors/failures.dart';
import '../repositories/comment_repository.dart';

class DeleteComment {
  const DeleteComment(this._repository);

  final CommentRepository _repository;

  Future<Failure?> call({
    required String articleId,
    required String commentId,
  }) {
    return _repository.deleteComment(
      articleId: articleId,
      commentId: commentId,
    );
  }
}
