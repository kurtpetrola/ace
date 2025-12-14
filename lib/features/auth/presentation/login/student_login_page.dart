// lib/features/auth/presentation/login/student_login_page.dart

import 'package:ace/features/auth/wrapper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/constants/app_strings.dart';
import 'package:ace/features/auth/presentation/login/login_notifier.dart';
import 'package:ace/features/auth/presentation/login/login_state.dart';
import 'package:ace/features/auth/presentation/registration/registration_page.dart';

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
    String? errorText,
    Widget? suffixIcon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType ??
            (isPassword ? TextInputType.visiblePassword : TextInputType.text),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          hintText: hint,
          hintStyle: TextStyle(
              fontSize: 12,
              color:
                  isDarkMode ? ColorPalette.lightGray : ColorPalette.darkGrey),
          errorText: errorText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textColor),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          prefixIcon: Icon(icon, color: textColor),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH the state, passing the UserType to get the correct Notifier instance
    final state = ref.watch(loginNotifierProvider(userType: UserType.student));

    // READ the notifier for calling methods
    final notifier =
        ref.read(loginNotifierProvider(userType: UserType.student).notifier);

    final theme = Theme.of(context);

    // Function to handle the login and navigation
    void handleLogin() async {
      // The notifier now handles local validation before calling the service
      bool success = await notifier.login();
      if (success && context.mounted) {
        // Since login logic handles Hive, just navigate on success
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const WrapperScreen(),
          ),
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: ColorPalette.accentBlack, // Removed to use theme
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 360,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  color: theme.cardTheme.color, // Adaptive card color
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        AceStrings.studentLogin,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
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
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Email Field
                      _buildTextField(
                        context,
                        label: AceStrings.emailLabel,
                        hint: AceStrings.emailHint,
                        icon: Icons.email,
                        initialValue: state.email,
                        onChanged: notifier.setEmail,
                        errorText: state.emailError,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      _buildTextField(
                        context,
                        label: AceStrings.passwordLabel,
                        hint: AceStrings.passwordHint,
                        icon: Icons.key,
                        initialValue: state.password,
                        onChanged: notifier.setPassword,
                        errorText: state.passwordError, // <-- PASSING NEW ERROR
                        isPassword: true,
                        obscureText: !state.isPasswordVisible,
                        suffixIcon: IconButton(
                          color: theme.colorScheme.onSurface,
                          icon: state.isPasswordVisible
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                          onPressed: notifier.togglePasswordVisibility,
                        ),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25.0),
                          child: TextButton(
                            onPressed: () async {
                              bool success = await notifier.forgotPassword();
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Password reset link sent! Check your email.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color:
                                    theme.colorScheme.primary, // Adaptive color
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

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
                              ColorPalette.primary,
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
                              : Text(
                                  AceStrings.login.toUpperCase(),
                                  style: const TextStyle(
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
                          Text(
                            AceStrings.dontHaveAccount,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 12,
                            ),
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
                              AceStrings.signUp,
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
          ),
        ],
      ),
    );
  }
}
