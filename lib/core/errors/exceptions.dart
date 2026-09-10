class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message);

  final String message;
}

class NotFoundException implements Exception {
  const NotFoundException(this.message);

  final String message;
}
