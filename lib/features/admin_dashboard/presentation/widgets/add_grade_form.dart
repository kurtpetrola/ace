// lib/features/admin_dashboard/presentation/widgets/add_grade_form.dart

import 'package:flutter/material.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/services/grade_service.dart';

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

  final List<String> gradeTypes = ['P1', 'P2', 'P3', 'Final'];

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Grade for Student: ${widget.studentId}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorPalette.accentBlack,
              ),
            ),
            const SizedBox(height: 20),

            // Subject Code Input
            TextFormField(
              decoration: _inputDecoration('Subject Code (e.g., ITE 115)'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter subject code' : null,
              onSaved: (value) => _subjectCode = value!.toUpperCase().trim(),
              keyboardType: TextInputType.text,
              style: const TextStyle(color: ColorPalette.accentBlack),
            ),
            const SizedBox(height: 16),

            // Grade Type Dropdown
            DropdownButtonFormField<String>(
              decoration:
                  _inputDecoration('Select Grade Type (P1, Final, etc.)'),
              value: _selectedGradeType,
              hint: const Text('Grade Type',
                  style: TextStyle(color: ColorPalette.darkGrey)),
              items: gradeTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type,
                      style: const TextStyle(color: ColorPalette.accentBlack)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGradeType = value),
              validator: (value) =>
                  value == null ? 'Select a grade type' : null,
              dropdownColor: Colors.white,
            ),
            const SizedBox(height: 16),

            // Score Input
            TextFormField(
              controller: _scoreController,
              decoration: _inputDecoration('Score Value'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter a score';
                // Basic validation to ensure it's a number
                if (double.tryParse(value) == null)
                  return 'Score must be a number';
                return null;
              },
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: ColorPalette.accentBlack),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitGrade,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: ColorPalette.accentBlack,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Grade',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.accentBlack,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for consistent input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ColorPalette.darkGrey),
      filled: true,
      fillColor: ColorPalette.lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorPalette.primary, width: 2),
      ),
    );
  }
}
