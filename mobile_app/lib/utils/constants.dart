import 'package:flutter/foundation.dart';

/// Override with `--dart-define=API_BASE=http://192.168.1.10:8000` for physical devices.
const String _apiFromEnv = String.fromEnvironment('API_BASE');

/// Live Render API (Flutter web is a separate static site on Render).
const String productionApiBase = 'https://sme-advisor-api.onrender.com';

String resolveApiBase() {
  if (_apiFromEnv.isNotEmpty) return _apiFromEnv;
  if (kIsWeb) {
    final uri = Uri.base;
    final host = uri.host.toLowerCase();
    // API service URL (Swagger, health) — same origin, no :8000
    if (host == 'sme-advisor-api.onrender.com') {
      return '${uri.scheme}://$host';
    }
    // Static web on Render (or any non-API host) → separate API service
    if (host.endsWith('.onrender.com')) {
      return productionApiBase;
    }
    // Local / LAN dev: page and API on same machine, API on port 8000
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://${uri.host}:8000';
    }
    return '${uri.scheme}://${uri.host}:8000';
  }
  return 'http://127.0.0.1:8000';
}
