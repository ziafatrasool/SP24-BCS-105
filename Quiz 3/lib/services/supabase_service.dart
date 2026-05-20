import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<Submission>> fetchSubmissions() async {
    final response = await _client
        .from('submissions')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Submission.fromJson(json)).toList();
  }

  Future<void> insertSubmission(Submission submission) async {
    await _client.from('submissions').insert(submission.toJson());
  }

  Future<void> updateSubmission(Submission submission) async {
    if (submission.id == null) return;
    await _client
        .from('submissions')
        .update(submission.toJson())
        .eq('id', submission.id!);
  }

  Future<void> deleteSubmission(String id) async {
    await _client.from('submissions').delete().eq('id', id);
  }
}
