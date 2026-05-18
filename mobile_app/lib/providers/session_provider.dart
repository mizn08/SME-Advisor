import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider extends ChangeNotifier {
  static const _keySme = 'sme_id';

  int smeId = 1;
  bool loaded = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    smeId = p.getInt(_keySme) ?? 1;
    loaded = true;
    notifyListeners();
  }

  Future<void> setSmeId(int id) async {
    smeId = id;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_keySme, id);
    notifyListeners();
  }
}
