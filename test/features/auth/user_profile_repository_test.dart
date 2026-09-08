import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mini_blog_app/core/errors/failures.dart';
import 'package:mini_blog_app/features/auth/data/datasources/user_profile_remote_data_source.dart';
import 'package:mini_blog_app/features/auth/data/repositories/user_profile_repository_impl.dart';

void main() {
  test('upsert puis lecture du profil', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = UserProfileRepositoryImpl(
      UserProfileRemoteDataSourceImpl(firestore: firestore),
    );

    final writeFailure = await repo.upsertProfile(
      uid: 'uid-1',
      displayName: 'Ada',
      photoUrl: null,
    );
    expect(writeFailure, isNull);

    final (profile, readFailure) = await repo.getProfile('uid-1');
    expect(readFailure, isNull);
    expect(profile!.uid, 'uid-1');
    expect(profile.displayName, 'Ada');
  });

  test('profil absent → NotFoundFailure', () async {
    final repo = UserProfileRepositoryImpl(
      UserProfileRemoteDataSourceImpl(firestore: FakeFirebaseFirestore()),
    );

    final (profile, failure) = await repo.getProfile('missing');
    expect(profile, isNull);
    expect(failure, isA<NotFoundFailure>());
  });
}
