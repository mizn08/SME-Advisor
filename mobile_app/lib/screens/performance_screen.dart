import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/prediction.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/recommendation_result.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  Map<String, dynamic>? metrics;
  List<PredictionHistoryItem> history = [];
  String? err;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final sid = context.read<SessionProvider>().smeId;
    setState(() {
      loading = true;
      err = null;
    });
    try {
      final api = ApiService();
      final m = await api.fetchModelMetrics();
      final h = await api.fetchHistory(sid);
      setState(() {
        metrics = m;
        history = h;
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _openDetail(int id) async {
    try {
      final raw = await ApiService().fetchPredictionDetail(id);
      if (!mounted) return;
      final shap = (raw['shap_values'] as List<dynamic>? ?? [])
          .map((e) => ShapItem.fromJson(e as Map<String, dynamic>))
          .toList();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(raw['product_name'] as String? ?? 'Prediction'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(raw['explanation'] as String? ?? ''),
                const SizedBox(height: 12),
                ShapFactorsList(items: shap),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (err != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(err!)));
    }
    final acc = ((metrics?['overall_accuracy'] as num?)?.toDouble() ?? 0) * 100;
    final f1 = (metrics?['f1_score'] as num?)?.toDouble() ?? 0;
    final fi = (metrics?['feature_importance'] as List<dynamic>? ?? []);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Model performance', style: Theme.of(context).textTheme.headlineSmall),
          Text(
            'Transparency metrics for the advisory engine (demo values + live history).',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, color: AppTheme.accentGreen),
                      const SizedBox(width: 8),
                      Text('OVERALL ACCURACY', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  Text('${acc.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.displaySmall),
                  Text(
                    metrics?['accuracy_trend'] as String? ?? '',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.search, color: AppTheme.teal),
                        const Text('F1 score'),
                        Text(f1.toStringAsFixed(2), style: Theme.of(context).textTheme.titleLarge),
                        const Text('Balanced precision & recall', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.storage, color: AppTheme.teal),
                        const Text('Data points'),
                        Text('${metrics?['data_points_analyzed']}', style: Theme.of(context).textTheme.titleLarge),
                        const Text('Synthetic + SME records', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Feature importance (weights)', style: Theme.of(context).textTheme.titleMedium),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final raw in fi)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (raw as Map)['name'] as String? ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                ),
                              ),
                              Text('${((raw as Map)['weight_pct'] as num?)?.toStringAsFixed(0) ?? '0'}%'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (((raw as Map)['weight_pct'] as num?)?.toDouble() ?? 0) / 100.0,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            color: AppTheme.accentGreen,
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Prediction history', style: Theme.of(context).textTheme.titleMedium),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No predictions yet. Run the simulator.'),
            )
          else
            ...history.map(
              (h) => ListTile(
                title: Text(h.productName),
                subtitle: Text(DateFormat.yMMMd().format(h.createdAt)),
                trailing: Text(h.recommendationType),
                onTap: () => _openDetail(h.id),
              ),
            ),
        ],
      ),
    );
  }
}
