import 'dart:html' as html;

/// Read API URL from web/index.html meta tag (works without --dart-define).
String? readRuntimeApiBase() {
  final el = html.document.querySelector('meta[name="api-base"]');
  final value = el?.getAttribute('content')?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}
