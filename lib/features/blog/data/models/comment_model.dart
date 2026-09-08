import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.articleId,
    required super.authorId,
    required super.authorName,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      articleId: comment.articleId,
      authorId: comment.authorId,
      authorName: comment.authorName,
      content: comment.content,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
    );
  }

  factory CommentModel.fromFirestore({
    required String articleId,
    required DocumentSnapshot doc,
  }) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Document comment ${doc.id} sans données');
    }

    return CommentModel(
      id: doc.id,
      articleId: articleId,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'content': content,
      'authorName': authorName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
