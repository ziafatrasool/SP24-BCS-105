import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_database.dart';
import '../models/patient.dart';
import 'patient_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _db = AppDatabase.instance;
  final _dateFormat = DateFormat('MMM d, yyyy');

  List<Patient> _patients = <Patient>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final data = await _db.fetchPatients();
    if (!mounted) return;
    setState(() {
      _patients = data;
      _loading = false;
    });
  }

  Future<void> _openEditor({Patient? patient}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PatientEditorScreen(patient: patient),
      ),
    );
    await _loadPatients();
  }

  Future<void> _deletePatient(Patient patient) async {
    if (patient.id == null) return;
    await _db.deletePatient(patient.id!);
    await _loadPatients();
  }

  List<Patient> get _filteredPatients {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _patients;
    }
    return _patients.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.phone.toLowerCase().contains(query) ||
          p.diagnosis.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2C3F),
              Color(0xFF123D52),
              Color(0xFF1E5A6E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doctor Desk',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage patient records quickly and safely.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadPatients,
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    hintText: 'Search by name, phone, or diagnosis',
                    hintStyle: const TextStyle(color: Colors.white60),
                    filled: true,
                    fillColor: const Color(0xFF17384A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F8FA),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredPatients.isEmpty
                          ? _EmptyState(onCreate: () => _openEditor())
                          : ListView.separated(
                              itemCount: _filteredPatients.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final patient = _filteredPatients[index];
                                return Dismissible(
                                  key: ValueKey('patient_${patient.id}_$index'),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade400,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (_) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete patient?'),
                                        content: Text(
                                          'Remove ${patient.name} from records?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (_) => _deletePatient(patient),
                                  child: _PatientCard(
                                    patient: patient,
                                    dateFormat: _dateFormat,
                                    onTap: () => _openEditor(patient: patient),
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        backgroundColor: const Color(0xFF1B6A6F),
        icon: const Icon(Icons.add),
        label: const Text('New Patient'),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.dateFormat,
    required this.onTap,
  });

  final Patient patient;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastVisit = patient.lastVisitIso.isEmpty
        ? 'Not set'
        : dateFormat.format(DateTime.parse(patient.lastVisitIso));
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _AvatarCircle(path: patient.avatarPath, initials: patient.name),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.diagnosis.isEmpty
                        ? 'No diagnosis yet'
                        : patient.diagnosis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.teal.shade600),
                      const SizedBox(width: 6),
                      Text(
                        lastVisit,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.path, required this.initials});

  final String? path;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final fallback = initials.trim().isEmpty
        ? 'DR'
        : initials.trim().split(' ').map((e) => e[0]).take(2).join();
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.teal.shade50,
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: path != null && File(path!).existsSync()
          ? ClipOval(child: Image.file(File(path!), fit: BoxFit.cover))
          : Center(
              child: Text(
                fallback.toUpperCase(),
                style: TextStyle(
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.medical_information, size: 56, color: Colors.teal),
            const SizedBox(height: 12),
            const Text(
              'No patients yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add the first patient to start tracking medical records.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Add Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
