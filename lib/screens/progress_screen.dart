import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_step_model.dart';
import '../utils/theme.dart';
import '../widgets/progress_header.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: const Text('Progress'),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: TextButton.icon(
                  onPressed: () => _showStepDetails(context, provider),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              ProgressHeader(
                progress: provider.progressPercentage,
                currentStep: provider.completedStepsCount,
                totalSteps: provider.totalStepsCount,
                label: 'Onboarding Progress',
              ),
              const SizedBox(height: 24),
              _buildEstimatedCompletion(provider),
              const SizedBox(height: 24),
              const Text(
                'All Steps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildTimeline(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstimatedCompletion(OnboardingProvider provider) {
    final completed = provider.completedStepsCount;
    final total = provider.totalStepsCount;
    final remaining = total - completed;
    final daysEstimate = remaining * 1; // 1 business day per step on average

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Completion',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining == 0
                      ? 'Completed!'
                      : '~$daysEstimate business days',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Onboarding Status',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: remaining == 0
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    remaining == 0 ? '✓ Complete' : '⏳ In Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: remaining == 0 ? AppTheme.success : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(OnboardingProvider provider) {
    return Column(
      children: provider.steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == provider.steps.length - 1;
        return _TimelineItem(step: step, isLast: isLast);
      }).toList(),
    );
  }

  void _showStepDetails(BuildContext context, OnboardingProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Step Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: provider.steps.length,
                itemBuilder: (_, i) {
                  final step = provider.steps[i];
                  return _StepDetailCard(step: step);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final OnboardingStep step;
  final bool isLast;

  const _TimelineItem({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: line + dot
          SizedBox(
            width: 44,
            child: Column(
              children: [
                // Top line
                if (step.index > 0)
                  Container(
                    width: 2,
                    height: 12,
                    color: step.isCompleted || step.isCurrent
                        ? AppTheme.primary.withOpacity(0.3)
                        : AppTheme.border,
                  )
                else
                  const SizedBox(height: 12),
                // Dot/circle
                _buildCircle(),
                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.isCompleted ? AppTheme.primary.withOpacity(0.3) : AppTheme.border,
                    ),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 4, top: 4),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    if (step.isCompleted) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    } else if (step.isCurrent) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primary, width: 2.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
          ),
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: Center(
          child: Text(
            '${step.index + 1}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textLight),
          ),
        ),
      );
    }
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: step.isCurrent ? AppTheme.primarySurface : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: step.isCurrent ? AppTheme.primary.withOpacity(0.25) : AppTheme.border,
          width: step.isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: step.isLocked ? AppTheme.textLight : AppTheme.textPrimary,
                  ),
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            step.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
          ),
          if (step.completedAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(
                  _formatDate(step.completedAt!),
                  style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    switch (step.status) {
      case StepStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('✓ Completed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
        );
      case StepStatus.current:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('⏳ Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
        );
      case StepStatus.locked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Text('🔒 Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StepDetailCard extends StatelessWidget {
  final OnboardingStep step;

  const _StepDetailCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: step.isCompleted
            ? AppTheme.success.withOpacity(0.05)
            : step.isCurrent
                ? AppTheme.primarySurface
                : AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: step.isCompleted
              ? AppTheme.success.withOpacity(0.2)
              : step.isCurrent
                  ? AppTheme.primary.withOpacity(0.25)
                  : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Text(step.statusIcon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Step ${step.index + 1}: ${step.name}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(step.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: step.isCompleted ? AppTheme.success : step.isCurrent ? AppTheme.primary : AppTheme.textLight,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
