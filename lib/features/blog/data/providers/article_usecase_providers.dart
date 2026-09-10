import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_article.dart';
import '../../domain/usecases/delete_article.dart';
import '../../domain/usecases/get_article.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/get_my_articles.dart';
import '../../domain/usecases/get_my_drafts.dart';
import '../../domain/usecases/publish_article.dart';
import '../../domain/usecases/save_draft.dart';
import '../../domain/usecases/update_article.dart';
import '../../domain/usecases/watch_article.dart';
import 'article_repository_provider.dart';

final getArticlesProvider = Provider<GetArticles>((ref) {
  return GetArticles(ref.watch(articleRepositoryProvider));
});

final getArticleProvider = Provider<GetArticle>((ref) {
  return GetArticle(ref.watch(articleRepositoryProvider));
});

final watchArticleProvider = Provider<WatchArticle>((ref) {
  return WatchArticle(ref.watch(articleRepositoryProvider));
});

final getMyArticlesProvider = Provider<GetMyArticles>((ref) {
  return GetMyArticles(ref.watch(articleRepositoryProvider));
});

final getMyDraftsProvider = Provider<GetMyDrafts>((ref) {
  return GetMyDrafts(ref.watch(articleRepositoryProvider));
});

final createArticleProvider = Provider<CreateArticle>((ref) {
  return CreateArticle(ref.watch(articleRepositoryProvider));
});

final saveDraftProvider = Provider<SaveDraft>((ref) {
  return SaveDraft(ref.watch(articleRepositoryProvider));
});

final updateArticleProvider = Provider<UpdateArticle>((ref) {
  return UpdateArticle(ref.watch(articleRepositoryProvider));
});

final publishArticleProvider = Provider<PublishArticle>((ref) {
  return PublishArticle(ref.watch(articleRepositoryProvider));
});

final deleteArticleProvider = Provider<DeleteArticle>((ref) {
  return DeleteArticle(ref.watch(articleRepositoryProvider));
});
