import '../../../../core/errors/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(List<Article>?, Failure?)> getArticles() async {
    try {
      final articles = await remoteDataSource.getArticles();
      return (articles, null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<(Article?, Failure?)> getArticle(String id) async {
    try {
      final article = await remoteDataSource.getArticle(id);
      return (article, null);
    } catch (e) {
      return (null, ServerFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> createArticle(Article article) async {
    try {
      final articleModel = ArticleModel.fromEntity(article);
      await remoteDataSource.createArticle(articleModel);
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> updateArticle(Article article) async {
    try {
      final articleModel = ArticleModel.fromEntity(article);
      await remoteDataSource.updateArticle(articleModel);
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }

  @override
  Future<Failure?> deleteArticle(String id) async {
    try {
      await remoteDataSource.deleteArticle(id);
      return null;
    } catch (e) {
      return ServerFailure(e.toString());
    }
  }
}