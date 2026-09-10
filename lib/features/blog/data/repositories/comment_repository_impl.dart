import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

class CommentRepositoryImpl implements CommentRepository {
  const CommentRepositoryImpl(this._remoteDataSource);

  final CommentRemoteDataSource _remoteDataSource;

  @override
  Future<(String?, Failure?)> createComment(Comment comment) {
    return _guard(() => _remoteDataSource.createComment(comment));
  }

  @override
  Future<(CommentPage?, Failure?)> getComments({
    required String articleId,
    CommentPageCursor? cursor,
    int limit = AppConstants.commentPageSize,
  }) {
    return _guard(
      () => _remoteDataSource.getComments(
        articleId: articleId,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  @override
  Stream<(List<Comment>?, Failure?)> watchComments(String articleId) async* {
    try {
      await for (final comments in _remoteDataSource.watchComments(articleId)) {
        yield (comments, null);
      }
    } on PermissionDeniedException catch (error) {
      yield (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      yield (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      yield (null, ServerFailure(error.message));
    } catch (error) {
      yield (null, ServerFailure(error.toString()));
    }
  }

  @override
  Future<Failure?> updateComment(Comment comment) {
    return _guardVoid(() => _remoteDataSource.updateComment(comment));
  }

  @override
  Future<Failure?> deleteComment({
    required String articleId,
    required String commentId,
  }) {
    return _guardVoid(
      () => _remoteDataSource.deleteComment(
        articleId: articleId,
        commentId: commentId,
      ),
    );
  }

  Future<(T?, Failure?)> _guard<T>(Future<T> Function() action) async {
    try {
      return (await action(), null);
    } on PermissionDeniedException catch (error) {
      return (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      return (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      return (null, ServerFailure(error.message));
    } catch (error) {
      return (null, ServerFailure(error.toString()));
    }
  }

  Future<Failure?> _guardVoid(Future<void> Function() action) async {
    final result = await _guard(action);
    return result.$2;
  }
}
