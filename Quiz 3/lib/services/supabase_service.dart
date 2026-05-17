import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;
  static final List<Map<String, dynamic>> _localStore = [];
  static int _nextLocalId = 1;

  Future insertData(Map<String, dynamic> data) async {
    try {
      await supabase.from('submissions').insert(data);
    } catch (_) {
      _localStore.add({'id': _nextLocalId++, ...data});
    }
  }

  Future<List<Map<String, dynamic>>> getData() async {
    try {
      final response = await supabase.from('submissions').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return List<Map<String, dynamic>>.from(_localStore);
    }
  }

  Future updateData(int id, Map<String, dynamic> data) async {
    try {
      await supabase.from('submissions').update(data).eq('id', id);
    } catch (_) {
      final index = _localStore.indexWhere((row) => row['id'] == id);
      if (index != -1) {
        _localStore[index] = {..._localStore[index], ...data};
      }
    }
  }

  Future deleteData(int id) async {
    try {
      await supabase.from('submissions').delete().eq('id', id);
    } catch (_) {
      _localStore.removeWhere((row) => row['id'] == id);
    }
  }
}
