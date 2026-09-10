import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/create_comment.dart';
import '../../domain/usecases/delete_comment.dart';
import '../../domain/usecases/get_comments.dart';
import '../../domain/usecases/update_comment.dart';
import '../../domain/usecases/watch_comments.dart';
import 'comment_repository_provider.dart';

final getCommentsProvider = Provider<GetComments>((ref) {
  return GetComments(ref.watch(commentRepositoryProvider));
});

final watchCommentsProvider = Provider<WatchComments>((ref) {
  return WatchComments(ref.watch(commentRepositoryProvider));
});

final createCommentProvider = Provider<CreateComment>((ref) {
  return CreateComment(ref.watch(commentRepositoryProvider));
});

final updateCommentProvider = Provider<UpdateComment>((ref) {
  return UpdateComment(ref.watch(commentRepositoryProvider));
});

final deleteCommentProvider = Provider<DeleteComment>((ref) {
  return DeleteComment(ref.watch(commentRepositoryProvider));
});
