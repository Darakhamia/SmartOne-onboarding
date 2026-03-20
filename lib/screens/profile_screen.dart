import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final m = provider.merchant;
        final name = m.contactPerson.isNotEmpty ? m.contactPerson : 'Merchant';
        final initials = name.isNotEmpty ? name[0].toUpperCase() : 'M';
        final company = m.companyName.isNotEmpty ? m.companyName : 'Your Company';
        final progress = provider.totalStepsCount > 0
            ? provider.completedStepsCount / provider.totalStepsCount
            : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F8),
          body: CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(
                      20, MediaQuery.of(context).padding.top + 16, 20, 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profile',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, AppConstants.routeAdmin),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.admin_panel_settings_outlined,
                                      size: 14, color: AppTheme.warning),
                                  SizedBox(width: 5),
                                  Text('Admin',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.warning)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(company,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      if (m.email.isNotEmpty)
                        Text(m.email,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textLight)),
                      const SizedBox(height: 16),
                      // Progress bar
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Onboarding Progress',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  '${(progress * 100).round()}%  ·  ${provider.completedStepsCount}/${provider.totalStepsCount} steps',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  AppTheme.primary.withOpacity(0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primary),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats row ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      _StatPill(
                        icon: Icons.folder_rounded,
                        label: 'Documents',
                        value: '${provider.uploadedDocumentsCount}/${provider.totalDocumentsCount}',
                        color: AppTheme.warning,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        icon: Icons.verified_user_rounded,
                        label: 'KYC',
                        value: provider.kycCompleted ? 'Done' : 'Pending',
                        color: provider.kycCompleted ? AppTheme.success : AppTheme.textLight,
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        icon: Icons.description_rounded,
                        label: 'Contract',
                        value: provider.contractSigned ? 'Signed' : 'Pending',
                        color: provider.contractSigned ? AppTheme.success : AppTheme.textLight,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Business details ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  title: 'Business Details',
                  children: [
                    _Row(Icons.business_rounded, 'Company', m.companyName.isNotEmpty ? m.companyName : '—'),
                    _Row(Icons.badge_rounded, 'Company ID', m.companyId.isNotEmpty ? m.companyId : '—'),
                    _Row(Icons.receipt_long_rounded, 'TIN', m.tin.isNotEmpty ? m.tin : '—'),
                    _Row(Icons.phone_rounded, 'Phone', m.phone.isNotEmpty ? m.phone : '—'),
                    _Row(Icons.location_city_rounded, 'City', m.city.isNotEmpty ? m.city : '—'),
                    _Row(Icons.storefront_rounded, 'Retail Type', m.retailType.isNotEmpty ? m.retailType : '—', last: true),
                  ],
                ),
              ),

              // ── Settings ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Card(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  title: 'Settings',
                  children: [
                    _ToggleRow(
                      icon: Icons.notifications_rounded,
                      label: 'Notifications',
                      color: AppTheme.primary,
                      value: true,
                      onChanged: (_) {},
                    ),
                    _TapRow(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      value: 'English (UK)',
                      color: AppTheme.accent,
                      onTap: () {},
                    ),
                    _TapRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'Security',
                      value: 'Biometric auth',
                      color: AppTheme.success,
                      onTap: () {},
                    ),
                    _TapRow(
                      icon: Icons.help_rounded,
                      label: 'Help & Docs',
                      value: 'Guides & FAQs',
                      color: AppTheme.textSecondary,
                      onTap: () {},
                      last: true,
                    ),
                  ],
                ),
              ),

              // ── Sign out ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      provider.logout();
                      Navigator.pushReplacementNamed(
                          context, AppConstants.routeWelcome);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.error.withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: AppTheme.error, size: 18),
                          SizedBox(width: 8),
                          Text('Sign Out',
                              style: TextStyle(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Version ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 8, 16, MediaQuery.of(context).padding.bottom + 24),
                  child: const Text(
                    'SmartOne v1.0.0 · Demo Prototype',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final EdgeInsets margin;
  final String title;
  final List<Widget> children;
  const _Card({required this.margin, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4)),
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool last;
  const _Row(this.icon, this.label, this.value, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textSecondary)),
              const Spacer(),
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 45),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.color, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 58),
      ],
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool last;
  const _TapRow({required this.icon, required this.label, required this.value, required this.color, required this.onTap, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textPrimary)),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppTheme.textLight),
              ],
            ),
          ),
        ),
        if (!last) const Divider(height: 1, indent: 58),
      ],
    );
  }
}
