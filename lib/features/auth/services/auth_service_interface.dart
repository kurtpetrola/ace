abstract class AuthServiceInterface {
  /// Logs in the user using their email and password.
  ///
  /// Throws an exception if login fails.
  Future<void> login({required String email, required String password});
}
