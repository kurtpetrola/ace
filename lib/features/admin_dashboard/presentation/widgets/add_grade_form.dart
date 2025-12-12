// lib/features/admin_dashboard/presentation/widgets/add_grade_form.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/services/grade_service.dart';
import 'package:flutter/services.dart';

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AddGradeForm extends StatefulWidget {
  // The student ID must be passed to this form after the admin searches for them.
  final String studentId;

  const AddGradeForm({super.key, required this.studentId});

  @override
  State<AddGradeForm> createState() => _AddGradeFormState();
}

class _AddGradeFormState extends State<AddGradeForm> {
  final _formKey = GlobalKey<FormState>();
  final GradeService _gradeService = GradeService();

  String? _subjectCode;
  String? _selectedGradeType;
  final TextEditingController _scoreController = TextEditingController();

  bool _isLoading = false;

  final List<String> gradeTypes = ['Prelim', 'Midterm', 'Final'];

  // --- Submission Logic ---
  Future<void> _submitGrade() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        // Call the user's existing GradeService method
        await _gradeService.updateStudentGrade(
          studentId: widget.studentId,
          subjectCode: _subjectCode!,
          gradeType: _selectedGradeType!,
          gradeValue: _scoreController.text,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Grade saved successfully!"),
            backgroundColor: ColorPalette.secondary,
          ),
        );

        // Clear the form fields after successful submission
        _formKey.currentState!.reset();
        _scoreController.clear();
        setState(() {
          _selectedGradeType = null;
          _subjectCode = null;
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save grade: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      // Use theme card color
      color: theme.cardTheme.color,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorPalette.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_task,
                        color: ColorPalette.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Grade',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Student ID: ${widget.studentId}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),

              // Subject Code Input
              TextFormField(
                decoration: _inputDecoration(context, 'Subject Code',
                    'e.g., ITE 115', Icons.auto_stories),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter the subject code'
                    : null,
                onSaved: (value) => _subjectCode = value!.toUpperCase().trim(),
                keyboardType: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.singleLineFormatter,
                  _UpperCaseTextFormatter(),
                ],
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Grade Type Dropdown
              DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                    context, 'Grade Type', 'Select Period', Icons.grade),
                value: _selectedGradeType,
                hint: Text('Choose Period',
                    style: TextStyle(color: theme.hintColor)),
                items: gradeTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: theme.textTheme.bodyLarge),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGradeType = value),
                validator: (value) =>
                    value == null ? 'Please select a grade type' : null,
                dropdownColor: theme.cardTheme.color,
                icon: const Icon(Icons.arrow_drop_down_circle,
                    color: ColorPalette.primary),
              ),
              const SizedBox(height: 20),

              // Score Input
              TextFormField(
                controller: _scoreController,
                decoration:
                    _inputDecoration(context, 'Score', '0-100', Icons.numbers),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a score';
                  if (double.tryParse(value) == null) {
                    return 'Score must be a number';
                  }
                  return null;
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitGrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.secondary,
                    foregroundColor: ColorPalette.accentBlack,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.save_rounded, size: 22),
                  label: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: ColorPalette.accentBlack,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save Grade',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for polished input decoration
  InputDecoration _inputDecoration(
      BuildContext context, String label, String hint, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: ColorPalette.primary.withOpacity(0.7)),
      labelStyle: TextStyle(
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.6)),
      filled: true,
      // Use a slightly different color for input background based on theme
      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Make border darker and more visible in light mode
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade600,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
