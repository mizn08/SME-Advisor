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

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  DashboardData? data;
  String? error;
  bool loading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sid = context.read<SessionProvider>().smeId;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final d = await ApiService().fetchDashboard(sid);
      if (mounted) {
        setState(() => data = d);
        _animCtrl.forward(from: 0);
      }
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
      color: AppTheme.teal,
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppTheme.accentGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live · Data synced as of today',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.teal)))
          else if (error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load dashboard',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),
            )
          else if (data != null)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _body(context, data!, currency),
              ),
            ),
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
        const SizedBox(height: 8),
        if (d.alerts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Material(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                title: Text(d.alerts.first, style: TextStyle(fontSize: 13, color: Colors.orange.shade900)),
                subtitle: d.runwayDaysEst != null
                    ? Text('Runway ~${d.runwayDaysEst!.toStringAsFixed(0)} days · ${d.anomalyCount} anomalies')
                    : null,
              ),
            ),
          ),
        // ── Health score hero card ──
        PremiumCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              HealthScoreGauge(score: score, label: label),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.iceBlue.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.teal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Business credit health snapshot. Maintain cash reserves aligned to burn rate.',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Cash posture ──
        KPICard(
          title: '30-day cash posture',
          value: currency.format(d.netOperatingCashRm),
          subtitle: 'Net operating cash (90d window)',
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.teal, size: 20),
          ),
          trend: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up_rounded, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${d.revenueMtdRm > d.expenseMtdRm ? '+' : ''}MTD',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        // ── Two-up KPIs ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: KPICard(
                  title: 'Liquidity',
                  value: d.currentRatio.toStringAsFixed(2),
                  subtitle: 'Inflow / burn proxy',
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppTheme.teal, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: KPICard(
                  title: 'Days cash on hand',
                  value: d.daysCashOnHand.toStringAsFixed(0),
                  subtitle: 'Estimated runway',
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shield_rounded, color: AppTheme.teal, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ── Chart section ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Text(
                'Revenue vs Expenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('12M', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.teal)),
              ),
            ],
          ),
        ),
        PremiumCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          child: MonthlyCashChart(points: d.monthlySeries),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
