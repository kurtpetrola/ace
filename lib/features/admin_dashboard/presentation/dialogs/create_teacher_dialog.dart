// lib/features/admin_dashboard/presentation/dialogs/create_teacher_dialog.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ace/firebase_options.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/services/user_service.dart';

class CreateTeacherDialog extends StatefulWidget {
  final VoidCallback onTeacherCreated;

  const CreateTeacherDialog({super.key, required this.onTeacherCreated});

  @override
  State<CreateTeacherDialog> createState() => _CreateTeacherDialogState();
}

class _CreateTeacherDialogState extends State<CreateTeacherDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedGender = 'Female';
  final List<String> _genders = ['Male', 'Female', 'Other'];

  Future<void> _createTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FirebaseApp? secondaryApp;

    try {
      // 1. Initialize secondary app to create user without logging out Admin
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      final db = FirebaseDatabase.instance.ref();
      final userService = UserService();

      final teacherId = _teacherIdController.text.trim();

      // Check for uniqueness
      final exists = await userService.checkTeacherIdExists(teacherId);
      if (exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Teacher ID already exists. Please choose a different one.'),
                backgroundColor: Colors.red),
          );
        }
        return;
      }

      // 2. Create Auth User
      final credential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // 3. Create DB Entry
      final teacherData = {
        'fullname': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'teacher',
        'gender': _selectedGender,
        'age': int.tryParse(_ageController.text) ?? 30,
        'userId': uid,
        'teacherid': teacherId,
        'department': _deptController.text.trim(),
      };

      // Use teacherId as the key, consistent with Admins/Students pattern (likely)
      // or as requested
      await db.child('Teachers/$teacherId').set(teacherData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher account created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onTeacherCreated();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auth Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 4. Clean up secondary app
      await secondaryApp?.delete();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Teacher Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.accentBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDeco('Full Name', Icons.person),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teacherIdController,
                  decoration:
                      _inputDeco('Teacher ID (e.g. TCH-001)', Icons.badge),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDeco('Email', Icons.email),
                  validator: (v) => v!.contains('@') ? null : 'Invalid email',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDeco('Password', Icons.lock),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deptController,
                  decoration: _inputDeco('Department', Icons.school),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        decoration: _inputDeco('Age', Icons.cake),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        items: _genders
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedGender = v!),
                        decoration: _inputDeco('Gender', null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData? icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
