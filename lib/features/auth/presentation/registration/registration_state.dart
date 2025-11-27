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
  final String? errorMessage;

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
    this.errorMessage,
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
    String? errorMessage,
  }) {
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
      errorMessage: errorMessage,
    );
  }

  // Derived property for form validation logic
  bool get isValidForm {
    return fullName.isNotEmpty &&
        studentId.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        gender != null &&
        age != null &&
        department != null;
  }
}

// 2. State Notifier (The business logic/controller)
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final StudentRegistrationService _registrationService;

  // Constructor now accepts the service
  RegistrationNotifier(this._registrationService) : super(RegistrationState());

  void setFullName(String name) =>
      state = state.copyWith(fullName: name, errorMessage: null);
  void setStudentId(String id) =>
      state = state.copyWith(studentId: id, errorMessage: null);
  void setEmail(String email) =>
      state = state.copyWith(email: email, errorMessage: null);
  void setPassword(String password) =>
      state = state.copyWith(password: password, errorMessage: null);
  void setGender(String? gender) =>
      state = state.copyWith(gender: gender, errorMessage: null);
  void setAge(String? age) =>
      state = state.copyWith(age: age, errorMessage: null);
  void setDepartment(String? department) =>
      state = state.copyWith(department: department, errorMessage: null);

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 3. Registration Logic (NOW SECURE)
  Future<bool> register() async {
    if (!state.isValidForm) return false;

    // Clear previous errors and start loading
    state = state.copyWith(isLoading: true, errorMessage: null);

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

      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      return false; // Registration failed
    }
  }
}

// 3. StateNotifier Provider (MODIFIED to inject the service)
final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  // Read the service provider
  final service = ref.watch(studentRegistrationServiceProvider);
  return RegistrationNotifier(service);
});
