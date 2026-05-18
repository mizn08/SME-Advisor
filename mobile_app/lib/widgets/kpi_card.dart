import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class KPICard extends StatelessWidget {
  const KPICard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.leading,
    this.trend,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Widget? leading;
  final Widget? trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black45,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
                if (trend != null) trend!,
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitle!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class HealthScoreGauge extends StatelessWidget {
  const HealthScoreGauge({super.key, required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final pct = (score.clamp(0, 100)) / 100.0;
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 12,
              backgroundColor: AppTheme.iceBlue,
              color: AppTheme.teal,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
