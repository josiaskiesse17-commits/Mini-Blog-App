import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class CreateComment {
  const CreateComment(this._repository);

  final CommentRepository _repository;

  Future<(String?, Failure?)> call(Comment comment) {
    return _repository.createComment(comment);
  }
}
