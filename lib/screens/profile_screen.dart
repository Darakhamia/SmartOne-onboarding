import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/info_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final merchant = provider.merchant;

        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: const Text('Profile'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pushNamed(context, AppConstants.routeAdmin),
                tooltip: 'Admin Panel',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              _buildProfileHeader(merchant),
              const SizedBox(height: 24),
              _buildMerchantDetails(merchant),
              const SizedBox(height: 24),
              _buildOnboardingStats(provider),
              const SizedBox(height: 24),
              _buildSettings(context, provider),
              const SizedBox(height: 24),
              _buildLogout(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(merchant) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                merchant.contactPerson.isNotEmpty
                    ? merchant.contactPerson[0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.contactPerson.isNotEmpty ? merchant.contactPerson : 'Merchant',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  merchant.email.isNotEmpty ? merchant.email : 'No email provided',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MERCHANT ACCOUNT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantDetails(merchant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Business Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              _detailRow(Icons.business_outlined, 'Company', merchant.companyName.isNotEmpty ? merchant.companyName : 'N/A'),
              const Divider(height: 20),
              _detailRow(Icons.badge_outlined, 'Company ID', merchant.companyId.isNotEmpty ? merchant.companyId : 'N/A'),
              const Divider(height: 20),
              _detailRow(Icons.receipt_long_outlined, 'TIN', merchant.tin.isNotEmpty ? merchant.tin : 'N/A'),
              const Divider(height: 20),
              _detailRow(Icons.phone_outlined, 'Phone', merchant.phone.isNotEmpty ? merchant.phone : 'N/A'),
              const Divider(height: 20),
              _detailRow(Icons.location_city_outlined, 'City', merchant.city.isNotEmpty ? merchant.city : 'N/A'),
              const Divider(height: 20),
              _detailRow(Icons.store_outlined, 'Retail Type', merchant.retailType.isNotEmpty ? merchant.retailType : 'N/A'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnboardingStats(OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Onboarding Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Row(
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
                label: 'Docs Uploaded',
                icon: Icons.folder_outlined,
                color: AppTheme.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                value: provider.kycCompleted ? 'Done' : 'Pending',
                label: 'KYC Status',
                icon: Icons.verified_user_outlined,
                color: provider.kycCompleted ? AppTheme.success : AppTheme.textLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: provider.contractSigned ? 'Signed' : 'Pending',
                label: 'Contract',
                icon: Icons.description_outlined,
                color: provider.contractSigned ? AppTheme.success : AppTheme.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context, OnboardingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        InfoCard(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Email & push notifications enabled',
          iconColor: AppTheme.primary,
          trailing: Switch(
            value: true,
            onChanged: (_) {},
            activeColor: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.language_outlined,
          title: 'Language',
          subtitle: 'English (UK)',
          onTap: () {},
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.security_outlined,
          title: 'Security',
          subtitle: 'Biometric authentication',
          onTap: () {},
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.help_outline,
          title: 'Help & Documentation',
          subtitle: 'Guides and FAQs',
          onTap: () {},
        ),
        const SizedBox(height: 10),
        InfoCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Demo Admin Panel',
          subtitle: 'Manually control onboarding steps',
          iconColor: AppTheme.warning,
          iconBg: AppTheme.warning.withOpacity(0.1),
          onTap: () => Navigator.pushNamed(context, AppConstants.routeAdmin),
        ),
      ],
    );
  }

  Widget _buildLogout(BuildContext context, OnboardingProvider provider) {
    return Column(
      children: [
        const Text(
          'SmartOne Merchant Onboarding v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppTheme.textLight),
        ),
        const SizedBox(height: 4),
        const Text(
          'Demo Prototype – No real data processed',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              provider.logout();
              Navigator.pushReplacementNamed(context, AppConstants.routeWelcome);
            },
            icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
            label: const Text('Sign Out', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
