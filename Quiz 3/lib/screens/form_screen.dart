import 'dart:ui';

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'records_screen.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Male';

  final SupabaseService _service = SupabaseService();

  // Draggable FAB state
  Offset? _fabPosition;
  Color _fabColor = const Color(0xFF2E6BEA);

  final List<Color> _colorPalette = const [
    Color(0xFF1A3A8D),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF0EA5E9),
    Color(0xFF14B8A6),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final email = _emailController.text.trim();
    final color = _colorFromEmail(email);

    final data = {
      'full_name': _nameController.text.trim(),
      'email': email,
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'gender': _gender,
      'color': color.value,
    };

    await _service.insertData(data);

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitted successfully')),
    );

    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    setState(() => _gender = 'Male');
  }

  Color _colorFromEmail(String email) {
    if (email.isEmpty) return _fabColor;
    final idx = email.hashCode.abs() % _colorPalette.length;
    return _colorPalette[idx];
  }

  void _openColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 5,
            shrinkWrap: true,
            children: _colorPalette
                .map((c) => GestureDetector(
                      onTap: () {
                        setState(() => _fabColor = c);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2E6BEA)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _fabPosition ??= Offset(size.width - 84, size.height - 200);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF1FF), Color(0xFFD9E3FF), Color(0xFFF8FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.6, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
                color: Colors.white.withOpacity(0.55),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Positioned(
              top: -90,
              left: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.26),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.shade900.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Submission Studio',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'A polished submission experience for every user, with bright highlights and intuitive form flow.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF344054),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          elevation: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'User Details',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Enter your info clearly so every record looks premium and easy to read.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF5B6987),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Full name',
                                    icon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      final text = (value ?? '').trim();
                                      if (text.isEmpty)
                                        return 'Please enter email';
                                      if (!text.contains('@'))
                                        return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Phone',
                                    icon: Icons.phone_android,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildTextField(
                                    controller: _addressController,
                                    label: 'Address',
                                    icon: Icons.home_outlined,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 18),
                                  InputDecorator(
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      prefixIcon: const Icon(Icons.wc),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _gender,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 'Male',
                                              child: Text('Male')),
                                          DropdownMenuItem(
                                              value: 'Female',
                                              child: Text('Female')),
                                          DropdownMenuItem(
                                              value: 'Other',
                                              child: Text('Other')),
                                        ],
                                        onChanged: (value) => setState(
                                            () => _gender = value ?? 'Male'),
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF3B82F6),
                                                Color(0xFF6366F1),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF3B82F6)
                                                    .withOpacity(0.28),
                                                blurRadius: 22,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            onPressed:
                                                _isSending ? null : submitForm,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 18),
                                            ),
                                            child: _isSending
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Text(
                                                        'Submit now',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        color: Colors.white,
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      OutlinedButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RecordsScreen(),
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF1A3A8D),
                                          side: const BorderSide(
                                              color: Color(0xFF1A3A8D)),
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 18, horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: const Text(
                                          'View records',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: _fabPosition!.dx,
              top: _fabPosition!.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabPosition = Offset(
                      (_fabPosition!.dx + details.delta.dx)
                          .clamp(8.0, size.width - 72),
                      (_fabPosition!.dy + details.delta.dy)
                          .clamp(8.0, size.height - 160),
                    );
                  });
                },
                onLongPress: _openColorPicker,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecordsScreen()),
                ),
                child: Material(
                  elevation: 16,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _fabColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _fabColor.withOpacity(0.32),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.list, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
