import 'package:flutter/material.dart';

import '../models/prediction.dart';
import '../theme/app_theme.dart';

class RecommendationResultCard extends StatelessWidget {
  const RecommendationResultCard({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final ok = result.recommendationType != 'Cash';
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.info_outline, color: ok ? AppTheme.accentGreen : Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.recommendationType,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(result.productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(result.explanation),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _chip('Cash preserved', 'RM ${result.cashPreservedRm.toStringAsFixed(2)}'),
                _chip('Extra cost (est.)', 'RM ${result.additionalCostRm.toStringAsFixed(2)}'),
                _chip('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String k, String v) => Chip(
        label: Text('$k: $v'),
        backgroundColor: AppTheme.iceBlue,
      );
}

class ShapFactorsList extends StatelessWidget {
  const ShapFactorsList({super.key, required this.items, this.title = 'AI decision factors'});

  final List<ShapItem> items;
  final String title;

  static String narrative(List<ShapItem> items) {
    if (items.isEmpty) return 'No factor breakdown available.';
    final parts = <String>[];
    for (final s in items.take(3)) {
      final dir = s.direction == 'positive' ? 'pushes toward financing' : 'pulls toward paying cash';
      String human = s.feature;
      if (s.feature == 'days_cash_on_hand') {
        human = 'days cash on hand (${s.value.toStringAsFixed(1)} days)';
      } else if (s.feature == 'purchase_to_burn') {
        human = 'purchase size vs monthly burn (${s.value.toStringAsFixed(2)}×)';
      } else if (s.feature == 'current_ratio') {
        human = 'liquidity ratio (${s.value.toStringAsFixed(2)})';
      }
      parts.add('$human $dir');
    }
    return 'Why this outcome: ${parts.join('; ')}.';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              ShapFactorsList.narrative(items),
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
            const SizedBox(height: 12),
            ...items.map((s) {
              final pos = s.direction == 'positive';
              final w = (s.impact.abs() * 120).clamp(8.0, 120.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.feature.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: w,
                          height: 8,
                          decoration: BoxDecoration(
                            color: pos ? Colors.green.shade400 : Colors.red.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${s.impact >= 0 ? '+' : ''}${s.impact.toStringAsFixed(2)} impact',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
