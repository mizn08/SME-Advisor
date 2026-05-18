import 'dart:io';

import 'package:flutter/foundation.dart';

/// Override with `--dart-define=API_BASE=http://192.168.1.10:8000` for physical devices.
const String _apiFromEnv = String.fromEnvironment('API_BASE');

String resolveApiBase() {
  if (_apiFromEnv.isNotEmpty) return _apiFromEnv;
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}
