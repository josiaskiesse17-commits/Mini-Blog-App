import 'package:flutter/material.dart';

// Imports corrigés avec les bons chemins relatifs (../../ pour remonter à features/blog/)
import '../../domain/entities/article.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/create_article.dart';
import '../../domain/usecases/update_article.dart';
import '../../domain/usecases/delete_article.dart';

class ArticleProvider extends ChangeNotifier {
  final GetArticles getArticlesUseCase;
  final CreateArticle createArticleUseCase;
  final UpdateArticle updateArticleUseCase;
  final DeleteArticle deleteArticleUseCase;

  ArticleProvider({
    required this.getArticlesUseCase,
    required this.createArticleUseCase,
    required this.updateArticleUseCase,
    required this.deleteArticleUseCase,
  });

  bool isLoading = false;
  String? errorMessage;
  List<Article> articles = [];

  // Récupérer tous les articles
  Future<void> fetchArticles() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await getArticlesUseCase();
    
    
    final (fetchedArticles, failure) = result;

    if (failure != null) {
      errorMessage = failure.message; 
    } else if (fetchedArticles != null) {
      articles = fetchedArticles;
    }

    isLoading = false;
    notifyListeners();
  }

  // Créer un article
  Future<bool> createArticle(Article article) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final failure = await createArticleUseCase(article);

    isLoading = false;
    if (failure != null) {
      errorMessage = failure.message;
      notifyListeners();
      return false;
    }

    await fetchArticles();
    return true;
  }

  // Mettre à jour un article
  Future<bool> updateArticle(Article article) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final failure = await updateArticleUseCase(article);

    isLoading = false;
    if (failure != null) {
      errorMessage = failure.message;
      notifyListeners();
      return false;
    }

    await fetchArticles();
    return true;
  }

  // Supprimer un article
  Future<bool> deleteArticle(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final failure = await deleteArticleUseCase(id);

    isLoading = false;
    if (failure != null) {
      errorMessage = failure.message;
      notifyListeners();
      return false;
    }

    await fetchArticles();
    return true;
  }
}