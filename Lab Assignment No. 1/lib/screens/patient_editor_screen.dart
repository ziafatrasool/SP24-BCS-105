import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../models/patient.dart';
import '../services/file_service.dart';

class PatientEditorScreen extends StatefulWidget {
  const PatientEditorScreen({super.key, this.patient});

  final Patient? patient;

  @override
  State<PatientEditorScreen> createState() => _PatientEditorScreenState();
}

class _PatientEditorScreenState extends State<PatientEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('MMM d, yyyy');

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _notesController;

  String _gender = 'Male';
  DateTime _lastVisit = DateTime.now();
  String? _avatarPath;
  List<String> _documents = <String>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    _nameController = TextEditingController(text: patient?.name ?? '');
    _ageController =
        TextEditingController(text: patient?.age.toString() ?? '');
    _phoneController = TextEditingController(text: patient?.phone ?? '');
    _diagnosisController =
        TextEditingController(text: patient?.diagnosis ?? '');
    _notesController = TextEditingController(text: patient?.notes ?? '');
    _gender = patient?.gender ?? 'Male';
    _lastVisit = patient?.lastVisitIso.isNotEmpty == true
        ? DateTime.parse(patient!.lastVisitIso)
        : DateTime.now();
    _avatarPath = patient?.avatarPath;
    _documents = List.of(patient?.documentPaths ?? <String>[]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final copied = await FileService.copyPickedFile(result.files.first);
    setState(() => _avatarPath = copied);
  }

  Future<void> _pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    final copied = await FileService.copyPickedFiles(result.files);
    setState(() => _documents.addAll(copied));
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final patient = Patient(
      id: widget.patient?.id,
      name: _nameController.text.trim(),
      age: age,
      gender: _gender,
      phone: _phoneController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      notes: _notesController.text.trim(),
      lastVisitIso: _lastVisit.toIso8601String(),
      avatarPath: _avatarPath,
      documentPaths: _documents,
    );
    final db = AppDatabase.instance;
    if (widget.patient == null) {
      await db.insertPatient(patient);
    } else {
      await db.updatePatient(patient);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  Future<void> _pickLastVisit() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastVisit,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _lastVisit = picked);
  }

  void _removeDocument(String path) {
    setState(() => _documents.remove(path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient == null ? 'New Patient' : 'Edit Patient'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Profile',
                  subtitle: 'Basic identification for the patient.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _AvatarPicker(path: _avatarPath, onTap: _pickAvatar),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter a patient name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Age',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Age required';
                                    }
                                    final parsed = int.tryParse(value.trim());
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter a valid age';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _gender,
                                  decoration: const InputDecoration(
                                    labelText: 'Gender',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Male',
                                      child: Text('Male'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Female',
                                      child: Text('Female'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Other',
                                      child: Text('Other'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _gender = value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Contact & Visit',
                  subtitle: 'Keep reachable contact details and last visit.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickLastVisit,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Last visit',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_dateFormat.format(_lastVisit)),
                              const Icon(Icons.calendar_today, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Medical',
                  subtitle: 'Clinical summary and notes.',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(labelText: 'Diagnosis'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    alignLabelWithHint: true,
                  ),
                  minLines: 4,
                  maxLines: 6,
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Documents',
                  subtitle: 'Attach scans, prescriptions, and lab reports.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickDocuments,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Add Documents'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_documents.isEmpty)
                  const Text('No documents uploaded yet.')
                else
                  Column(
                    children: _documents
                        .map(
                          (path) => _DocumentTile(
                            path: path,
                            onRemove: () => _removeDocument(path),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _savePatient,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.patient == null
                            ? 'Create Patient'
                            : 'Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.path, required this.onTap});

  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(36),
          child: Ink(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.shade50,
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: path != null && File(path!).existsSync()
                ? ClipOval(child: Image.file(File(path!), fit: BoxFit.cover))
                : const Icon(Icons.person, size: 36, color: Colors.teal),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Add photo'),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fileName = path.split(Platform.pathSeparator).last;
    return Card(
      elevation: 0,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.teal),
        title: Text(fileName),
        subtitle: const Text('Stored locally'),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
