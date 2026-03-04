import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../widgets/custom_button.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: const Text('KYC Verification'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: provider.kycCompleted
                ? _buildCompleted()
                : _buildKycRequired(provider),
          ),
        );
      },
    );
  }

  Widget _buildKycRequired(OnboardingProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildAnimatedIcon(),
        const SizedBox(height: 32),
        const Text(
          'KYC Verification Required',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'As part of our compliance process, we need to verify the identity of all company directors and beneficial owners.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _buildStepsInfo(),
        const SizedBox(height: 32),
        _buildProviderBadge(),
        const SizedBox(height: 32),
        PrimaryButton(
          label: provider.kycStarted ? 'Continue KYC Verification' : 'Start KYC Verification',
          icon: Icons.verified_user_outlined,
          onPressed: () => _startKyc(provider),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your data is encrypted and processed securely by iDenfy, an EU-regulated identity verification provider.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (ctx, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120 + (_pulseController.value * 20),
              height: 120 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05 + (_pulseController.value * 0.05)),
              ),
            ),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3 + _pulseController.value * 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 48),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepsInfo() {
    final steps = [
      (Icons.phone_android_outlined, 'Open iDenfy', 'Tap the button to open the KYC portal'),
      (Icons.photo_camera_outlined, 'Scan Document', 'Take a photo of your government-issued ID'),
      (Icons.face_retouching_natural, 'Facial Recognition', 'Complete a quick liveness check'),
      (Icons.check_circle_outline, 'Verification', 'Results in 5–10 minutes'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 14 : 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(step.$1, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      Text(step.$3, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProviderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.security, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Powered by iDenfy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              Text('EU-regulated • GDPR Compliant', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.success.withOpacity(0.1),
          ),
          child: const Icon(Icons.verified, color: AppTheme.success, size: 56),
        ),
        const SizedBox(height: 28),
        const Text(
          'KYC Verified!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        const Text(
          'Identity verification completed successfully. Your application will now proceed to the AML review stage.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 40),
        _buildVerifiedDetails(),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Back to Dashboard',
          icon: Icons.dashboard_outlined,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildVerifiedDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _verifiedRow(Icons.person_outlined, 'Identity', 'Verified'),
          const Divider(height: 20),
          _verifiedRow(Icons.face_retouching_natural, 'Liveness Check', 'Passed'),
          const Divider(height: 20),
          _verifiedRow(Icons.document_scanner_outlined, 'Document Scan', 'Verified'),
          const Divider(height: 20),
          _verifiedRow(Icons.security_outlined, 'AML Screening', 'Clear'),
        ],
      ),
    );
  }

  Widget _verifiedRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.success),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.success)),
        ),
      ],
    );
  }

  Future<void> _startKyc(OnboardingProvider provider) async {
    provider.startKyc();

    // Show mock loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _KycLoadingDialog(),
    );

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pop(context);

    // Simulate KYC flow with mock screens
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _MockKycFlow()),
    );

    if (result == true && mounted) {
      provider.completeKyc();
    }
  }
}

class _KycLoadingDialog extends StatelessWidget {
  const _KycLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 20),
          Text('Connecting to iDenfy...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('Preparing secure verification session', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _MockKycFlow extends StatefulWidget {
  const _MockKycFlow();

  @override
  State<_MockKycFlow> createState() => _MockKycFlowState();
}

class _MockKycFlowState extends State<_MockKycFlow> {
  int _step = 0;
  bool _scanning = false;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': Icons.photo_camera_outlined,
      'title': 'Document Scan',
      'desc': 'Position your ID document within the frame. Make sure it is clear and well-lit.',
      'action': 'Scan Document',
    },
    {
      'icon': Icons.face_retouching_natural,
      'title': 'Selfie & Liveness',
      'desc': 'Look directly at the camera and follow the on-screen instructions for the liveness check.',
      'action': 'Start Liveness Check',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'AML Pre-Screening',
      'desc': 'Running automated anti-money laundering pre-screening against global watchlists.',
      'action': 'Run AML Check',
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (_step >= _steps.length) {
      return _buildSuccess();
    }

    final current = _steps[_step];

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('iDenfy Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / _steps.length,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${_step + 1} of ${_steps.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primarySurface,
              ),
              child: _scanning
                  ? const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3)
                  : Icon(current['icon'] as IconData, size: 50, color: AppTheme.primary),
            ),
            const SizedBox(height: 28),
            Text(
              current['title'] as String,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              current['desc'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 48),
            // Mock camera/scan frame
            if (!_scanning)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(current['icon'] as IconData, size: 48, color: AppTheme.primary.withOpacity(0.4)),
                    const SizedBox(height: 8),
                    const Text('MOCK CAMERA FRAME', style: TextStyle(fontSize: 11, color: AppTheme.textLight, letterSpacing: 1)),
                  ],
                ),
              ),
            if (_scanning) ...[
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 12),
                    Text('Processing...', style: TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (!_scanning)
              PrimaryButton(
                label: current['action'] as String,
                onPressed: _processStep,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withOpacity(0.1),
                ),
                child: const Icon(Icons.verified, color: AppTheme.success, size: 56),
              ),
              const SizedBox(height: 28),
              const Text(
                'Verification Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Identity successfully verified. Returning to SmartOne onboarding...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processStep() async {
    setState(() => _scanning = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _step++;
    });
  }
}
