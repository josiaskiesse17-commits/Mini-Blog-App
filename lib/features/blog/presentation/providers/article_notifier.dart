import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/article.dart';
import '../../domain/usecases/create_article.dart';
import '../../domain/usecases/delete_article.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/update_article.dart';
import '../../data/providers/article_usecase_providers.dart';

class ArticleState {
  const ArticleState({
    this.articles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Article> articles;
  final bool isLoading;
  final String? errorMessage;

  ArticleState copyWith({
    List<Article>? articles,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ArticleState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ArticleNotifier extends Notifier<ArticleState> {
  late final GetArticles _getArticles;
  late final CreateArticle _createArticle;
  late final UpdateArticle _updateArticle;
  late final DeleteArticle _deleteArticle;

  @override
  ArticleState build() {
    _getArticles = ref.read(getArticlesProvider);
    _createArticle = ref.read(createArticleProvider);
    _updateArticle = ref.read(updateArticleProvider);
    _deleteArticle = ref.read(deleteArticleProvider);

    return const ArticleState();
  }

  Future<void> fetchArticles() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final (page, failure) = await _getArticles();

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
      return;
    }

    state = state.copyWith(
      articles: page?.items ?? const [],
      isLoading: false,
    );
  }

  Future<bool> createArticle(Article article) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final (articleId, failure) = await _createArticle(article);

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
      return false;
    }

    if (articleId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Impossible de créer l\'article.',
      );
      return false;
    }

    await fetchArticles();
    return true;
  }

  Future<bool> updateArticle(Article article) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final failure = await _updateArticle(article);

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
      return false;
    }

    await fetchArticles();
    return true;
  }

  Future<bool> deleteArticle(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    final failure = await _deleteArticle(id);

    if (failure != null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      );
      return false;
    }

    await fetchArticles();
    return true;
  }
}

final articleNotifierProvider =
    NotifierProvider<ArticleNotifier, ArticleState>(
  ArticleNotifier.new,
);