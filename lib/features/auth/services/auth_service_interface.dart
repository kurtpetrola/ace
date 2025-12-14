// lib/features/auth/services/auth_service_interface.dart

abstract class AuthServiceInterface {
  /// Logs in the user using their email and password.
  ///
  /// Throws an exception if login fails.
  Future<void> login({required String email, required String password});

  /// Sends a password reset email to the given [email].
  Future<void> sendPasswordResetEmail(String email);
}
