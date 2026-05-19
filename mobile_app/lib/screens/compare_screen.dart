import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recommendation_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _api = ApiService();
  bool _sst = false;
  bool _islamic = false;
  Map<String, dynamic>? _result;
  bool _busy = false;

  Future<void> _run() async {
    final rec = context.read<RecommendationProvider>();
    final amt = rec.lastPurchaseAmount ?? 5000.0;
    final cat = rec.lastPurchaseCategory ?? 'equipment';
    setState(() => _busy = true);
    try {
      final sid = context.read<SessionProvider>().smeId;
      final res = await _api.compareFinancing(
        smeId: sid,
        purchaseAmount: amt,
        purchaseCategory: cat,
        includeSst: _sst,
        islamicOnly: _islamic,
      );
      if (mounted) setState(() => _result = res);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = (_result?['options'] as List<dynamic>?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Compare financing'), backgroundColor: AppTheme.teal, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(title: const Text('Include SST (6%)'), value: _sst, onChanged: (v) => setState(() => _sst = v)),
          SwitchListTile(title: const Text('Islamic only'), value: _islamic, onChanged: (v) => setState(() => _islamic = v)),
          FilledButton(
            onPressed: _busy ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.teal),
            child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Compare all options'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text('Recommended: ${_result!['recommended']['type']} — ${_result!['recommended']['product_name']}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...options.map((o) {
              final m = o as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text('${m['type']} · ${m['product_name']}'),
                  subtitle: Text(
                    'Cost RM ${m['additional_cost_rm']} · Cash preserved RM ${m['cash_preserved_rm']}\nTotal w/ SST RM ${m['total_with_sst_rm']}',
                  ),
                  isThreeLine: true,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
