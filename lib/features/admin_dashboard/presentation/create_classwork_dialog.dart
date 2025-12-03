// lib/features/admin_dashboard/presentation/admin_classwork_management_screen.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/classroom.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

class CreateClassworkDialog extends StatefulWidget {
  final Classroom classroom;
  final String adminId;
  final Classwork? existingClasswork;

  const CreateClassworkDialog({
    super.key,
    required this.classroom,
    required this.adminId,
    this.existingClasswork,
  });

  @override
  State<CreateClassworkDialog> createState() => _CreateClassworkDialogState();
}

class _CreateClassworkDialogState extends State<CreateClassworkDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  ClassworkType _selectedType = ClassworkType.assignment;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;

  // File? _pickedFile;
  // String? _attachmentUrl;
  // bool _isUploading = false;
  // String? _statusMessage; // Status message for upload or errors

  @override
  void initState() {
    super.initState();
    if (widget.existingClasswork != null) _loadExistingData();
    _pointsController.text =
        widget.existingClasswork?.points.toString() ?? '100';
  }

  void _loadExistingData() {
    final cw = widget.existingClasswork!;
    _titleController.text = cw.title;
    _descriptionController.text = cw.description;
    _pointsController.text = cw.points.toString();
    _selectedType = cw.type;
    // _attachmentUrl = cw.attachmentUrl;
    if (cw.dueDate != null) {
      _selectedDueDate = cw.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(cw.dueDate!);
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Future<void> _selectDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedDueTime = picked);
  }

  // Future<void> _pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.any,
  //     allowMultiple: false,
  //   );
  //   if (result != null && result.files.single.path != null) {
  //     setState(() => _pickedFile = File(result.files.single.path!));
  //   }
  // }

  // Future<String?> _uploadFile(File file) async {
  //   try {
  //     setState(() {
  //       _isUploading = true;
  //       _statusMessage = 'Uploading file...';
  //     });
  //     final storageRef = FirebaseStorage.instance.ref().child(
  //         'classwork_attachments/${widget.classroom.classId}/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
  //     final snapshot = await storageRef.putFile(file);
  //     final url = await snapshot.ref.getDownloadURL();
  //     setState(() {
  //       _isUploading = false;
  //       _statusMessage = 'File uploaded successfully';
  //     });
  //     return url;
  //   } catch (e) {
  //     setState(() {
  //       _isUploading = false;
  //       _statusMessage = 'Failed to upload file';
  //     });
  //     return null;
  //   }
  // }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Upload file if selected (temporarily disabled)
    // if (_pickedFile != null) {
    //   _attachmentUrl = await _uploadFile(_pickedFile!);
    //   if (_attachmentUrl == null) return; // stop if upload failed
    // }

    DateTime? finalDueDate;
    if (_selectedDueDate != null) {
      finalDueDate = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedDueTime?.hour ?? 23,
        _selectedDueTime?.minute ?? 59,
      );
    }

    final classwork = Classwork(
      classworkId: widget.existingClasswork?.classworkId ?? '',
      classId: widget.classroom.classId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      dueDate: finalDueDate,
      points: int.tryParse(_pointsController.text) ?? 100,
      createdBy: widget.adminId,
      createdAt: widget.existingClasswork?.createdAt ?? DateTime.now(),
      // attachmentUrl: _attachmentUrl,
    );

    Navigator.of(context).pop(classwork);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClasswork != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Ionicons.create_outline,
                      color: ColorPalette.secondary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                        isEditing ? 'Edit Classwork' : 'Create Classwork',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              Text('For: ${widget.classroom.className}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const Divider(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Classwork Type
                      Text('Classwork Type',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ClassworkType.values.map((type) {
                          return ChoiceChip(
                            label: Text(type.displayName),
                            selected: _selectedType == type,
                            onSelected: (s) =>
                                setState(() => _selectedType = type),
                            selectedColor: ColorPalette.secondary,
                            labelStyle: TextStyle(
                                color: _selectedType == type
                                    ? Colors.white
                                    : Colors.black),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          hintText: 'e.g., Assignment 1',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Ionicons.document_text),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Instructions...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter description'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Points
                      TextFormField(
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Points *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Ionicons.medal),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Enter points';
                          if (int.tryParse(v) == null)
                            return 'Enter valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due date/time
                      Text('Due Date (Optional)',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDueDate,
                              icon: const Icon(Ionicons.calendar_outline),
                              label: Text(_selectedDueDate == null
                                  ? 'Select Date'
                                  : '${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDueTime,
                              icon: const Icon(Ionicons.time_outline),
                              label: Text(_selectedDueTime?.format(context) ??
                                  'Select Time'),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedDueDate != null)
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _selectedDueDate = null;
                            _selectedDueTime = null;
                          }),
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear Due Date'),
                          style:
                              TextButton.styleFrom(foregroundColor: Colors.red),
                        ),

                      // Attachment UI removed since Firebase Storage is unavailable
                    ],
                  ),
                ),
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: Icon(isEditing ? Ionicons.save : Ionicons.add),
                    label: Text(isEditing ? 'Save' : 'Create'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
