import '../../../../core/errors/failures.dart';
import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class UpdateComment {
  const UpdateComment(this._repository);

  final CommentRepository _repository;

  Future<Failure?> call(Comment comment) {
    return _repository.updateComment(comment);
  }
}
