import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/features/blog/data/datasources/comment_remote_data_source.dart';
import 'package:mini_blog_app/features/blog/data/repositories/comment_repository_impl.dart';
import 'package:mini_blog_app/features/blog/domain/entities/comment.dart';

void main() {
  test('crée et liste les commentaires d\'un article', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = CommentRepositoryImpl(
      CommentRemoteDataSourceImpl(firestore: firestore),
    );

    await firestore.collection('articles').doc('art-1').set({
      'title': 'Publié',
      'status': 'published',
    });

    final comment = Comment(
      id: '',
      articleId: 'art-1',
      authorId: 'uid-alice',
      authorName: 'Alice',
      content: 'Bravo',
      createdAt: DateTime.utc(2026, 9, 8),
      updatedAt: DateTime.utc(2026, 9, 8),
    );

    final (id, createFailure) = await repo.createComment(comment);
    expect(createFailure, isNull);
    expect(id, isNotEmpty);

    final (page, listFailure) = await repo.getComments(articleId: 'art-1');
    expect(listFailure, isNull);
    expect(page!.items, hasLength(1));
    expect(page.items.first.content, 'Bravo');
    expect(page.items.first.articleId, 'art-1');
  });

  test('deleteComment retire le document', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = CommentRepositoryImpl(
      CommentRemoteDataSourceImpl(firestore: firestore),
    );

    final (id, _) = await repo.createComment(
      Comment(
        id: '',
        articleId: 'art-1',
        authorId: 'uid-alice',
        authorName: 'Alice',
        content: 'À supprimer',
        createdAt: DateTime.utc(2026, 9, 8),
        updatedAt: DateTime.utc(2026, 9, 8),
      ),
    );

    final failure = await repo.deleteComment(
      articleId: 'art-1',
      commentId: id!,
    );
    expect(failure, isNull);

    final (page, _) = await repo.getComments(articleId: 'art-1');
    expect(page!.items, isEmpty);
  });
}
