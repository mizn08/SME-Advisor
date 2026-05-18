class MonthlyPoint {
  MonthlyPoint({required this.month, required this.revenueRm, required this.expenseRm});
  final String month;
  final double revenueRm;
  final double expenseRm;

  factory MonthlyPoint.fromJson(Map<String, dynamic> j) => MonthlyPoint(
        month: j['month'] as String,
        revenueRm: (j['revenue_rm'] as num).toDouble(),
        expenseRm: (j['expense_rm'] as num).toDouble(),
      );
}

class DashboardData {
  DashboardData({
    required this.smeId,
    required this.businessName,
    required this.industry,
    required this.currentRatio,
    required this.daysCashOnHand,
    required this.burnRateMonthlyRm,
    required this.revenueMtdRm,
    required this.expenseMtdRm,
    required this.netOperatingCashRm,
    required this.monthlySeries,
  });

  final int smeId;
  final String businessName;
  final String industry;
  final double currentRatio;
  final double daysCashOnHand;
  final double burnRateMonthlyRm;
  final double revenueMtdRm;
  final double expenseMtdRm;
  final double netOperatingCashRm;
  final List<MonthlyPoint> monthlySeries;

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final kpis = j['kpis'] as Map<String, dynamic>;
    final series = (j['monthly_series'] as List<dynamic>? ?? [])
        .map((e) => MonthlyPoint.fromJson(e as Map<String, dynamic>))
        .toList();
    return DashboardData(
      smeId: j['sme_id'] as int,
      businessName: j['business_name'] as String,
      industry: j['industry'] as String,
      currentRatio: (kpis['current_ratio'] as num).toDouble(),
      daysCashOnHand: (kpis['days_cash_on_hand'] as num).toDouble(),
      burnRateMonthlyRm: (kpis['burn_rate_monthly_rm'] as num).toDouble(),
      revenueMtdRm: (kpis['revenue_mtd_rm'] as num).toDouble(),
      expenseMtdRm: (kpis['expense_mtd_rm'] as num).toDouble(),
      netOperatingCashRm: (kpis['net_operating_cash_rm'] as num).toDouble(),
      monthlySeries: series,
    );
  }
}
