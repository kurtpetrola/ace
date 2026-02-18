// lib/features/teacher_dashboard/presentation/dialogs/create_classwork_dialog.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ace/core/constants/app_colors.dart';
import 'package:ace/models/classwork.dart';
import 'package:ace/models/classroom.dart';

class TeacherCreateClassworkDialog extends StatefulWidget {
  final Classroom classroom;
  final String teacherId; // Renamed from adminId
  final Classwork? existingClasswork;

  const TeacherCreateClassworkDialog({
    super.key,
    required this.classroom,
    required this.teacherId,
    this.existingClasswork,
  });

  @override
  State<TeacherCreateClassworkDialog> createState() =>
      _TeacherCreateClassworkDialogState();
}

class _TeacherCreateClassworkDialogState
    extends State<TeacherCreateClassworkDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _correctAnswerController =
      TextEditingController();

  ClassworkType _selectedType = ClassworkType.assignment;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  bool _allowResubmission = true;

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
    _correctAnswerController.text = cw.correctAnswer ?? '';
    _selectedType = cw.type;
    if (cw.dueDate != null) {
      _selectedDueDate = cw.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(cw.dueDate!);
      _selectedDueDate = cw.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(cw.dueDate!);
    }
    _allowResubmission = cw.allowResubmission;
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

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
      createdBy: widget.teacherId, // Using teacherId

      createdAt: widget.existingClasswork?.createdAt ?? DateTime.now(),
      correctAnswer: _correctAnswerController.text.trim().isNotEmpty
          ? _correctAnswerController.text.trim()
          : null,
      allowResubmission: _allowResubmission,
    );

    Navigator.of(context).pop(classwork);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingClasswork != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).cardTheme.color,
      surfaceTintColor: Theme.of(context).cardTheme.color,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 750),
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ColorPalette.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                          isEditing
                              ? Ionicons.create_outline
                              : Ionicons.add_circle_outline,
                          color: ColorPalette.primary,
                          size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Classwork' : 'Create Classwork',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        Text(
                          'For: ${widget.classroom.className}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Classwork Type',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ClassworkType.values.map((type) {
                          final isSelected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(type.displayName),
                            selected: isSelected,
                            onSelected: (s) =>
                                setState(() => _selectedType = type),
                            selectedColor: ColorPalette.primary,
                            checkmarkColor: Colors.white,
                            backgroundColor: Theme.of(context).cardTheme.color,
                            side: BorderSide(
                              color: isSelected
                                  ? ColorPalette.primary
                                  : Theme.of(context).dividerTheme.color ??
                                      Colors.grey.shade300,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Title'),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration('e.g., Assignment 1',
                            icon: Ionicons.document_text_outline),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter title'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration('Instructions, details...',
                            icon: null),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter description'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Points'),
                      SizedBox(
                        width: 150,
                        child: TextFormField(
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('100',
                              icon: Ionicons.medal_outline),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      if (_selectedType == ClassworkType.quiz) ...[
                        const SizedBox(height: 20),
                        _buildLabel('Correct Answer'),
                        TextFormField(
                          controller: _correctAnswerController,
                          decoration: _inputDecoration('(Optional)',
                              icon: Ionicons.checkmark_circle_outline),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Allow Resubmission',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color)),
                        subtitle: const Text(
                          'Students can resubmit work before the due date.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        value: _allowResubmission,
                        onChanged: (val) =>
                            setState(() => _allowResubmission = val),
                        activeThumbColor: ColorPalette.primary,
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Due Date (Optional)'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectDueDate,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Ionicons.calendar_outline,
                                              size: 18,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _selectedDueDate == null
                                                  ? 'Select Date'
                                                  : '${_selectedDueDate!.month}/${_selectedDueDate!.day}/${_selectedDueDate!.year}',
                                              style: TextStyle(
                                                color: _selectedDueDate == null
                                                    ? Colors.grey
                                                    : Colors.black87,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectDueTime,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Ionicons.time_outline,
                                              size: 18,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              _selectedDueTime
                                                      ?.format(context) ??
                                                  'Select Time',
                                              style: TextStyle(
                                                color: _selectedDueTime == null
                                                    ? Colors.grey
                                                    : Colors.black87,
                                                overflow: TextOverflow.ellipsis,
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
                            if (_selectedDueDate != null) ...[
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => setState(() {
                                    _selectedDueDate = null;
                                    _selectedDueTime = null;
                                  }),
                                  icon: const Icon(Icons.clear, size: 16),
                                  label: const Text('Clear Due Date'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).textTheme.bodyMedium?.color,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: Icon(isEditing ? Ionicons.save : Ionicons.add,
                          size: 20),
                      label: Text(
                        isEditing ? 'Save' : 'Create',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color)),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null
          ? Icon(icon, color: Theme.of(context).iconTheme.color)
          : null,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface
          : Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).dividerTheme.color ?? Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).dividerTheme.color ?? Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ColorPalette.primary, width: 1.5),
      ),
    );
  }
}
