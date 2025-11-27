// lib/features/auth/registration/registration_state.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/features/auth/services/student_registration_service.dart';
import 'package:ace/models/user.dart';

// --- NEW PROVIDER FOR THE SERVICE ---
// We need a provider for the service so the Notifier can access it.
final studentRegistrationServiceProvider = Provider((ref) {
  return StudentRegistrationService();
});
// ------------------------------------

// 1. State Data Model
class RegistrationState {
  final String fullName;
  final String studentId;
  final String email;
  final String password;
  final String? gender;
  final String? age;
  final String? department;
  final bool isPasswordVisible;
  final bool isLoading;
  // Global error message (used for registration failure like email already in use)
  final String? globalErrorMessage;

  // Field-specific error messages (NEW)
  final String? fullNameError;
  final String? studentIdError;
  final String? emailError;
  final String? passwordError;
  final String? genderError;
  final String? ageError;
  final String? departmentError;

  RegistrationState({
    this.fullName = '',
    this.studentId = '',
    this.email = '',
    this.password = '',
    this.gender,
    this.age,
    this.department,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.globalErrorMessage,
    this.fullNameError,
    this.studentIdError,
    this.emailError,
    this.passwordError,
    this.genderError,
    this.ageError,
    this.departmentError,
  });

  // Helper to create a copy of the state, updating specific fields
  RegistrationState copyWith({
    String? fullName,
    String? studentId,
    String? email,
    String? password,
    String? gender,
    String? age,
    String? department,
    bool? isPasswordVisible,
    bool? isLoading,
    String? globalErrorMessage,
    // Use Object? and const Object() trick to allow setting nullable fields to null
    Object? fullNameError = const Object(),
    Object? studentIdError = const Object(),
    Object? emailError = const Object(),
    Object? passwordError = const Object(),
    Object? genderError = const Object(),
    Object? ageError = const Object(),
    Object? departmentError = const Object(),
  }) {
    // Helper function to safely resolve nullable copyWith arguments
    T? resolveNullable<T>(Object? arg, T? currentValue) {
      if (arg == const Object()) return currentValue;
      return arg as T?;
    }

    return RegistrationState(
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      department: department ?? this.department,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      globalErrorMessage: globalErrorMessage,
      // Resolve nullable errors
      fullNameError: resolveNullable(fullNameError, this.fullNameError),
      studentIdError: resolveNullable(studentIdError, this.studentIdError),
      emailError: resolveNullable(emailError, this.emailError),
      passwordError: resolveNullable(passwordError, this.passwordError),
      genderError: resolveNullable(genderError, this.genderError),
      ageError: resolveNullable(ageError, this.ageError),
      departmentError: resolveNullable(departmentError, this.departmentError),
    );
  }

  // Derived property for form validation logic
  bool get isValidForm {
    // 1. Check if all required fields are filled (basic check)
    final fieldsFilled = fullName.isNotEmpty &&
        studentId.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        gender != null &&
        age != null &&
        department != null;

    // 2. Check if there are any current field errors
    final hasFieldErrors = fullNameError != null ||
        studentIdError != null ||
        emailError != null ||
        passwordError != null ||
        genderError != null ||
        ageError != null ||
        departmentError != null;

    // The form is valid only if all fields are filled AND there are no active validation errors.
    return fieldsFilled && !hasFieldErrors;
  }

  // Helper to check for any active field errors
  bool get hasAnyFieldErrors =>
      fullNameError != null ||
      studentIdError != null ||
      emailError != null ||
      passwordError != null ||
      genderError != null ||
      ageError != null ||
      departmentError != null;
}

// 2. State Notifier (The business logic/controller)
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final StudentRegistrationService _registrationService;

  // Constructor now accepts the service
  RegistrationNotifier(this._registrationService) : super(RegistrationState());

  // --- Utility Validation Methods ---

  String? _validateFullName(String name) {
    if (name.isEmpty) return 'Full Name is required.';
    if (name.length < 3) return 'Full Name must be at least 3 characters.';
    return null;
  }

  String? _validateStudentId(String id) {
    if (id.isEmpty) return 'Student ID is required.';
    if (id.length < 5)
      return 'Student ID must be at least 5 digits/characters.';
    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required.';
    // Simple regex check for email format
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return 'Password is required.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    // Example rule: require one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one capital letter.';
    }
    return null;
  }

  String? _validateDropdown<T>(T? value, String fieldName) {
    if (value == null) return '$fieldName is required.';
    return null;
  }

  // --- Field Setters with Instant Validation ---

  void setFullName(String name) {
    final error = _validateFullName(name);
    state = state.copyWith(
      fullName: name,
      fullNameError: error,
      globalErrorMessage: null, // Clear global error on any field change
    );
  }

  void setStudentId(String id) {
    final error = _validateStudentId(id);
    state = state.copyWith(
      studentId: id,
      studentIdError: error,
      globalErrorMessage: null,
    );
  }

  void setEmail(String email) {
    final error = _validateEmail(email);
    state = state.copyWith(
      email: email,
      emailError: error,
      globalErrorMessage: null,
    );
  }

  void setPassword(String password) {
    final error = _validatePassword(password);
    state = state.copyWith(
      password: password,
      passwordError: error,
      globalErrorMessage: null,
    );
  }

  void setGender(String? gender) {
    final error = _validateDropdown(gender, 'Gender');
    state = state.copyWith(
      gender: gender,
      genderError: error,
      globalErrorMessage: null,
    );
  }

  void setAge(String? age) {
    final error = _validateDropdown(age, 'Age');
    state = state.copyWith(
      age: age,
      ageError: error,
      globalErrorMessage: null,
    );
  }

  void setDepartment(String? department) {
    final error = _validateDropdown(department, 'Department');
    state = state.copyWith(
      department: department,
      departmentError: error,
      globalErrorMessage: null,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // --- Full Form Validation before Registration ---
  bool _runFullFormValidation() {
    // Re-run validation for all fields, which updates the state with all errors
    // Since the setters also check for required fields, calling them here ensures
    // the error state is updated immediately before checking isValidForm.
    setFullName(state.fullName);
    setStudentId(state.studentId);
    setEmail(state.email);
    setPassword(state.password);
    setGender(state.gender);
    setAge(state.age);
    setDepartment(state.department);

    // After updating the state with all potential errors, check the derived property
    return state.isValidForm;
  }

  // 3. Registration Logic
  Future<bool> register() async {
    // 1. Run immediate validation check. This updates the state with inline errors.
    if (!_runFullFormValidation()) {
      return false;
    }

    // Clear previous global errors and start loading
    state = state.copyWith(isLoading: true, globalErrorMessage: null);

    final userProfile = User(
      userId: state.studentId,
      fullname: state.fullName,
      email: state.email,
      gender: state.gender!,
      age: state.age!,
      department: state.department!,
    );

    try {
      await _registrationService.register(
        user: userProfile,
        password: state.password,
      );

      state = state.copyWith(isLoading: false);
      return true; // Registration successful
    } catch (e) {
      // Handle service exceptions (e.g., 'Email already in use' from the service)
      final errorMsg = e.toString().contains('Exception:')
          ? e.toString().split('Exception: ')[1]
          : 'An unknown registration error occurred.';

      // Update state with the global error message
      state = state.copyWith(isLoading: false, globalErrorMessage: errorMsg);
      return false; // Registration failed
    }
  }

  // FIX: Implement the reset logic to clear the form
  void resetState() {
    state = RegistrationState();
  }
}

// 3. StateNotifier Provider (MODIFIED to inject the service)
final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  // Read the service provider
  final service = ref.watch(studentRegistrationServiceProvider);
  return RegistrationNotifier(service);
});
