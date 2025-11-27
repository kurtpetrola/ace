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
  }) = _LoginState;

  // Custom getter for form validation
  bool get isValidForm => studentId.isNotEmpty && password.isNotEmpty;
}
