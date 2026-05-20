import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/submission.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class FormScreen extends StatefulWidget {
  final Submission? submissionToEdit;

  const FormScreen({super.key, this.submissionToEdit});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SupabaseService();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String _gender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.submissionToEdit?.fullName);
    _emailController =
        TextEditingController(text: widget.submissionToEdit?.email);
    _phoneController =
        TextEditingController(text: widget.submissionToEdit?.phoneNumber);
    _addressController =
        TextEditingController(text: widget.submissionToEdit?.address);
    if (widget.submissionToEdit != null) {
      _gender = widget.submissionToEdit!.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final submission = Submission(
      id: widget.submissionToEdit?.id,
      fullName: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      gender: _gender,
    );

    try {
      if (widget.submissionToEdit == null) {
        await _service.insertSubmission(submission);
      } else {
        await _service.updateSubmission(submission);
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/records');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.submissionToEdit == null ? 'Registration' : 'Edit Entry',
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.list),
            onPressed: () => Navigator.pushNamed(context, '/records'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Sync with Remote DB',
                  style: TextStyle(
                      color: AppTheme.darkMuted,
                      fontSize: 12,
                      letterSpacing: 1.5)),
              const SizedBox(height: 32),
              _buildField(
                  'Full Legal Name', _nameController, FontAwesomeIcons.user),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildField('Email Address', _emailController,
                          FontAwesomeIcons.envelope)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildField('Phone Number', _phoneController,
                          FontAwesomeIcons.phone)),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('Physical Location', _addressController,
                  FontAwesomeIcons.mapPin,
                  maxLines: 2),
              const SizedBox(height: 24),
              const Text('CLASSIFICATION',
                  style: TextStyle(
                      color: AppTheme.darkMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0)),
              const SizedBox(height: 12),
              _buildGenderPicker(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : Text(widget.submissionToEdit == null
                        ? 'PUSH TO SUPABASE'
                        : 'UPDATE CLOUD ENTRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                color: AppTheme.darkMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 14, color: AppTheme.darkMuted),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildGenderPicker() {
    return Row(
      children: ['Male', 'Female', 'Other'].map((g) {
        final isSelected = _gender == g;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => setState(() => _gender = g),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.gold : const Color(0xFF0A0A0A),
                  border: Border.all(
                      color: isSelected ? AppTheme.gold : AppTheme.darkBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(g.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.darkMuted,
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        letterSpacing: 1.2,
                      )),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
