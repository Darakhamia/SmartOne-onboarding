import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_step_model.dart';
import '../utils/theme.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEMO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.warning, letterSpacing: 1),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Admin Panel'),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildAdminBanner(),
              const SizedBox(height: 24),
              _buildQuickActions(context, provider),
              const SizedBox(height: 24),
              const Text(
                'Onboarding Steps Control',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap any step to change its status and simulate the onboarding flow.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ...provider.steps.map((step) => _buildStepControl(context, step, provider)),
              const SizedBox(height: 24),
              _buildDocumentControls(provider),
              const SizedBox(height: 24),
              _buildKycControls(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdminBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.warning.withOpacity(0.15), AppTheme.warning.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.admin_panel_settings_outlined, color: AppTheme.warning, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Admin Panel',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.warning),
                ),
                SizedBox(height: 4),
                Text(
                  'This panel allows you to manually control the onboarding flow for demonstration purposes. No real backend calls are made.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Scenarios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _scenarioChip('Reset to Start', Icons.refresh, AppTheme.error, () {
              _applyScenario(provider, 0);
            }),
            _scenarioChip('Step 4: AML Review', Icons.search, AppTheme.warning, () {
              _applyScenario(provider, 3);
            }),
            _scenarioChip('Step 7: Contract', Icons.description, AppTheme.primary, () {
              _applyScenario(provider, 6);
            }),
            _scenarioChip('Step 9: Terminal Prep', Icons.point_of_sale, Colors.teal, () {
              _applyScenario(provider, 8);
            }),
            _scenarioChip('All Complete!', Icons.celebration, AppTheme.success, () {
              _completeAll(provider);
            }),
          ],
        ),
      ],
    );
  }

  Widget _scenarioChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildStepControl(BuildContext context, OnboardingStep step, OnboardingProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: step.isCurrent ? AppTheme.primarySurface : AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: step.isCurrent ? AppTheme.primary.withOpacity(0.3) : AppTheme.border,
          width: step.isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Step number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _stepColor(step).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${step.index + 1}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _stepColor(step)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(step.statusLabel, style: TextStyle(fontSize: 11, color: _stepColor(step))),
              ],
            ),
          ),
          // Status controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statusButton('✓', step.isCompleted, AppTheme.success, () {
                provider.setStepStatus(step.index, StepStatus.completed);
              }),
              const SizedBox(width: 4),
              _statusButton('⏳', step.isCurrent, AppTheme.primary, () {
                provider.setStepStatus(step.index, StepStatus.current);
              }),
              const SizedBox(width: 4),
              _statusButton('🔒', step.isLocked, AppTheme.textLight, () {
                provider.setStepStatus(step.index, StepStatus.locked);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String emoji, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : AppTheme.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildDocumentControls(OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Document Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Documents uploaded', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    '${provider.uploadedDocumentsCount}/${provider.totalDocumentsCount}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...provider.documents.asMap().entries.map((entry) {
                final i = entry.key;
                final doc = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(doc.name, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ),
                      GestureDetector(
                        onTap: doc.isUploaded
                            ? null
                            : () => provider.uploadDocument(i, 'mock_doc_${i + 1}.pdf'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: doc.isUploaded ? AppTheme.success.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            doc.isUploaded ? '✓ Done' : '+ Upload',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: doc.isUploaded ? AppTheme.success : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKycControls(OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('KYC & Contract Controls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('KYC Verification', style: TextStyle(fontSize: 13)),
                  GestureDetector(
                    onTap: provider.kycCompleted ? null : provider.completeKyc,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: provider.kycCompleted
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.kycCompleted ? '✓ Completed' : 'Mark Complete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: provider.kycCompleted ? AppTheme.success : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Contract Signing', style: TextStyle(fontSize: 13)),
                  GestureDetector(
                    onTap: provider.contractSigned ? null : provider.signContract,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: provider.contractSigned
                            ? AppTheme.success.withOpacity(0.1)
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.contractSigned ? '✓ Signed' : 'Mark Signed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: provider.contractSigned ? AppTheme.success : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Color _stepColor(OnboardingStep step) {
    if (step.isCompleted) return AppTheme.success;
    if (step.isCurrent) return AppTheme.primary;
    return AppTheme.textLight;
  }

  void _applyScenario(OnboardingProvider provider, int targetStep) {
    provider.setStepStatus(targetStep, StepStatus.current);
  }

  void _completeAll(OnboardingProvider provider) {
    for (int i = 0; i < provider.steps.length; i++) {
      provider.setStepStatus(i, StepStatus.completed);
    }
  }
}
