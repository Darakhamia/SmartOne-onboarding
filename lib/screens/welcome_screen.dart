import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildLogo(),
                    const SizedBox(height: 48),
                    _buildHero(),
                    const SizedBox(height: 48),
                    _buildSteps(),
                    const SizedBox(height: 48),
                    _buildButtons(),
                    const SizedBox(height: 32),
                    _buildFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.point_of_sale_rounded, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          AppConstants.appTagline,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primarySurface, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch_rounded, size: 48, color: AppTheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Start accepting card payments\nfor your business',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete onboarding in just a few steps and\nget your POS terminal delivered to your door.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSteps() {
    final steps = [
      ('Submit Application', Icons.article_outlined, '5 min'),
      ('Upload Documents', Icons.upload_file_outlined, '10 min'),
      ('KYC Verification', Icons.verified_user_outlined, '5 min'),
      ('Get Your Terminal', Icons.point_of_sale_outlined, '1-3 days'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it works',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 14),
        ...steps.asMap().entries.map((e) {
          final idx = e.key;
          final step = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(step.$2, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${idx + 1}. ${step.$1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    step.$3,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildButtons() {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Column(
          children: [
            PrimaryButton(
              label: 'New Merchant',
              icon: Icons.person_add_outlined,
              onPressed: () {
                provider.startAsNewMerchant();
                Navigator.pushReplacementNamed(context, AppConstants.routeApplication);
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Login (Demo)',
              icon: Icons.login_rounded,
              onPressed: () {
                provider.loginAsDemo();
                Navigator.pushReplacementNamed(context, AppConstants.routeMain);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBadge(Icons.lock_outline, 'PCI DSS'),
            const SizedBox(width: 16),
            _buildBadge(Icons.shield_outlined, 'AML/KYC'),
            const SizedBox(width: 16),
            _buildBadge(Icons.verified_outlined, 'Paynetics'),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Powered by DNA Payments & Paynetics',
          style: TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
