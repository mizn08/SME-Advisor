import 'dart:typed_data';

/// Web has no dart:io File — callers use bytes + Share directly.
Future<Never> writePdfBytes(Uint8List bytes, String name) async {
  throw UnsupportedError('Use buildFullReportBytes on web');
}
