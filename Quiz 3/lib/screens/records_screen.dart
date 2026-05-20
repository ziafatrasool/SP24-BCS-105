import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/submission.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'form_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _service = SupabaseService();
  late Future<List<Submission>> _submissionsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _submissionsFuture = _service.fetchSubmissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Library',
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus, size: 16),
            onPressed: () => Navigator.pushNamed(context, '/'),
          ),
        ],
      ),
      body: FutureBuilder<List<Submission>>(
        future: _submissionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.gold));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.database,
                      color: AppTheme.darkMuted.withValues(alpha: 0.2),
                      size: 64),
                  const SizedBox(height: 16),
                  const Text('NULL RETURN ON QUERY',
                      style: TextStyle(
                          color: AppTheme.darkMuted,
                          letterSpacing: 2.0,
                          fontSize: 10)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildRecordCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(Submission item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface.withValues(alpha: 0.5),
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Center(
                      child: Text(item.fullName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item.gender.toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.darkMuted,
                              fontSize: 8,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Text('#${item.id?.substring(0, 4)}',
                  style: const TextStyle(
                      color: Color(0xFF333333),
                      fontFamily: 'monospace',
                      fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(FontAwesomeIcons.envelope, item.email),
          _buildInfoRow(FontAwesomeIcons.phone, item.phoneNumber),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.penToSquare,
                    size: 14, color: AppTheme.darkMuted),
                onPressed: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FormScreen(submissionToEdit: item)))
                      .then((_) => _refresh());
                },
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.trashCan,
                    size: 14, color: AppTheme.darkMuted),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: AppTheme.darkSurface,
                      title: const Text('PURGE ENTRY?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('CANCEL')),
                        TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('DELETE',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _service.deleteSubmission(item.id!);
                    _refresh();
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 10, color: AppTheme.gold),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }
}
