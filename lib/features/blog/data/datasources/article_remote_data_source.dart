import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<ArticleModel> getArticle(String id);
  Future<void> createArticle(ArticleModel article);
  Future<void> updateArticle(ArticleModel article);
  Future<void> deleteArticle(String id);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final FirebaseFirestore firestore;

  ArticleRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ArticleModel>> getArticles() async {
    final querySnapshot = await firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ArticleModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<ArticleModel> getArticle(String id) async {
    final docSnapshot = await firestore.collection('articles').doc(id).get();

    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw Exception('Article introuvable');
    }

    return ArticleModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
  }

  @override
  Future<void> createArticle(ArticleModel article) async {
    // Si un ID existe déjà, on l'utilise comme clé de document, sinon Firestore en générera un
    if (article.id.isNotEmpty) {
      await firestore.collection('articles').doc(article.id).set(article.toMap());
    } else {
      await firestore.collection('articles').add(article.toMap());
    }
  }

  @override
  Future<void> updateArticle(ArticleModel article) async {
    await firestore
        .collection('articles')
        .doc(article.id)
        .update(article.toMap());
  }

  @override
  Future<void> deleteArticle(String id) async {
    await firestore.collection('articles').doc(id).delete();
  }
}