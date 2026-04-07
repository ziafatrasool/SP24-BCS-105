import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subtask_item.dart';
import '../models/task_item.dart';
import '../services/settings_service.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    super.key,
    required this.onSubmit,
    required this.settingsService,
    this.initialTask,
  });

  final TaskItem? initialTask;
  final SettingsService settingsService;
  final Future<void> Function(TaskItem task) onSubmit;

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subtaskController = TextEditingController();

  late DateTime _selectedDateTime;
  late RepeatType _repeatType;
  late List<int> _repeatDays;
  late List<SubtaskItem> _subtasks;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _selectedDateTime = task?.dueDate ?? DateTime.now().add(const Duration(hours: 1));
    _repeatType = task?.repeatType ?? RepeatType.none;
    _repeatDays = List<int>.from(task?.repeatDays ?? const <int>[]);
    _subtasks = List<SubtaskItem>.from(task?.subtasks ?? const <SubtaskItem>[]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.initialTask == null ? 'Create Task' : 'Edit Task',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date & Time'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDateTime),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: _pickDateTime,
                    child: const Text('Choose'),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<RepeatType>(
                  initialValue: _repeatType,
                  decoration: const InputDecoration(labelText: 'Repeat'),
                  items: const <DropdownMenuItem<RepeatType>>[
                    DropdownMenuItem(
                      value: RepeatType.none,
                      child: Text('Do not repeat'),
                    ),
                    DropdownMenuItem(
                      value: RepeatType.daily,
                      child: Text('Repeat daily'),
                    ),
                    DropdownMenuItem(
                      value: RepeatType.weeklyCustom,
                      child: Text('Selected weekdays'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _repeatType = value;
                      });
                    }
                  },
                ),
                if (_repeatType == RepeatType.weeklyCustom) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(7, (index) {
                      final weekday = index + 1;
                      final labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return FilterChip(
                        label: Text(labels[index]),
                        selected: _repeatDays.contains(weekday),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _repeatDays.add(weekday);
                            } else {
                              _repeatDays.remove(weekday);
                            }
                            _repeatDays.sort();
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Subtasks & Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(labelText: 'Add subtask'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.tonal(
                      onPressed: _addSubtask,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._subtasks.map(
                  (subtask) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: subtask.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _subtasks = _subtasks
                              .map(
                                (item) => item == subtask
                                    ? item.copyWith(isCompleted: value ?? false)
                                    : item,
                              )
                              .toList(growable: false);
                        });
                      },
                    ),
                    title: Text(subtask.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _subtasks.remove(subtask);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_isSaving ? 'Saving...' : 'Save Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (!mounted || pickedDate == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (!mounted || pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _addSubtask() {
    final title = _subtaskController.text.trim();
    if (title.isEmpty) {
      return;
    }
    setState(() {
      _subtasks = <SubtaskItem>[
        ..._subtasks,
        SubtaskItem(title: title),
      ];
      _subtaskController.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_repeatType == RepeatType.weeklyCustom && _repeatDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose at least one weekday for repeating')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draftTask = TaskItem(
      id: widget.initialTask?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _selectedDateTime,
      isCompleted: widget.initialTask?.isCompleted ?? false,
      completedAt: widget.initialTask?.completedAt,
      repeatType: _repeatType,
      repeatDays: _repeatType == RepeatType.weeklyCustom
          ? _repeatDays
          : const <int>[],
      notificationSound: widget.initialTask?.notificationSound ??
          widget.settingsService.notificationSound,
      subtasks: _subtasks,
    );

    await widget.onSubmit(draftTask);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }
}
