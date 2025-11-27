// student_login_page.dart

import 'package:ace/features/auth/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/auth/presentation/login/login_notifier.dart';
import 'package:ace/features/auth/presentation/login/login_state.dart';
import 'package:ace/features/auth/presentation/registration/registration_page.dart';

// 1. Changed from StatefulWidget to ConsumerWidget
class StudentLoginPage extends ConsumerWidget {
  const StudentLoginPage({super.key});

  // Helper method for the TextField structure
  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String initialValue = '',
    Widget? suffixIcon,
    bool isPassword = false,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: obscureText,
        // Use keyboardType appropriate for text/password
        keyboardType:
            isPassword ? TextInputType.visiblePassword : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColorPalette.accentBlack),
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 12, color: ColorPalette.accentBlack),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          prefixIcon: Icon(icon, color: ColorPalette.accentBlack),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. WATCH the state, passing the UserType to get the correct Notifier instance
    final state = ref.watch(loginNotifierProvider(userType: UserType.student));

    // 3. READ the notifier for calling methods
    final notifier =
        ref.read(loginNotifierProvider(userType: UserType.student).notifier);

    // Function to handle the login and navigation
    void handleLogin() async {
      bool success = await notifier.login();
      if (success && context.mounted) {
        // Since login logic handles Hive, just navigate on success
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const WrapperScreen(),
          ),
        );
      }
      // Error is handled by state.errorMessage, which rebuilds the UI automatically
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.accentBlack,
      body: Stack(
        children: [
          Center(
            child: Container(
              height: 410 +
                  (state.errorMessage.isNotEmpty
                      ? 20
                      : 0), // Adjust height for error message
              width: 360,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Student Login',
                      style: TextStyle(
                        color: ColorPalette.accentBlack,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lato',
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),

                    // Display Error Message
                    if (state.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          state.errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Student Number Field
                    _buildTextField(
                      context,
                      label: 'Student Number',
                      hint: 'Enter your student number',
                      icon: Icons.person,
                      initialValue: state.studentId,
                      onChanged:
                          notifier.setStudentId, // Calls the notifier method
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _buildTextField(
                      context,
                      label: 'Password',
                      hint: 'Enter your Password',
                      icon: Icons.key,
                      initialValue: state.password,
                      onChanged:
                          notifier.setPassword, // Calls the notifier method
                      isPassword: true,
                      obscureText: !state.isPasswordVisible, // Reads state
                      suffixIcon: IconButton(
                        color: ColorPalette.accentBlack,
                        icon: state.isPasswordVisible
                            ? const Icon(Icons.visibility_off) // Reads state
                            : const Icon(Icons.visibility),
                        onPressed: notifier
                            .togglePasswordVisibility, // Calls the notifier method
                      ),
                    ),

                    const SizedBox(height: 35),

                    // LOGIN Button
                    Container(
                      padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.symmetric(horizontal: 55),
                      width: 355,
                      height: 50,
                      child: ElevatedButton(
                        // Disable button while loading
                        onPressed: state.isLoading ? null : handleLogin,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            ColorPalette.accentBlack,
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        child: state
                                .isLoading // Shows CircularProgressIndicator when loading
                            ? const CircularProgressIndicator(
                                color: ColorPalette.secondary,
                                strokeWidth: 3,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: ColorPalette.secondary,
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
