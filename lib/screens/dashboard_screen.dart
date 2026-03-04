import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_step_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/progress_header.dart';
import '../widgets/info_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final merchant = provider.merchant;
        final currentStep = provider.steps.firstWhere(
          (s) => s.isCurrent,
          orElse: () => provider.steps.last,
        );

        return Scaffold(
          backgroundColor: AppTheme.white,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, provider),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 20),
                    _buildGreeting(merchant.contactPerson),
                    const SizedBox(height: 20),
                    ProgressHeader(
                      progress: provider.progressPercentage,
                      currentStep: provider.completedStepsCount,
                      totalSteps: provider.totalStepsCount,
                    ),
                    const SizedBox(height: 24),
                    _buildCurrentStep(context, currentStep, provider),
                    const SizedBox(height: 24),
                    _buildQuickStats(provider),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, provider),
                    const SizedBox(height: 24),
                    _buildRecentSteps(provider),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, OnboardingProvider provider) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.white,
      elevation: 0,
      expandedHeight: 0,
      pinned: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 20),
        ),
      ),
      title: const Text(
        'SmartOne',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.textSecondary),
          onPressed: () => Navigator.pushNamed(context, AppConstants.routeAdmin),
          tooltip: 'Demo Admin Panel',
        ),
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.person_outline, size: 20, color: AppTheme.textSecondary),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    final displayName = name.isNotEmpty ? name.split(' ').first : 'Merchant';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $displayName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's your onboarding status",
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(BuildContext context, OnboardingStep step, OnboardingProvider provider) {
    return GestureDetector(
      onTap: () => _handleStepTap(context, step, provider),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5A19B5), Color(0xFF7B3FD4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⏳  CURRENT STEP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  'Step ${step.index + 1}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              step.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              step.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleStepTap(context, step, provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Take Action →',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleStepTap(BuildContext context, OnboardingStep step, OnboardingProvider provider) {
    switch (step.index) {
      case 0:
        Navigator.pushNamed(context, AppConstants.routeApplication);
        break;
      case 1:
        Navigator.pushNamed(context, AppConstants.routeDocuments);
        break;
      case 2:
        Navigator.pushNamed(context, AppConstants.routeKyc);
        break;
      case 6:
        Navigator.pushNamed(context, AppConstants.routeContract);
        break;
      default:
        _showStepInfo(context, step);
    }
  }

  void _showStepInfo(BuildContext context, OnboardingStep step) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      step.statusIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Step ${step.index + 1}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      Text(step.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(step.description,
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'SmartOne team will notify you when this step requires your action.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(OnboardingProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${provider.completedStepsCount}/${provider.totalStepsCount}',
            label: 'Steps Done',
            icon: Icons.checklist_rounded,
            color: AppTheme.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '${provider.uploadedDocumentsCount}/${provider.totalDocumentsCount}',
            label: 'Documents',
            icon: Icons.folder_outlined,
            color: AppTheme.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '${(provider.progressPercentage * 100).round()}%',
            label: 'Complete',
            icon: Icons.pie_chart_outline,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        InfoCard(
          icon: Icons.upload_file_outlined,
          title: 'Upload Documents',
          subtitle: '${provider.uploadedDocumentsCount} of ${provider.totalDocumentsCount} uploaded',
          iconColor: AppTheme.warning,
          iconBg: AppTheme.warning.withOpacity(0.1),
          onTap: () => Navigator.pushNamed(context, AppConstants.routeDocuments),
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.verified_user_outlined,
          title: 'KYC Verification',
          subtitle: provider.kycCompleted ? 'Completed' : 'Required – via iDenfy',
          iconColor: provider.kycCompleted ? AppTheme.success : AppTheme.primary,
          iconBg: provider.kycCompleted
              ? AppTheme.success.withOpacity(0.1)
              : AppTheme.primarySurface,
          onTap: () => Navigator.pushNamed(context, AppConstants.routeKyc),
          trailing: provider.kycCompleted
              ? const Icon(Icons.check_circle, color: AppTheme.success, size: 22)
              : null,
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.description_outlined,
          title: 'Contract Signing',
          subtitle: provider.contractSigned ? 'Signed' : 'Pending Paynetics approval',
          iconColor: provider.contractSigned ? AppTheme.success : AppTheme.textLight,
          iconBg: provider.contractSigned
              ? AppTheme.success.withOpacity(0.1)
              : AppTheme.surface,
          onTap: () => Navigator.pushNamed(context, AppConstants.routeContract),
        ),
      ],
    );
  }

  Widget _buildRecentSteps(OnboardingProvider provider) {
    final visibleSteps = provider.steps.where((s) => !s.isLocked).toList();
    if (visibleSteps.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            Text(
              '${provider.completedStepsCount} completed',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...provider.steps.take(6).map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: step.isCurrent ? AppTheme.primarySurface : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.isCurrent
                      ? AppTheme.primary.withOpacity(0.25)
                      : AppTheme.border,
                ),
              ),
              child: Row(
                children: [
                  _buildMiniStepIcon(step),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: step.isCurrent ? FontWeight.w600 : FontWeight.w500,
                        color: step.isLocked ? AppTheme.textLight : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    step.statusIcon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }),
        if (provider.steps.length > 6)
          Center(
            child: TextButton(
              onPressed: () {
                // Switch to progress tab
                Provider.of<OnboardingProvider>(
                  // ignore: use_build_context_synchronously
                  // This is fine as onPressed is synchronous
                  context as BuildContext,
                  listen: false,
                ).setTabIndex(2);
              },
              child: const Text('View all steps →', style: TextStyle(color: AppTheme.primary)),
            ),
          ),
      ],
    );
  }

  Widget _buildMiniStepIcon(step) {
    if (step.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    } else if (step.isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.radio_button_checked, color: Colors.white, size: 14),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Center(
          child: Text(
            '${step.index + 1}',
            style: const TextStyle(fontSize: 10, color: AppTheme.textLight),
          ),
        ),
      );
    }
  }
}
