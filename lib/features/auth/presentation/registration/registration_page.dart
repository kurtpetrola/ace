// lib/features/auth/registration/registration_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/core/constants/app_strings.dart';
import 'package:ace/features/auth/widgets/selection_page.dart';
import 'package:ace/features/auth/presentation/registration/registration_state.dart';

// Converted to ConsumerStatefulWidget for lifecycle management (initState)
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  @override
  void initState() {
    super.initState();

    // FIX: Defer state reset to after the current build frame is complete.
    // This prevents the 'setState or markNeedsBuild' error by ensuring the
    // state change (and subsequent rebuild) happens outside of the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationNotifierProvider.notifier).resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the state for UI updates
    final state = ref.watch(registrationNotifierProvider);
    // 2. Read the notifier for calling methods/actions
    final notifier = ref.read(registrationNotifierProvider.notifier);

    final theme = Theme.of(context);

    // Define the async registration handler
    Future<void> handleRegister() async {
      // Calling register will internally run validation, update the error states,
      // and only proceed with registration if valid.
      final success = await notifier.register();
      if (success && context.mounted) {
        // Navigate on success
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const SelectionPage(),
        ));
      } else if (!success && context.mounted) {
        // If registration fails (either due to invalid form or a global error like 'email in use'),
        // the state errors will be updated by the notifier, triggering a UI rebuild
        // to show the inline field errors.
        if (state.globalErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.globalErrorMessage!, // Use globalErrorMessage
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 360,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(30),
              ),
              color: theme.cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  AceStrings.registrationTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // --- Text Fields connect directly to the notifier and show errors ---
                _buildTextField(
                  context,
                  initialValue: state.fullName,
                  labelText: AceStrings.fullNameLabel,
                  hintText: AceStrings.fullNameHint,
                  icon: Icons.person,
                  onChanged: notifier.setFullName,
                  errorText: state.fullNameError, // Pass error state
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  context,
                  initialValue: state.studentId,
                  labelText: AceStrings.studentIdLabel,
                  hintText: AceStrings.studentIdHint,
                  icon: Icons.assignment_ind_rounded,
                  onChanged: notifier.setStudentId,
                  errorText: state.studentIdError, // Pass error state
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  context,
                  initialValue: state.email,
                  labelText: AceStrings.emailLabel,
                  hintText: AceStrings.emailHint,
                  icon: Icons.email,
                  onChanged: notifier.setEmail,
                  errorText: state.emailError, // Pass error state
                ),
                const SizedBox(height: 10),
                _buildPasswordTextField(
                  context,
                  state: state,
                  onChanged: notifier.setPassword,
                  onToggleVisibility: notifier.togglePasswordVisibility,
                  errorText: state.passwordError, // Pass error state
                ),
                const SizedBox(height: 10),
                // --- Dropdowns connect directly to the notifier and show errors ---
                _buildDropdownField(
                  context,
                  hint: AceStrings.genderHint,
                  value: state.gender,
                  items: AceStrings.sex,
                  onChanged: notifier.setGender,
                  errorText: state.genderError, // Pass error state
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  context,
                  hint: AceStrings.ageHint,
                  value: state.age,
                  items: AceStrings.ages,
                  onChanged: notifier.setAge,
                  errorText: state.ageError, // Pass error state
                ),
                const SizedBox(height: 10),
                _buildDropdownField(
                  context,
                  hint: AceStrings.deptHint,
                  value: state.department,
                  items: AceStrings.dept,
                  onChanged: notifier.setDepartment,
                  errorText: state.departmentError, // Pass error state
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 270,
                  height: 50,
                  child: ElevatedButton(
                    // Enable button unless loading.
                    // This allows the user to click the button and trigger the full validation
                    // process inside handleRegister, which updates the error states.
                    onPressed: !state.isLoading ? handleRegister : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                        ColorPalette.primary, // Primary Red
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
                              AceStrings.register,
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

  // --- Widget Builders (Updated for consistent padding and error display) ---

  Widget _buildTextField(
    context, {
    required String initialValue,
    required String labelText,
    required String hintText,
    required IconData icon,
    required void Function(String) onChanged,
    String? errorText, // optional error text
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          errorText: errorText, // Display error text inline
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(color: textColor),
          hintStyle: TextStyle(
              fontSize: 12,
              color:
                  isDarkMode ? ColorPalette.lightGray : ColorPalette.darkGrey),
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
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
    context, {
    required RegistrationState state,
    required void Function(String) onChanged,
    required VoidCallback onToggleVisibility,
    String? errorText, // optional error text
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        initialValue: state.password,
        onChanged: onChanged,
        obscureText: !state.isPasswordVisible, // Use state from Riverpod
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          errorText: errorText, // Display error text inline
          labelText: AceStrings.passwordLabel,
          labelStyle: TextStyle(fontSize: 16, color: textColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textColor),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          hintText: AceStrings.passwordStrongHint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          prefixIcon: Icon(Icons.key, color: textColor),
          suffixIcon: IconButton(
            color: textColor,
            icon: state.isPasswordVisible
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: onToggleVisibility, // Call the callback function
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    context, {
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? errorText, // optional error text
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    // We use Padding outside for consistent horizontal spacing
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: DropdownButtonFormField<String>(
        dropdownColor: Theme.of(context).cardTheme.color,
        hint: Text(
          hint,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Lato',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        initialValue: value,
        isExpanded: true,
        iconSize: 32,
        icon: const Icon(Icons.arrow_drop_down, color: ColorPalette.secondary),
        items: items.map((item) => _buildMenuItem(context, item)).toList(),
        onChanged: onChanged,
        // Use InputDecoration to define the look and handle the errorText
        decoration: InputDecoration(
          errorText: errorText, // Display error text
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          filled: true,
          fillColor: ColorPalette.hintColor,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          // Normal/Enabled Border
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          // Focused Border
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          // Error Border
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(20.0),
          ),
          // Focused Error Border
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildMenuItem(BuildContext context, String item) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: TextStyle(
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: textColor,
        ),
      ),
    );
  }
}
