import 'package:flutter/material.dart';

import '../models/prediction.dart';
import '../theme/app_theme.dart';

class RecommendationResultCard extends StatelessWidget {
  const RecommendationResultCard({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final ok = result.recommendationType != 'Cash';
    return PremiumCard(
      margin: const EdgeInsets.all(16),
      borderColor: ok ? AppTheme.accentGreen.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (ok ? AppTheme.accentGreen : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ok ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: ok ? AppTheme.accentGreen : Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.recommendationType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.productName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.teal),
          ),
          const SizedBox(height: 12),
          Text(result.explanation, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _chip('Cash preserved', 'RM ${result.cashPreservedRm.toStringAsFixed(2)}', Icons.savings_rounded),
              _chip('Extra cost', 'RM ${result.additionalCostRm.toStringAsFixed(2)}', Icons.receipt_long_rounded),
              _chip('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%', Icons.verified_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String k, String v, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.teal.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.teal.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.teal),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

class ShapFactorsList extends StatelessWidget {
  const ShapFactorsList({super.key, required this.items, this.title = 'AI Decision Factors'});

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
    return PremiumCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insights_rounded, color: AppTheme.teal, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              ShapFactorsList.narrative(items),
              style: TextStyle(color: Colors.grey.shade600, height: 1.4, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((s) {
            final pos = s.direction == 'positive';
            final w = (s.impact.abs() * 120).clamp(8.0, 120.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.feature.replaceAll('_', ' '),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: w,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: pos
                                ? [Colors.green.shade300, Colors.green.shade500]
                                : [Colors.red.shade200, Colors.red.shade400],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${s.impact >= 0 ? '+' : ''}${s.impact.toStringAsFixed(2)} impact',
                        style: TextStyle(
                          fontSize: 12,
                          color: pos ? Colors.green.shade700 : Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
