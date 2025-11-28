// login_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

enum UserType { student, admin }

@freezed
class LoginState with _$LoginState {
  // Required private constructor for custom getters/methods
  const LoginState._();

  // Factory constructor defines the immutable state fields
  const factory LoginState({
    @Default('') String studentId,
    @Default('') String password,
    @Default(false) bool isLoading,
    @Default(false) bool isPasswordVisible,
    @Default('') String errorMessage,
    required UserType userType,
    // --- ADDED Validation Error Fields ---
    String? studentIdError,
    String? passwordError,
    // ------------------------------------
  }) = _LoginState;

  // Custom getter for form validation is now focused on basic presence
  // Detailed validation is now handled in the Notifier's `validateForm` method.
  bool get isReadyToValidate => studentId.isNotEmpty && password.isNotEmpty;
}
