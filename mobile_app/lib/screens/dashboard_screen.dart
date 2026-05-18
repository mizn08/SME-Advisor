import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/dashboard.dart';
import '../providers/session_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/kpi_card.dart';
import '../widgets/monthly_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData? data;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final sid = context.read<SessionProvider>().smeId;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final d = await ApiService().fetchDashboard(sid);
      if (mounted) setState(() => data = d);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  int _healthScore(DashboardData d) {
    final liquidity = (d.currentRatio / 2).clamp(0.0, 1.0);
    final cash = (d.daysCashOnHand / 90).clamp(0.0, 1.0);
    final burnOk = d.burnRateMonthlyRm > 0 ? (1 - (d.expenseMtdRm / (d.burnRateMonthlyRm + 1)).clamp(0.0, 0.5)) : 0.5;
    final raw = (0.4 * liquidity + 0.45 * cash + 0.15 * burnOk) * 100;
    return raw.round().clamp(0, 100);
  }

  String _healthLabel(int s) {
    if (s >= 75) return 'GOOD';
    if (s >= 55) return 'FAIR';
    return 'WATCH';
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Overview', style: Theme.of(context).textTheme.headlineSmall),
                  Text('Data synced as of today.', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Could not load dashboard.\n$error', textAlign: TextAlign.center),
                ),
              ),
            )
          else if (data != null)
            SliverToBoxAdapter(child: _body(context, data!, currency)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, DashboardData d, NumberFormat currency) {
    final score = _healthScore(d);
    final label = _healthLabel(score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HealthScoreGauge(score: score, label: label),
                const SizedBox(height: 12),
                Text(
                  'Your business credit health snapshot. Maintain cash reserves aligned to burn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
        KPICard(
          title: '30-day cash posture (proxy)',
          value: currency.format(d.netOperatingCashRm),
          subtitle: 'Net operating cash (90d window)',
          leading: const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.teal),
          trend: Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade600, size: 18),
              Text(' ${d.revenueMtdRm > d.expenseMtdRm ? '+' : ''}MTD', style: TextStyle(color: Colors.green.shade700)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: KPICard(
                  title: 'Liquidity (proxy)',
                  value: d.currentRatio.toStringAsFixed(2),
                  subtitle: 'Inflow / burn proxy',
                  leading: const Icon(Icons.account_balance, color: AppTheme.teal),
                ),
              ),
              Expanded(
                child: KPICard(
                  title: 'Days cash on hand',
                  value: d.daysCashOnHand.toStringAsFixed(0),
                  subtitle: 'Estimated runway',
                  leading: const Icon(Icons.shield_moon_outlined, color: AppTheme.teal),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Revenue vs expenses', style: Theme.of(context).textTheme.titleMedium),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: MonthlyCashChart(points: d.monthlySeries),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
