import 'package:mini_blog_app/core/errors/failures.dart';

import '../entities/comment.dart';

abstract class CommentRepository {
  Future<(String?, Failure?)> createComment(Comment comment);

  Future<(CommentPage?, Failure?)> getComments({
    required String articleId,
    CommentPageCursor? cursor,
    int limit = 20,
  });

  Stream<(List<Comment>?, Failure?)> watchComments(String articleId);

  Future<Failure?> updateComment(Comment comment);

  Future<Failure?> deleteComment({
    required String articleId,
    required String commentId,
  });
}
