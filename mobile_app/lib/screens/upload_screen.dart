import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

/// CSV upload: uses device file picker; on simulator you can pick `assets/sample_transactions.csv`
/// copied to temp (see README).
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  double? progress;
  List<String> report = [];
  String? err;
  bool busy = false;

  Future<void> _pickAndUpload() async {
    setState(() {
      err = null;
      report = [];
      busy = true;
      progress = 0.1;
    });
    try {
      final sid = context.read<SessionProvider>().smeId;
      final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (res == null || res.files.single.path == null) {
        setState(() {
          busy = false;
          progress = null;
        });
        return;
      }
      setState(() => progress = 0.45);
      final path = res.files.single.path!;
      final name = res.files.single.name;
      final body = await ApiService().uploadCsv(smeId: sid, filePath: path, fileName: name);
      setState(() {
        progress = 1;
        report = List<String>.from((body['cleaning_report'] as List<dynamic>? ?? []).map((e) => '$e'));
        report.insert(0, 'Imported ${body['transactions_imported']} rows.');
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() {
        busy = false;
        progress = null;
      });
    }
  }

  Future<void> _uploadBundledSample() async {
    setState(() {
      err = null;
      report = [];
      busy = true;
    });
    try {
      final sid = context.read<SessionProvider>().smeId;
      final data = await rootBundle.loadString('assets/sample_transactions.csv');
      final dir = Directory.systemTemp;
      final f = File('${dir.path}/sample_transactions.csv');
      await f.writeAsString(data);
      final body = await ApiService().uploadCsv(smeId: sid, filePath: f.path, fileName: 'sample_transactions.csv');
      setState(() {
        report = List<String>.from((body['cleaning_report'] as List<dynamic>? ?? []).map((e) => '$e'));
        report.insert(0, 'Imported ${body['transactions_imported']} rows from bundled sample.');
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Upload transactions', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Upload a CSV with columns: date, amount, category, optional description, optional is_expense.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 24),
        if (progress != null) LinearProgressIndicator(value: progress),
        if (busy && progress == null) const LinearProgressIndicator(),
        if (err != null) ...[
          const SizedBox(height: 12),
          Text(err!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: busy ? null : _pickAndUpload,
          icon: const Icon(Icons.folder_open),
          label: const Text('Pick CSV from device'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy ? null : _uploadBundledSample,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload bundled sample CSV'),
        ),
        if (report.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Cleaning report', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.iceBlue,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final line in report) Text('• $line')],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
