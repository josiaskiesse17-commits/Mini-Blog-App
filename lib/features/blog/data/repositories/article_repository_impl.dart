import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_page.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_local_data_source.dart';
import '../datasources/article_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final ArticleRemoteDataSource _remoteDataSource;
  final ArticleLocalDataSource _localDataSource;

  @override
  Future<(String?, Failure?)> createArticle(Article article) {
    return _guard(() => _remoteDataSource.createArticle(article));
  }

  @override
  Future<(Article?, Failure?)> getArticle(String id) async {
    try {
      final article = await _remoteDataSource.getArticle(id);
      await _cacheArticleSilently(article);
      return (article, null);
    } on PermissionDeniedException catch (error) {
      return (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      return (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      final cached = await _getCachedArticleSilently(id);
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.message));
    } catch (error) {
      final cached = await _getCachedArticleSilently(id);
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.toString()));
    }
  }

  @override
  Stream<(Article?, Failure?)> watchArticle(String id) async* {
    try {
      await for (final article in _remoteDataSource.watchArticle(id)) {
        await _cacheArticleSilently(article);
        yield (article, null);
      }
    } on PermissionDeniedException catch (error) {
      yield (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      yield (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      final cached = await _getCachedArticleSilently(id);
      if (cached != null) {
        yield (cached, null);
      } else {
        yield (null, ServerFailure(error.message));
      }
    } catch (error) {
      final cached = await _getCachedArticleSilently(id);
      if (cached != null) {
        yield (cached, null);
      } else {
        yield (null, ServerFailure(error.toString()));
      }
    }
  }

  @override
  Future<(ArticlePage?, Failure?)> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) async {
    try {
      final page = await _remoteDataSource.getPublishedArticles(
        authorId: authorId,
        cursor: cursor,
        limit: limit,
      );
      await _cacheArticlesSilently(page.items);
      return (page, null);
    } on PermissionDeniedException catch (error) {
      return (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      return (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      final cached = cursor == null
          ? await _getCachedPublishedArticles(authorId: authorId, limit: limit)
          : null;
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.message));
    } catch (error) {
      final cached = cursor == null
          ? await _getCachedPublishedArticles(authorId: authorId, limit: limit)
          : null;
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.toString()));
    }
  }

  @override
  Future<(ArticlePage?, Failure?)> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    int limit = AppConstants.articlePageSize,
  }) async {
    try {
      final page = await _remoteDataSource.getMyArticles(
        authorId: authorId,
        status: status,
        cursor: cursor,
        limit: limit,
      );
      await _cacheArticlesSilently(page.items);
      return (page, null);
    } on PermissionDeniedException catch (error) {
      return (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      return (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      final cached = cursor == null
          ? await _getCachedMyArticles(
              authorId: authorId,
              status: status,
              limit: limit,
            )
          : null;
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.message));
    } catch (error) {
      final cached = cursor == null
          ? await _getCachedMyArticles(
              authorId: authorId,
              status: status,
              limit: limit,
            )
          : null;
      if (cached != null) return (cached, null);
      return (null, ServerFailure(error.toString()));
    }
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

  Future<Article?> _getCachedArticleSilently(String id) async {
    try {
      return await _localDataSource.getCachedArticle(id);
    } catch (_) {
      return null;
    }
  }

  Future<ArticlePage?> _getCachedPublishedArticles({
    String? authorId,
    required int limit,
  }) async {
    try {
      final cached = await _localDataSource.getCachedArticles();
      final filtered = cached.where((article) {
        if (article.status != ArticleStatus.published) return false;
        if (authorId != null && article.authorId != authorId) return false;
        return true;
      }).toList()
        ..sort(
          (a, b) => (b.publishedAt ?? b.updatedAt)
              .compareTo(a.publishedAt ?? a.updatedAt),
        );
      if (filtered.isEmpty) return null;
      return ArticlePage(items: filtered.take(limit).toList());
    } catch (_) {
      return null;
    }
  }

  Future<ArticlePage?> _getCachedMyArticles({
    required String authorId,
    ArticleStatus? status,
    required int limit,
  }) async {
    try {
      final cached = await _localDataSource.getCachedArticles();
      final filtered = cached.where((article) {
        if (article.authorId != authorId) return false;
        if (status != null && article.status != status) return false;
        return true;
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (filtered.isEmpty) return null;
      return ArticlePage(items: filtered.take(limit).toList());
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheArticleSilently(Article? article) async {
    if (article == null) return;
    try {
      await _localDataSource.cacheArticle(ArticleModel.fromEntity(article));
    } catch (_) {}
  }

  Future<void> _cacheArticlesSilently(List<Article> articles) async {
    try {
      await _localDataSource.cacheArticles(
        articles.map(ArticleModel.fromEntity).toList(),
      );
    } catch (_) {}
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
