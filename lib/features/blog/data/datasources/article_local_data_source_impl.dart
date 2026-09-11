import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';
import 'article_local_data_source.dart';

class HiveArticleLocalDataSource implements ArticleLocalDataSource {
  HiveArticleLocalDataSource(this._box);

  static const String boxName = 'articles_cache';

  final Box<Map> _box;

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    try {
      final entries = {
        for (final article in articles) article.id: _toMap(article),
      };
      await _box.putAll(entries);
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<List<ArticleModel>> getCachedArticles() async {
    try {
      final articles = _box.values
          .map((raw) => _fromMap(Map<String, dynamic>.from(raw)))
          .toList();
      articles.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return articles;
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> cacheArticle(ArticleModel article) async {
    try {
      await _box.put(article.id, _toMap(article));
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<ArticleModel?> getCachedArticle(String id) async {
    try {
      final raw = _box.get(id);
      if (raw == null) return null;
      return _fromMap(Map<String, dynamic>.from(raw));
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _box.clear();
    } catch (error) {
      throw CacheException(error.toString());
    }
  }

  Map<String, dynamic> _toMap(ArticleModel article) {
    return {
      'id': article.id,
      'title': article.title,
      'content': article.content,
      'authorId': article.authorId,
      'authorName': article.authorName,
      'status': article.status.name,
      'createdAt': article.createdAt,
      'updatedAt': article.updatedAt,
      'publishedAt': article.publishedAt,
    };
  }

  ArticleModel _fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      authorId: map['authorId'] as String,
      authorName: map['authorName'] as String,
      status: ArticleStatus.fromName(map['status'] as String),
      createdAt: map['createdAt'] as DateTime,
      updatedAt: map['updatedAt'] as DateTime,
      publishedAt: map['publishedAt'] as DateTime?,
    );
  }
}
