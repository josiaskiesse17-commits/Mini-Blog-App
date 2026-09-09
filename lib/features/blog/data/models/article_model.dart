import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.authorName,
    required super.createdAt,
    super.updatedAt,
  });

  // Convertir un document Firebase (Map) en ArticleModel
  factory ArticleModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return ArticleModel(
      id: docId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convertir un ArticleModel en Map pour l'enregistrer dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      title: article.title,
      content: article.content,
      authorId: article.authorId,
      authorName: article.authorName,
      createdAt: article.createdAt,
      updatedAt: article.updatedAt,
    );
  }
}