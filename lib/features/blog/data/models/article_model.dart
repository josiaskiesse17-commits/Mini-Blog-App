import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.publishedAt,
  });

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      content: article.content,
      authorId: article.authorId,
      authorName: article.authorName,
      status: article.status,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
      publishedAt: article.publishedAt,
    );
  }

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Document article ${doc.id} sans données');
    }

    return ArticleModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      status: ArticleStatus.fromName(
        data['status'] as String? ?? 'draft',
      ),
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
      publishedAt: _toDateOrNull(data['publishedAt']),
    );
  }

  /// Champs écrits à la création. Les timestamps sont posés côté serveur.
  Map<String, dynamic> toCreateMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'publishedAt': status == ArticleStatus.published
          ? FieldValue.serverTimestamp()
          : null,
    };
  }

  /// Champs mutables uniquement. Ne jamais envoyer [authorId] ni [createdAt].
  Map<String, dynamic> toUpdateMap({bool publishing = false}) {
    return {
      'title': title,
      'content': content,
      'authorName': authorName,
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      if (publishing) 'publishedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    // serverTimestamp pas encore résolu sur un snapshot local.
    return DateTime.fromMillisecondsSinceEpoch(
      0,
      isUtc: true,
    );
  }

  static DateTime? _toDateOrNull(dynamic value) {
    if (value == null) {
      return null;
    }

    return _toDate(value);
  }
}