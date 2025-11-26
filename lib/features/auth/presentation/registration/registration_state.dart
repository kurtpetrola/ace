// registration_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

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
  RegistrationNotifier() : super(RegistrationState());

  void setFullName(String name) => state = state.copyWith(fullName: name);
  void setStudentId(String id) => state = state.copyWith(studentId: id);
  void setEmail(String email) => state = state.copyWith(email: email);
  void setPassword(String password) =>
      state = state.copyWith(password: password);
  void setGender(String? gender) => state = state.copyWith(gender: gender);
  void setAge(String? age) => state = state.copyWith(age: age);
  void setDepartment(String? department) =>
      state = state.copyWith(department: department);

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 3. Registration Logic (Moved from _RegisterPageState)
  Future<bool> register() async {
    if (!state.isValidForm) return false;

    state = state.copyWith(isLoading: true);

    // Simulating Firebase logic (Replace with your actual Firebase/Repository calls)
    try {
      // NOTE: You'll need to inject or use a Riverpod provider for FirebaseDatabase
      // to completely decouple this. For this example, we keep the original logic.
      final dbReference =
          FirebaseDatabase.instance.ref().child("Students/${state.studentId}/");

      await dbReference.set({
        "fullname": state.fullName,
        "studentid": state.studentId,
        "email": state.email,
        "password": state.password,
        "gender": state.gender,
        "age": state.age,
        "department": state.department,
      });

      state = state.copyWith(isLoading: false);
      return true; // Registration successful
    } catch (e) {
      // Handle error (e.g., logging, showing an error message)
      state = state.copyWith(isLoading: false);
      return false; // Registration failed
    }
  }
}

// 3. StateNotifier Provider
final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
});
