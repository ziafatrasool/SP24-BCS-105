import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final SupabaseService service = SupabaseService();
  List<Map<String, dynamic>> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future fetchRecords() async {
    setState(() {
      isLoading = true;
    });

    final data = await service.getData();

    setState(() {
      records = data;
      isLoading = false;
    });
  }

  Future deleteRecord(int id) async {
    await service.deleteData(id);
    await fetchRecords();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        content: Text('Record deleted successfully.'),
      ),
    );
  }

  Future editRecord(Map<String, dynamic> record) async {
    final nameController = TextEditingController(text: record['full_name']);
    final emailController = TextEditingController(text: record['email']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await service.updateData(record['id'], {
                  'full_name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                });

                Navigator.pop(context);
                await fetchRecords();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRecordTile(Map<String, dynamic> record) {
    final int? colorValue =
        record['color'] is int ? record['color'] as int : null;
    final Color accent =
        colorValue != null ? Color(colorValue) : const Color(0xFF1A3A8D);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.18), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    record['full_name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record['gender'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record['email'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_android,
                        size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Text(
                      record['phone'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.home_outlined,
                        size: 18, color: Color(0xFF475569)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record['address'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => editRecord(record),
                      icon: Icon(Icons.edit, color: accent),
                      label: Text(
                        'Edit',
                        style: TextStyle(color: accent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => deleteRecord(record['id']),
                      icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4F7FF), Color(0xFFE6F0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1496307042754-b4aa456c4a2d?auto=format&fit=crop&w=1200&q=80',
                fit: BoxFit.cover,
                color: Colors.white.withOpacity(0.6),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
            Positioned(
              top: 40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.24),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: fetchRecords,
              edgeOffset: 80,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.only(top: 140),
                          children: [
                            Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Column(
                                  children: const [
                                    Icon(Icons.inbox,
                                        size: 72, color: Color(0xFF1A3A8D)),
                                    SizedBox(height: 20),
                                    Text(
                                      'No records yet',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Submit the form to create beautiful records that appear here with unique accent colors.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF505B74),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 16, bottom: 36),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return buildRecordTile(records[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
