import 'package:mini_blog_app/core/errors/failures.dart';
import '../repositories/article_repository.dart';

class DeleteArticle {
  final ArticleRepository repository;

  DeleteArticle(this.repository);

  Future<Failure?> call(String id) async {
    return await repository.deleteArticle(id);
  }
}