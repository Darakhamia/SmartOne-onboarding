import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/onboarding_provider.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Transaction>> _txnFuture;
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _txnFuture = ApiService.getTransactions();
      _statsFuture = ApiService.getStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final merchant = provider.merchant;
        final completedSteps = provider.completedStepsCount;
        final totalSteps = provider.totalStepsCount;
        final progressPct =
            totalSteps > 0 ? (completedSteps / totalSteps * 100).round() : 0;
        final docsUploaded = provider.uploadedDocumentsCount;
        final totalDocs = provider.totalDocumentsCount;

        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async => _load(),
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF5A19B5), Color(0xFF8B4FD8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${merchant?.companyName.split(' ').first ?? 'Merchant'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('EEEE, dd MMMM')
                                        .format(DateTime.now()),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.radio_button_checked,
                                            size: 10,
                                            color: Color(0xFF00C896)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Step ${completedSteps + 1} of $totalSteps',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  merchant?.companyName.isNotEmpty == true
                                      ? merchant!.companyName[0].toUpperCase()
                                      : 'M',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Stat cards ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _statsFuture,
                    builder: (ctx, snap) {
                      final vol =
                          (snap.data?['total_volume'] as double?) ?? 0.0;
                      final count =
                          (snap.data?['total_count'] as int?) ?? 0;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.55,
                          children: [
                            _StatCard(
                              label: 'Total Volume',
                              value: '€${vol.toStringAsFixed(0)}',
                              icon: Icons.euro_rounded,
                              color: AppTheme.primary,
                            ),
                            _StatCard(
                              label: 'Transactions',
                              value: '$count',
                              icon: Icons.receipt_long_rounded,
                              color: AppTheme.accent,
                            ),
                            _StatCard(
                              label: 'Progress',
                              value: '$progressPct%',
                              icon: Icons.trending_up_rounded,
                              color: AppTheme.success,
                              subtitle: '$completedSteps/$totalSteps steps',
                            ),
                            _StatCard(
                              label: 'Documents',
                              value: '$docsUploaded/$totalDocs',
                              icon: Icons.folder_rounded,
                              color: AppTheme.warning,
                              subtitle: docsUploaded == totalDocs
                                  ? 'All uploaded'
                                  : '${totalDocs - docsUploaded} remaining',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── KYC Banner ───────────────────────────────────────────────
                if (provider.merchant != null &&
                    provider.merchant!.isSubmitted &&
                    !provider.kycCompleted)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context, AppConstants.routeKyc),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A1033), Color(0xFF3B1F7A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                    Icons.verified_user_rounded,
                                    color: Colors.white,
                                    size: 22),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Complete KYC Verification',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    SizedBox(height: 3),
                                    Text('Verify your identity to activate your account',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white54, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Weekly chart ─────────────────────────────────────────────
                const SliverToBoxAdapter(child: _WeeklyChart()),

                // ── Current step card ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _CurrentStepCard(provider: provider),
                  ),
                ),

                // ── Recent transactions ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: FutureBuilder<List<Transaction>>(
                    future: _txnFuture,
                    builder: (ctx, snap) {
                      final txns = (snap.data ?? Transaction.mockData())
                          .take(3)
                          .toList();
                      return _RecentTransactions(
                        transactions: txns,
                        onViewAll: () => provider.setTabIndex(1),
                      );
                    },
                  ),
                ),

                // ── Quick actions ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: _QuickActions(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                subtitle ?? label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Weekly chart ─────────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart();

  static const List<double> _data = [890, 1200, 750, 1450, 980, 1680, 1100];
  static const List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    const maxY = 1680.0 * 1.3;
    final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Weekly Revenue',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              const Text('Last 7 days',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '€${rod.toY.toInt()}',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= _days.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _days[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: i == todayIdx
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: i == todayIdx
                                  ? AppTheme.primary
                                  : AppTheme.textLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  7,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _data[i],
                        color: i == todayIdx
                            ? AppTheme.primary
                            : AppTheme.primary.withOpacity(0.35),
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Current step card ─────────────────────────────────────────────────────────

class _CurrentStepCard extends StatelessWidget {
  final OnboardingProvider provider;
  const _CurrentStepCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final stepIdx = provider.currentStepIndex;
    final step = provider.steps.isNotEmpty ? provider.steps[stepIdx] : null;
    final progress = provider.totalStepsCount > 0
        ? provider.completedStepsCount / provider.totalStepsCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D0E8A), Color(0xFF5A19B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Current Step',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            step?.name ?? 'Loading…',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            step?.description ?? '',
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00C896)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent transactions ───────────────────────────────────────────────────────

class _RecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback onViewAll;

  const _RecentTransactions(
      {required this.transactions, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                const Text('Recent Transactions',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('View all',
                      style:
                          TextStyle(fontSize: 13, color: AppTheme.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No transactions yet',
                  style: TextStyle(color: AppTheme.textLight)),
            )
          else
            ...transactions.asMap().entries.map((e) {
              final isLast = e.key == transactions.length - 1;
              final t = e.value;
              return Column(
                children: [
                  _MiniTxnTile(
                    t: t,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              TransactionDetailScreen(transaction: t)),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, indent: 68, endIndent: 16),
                ],
              );
            }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MiniTxnTile extends StatelessWidget {
  final Transaction t;
  final VoidCallback onTap;
  const _MiniTxnTile({required this.t, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(t.typeIcon, color: t.typeColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.description,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  Text(t.outlet,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Text(
              t.formattedAmount,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: t.type == 'REFUND'
                    ? AppTheme.warning
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
          icon: Icons.upload_file_rounded,
          label: 'Upload\nDocuments',
          color: AppTheme.primary,
          route: AppConstants.routeDocuments),
      _Action(
          icon: Icons.verified_user_rounded,
          label: 'KYC\nVerification',
          color: AppTheme.success,
          route: AppConstants.routeKyc),
      _Action(
          icon: Icons.description_rounded,
          label: 'Sign\nContract',
          color: AppTheme.warning,
          route: AppConstants.routeContract),
      _Action(
          icon: Icons.headset_mic_rounded,
          label: 'Get\nSupport',
          color: AppTheme.accent,
          tab: 3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: actions.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < actions.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () {
                    if (a.route != null) {
                      Navigator.pushNamed(context, a.route!);
                    } else if (a.tab != null) {
                      Provider.of<OnboardingProvider>(context, listen: false)
                          .setTabIndex(a.tab!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(a.icon, color: a.color, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  final int? tab;
  const _Action(
      {required this.icon,
      required this.label,
      required this.color,
      this.route,
      this.tab});
}
