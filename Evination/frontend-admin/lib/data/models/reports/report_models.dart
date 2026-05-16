class DashboardStats {
  final int totalEvents;
  final int activeEvents;
  final int completedEvents;
  final double totalBudget;
  final double totalRevenue;
  final int totalVendors;
  final int pendingBids;

  DashboardStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.completedEvents,
    required this.totalBudget,
    required this.totalRevenue,
    required this.totalVendors,
    required this.pendingBids,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEvents: json['totalEvents'] ?? 0,
      activeEvents: json['activeEvents'] ?? 0,
      completedEvents: json['completedEvents'] ?? 0,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(), // typo fix in backend?
      totalVendors: json['totalVendors'] ?? 0,
      pendingBids: json['pendingBids'] ?? 0,
    );
  }
}

class PerformanceReport {
  final List<TopVendor> topVendors;

  PerformanceReport({required this.topVendors});

  factory PerformanceReport.fromJson(Map<String, dynamic> json) {
    return PerformanceReport(
      topVendors: (json['topVendors'] as List?)?.map((e) => TopVendor.fromJson(e)).toList() ?? [],
    );
  }
}

class TopVendor {
  final String name;
  final int orders;
  final double value;

  TopVendor({required this.name, required this.orders, required this.value});

  factory TopVendor.fromJson(Map<String, dynamic> json) {
    return TopVendor(
      name: json['name'] ?? 'Unknown',
      orders: json['orders'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}

class ProfitLossReport {
  final double grossTransactionValue;
  final double vendorPayoutsEstimated;
  final double platformRevenue;
  final double platformExpenses;
  final double netProfit;
  final double profitMargin;

  ProfitLossReport({
    required this.grossTransactionValue,
    required this.vendorPayoutsEstimated,
    required this.platformRevenue,
    required this.platformExpenses,
    required this.netProfit,
    required this.profitMargin,
  });

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    return ProfitLossReport(
      grossTransactionValue: (json['gross_transaction_value'] ?? 0).toDouble(),
      vendorPayoutsEstimated: (json['vendor_payouts_estimated'] ?? 0).toDouble(),
      platformRevenue: (json['platform_revenue'] ?? 0).toDouble(),
      platformExpenses: (json['platform_expenses'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0).toDouble(),
    );
  }
}

class DashboardCharts {
  final List<ChartItem> eventsByStatus;
  final List<ChartItem> budgetVsActual;
  final List<ChartItem> monthlyRevenue;

  DashboardCharts({
    required this.eventsByStatus,
    required this.budgetVsActual,
    required this.monthlyRevenue,
  });

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      eventsByStatus: (json['eventsByStatus'] as List?)?.map((e) => ChartItem.fromJson(e)).toList() ?? [],
      budgetVsActual: (json['budgetVsActual'] as List?)?.map((e) => ChartItem.fromJson(e)).toList() ?? [],
      monthlyRevenue: (json['monthlyRevenue'] as List?)?.map((e) => ChartItem.fromJson(e)).toList() ?? [],
    );
  }
}

class ChartItem {
  final String label;
  final double value;

  ChartItem({required this.label, required this.value});

  factory ChartItem.fromJson(Map<String, dynamic> json) {
    return ChartItem(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}
