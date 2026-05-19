import 'package:flutter/foundation.dart';

/// Override with `--dart-define=API_BASE=http://192.168.1.10:8000` for physical devices.
const String _apiFromEnv = String.fromEnvironment('API_BASE');

String resolveApiBase() {
  if (_apiFromEnv.isNotEmpty) return _apiFromEnv;
  if (kIsWeb) {
    // Auto-detect the host the page was served from so it works on LAN too
    final uri = Uri.base;
    return '${uri.scheme}://${uri.host}:8000';
  }
  // dart:io is not available on web, so we only use it on non-web platforms
  return 'http://127.0.0.1:8000';
}
