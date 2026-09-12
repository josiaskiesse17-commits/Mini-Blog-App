import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/core/errors/exceptions.dart';
import 'package:mini_blog_app/core/errors/failures.dart';
import 'package:mini_blog_app/features/blog/data/datasources/article_local_data_source.dart';
import 'package:mini_blog_app/features/blog/data/datasources/article_remote_data_source.dart';
import 'package:mini_blog_app/features/blog/data/models/article_model.dart';
import 'package:mini_blog_app/features/blog/data/repositories/article_repository_impl.dart';
import 'package:mini_blog_app/features/blog/domain/entities/article.dart';
import 'package:mini_blog_app/features/blog/domain/entities/article_page.dart';
import 'package:mini_blog_app/features/blog/domain/repositories/article_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FakeArticleLocalDataSource localDataSource;
  late ArticleRepository repository;

  Article draft({
    String id = '',
    String authorId = 'uid-alice',
    String title = 'Mon article',
    String content = 'Contenu',
    ArticleStatus status = ArticleStatus.draft,
  }) {
    final now = DateTime.utc(2026, 9, 8);
    return Article(
      id: id,
      title: title,
      content: content,
      authorId: authorId,
      authorName: 'Alice',
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    localDataSource = FakeArticleLocalDataSource();
    repository = ArticleRepositoryImpl(
      ArticleRemoteDataSourceImpl(firestore: firestore),
      localDataSource,
    );
  });

  group('create / read', () {
    test('crée un brouillon et le relit par id', () async {
      final (id, createFailure) = await repository.createArticle(draft());
      expect(createFailure, isNull);
      expect(id, isNotEmpty);

      final (article, getFailure) = await repository.getArticle(id!);
      expect(getFailure, isNull);
      expect(article!.title, 'Mon article');
      expect(article.authorId, 'uid-alice');
      expect(article.status, ArticleStatus.draft);
      expect(article.publishedAt, isNull);
    });

    test('getArticle introuvable retourne NotFoundFailure', () async {
      final (article, failure) = await repository.getArticle('missing');
      expect(article, isNull);
      expect(failure, isA<NotFoundFailure>());
    });
  });

  group('published feed and pagination', () {
    test('getPublishedArticles n\'inclut pas les brouillons', () async {
      await repository.createArticle(draft(title: 'Brouillon'));
      await repository.createArticle(
        draft(
          title: 'Publié',
          content: 'Texte',
          status: ArticleStatus.published,
        ),
      );

      final (page, failure) = await repository.getPublishedArticles();
      expect(failure, isNull);
      expect(page!.items, hasLength(1));
      expect(page.items.first.title, 'Publié');
      expect(page.items.first.status, ArticleStatus.published);
    });

    test('pagine avec cursor sans exposer Firestore', () async {
      for (var i = 0; i < 3; i++) {
        await repository.createArticle(
          draft(
            title: 'Article $i',
            content: 'Texte $i',
            status: ArticleStatus.published,
          ),
        );
      }

      final (firstPage, firstFailure) = await repository.getPublishedArticles(
        limit: 2,
      );
      expect(firstFailure, isNull);
      expect(firstPage!.items, hasLength(2));
      expect(firstPage.hasMore, isTrue);
      expect(firstPage.nextCursor, isA<ArticlePageCursor>());

      final (secondPage, secondFailure) = await repository.getPublishedArticles(
        limit: 2,
        cursor: firstPage.nextCursor,
      );
      expect(secondFailure, isNull);
      expect(secondPage!.items, hasLength(1));
      expect(secondPage.hasMore, isFalse);
    });
  });

  group('my articles / drafts', () {
    test('getMyDrafts ne retourne que les brouillons de l\'auteur', () async {
      await repository.createArticle(draft(title: 'Mine draft'));
      await repository.createArticle(
        draft(title: 'Mine published', status: ArticleStatus.published),
      );
      await repository.createArticle(
        draft(authorId: 'uid-bob', title: 'Bob draft'),
      );

      final (page, failure) = await repository.getMyDrafts(
        authorId: 'uid-alice',
      );
      expect(failure, isNull);
      expect(page!.items, hasLength(1));
      expect(page.items.first.title, 'Mine draft');
    });
  });

  group('update / publish / delete', () {
    test('updateArticle change le titre', () async {
      final (id, _) = await repository.createArticle(draft());
      final (created, _) = await repository.getArticle(id!);

      final failure = await repository.updateArticle(
        created!.copyWith(title: 'Nouveau titre', content: 'Nouveau'),
      );
      expect(failure, isNull);

      final (updated, _) = await repository.getArticle(id);
      expect(updated!.title, 'Nouveau titre');
      expect(updated.authorId, 'uid-alice');
    });

    test('publishArticle passe le statut à published', () async {
      final (id, _) = await repository.createArticle(
        draft(content: 'Assez de contenu'),
      );

      final failure = await repository.publishArticle(id!);
      expect(failure, isNull);

      final (published, _) = await repository.getArticle(id);
      expect(published!.status, ArticleStatus.published);
      expect(published.publishedAt, isNotNull);
    });

    test('deleteArticle supprime le document', () async {
      final (id, _) = await repository.createArticle(draft());
      final failure = await repository.deleteArticle(id!);
      expect(failure, isNull);

      final (article, getFailure) = await repository.getArticle(id);
      expect(article, isNull);
      expect(getFailure, isA<NotFoundFailure>());
    });
  });

  group('erreurs', () {
    test('PermissionDeniedException devient PermissionDeniedFailure', () async {
      final repo = ArticleRepositoryImpl(
        _ThrowingDataSource(),
        FakeArticleLocalDataSource(),
      );
      final failure = await repo.deleteArticle('x');
      expect(failure, isA<PermissionDeniedFailure>());
      expect(failure!.message, 'interdit');
    });
  });

  group('cache local (repli hors-ligne)', () {
    test('getArticle met en cache le résultat distant', () async {
      final (id, _) = await repository.createArticle(draft());
      await repository.getArticle(id!);

      final cached = await localDataSource.getCachedArticle(id);
      expect(cached, isNotNull);
      expect(cached!.title, 'Mon article');
    });

    test('getArticle retombe sur le cache quand Firestore échoue', () async {
      final cachedArticle = ArticleModel(
        id: 'offline-1',
        title: 'Article hors-ligne',
        content: 'Contenu local',
        authorId: 'uid-alice',
        authorName: 'Alice',
        status: ArticleStatus.draft,
        createdAt: DateTime.utc(2026, 9, 8),
        updatedAt: DateTime.utc(2026, 9, 8),
      );
      await localDataSource.cacheArticle(cachedArticle);

      final repo = ArticleRepositoryImpl(
        _ServerErrorDataSource(),
        localDataSource,
      );

      final (article, failure) = await repo.getArticle('offline-1');
      expect(failure, isNull);
      expect(article, isNotNull);
      expect(article!.title, 'Article hors-ligne');
    });

    test(
      'getArticle ne retombe pas sur le cache pour une erreur métier',
      () async {
        await localDataSource.cacheArticle(
          ArticleModel(
            id: 'x',
            title: 'Ne doit pas être retourné',
            content: 'Contenu',
            authorId: 'uid-alice',
            authorName: 'Alice',
            status: ArticleStatus.draft,
            createdAt: DateTime.utc(2026, 9, 8),
            updatedAt: DateTime.utc(2026, 9, 8),
          ),
        );
        final repo = ArticleRepositoryImpl(
          _PermissionDeniedDataSource(),
          localDataSource,
        );

        final (article, failure) = await repo.getArticle('x');
        expect(article, isNull);
        expect(failure, isA<PermissionDeniedFailure>());
      },
    );

    test(
      'getArticle retourne ServerFailure si Firestore échoue et rien en cache',
      () async {
        final repo = ArticleRepositoryImpl(
          _ServerErrorDataSource(),
          localDataSource,
        );

        final (article, failure) = await repo.getArticle('inconnu');
        expect(article, isNull);
        expect(failure, isA<ServerFailure>());
      },
    );

    test(
      'getPublishedArticles retombe sur le cache filtré quand Firestore échoue',
      () async {
        await localDataSource.cacheArticles([
          ArticleModel(
            id: 'p1',
            title: 'Publié',
            content: 'Contenu',
            authorId: 'uid-alice',
            authorName: 'Alice',
            status: ArticleStatus.published,
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
            publishedAt: DateTime.utc(2026, 9, 1),
          ),
          ArticleModel(
            id: 'd1',
            title: 'Brouillon',
            content: 'Contenu',
            authorId: 'uid-alice',
            authorName: 'Alice',
            status: ArticleStatus.draft,
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        ]);

        final repo = ArticleRepositoryImpl(
          _ServerErrorDataSource(),
          localDataSource,
        );

        final (page, failure) = await repo.getPublishedArticles();
        expect(failure, isNull);
        expect(page!.items, hasLength(1));
        expect(page.items.first.title, 'Publié');
        expect(page.hasMore, isFalse);
      },
    );

    test(
      'getPublishedArticles avec un curseur ne retombe pas sur le cache',
      () async {
        final repo = ArticleRepositoryImpl(
          _ServerErrorDataSource(),
          localDataSource,
        );

        final (page, failure) = await repo.getPublishedArticles(
          cursor: const ArticlePageCursor('doc-1'),
        );
        expect(page, isNull);
        expect(failure, isA<ServerFailure>());
      },
    );

    test(
      'getMyArticles met en cache les résultats et retombe dessus hors-ligne',
      () async {
        await repository.createArticle(draft(title: 'Article A'));
        await repository.createArticle(draft(title: 'Article B'));

        await repository.getMyArticles(authorId: 'uid-alice');
        final cached = await localDataSource.getCachedArticles();
        expect(cached, hasLength(2));

        final repo = ArticleRepositoryImpl(
          _ServerErrorDataSource(),
          localDataSource,
        );
        final (page, failure) = await repo.getMyArticles(
          authorId: 'uid-alice',
        );
        expect(failure, isNull);
        expect(page!.items, hasLength(2));
      },
    );
  });
}

class FakeArticleLocalDataSource implements ArticleLocalDataSource {
  final Map<String, ArticleModel> _store = {};

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    for (final article in articles) {
      _store[article.id] = article;
    }
  }

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    final articles = _store.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return articles;
  }

  @override
  Future<void> cacheArticle(ArticleModel article) async {
    _store[article.id] = article;
  }

  @override
  Future<ArticleModel?> getCachedArticle(String id) async {
    return _store[id];
  }

  @override
  Future<void> clearCache() async {
    _store.clear();
  }
}

class _ServerErrorDataSource implements ArticleRemoteDataSource {
  @override
  Future<String> createArticle(Article article) => throw UnimplementedError();

  @override
  Future<ArticleModel> getArticle(String id) {
    throw const ServerException('indisponible');
  }

  @override
  Stream<ArticleModel?> watchArticle(String id) => throw UnimplementedError();

  @override
  Future<ArticlePage> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    required int limit,
  }) {
    throw const ServerException('indisponible');
  }

  @override
  Future<ArticlePage> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    required int limit,
  }) {
    throw const ServerException('indisponible');
  }

  @override
  Future<void> updateArticle(Article article) => throw UnimplementedError();

  @override
  Future<void> publishArticle(String id) => throw UnimplementedError();

  @override
  Future<String> saveDraft(Article article) => throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
}

class _PermissionDeniedDataSource implements ArticleRemoteDataSource {
  @override
  Future<String> createArticle(Article article) => throw UnimplementedError();

  @override
  Future<ArticleModel> getArticle(String id) {
    throw const PermissionDeniedException('interdit');
  }

  @override
  Stream<ArticleModel?> watchArticle(String id) => throw UnimplementedError();

  @override
  Future<ArticlePage> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<ArticlePage> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<void> updateArticle(Article article) => throw UnimplementedError();

  @override
  Future<void> publishArticle(String id) => throw UnimplementedError();

  @override
  Future<String> saveDraft(Article article) => throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) => throw UnimplementedError();
}

class _ThrowingDataSource implements ArticleRemoteDataSource {
  @override
  Future<String> createArticle(Article article) => throw UnimplementedError();

  @override
  Future<ArticleModel> getArticle(String id) => throw UnimplementedError();

  @override
  Stream<ArticleModel?> watchArticle(String id) => throw UnimplementedError();

  @override
  Future<ArticlePage> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<ArticlePage> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    required int limit,
  }) => throw UnimplementedError();

  @override
  Future<void> updateArticle(Article article) => throw UnimplementedError();

  @override
  Future<void> publishArticle(String id) => throw UnimplementedError();

  @override
  Future<String> saveDraft(Article article) => throw UnimplementedError();

  @override
  Future<void> deleteArticle(String id) {
    throw const PermissionDeniedException('interdit');
  }
}
