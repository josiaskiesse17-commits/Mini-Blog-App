import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/article_page.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<String> createArticle(Article article);

  Future<ArticleModel> getArticle(String id);

  Stream<ArticleModel?> watchArticle(String id);

  Future<ArticlePage> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    required int limit,
  });

  Future<ArticlePage> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    required int limit,
  });

  Future<void> updateArticle(Article article);

  Future<void> publishArticle(String id);

  Future<String> saveDraft(Article article);

  Future<void> deleteArticle(String id);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  ArticleRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _articles =>
      _firestore.collection(AppConstants.articlesCollection);

  @override
  Future<String> createArticle(Article article) async {
    try {
      final doc =
          article.id.isEmpty ? _articles.doc() : _articles.doc(article.id);

      final authorName = article.authorName.trim().isEmpty
          ? 'Utilisateur'
          : article.authorName.trim();

      final model = ArticleModel.fromEntity(
        article.copyWith(
          id: doc.id,
          authorName: authorName,
        ),
      );

      await doc.set(model.toCreateMap());
      return doc.id;
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<ArticleModel> getArticle(String id) async {
    try {
      final snap = await _articles.doc(id).get();

      if (!snap.exists) {
        throw const NotFoundException('Article introuvable');
      }

      return ArticleModel.fromFirestore(snap);
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Stream<ArticleModel?> watchArticle(String id) {
    return _articles.doc(id).snapshots().map((snap) {
      if (!snap.exists) {
        return null;
      }

      return ArticleModel.fromFirestore(snap);
    }).handleError((Object error, StackTrace _) {
      if (error is FirebaseException) {
        throw _mapFirebaseException(error);
      }

      throw error;
    });
  }

  @override
  Future<ArticlePage> getPublishedArticles({
    String? authorId,
    ArticlePageCursor? cursor,
    required int limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _articles
          .where(
            'status',
            isEqualTo: ArticleStatus.published.name,
          )
          .orderBy(
            'publishedAt',
            descending: true,
          );

      if (authorId != null) {
        query = _articles
            .where(
              'authorId',
              isEqualTo: authorId,
            )
            .where(
              'status',
              isEqualTo: ArticleStatus.published.name,
            )
            .orderBy(
              'publishedAt',
              descending: true,
            );
      }

      return _paginate(
        query: query,
        cursor: cursor,
        limit: limit,
      );
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<ArticlePage> getMyArticles({
    required String authorId,
    ArticleStatus? status,
    ArticlePageCursor? cursor,
    required int limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _articles
          .where(
            'authorId',
            isEqualTo: authorId,
          )
          .orderBy(
            'createdAt',
            descending: true,
          );

      if (status != null) {
        query = _articles
            .where(
              'authorId',
              isEqualTo: authorId,
            )
            .where(
              'status',
              isEqualTo: status.name,
            )
            .orderBy(
              'createdAt',
              descending: true,
            );
      }

      return _paginate(
        query: query,
        cursor: cursor,
        limit: limit,
      );
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<void> updateArticle(Article article) async {
    try {
      final model = ArticleModel.fromEntity(article);
      await _articles.doc(article.id).update(model.toUpdateMap());
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<void> publishArticle(String id) async {
    try {
      await _articles.doc(id).update({
        'status': ArticleStatus.published.name,
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<String> saveDraft(Article article) async {
    try {
      if (article.id.isEmpty) {
        return createArticle(
          article.copyWith(
            status: ArticleStatus.draft,
          ),
        );
      }

      final model = ArticleModel.fromEntity(
        article.copyWith(
          status: ArticleStatus.draft,
        ),
      );

      await _articles.doc(article.id).update(
            model.toUpdateMap(),
          );

      return article.id;
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      await _articles.doc(id).delete();
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  Future<ArticlePage> _paginate({
    required Query<Map<String, dynamic>> query,
    required ArticlePageCursor? cursor,
    required int limit,
  }) async {
    var pageQuery = query.limit(limit + 1);

    if (cursor != null) {
      final cursorSnap = await _articles.doc(cursor.documentId).get();

      if (cursorSnap.exists) {
        pageQuery = pageQuery.startAfterDocument(cursorSnap);
      }
    }

    final snapshot = await pageQuery.get();
    final docs = snapshot.docs;

    final hasMore = docs.length > limit;
    final pageDocs = hasMore ? docs.sublist(0, limit) : docs;

    return ArticlePage(
      items: pageDocs.map(ArticleModel.fromFirestore).toList(),
      nextCursor:
          hasMore ? ArticlePageCursor(pageDocs.last.id) : null,
    );
  }
}

Exception _mapFirebaseException(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return PermissionDeniedException(
        error.message ?? 'Permission refusée',
      );
    case 'not-found':
      return NotFoundException(
        error.message ?? 'Document introuvable',
      );
    default:
      return ServerException(
        error.message ?? error.code,
      );
  }
}