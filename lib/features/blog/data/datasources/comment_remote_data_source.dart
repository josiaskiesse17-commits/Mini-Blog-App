import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/comment.dart';
import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<String> createComment(Comment comment);

  Future<CommentPage> getComments({
    required String articleId,
    CommentPageCursor? cursor,
    required int limit,
  });

  Stream<List<CommentModel>> watchComments(String articleId);

  Future<void> updateComment(Comment comment);

  Future<void> deleteComment({
    required String articleId,
    required String commentId,
  });
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  CommentRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _comments(String articleId) {
    return _firestore
        .collection(AppConstants.articlesCollection)
        .doc(articleId)
        .collection(AppConstants.commentsCollection);
  }

  @override
  Future<String> createComment(Comment comment) async {
    try {
      final col = _comments(comment.articleId);
      final doc = comment.id.isEmpty ? col.doc() : col.doc(comment.id);
      final authorName = comment.authorName.trim().isEmpty
          ? 'Utilisateur'
          : comment.authorName.trim();
      final model = CommentModel.fromEntity(
        comment.copyWith(id: doc.id, authorName: authorName),
      );
      await doc.set(model.toCreateMap());
      return doc.id;
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<CommentPage> getComments({
    required String articleId,
    CommentPageCursor? cursor,
    required int limit,
  }) async {
    try {
      final col = _comments(articleId);
      var query = col.orderBy('createdAt', descending: false).limit(limit + 1);

      if (cursor != null) {
        final cursorSnap = await col.doc(cursor.documentId).get();
        if (cursorSnap.exists) {
          query = query.startAfterDocument(cursorSnap);
        }
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final hasMore = docs.length > limit;
      final pageDocs = hasMore ? docs.sublist(0, limit) : docs;

      return CommentPage(
        items: pageDocs
            .map(
              (doc) =>
                  CommentModel.fromFirestore(articleId: articleId, doc: doc),
            )
            .toList(),
        nextCursor: hasMore ? CommentPageCursor(pageDocs.last.id) : null,
      );
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Stream<List<CommentModel>> watchComments(String articleId) {
    return _comments(articleId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CommentModel.fromFirestore(articleId: articleId, doc: doc),
              )
              .toList(),
        )
        .handleError((Object error, StackTrace _) {
          if (error is FirebaseException) {
            throw _mapFirebaseException(error);
          }
          throw error;
        });
  }

  @override
  Future<void> updateComment(Comment comment) async {
    try {
      final model = CommentModel.fromEntity(comment);
      await _comments(
        comment.articleId,
      ).doc(comment.id).update(model.toUpdateMap());
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }

  @override
  Future<void> deleteComment({
    required String articleId,
    required String commentId,
  }) async {
    try {
      await _comments(articleId).doc(commentId).delete();
    } on FirebaseException catch (error) {
      throw _mapFirebaseException(error);
    }
  }
}

Exception _mapFirebaseException(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return PermissionDeniedException(error.message ?? 'Permission refusée');
    case 'not-found':
      return NotFoundException(error.message ?? 'Document introuvable');
    default:
      return ServerException(error.message ?? error.code);
  }
}
