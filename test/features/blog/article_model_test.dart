import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/features/blog/data/models/article_model.dart';
import 'package:mini_blog_app/features/blog/domain/entities/article.dart';

void main() {
  final now = DateTime.utc(2026, 9, 8, 10);

  ArticleModel buildModel({
    ArticleStatus status = ArticleStatus.draft,
    DateTime? publishedAt,
  }) {
    return ArticleModel(
      id: 'art-1',
      title: 'Titre',
      content: 'Contenu',
      authorId: 'uid-1',
      authorName: 'Ada',
      status: status,
      createdAt: now,
      updatedAt: now,
      publishedAt: publishedAt,
    );
  }

  test('toCreateMap pose des serverTimestamp et un status draft', () {
    final map = buildModel().toCreateMap();

    expect(map['title'], 'Titre');
    expect(map['authorId'], 'uid-1');
    expect(map['status'], 'draft');
    expect(map['createdAt'], isA<FieldValue>());
    expect(map['updatedAt'], isA<FieldValue>());
    expect(map['publishedAt'], isNull);
    expect(map.containsKey('id'), isFalse);
  });

  test('toCreateMap d\'un publié pose publishedAt serveur', () {
    final map = buildModel(status: ArticleStatus.published).toCreateMap();

    expect(map['status'], 'published');
    expect(map['publishedAt'], isA<FieldValue>());
  });

  test('toUpdateMap n\'envoie ni authorId ni createdAt', () {
    final map = buildModel().toUpdateMap();

    expect(map.containsKey('authorId'), isFalse);
    expect(map.containsKey('createdAt'), isFalse);
    expect(map['updatedAt'], isA<FieldValue>());
  });

  test('fromFirestore convertit Timestamp vers DateTime', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('articles').doc('art-1').set({
      'title': 'Titre',
      'content': 'Contenu',
      'authorId': 'uid-1',
      'authorName': 'Ada',
      'status': 'published',
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'publishedAt': Timestamp.fromDate(now),
    });

    final snap = await firestore.collection('articles').doc('art-1').get();
    final article = ArticleModel.fromFirestore(snap);

    expect(article.id, 'art-1');
    expect(article.status, ArticleStatus.published);
    expect(article.createdAt.isAtSameMomentAs(now), isTrue);
    expect(article.publishedAt!.isAtSameMomentAs(now), isTrue);
  });
}
