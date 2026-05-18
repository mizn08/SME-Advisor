import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gov_aid.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class GrantsScreen extends StatefulWidget {
  const GrantsScreen({super.key});

  @override
  State<GrantsScreen> createState() => _GrantsScreenState();
}

class _GrantsScreenState extends State<GrantsScreen> {
  List<GovAid> all = [];
  bool grantsOnly = false;
  bool bumiOnly = false;
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final list = await ApiService().fetchGovAid();
      setState(() => all = list);
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Iterable<GovAid> get _filtered sync* {
    for (final g in all) {
      if (grantsOnly && g.aidType.toLowerCase() != 'grant') continue;
      if (bumiOnly && !g.requiresBumiputera) continue;
      yield g;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Funding options', style: Theme.of(context).textTheme.headlineSmall),
              Text(
                'Compare BNPL with government grants and concessionary schemes.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Grants only'),
                selected: grantsOnly,
                onSelected: (v) => setState(() => grantsOnly = v),
              ),
              FilterChip(
                label: const Text('Bumiputera schemes'),
                selected: bumiOnly,
                onSelected: (v) => setState(() => bumiOnly = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : err != null
                  ? Center(child: Text(err!))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        children: [
                          for (final g in _filtered) _card(context, g, currency),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, GovAid g, NumberFormat currency) {
    final isGrant = g.aidType.toLowerCase() == 'grant';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isGrant ? AppTheme.teal : Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.schemeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(g.agency, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                if (isGrant)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('GRANT', style: TextStyle(color: AppTheme.teal, fontSize: 11)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _grid(g, currency),
            if (g.description != null) ...[
              const SizedBox(height: 8),
              Text(g.description!, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
            ],
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(GovAid g, NumberFormat currency) {
    final maxAmt = g.maxAmountRm == null ? '—' : currency.format(g.maxAmountRm);
    final rate = g.interestRateLabel ?? '—';
    final tenure = g.tenureMonths == null ? '—' : '${g.tenureMonths} mo';
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
      children: [
        TableRow(children: [_cell('MAX AMOUNT', maxAmt), _cell('INTEREST', rate)]),
        TableRow(children: [_cell('SPEED', g.approvalSpeedLabel), _cell('TENURE', tenure)]),
      ],
    );
  }

  Widget _cell(String label, String value) => Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
