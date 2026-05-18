import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/recommendation_provider.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recommendation_result.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final _amountCtrl = TextEditingController(text: '50000');
  String _category = 'Equipment';
  String _bnplChoice = 'Auto-select';
  bool _busy = false;
  String? _err;

  static const _categories = [
    'Equipment',
    'Digital / Software',
    'Supplies',
    'Marketing',
    'Logistics',
    'Utilities',
    'Agri inputs',
  ];

  static const _bnplPlans = <MapEntry<String, String?>>[
    MapEntry('Auto-select', null),
    MapEntry('Atome Pay in 3', 'Atome Pay in 3'),
    MapEntry('Grab PayLater 4-month', 'Grab PayLater 4-month'),
    MapEntry('Shopee SPayLater 12-month', 'Shopee SPayLater 12-month'),
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amt = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
    if (amt <= 0) {
      setState(() => _err = 'Enter a valid purchase amount.');
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      final sid = context.read<SessionProvider>().smeId;
      String? selectedBnpl;
      for (final e in _bnplPlans) {
        if (e.key == _bnplChoice) {
          selectedBnpl = e.value;
          break;
        }
      }
      final res = await ApiService().predict(
        smeId: sid,
        purchaseAmount: amt,
        purchaseCategory: _category,
        selectedBnplPlan: selectedBnpl,
      );
      if (!mounted) return;
      context.read<RecommendationProvider>().setResult(res);
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.45,
          builder: (_, scroll) => ListView(
            controller: scroll,
            children: [
              RecommendationResultCard(result: res),
              ShapFactorsList(items: res.shapValues),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BNPL Purchase Simulator', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Model the impact of your next major business purchase. Our engine compares BNPL, '
            'micro-credit, and government programmes.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppTheme.teal,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Purchase amount',
                      prefixText: 'RM ',
                      helperText: 'Total invoice value before taxes.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Expense category'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _bnplChoice,
                    decoration: const InputDecoration(
                      labelText: 'Preferred BNPL plan (optional)',
                      helperText: 'Auto-select picks the lowest estimated BNPL cost.',
                    ),
                    items: _bnplPlans
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.key)))
                        .toList(),
                    onChanged: (v) => setState(() => _bnplChoice = v ?? _bnplChoice),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.iceBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.teal),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AI recommendation engine analyses this purchase against your '
                            'historical cash flow and limits.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_err != null) ...[
                    const SizedBox(height: 12),
                    Text(_err!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.lightbulb_outline),
                    label: Text(_busy ? 'Calculating…' : 'Calculate AI recommendation'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
