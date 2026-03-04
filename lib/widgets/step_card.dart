import 'package:flutter/material.dart';
import '../models/onboarding_step_model.dart';
import '../utils/theme.dart';

class StepCard extends StatelessWidget {
  final OnboardingStep step;
  final bool isLast;

  const StepCard({super.key, required this.step, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          Column(
            children: [
              _buildStepCircle(),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.isCompleted ? AppTheme.success : AppTheme.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step.isCurrent ? AppTheme.primarySurface : AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step.isCurrent ? AppTheme.primary.withOpacity(0.3) : AppTheme.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Step ${step.index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: step.isCurrent ? AppTheme.primary : AppTheme.textLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (step.isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'CURRENT',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            step.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: step.isLocked ? AppTheme.textLight : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (step.completedAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(step.completedAt!),
                              style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle() {
    Color bg;
    Color border;
    Widget child;

    if (step.isCompleted) {
      bg = AppTheme.success;
      border = AppTheme.success;
      child = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (step.isCurrent) {
      bg = AppTheme.primary;
      border = AppTheme.primary;
      child = const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
    } else {
      bg = AppTheme.white;
      border = AppTheme.border;
      child = Text(
        '${step.index + 1}',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textLight),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2),
      ),
      child: Center(child: child),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    Color bgColor;
    String label;

    switch (step.status) {
      case StepStatus.completed:
        color = AppTheme.success;
        bgColor = AppTheme.success.withOpacity(0.1);
        label = '✓ Done';
        break;
      case StepStatus.current:
        color = AppTheme.primary;
        bgColor = AppTheme.primarySurface;
        label = '⏳ Active';
        break;
      case StepStatus.locked:
        color = AppTheme.textLight;
        bgColor = AppTheme.surface;
        label = '🔒';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
