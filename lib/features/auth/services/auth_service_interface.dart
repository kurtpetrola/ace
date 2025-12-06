abstract class AuthServiceInterface {
  /// Logs in the user using their unique ID and password.
  ///
  /// Throws an exception if login fails.
  Future<void> login({required String id, required String password});
}
