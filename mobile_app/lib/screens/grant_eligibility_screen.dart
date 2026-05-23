import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class GrantEligibilityScreen extends StatefulWidget {
  const GrantEligibilityScreen({super.key});

  @override
  State<GrantEligibilityScreen> createState() => _GrantEligibilityScreenState();
}

class _GrantEligibilityScreenState extends State<GrantEligibilityScreen> {
  bool _bumi = false;
  bool _ssm = true;
  bool _tech = false;
  bool _export = false;
  double _revenue = 500000;
  String _sector = 'F&B retail';
  List<Map<String, dynamic>> _matches = [];
  bool _loading = false;
  String? _err;

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final sid = context.read<SessionProvider>().smeId;
      final res = await ApiService().grantEligibility(
        smeId: sid,
        bumiputera: _bumi,
        revenueRm: _revenue,
        sector: _sector,
        ssmRegistered: _ssm,
        techFocus: _tech,
        exportIntent: _export,
      );
      setState(() => _matches = (res['matches'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>());
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grant eligibility')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Budget 2026: RM50B business financing · TEKUN/BSN micro-loans · SJPP guarantees',
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 16),
          SwitchListTile(title: const Text('Bumiputera-owned'), value: _bumi, onChanged: (v) => setState(() => _bumi = v)),
          SwitchListTile(title: const Text('SSM registered'), value: _ssm, onChanged: (v) => setState(() => _ssm = v)),
          SwitchListTile(title: const Text('Tech / digitalisation focus'), value: _tech, onChanged: (v) => setState(() => _tech = v)),
          SwitchListTile(title: const Text('Export expansion intent'), value: _export, onChanged: (v) => setState(() => _export = v)),
          Text('Revenue: RM ${_revenue.toStringAsFixed(0)}'),
          Slider(value: _revenue, min: 50000, max: 5000000, divisions: 20, onChanged: (v) => setState(() => _revenue = v)),
          FilledButton(
            onPressed: _loading ? null : _run,
            style: FilledButton.styleFrom(backgroundColor: AppTheme.teal),
            child: Text(_loading ? 'Matching…' : 'Find grants I qualify for'),
          ),
          if (_err != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_err!, style: TextStyle(color: Colors.red.shade700))),
          ..._matches.map((m) {
            final reasons = (m['match_reasons'] as List<dynamic>? ?? []).join(' ');
            return Card(
              margin: const EdgeInsets.only(top: 12),
              child: ListTile(
                title: Text(m['scheme_name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${m['agency']} · ${m['aid_type']}\n$reasons'),
                isThreeLine: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
