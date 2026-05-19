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
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.analytics_rounded, color: AppTheme.teal, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            raw['product_name'] as String? ?? 'Prediction',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      raw['explanation'] as String? ?? '',
                      style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    ShapFactorsList(items: shap),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppTheme.teal));
    if (err != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(err!, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }
    final acc = ((metrics?['overall_accuracy'] as num?)?.toDouble() ?? 0) * 100;
    final f1 = (metrics?['f1_score'] as num?)?.toDouble() ?? 0;
    final fi = (metrics?['feature_importance'] as List<dynamic>? ?? []);

    return RefreshIndicator(
      color: AppTheme.teal,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Model Performance',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Transparency metrics for the advisory engine.',
            style: TextStyle(color: Colors.grey.shade500, height: 1.4),
          ),
          const SizedBox(height: 16),

          // ── Accuracy hero ──
          PremiumCard(
            margin: const EdgeInsets.only(bottom: 8),
            gradient: AppTheme.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.verified_rounded, color: AppTheme.tealAccent, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'OVERALL ACCURACY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${acc.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
                ),
                const SizedBox(height: 6),
                Text(
                  metrics?['accuracy_trend'] as String? ?? '',
                  style: TextStyle(color: AppTheme.tealAccent.withOpacity(0.9), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ── F1 + Data points ──
          Row(
            children: [
              Expanded(
                child: PremiumCard(
                  margin: const EdgeInsets.only(right: 4, top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search_rounded, color: AppTheme.teal, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text('F1 Score', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(
                        f1.toStringAsFixed(2),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('Precision & recall', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PremiumCard(
                  margin: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.storage_rounded, color: AppTheme.teal, size: 20),
                      ),
                      const SizedBox(height: 10),
                      Text('Data Points', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      Text(
                        '${metrics?['data_points_analyzed']}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('Synthetic + SME', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Feature importance ──
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Feature Importance',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${fi.length} features',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.teal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PremiumCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                for (final raw in fi)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${((raw as Map)['weight_pct'] as num?)?.toStringAsFixed(0) ?? '0'}%',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.teal),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (((raw as Map)['weight_pct'] as num?)?.toDouble() ?? 0) / 100.0,
                            minHeight: 8,
                            color: AppTheme.teal,
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── History ──
          const SizedBox(height: 8),
          Text(
            'Prediction History',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            PremiumCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'No predictions yet. Run the simulator.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            ...history.map(
              (h) => PremiumCard(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openDetail(h.id),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.insights_rounded, color: AppTheme.teal, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              DateFormat.yMMMd().format(h.createdAt),
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          h.recommendationType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
