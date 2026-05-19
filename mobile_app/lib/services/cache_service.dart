import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static String _key(int smeId) => 'dashboard_cache_$smeId';

  static Future<void> saveDashboard(int smeId, Map<String, dynamic> json) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key(smeId), jsonEncode(json));
    await p.setInt('${_key(smeId)}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, dynamic>?> loadDashboard(int smeId) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key(smeId));
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
