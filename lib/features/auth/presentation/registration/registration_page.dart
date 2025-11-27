// lib/features/auth/registration/registration_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/constants/app_strings.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/auth/presentation/registration/registration_state.dart';

// Convert to ConsumerWidget for Riverpod integration
class RegisterPage extends ConsumerWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the state for UI updates
    final state = ref.watch(registrationNotifierProvider);
    // 2. Read the notifier for calling methods/actions
    final notifier = ref.read(registrationNotifierProvider.notifier);

    // Define the async registration handler
    Future<void> handleRegister() async {
      final success = await notifier.register();
      if (success && context.mounted) {
        // Navigate on success
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const SelectionPage(),
        ));
      } else if (!success && context.mounted) {
        // Show the specific error message from the state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'Registration failed. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.accentBlack,
      body: Center(
        child: Container(
          height: 700,
          width: 360,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(30),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                const Icon(
                  Icons.assignment_ind_rounded,
                  color: ColorPalette.accentBlack,
                  size: 70,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // --- Text Fields connect directly to the notifier ---
                _buildTextField(
                  initialValue: state.fullName,
                  labelText: 'Full Name',
                  hintText: 'Enter your Full Name',
                  icon: Icons.person,
                  onChanged: notifier.setFullName,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  initialValue: state.studentId,
                  labelText: 'Student Number',
                  hintText: 'Enter your Student Number',
                  icon: Icons.assignment_ind_rounded,
                  onChanged: notifier.setStudentId,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  initialValue: state.email,
                  labelText: 'Email Address',
                  hintText: 'Enter your Email Address',
                  icon: Icons.email,
                  onChanged: notifier.setEmail,
                ),
                const SizedBox(height: 10),
                _buildPasswordTextField(
                  state: state,
                  onChanged: notifier.setPassword,
                  onToggleVisibility: notifier.togglePasswordVisibility,
                ),
                const SizedBox(height: 10),
                // --- Dropdowns connect directly to the notifier ---
                _buildDropdownField(
                  hint: 'Gender',
                  value: state.gender,
                  items: AceStrings.sex,
                  onChanged: notifier.setGender,
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  hint: 'Age',
                  value: state.age,
                  items: AceStrings.ages,
                  onChanged: notifier.setAge,
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  hint: 'Department',
                  value: state.department,
                  items: AceStrings.dept,
                  onChanged: notifier.setDepartment,
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 270,
                  height: 50,
                  child: ElevatedButton(
                    // Enable button only if form is valid AND not loading
                    onPressed: state.isValidForm && !state.isLoading
                        ? handleRegister
                        : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        Colors.black,
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    child: Center(
                      child: state.isLoading
                          ? const CircularProgressIndicator(
                              color: ColorPalette.secondary)
                          : const Text(
                              "REGISTER",
                              style: TextStyle(
                                color: ColorPalette.secondary,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Builders (Updated to take necessary parameters) ---

  Widget _buildTextField({
    required String initialValue,
    required String labelText,
    required String hintText,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        // Switched to TextFormField for better form handling
        initialValue: initialValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(color: ColorPalette.accentBlack),
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
        ),
      ),
    );
  }

  Widget _buildPasswordTextField({
    required RegistrationState state,
    required void Function(String) onChanged,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        initialValue: state.password,
        onChanged: onChanged,
        obscureText: !state.isPasswordVisible, // Use state from Riverpod
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle:
              const TextStyle(fontSize: 16, color: ColorPalette.accentBlack),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: ColorPalette.accentBlack),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
          hintText: 'Enter a strong password',
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: const Icon(Icons.key, color: ColorPalette.accentBlack),
          suffixIcon: IconButton(
            color: ColorPalette.accentBlack,
            icon: state.isPasswordVisible
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: onToggleVisibility, // Call the callback function
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: 300,
      height: 60,
      decoration: const BoxDecoration(
        color: ColorPalette.hintColor,
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: DropdownButtonFormField<String>(
        dropdownColor: ColorPalette.hintColor,
        hint: Text(
          hint,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        value: value,
        isExpanded: true,
        iconSize: 32,
        icon: const Icon(Icons.arrow_drop_down, color: ColorPalette.secondary),
        items: items.map(_buildMenuItem).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: ColorPalette.secondary,
          ),
        ),
      );
}
