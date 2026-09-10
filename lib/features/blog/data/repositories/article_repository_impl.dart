import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_page.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl(this._remoteDataSource);

  final ArticleRemoteDataSource _remoteDataSource;

  @override
  Future<(String?, Failure?)> createArticle(Article article) {
    return _guard(() => _remoteDataSource.createArticle(article));
  }

  @override
  Future<(Article?, Failure?)> getArticle(String id) {
    return _guard(() => _remoteDataSource.getArticle(id));
  }

  @override
  Stream<(Article?, Failure?)> watchArticle(String id) async* {
    try {
      await for (final article in _remoteDataSource.watchArticle(id)) {
        yield (article, null);
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
  Future<(ArticlePage?, Failure?)> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return _guard(
      () => _remoteDataSource.getPublishedArticles(
        authorId: authorId,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  @override
  Future<(ArticlePage?, Failure?)> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return _guard(
      () => _remoteDataSource.getMyArticles(
        authorId: authorId,
        status: status,
        cursor: cursor,
        limit: limit,
      ),
    );
  }

  @override
  Future<(ArticlePage?, Failure?)> getMyDrafts({
    required String authorId,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) {
    return getMyArticles(
      authorId: authorId,
      status: ArticleStatus.draft,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<Failure?> updateArticle(Article article) {
    return _guardVoid(
      () => _remoteDataSource.updateArticle(article),
    );
  }

  @override
  Future<(String?, Failure?)> saveDraft(Article article) {
    return _guard(
      () => _remoteDataSource.saveDraft(article),
    );
  }

  @override
  Future<Failure?> publishArticle(String id) {
    return _guardVoid(
      () => _remoteDataSource.publishArticle(id),
    );
  }

  @override
  Future<Failure?> deleteArticle(String id) {
    return _guardVoid(
      () => _remoteDataSource.deleteArticle(id),
    );
  }

  Future<(T?, Failure?)> _guard<T>(
    Future<T> Function() action,
  ) async {
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

  Future<Failure?> _guardVoid(
    Future<void> Function() action,
  ) async {
    final result = await _guard(action);
    return result.$2;
  }
}