class Comment {
  const Comment({
    required this.id,
    required this.articleId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String articleId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment copyWith({
    String? id,
    String? articleId,
    String? authorId,
    String? authorName,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommentPageCursor {
  const CommentPageCursor(this.documentId);

  final String documentId;
}

class CommentPage {
  const CommentPage({required this.items, this.nextCursor});

  final List<Comment> items;
  final CommentPageCursor? nextCursor;

  bool get hasMore => nextCursor != null;
}
