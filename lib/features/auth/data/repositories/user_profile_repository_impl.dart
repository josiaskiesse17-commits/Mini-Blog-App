import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  const UserProfileRepositoryImpl(this._remoteDataSource);

  final UserProfileRemoteDataSource _remoteDataSource;

  @override
  Future<(UserProfile?, Failure?)> getProfile(String uid) async {
    try {
      return (await _remoteDataSource.getProfile(uid), null);
    } on PermissionDeniedException catch (error) {
      return (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      return (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      return (null, ServerFailure(error.message));
    } catch (error) {
      return (null, ServerFailure(error.toString()));
    }
  }

  @override
  Stream<(UserProfile?, Failure?)> watchProfile(String uid) async* {
    try {
      await for (final profile in _remoteDataSource.watchProfile(uid)) {
        yield (profile, null);
      }
    } on PermissionDeniedException catch (error) {
      yield (null, PermissionDeniedFailure(error.message));
    } on NotFoundException catch (error) {
      yield (null, NotFoundFailure(error.message));
    } on ServerException catch (error) {
      yield (null, ServerFailure(error.message));
    } catch (error) {
      yield (null, ServerFailure(error.toString()));
    }
  }

  @override
  Future<Failure?> upsertProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _remoteDataSource.upsertProfile(
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return null;
    } on PermissionDeniedException catch (error) {
      return PermissionDeniedFailure(error.message);
    } on NotFoundException catch (error) {
      return NotFoundFailure(error.message);
    } on ServerException catch (error) {
      return ServerFailure(error.message);
    } catch (error) {
      return ServerFailure(error.toString());
    }
  }
}
