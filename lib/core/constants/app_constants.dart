class AppConstants {
  const AppConstants._();

  static const String appName = 'MiniBlog';

  static const String usersCollection = 'users';
  static const String articlesCollection = 'articles';

  static const String commentsCollection = 'comments';
  static const int articlePageSize = 20;
  static const int commentPageSize = 20;
  static const int commentContentMaxLength = 2000;
  static const int articleTitleMaxLength = 200;
  static const int articleContentMaxLength = 100000;
  static const int authorNameMaxLength = 80;
}
