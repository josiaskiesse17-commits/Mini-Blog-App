enum ArticleStatus {
  draft,
  published;

  static ArticleStatus fromName(String value) {
    return ArticleStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw FormatException('Statut d\'article invalide: $value'),
    );
  }
}

class Article {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final ArticleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  bool get isDraft => status == ArticleStatus.draft;
  bool get isPublished => status == ArticleStatus.published;

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    ArticleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    bool clearPublishedAt = false,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: clearPublishedAt ? null : (publishedAt ?? this.publishedAt),
    );
  }
}
