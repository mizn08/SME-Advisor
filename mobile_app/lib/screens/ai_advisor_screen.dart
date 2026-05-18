import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prediction.dart';
import '../providers/recommendation_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/recommendation_result.dart';

class AiAdvisorScreen extends StatelessWidget {
  const AiAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, rec, _) {
        final r = rec.lastResult;
        if (r == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology_alt, size: 64, color: AppTheme.teal),
                  const SizedBox(height: 16),
                  Text(
                    'Run a simulation to see AI recommendations and SHAP-style drivers here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('AI recommendation', style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            RecommendationResultCard(result: r),
            ShapFactorsList(items: r.shapValues),
            _financialBreakdown(r),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _financialBreakdown(PredictionResult r) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wallet, color: AppTheme.teal),
                SizedBox(width: 8),
                Text('Financial breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            _row('Simulated decision', r.recommendationType),
            _row('Product', r.productName),
            _row('Cash preserved (est.)', 'RM ${r.cashPreservedRm.toStringAsFixed(2)}'),
            _row('Additional cost (est.)', 'RM ${r.additionalCostRm.toStringAsFixed(2)}'),
            _row('Model financing probability', '${(r.mlProbability * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 160, child: Text(k, style: const TextStyle(color: Colors.black54))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}
