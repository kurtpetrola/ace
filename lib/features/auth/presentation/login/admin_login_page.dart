// lib/features/auth/presentation/login/admin_login_page.dart

import 'package:ace/features/auth/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/features/auth/presentation/login/login_notifier.dart';
import 'package:ace/features/auth/presentation/login/login_state.dart';

class AdminLoginPage extends ConsumerWidget {
  const AdminLoginPage({super.key});

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String initialValue = '',
    String? errorText, // Parameter for specific field error
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
        keyboardType:
            isPassword ? TextInputType.visiblePassword : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: ColorPalette.accentBlack),
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 12, color: ColorPalette.accentBlack),
          errorText: errorText, // Display the field-specific error
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
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
    // 1. WATCH the state, passing UserType.admin!
    final state = ref.watch(loginNotifierProvider(userType: UserType.admin));

    // 2. READ the notifier
    final notifier =
        ref.read(loginNotifierProvider(userType: UserType.admin).notifier);

    void handleLogin() async {
      bool success = await notifier.login();
      if (success && context.mounted) {
        // Navigate to the WrapperScreen on success
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const WrapperScreen(),
          ),
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.accentBlack,
      body: Stack(
        children: [
          Center(
            child: Container(
              height: 410 + (state.errorMessage.isNotEmpty ? 20 : 0),
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
                      'Admin Login',
                      style: TextStyle(
                        color: ColorPalette.accentBlack,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Lato',
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),

                    // Display Generic Service Error Message
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

                    // Admin ID Field
                    _buildTextField(
                      context,
                      label: 'Admin ID',
                      hint: 'Enter your Admin ID',
                      icon: Icons.security,
                      initialValue: state.studentId,
                      onChanged: notifier.setStudentId,
                      errorText: state.studentIdError,
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    _buildTextField(
                      context,
                      label: 'Password',
                      hint: 'Enter your Password',
                      icon: Icons.key,
                      initialValue: state.password,
                      onChanged: notifier.setPassword,
                      errorText: state.passwordError,
                      isPassword: true,
                      obscureText: !state.isPasswordVisible,
                      suffixIcon: IconButton(
                        color: ColorPalette.accentBlack,
                        icon: state.isPasswordVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: notifier.togglePasswordVisibility,
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
                        child: state.isLoading
                            ? const CircularProgressIndicator(
                                color: ColorPalette.secondary,
                                strokeWidth: 3,
                              )
                            : const Text(
                                "ADMIN LOGIN",
                                style: TextStyle(
                                  color: ColorPalette.secondary,
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
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
