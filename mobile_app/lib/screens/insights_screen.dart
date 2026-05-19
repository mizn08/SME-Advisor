import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _insights;
  Map<String, dynamic>? _bandit;
  bool _busy = false;
  String? _err;
  String? _ocrPreview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final sid = context.read<SessionProvider>().smeId;
      final ins = await _api.fetchInsights(sid);
      final bandit = await _api.fetchBanditStats();
      if (!mounted) return;
      setState(() {
        _insights = ins;
        _bandit = bandit;
      });
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickInvoice() async {
    final pick = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (pick == null || pick.files.isEmpty) return;
    final bytes = pick.files.first.bytes;
    if (bytes == null) return;
    setState(() => _busy = true);
    try {
      final sid = context.read<SessionProvider>().smeId;
      final res = await _api.uploadInvoice(smeId: sid, bytes: bytes, fileName: pick.files.first.name);
      if (!mounted) return;
      setState(() => _ocrPreview = res['csv_preview'] as String? ?? res.toString());
    } catch (e) {
      if (mounted) setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights (v3)'),
        backgroundColor: AppTheme.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _busy && _insights == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                _section(
                  'Unsupervised cluster',
                  _insights?['cluster'] != null
                      ? '${_insights!['cluster']['cluster_label']}\n(cluster ${_insights!['cluster']['cluster_id']})'
                      : 'Run after SME data is loaded',
                ),
                _section(
                  'Anomaly detection',
                  _formatAnomalies(_insights?['anomalies']),
                ),
                _section(
                  'Multi-armed bandit (UCB)',
                  _formatBandit(_bandit),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _pickInvoice,
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('Scan invoice (OCR)'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.teal),
                ),
                if (_ocrPreview != null) ...[
                  const SizedBox(height: 12),
                  _section('OCR CSV preview', _ocrPreview!),
                ],
              ],
            ),
    );
  }

  String _formatAnomalies(dynamic block) {
    if (block == null) return '—';
    final list = block['anomalies'] as List<dynamic>? ?? [];
    if (list.isEmpty) return block['message'] as String? ?? 'No anomalies flagged';
    return list
        .take(5)
        .map((a) => '${a['txn_date']} ${a['category']} RM ${a['amount_rm']}')
        .join('\n');
  }

  String _formatBandit(Map<String, dynamic>? b) {
    if (b == null) return '—';
    final sug = b['suggestion'] as Map<String, dynamic>?;
    final arms = b['arms'] as List<dynamic>? ?? [];
    final lines = <String>[
      if (sug != null) 'Explore arm: ${sug['suggested_arm']}',
      ...arms.map((a) => '${a['arm']}: ${a['pulls']} pulls, avg ${(a['avg_reward'] as num).toStringAsFixed(2)}'),
    ];
    return lines.join('\n');
  }

  Widget _section(String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(body, style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
