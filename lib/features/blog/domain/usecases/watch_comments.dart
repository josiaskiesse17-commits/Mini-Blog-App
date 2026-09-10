import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class WatchComments {
  const WatchComments(this._repository);

  final CommentRepository _repository;

  Stream<(List<Comment>?, Failure?)> call(String articleId) {
    return _repository.watchComments(articleId);
  }
}
