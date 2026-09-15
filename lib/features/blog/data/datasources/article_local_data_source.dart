import '../models/article_model.dart';

abstract class ArticleLocalDataSource {
  Future<void> cacheArticles(List<ArticleModel> articles);

  Future<List<ArticleModel>> getCachedArticles();

  Future<void> cacheArticle(ArticleModel article);

  Future<ArticleModel?> getCachedArticle(String id);

  Future<void> clearCache();
}