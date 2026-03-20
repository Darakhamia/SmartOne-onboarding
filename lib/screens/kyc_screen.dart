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

// ── iDenfy-style KYC flow ─────────────────────────────────────────────────────

class _MockKycFlow extends StatefulWidget {
  const _MockKycFlow();

  @override
  State<_MockKycFlow> createState() => _MockKycFlowState();
}

class _MockKycFlowState extends State<_MockKycFlow> {
  // Steps: 0=intro, 1=doc type, 2=doc scan, 3=face, 4=verifying, 5=done
  int _step = 0;
  String _selectedDoc = '';
  bool _processing = false;

  static const _docTypes = [
    (Icons.book_outlined, 'Passport'),
    (Icons.credit_card_outlined, 'National ID card'),
    (Icons.home_outlined, 'Residence Permit'),
    (Icons.drive_eta_outlined, 'Driving license'),
  ];

  void _next() => setState(() => _step++);

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      0 => _buildIntro(),
      1 => _buildDocChoice(),
      2 => _buildDocScan(),
      3 => _buildFaceRecording(),
      4 => _buildVerifying(),
      _ => _buildDone(),
    };
  }

  // ── Screen 1: Verify Identity intro ────────────────────────────────────────

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _closeBtn(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5A19B5), Color(0xFF8B4FD8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.shield_rounded,
                          color: Colors.white, size: 52),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Verify your Identity',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1033)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'To keep your account secure, we need to confirm your identity. This only takes a couple of minutes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.55),
                    ),
                    const SizedBox(height: 32),
                    _stepRow(Icons.credit_card_outlined, 'Scan your document',
                        'Passport, ID card or driving license'),
                    const SizedBox(height: 14),
                    _stepRow(Icons.face_retouching_natural, 'Take a selfie',
                        'Quick liveness check'),
                    const SizedBox(height: 14),
                    _stepRow(Icons.check_circle_outline, 'Get verified',
                        'Usually under 2 minutes'),
                    const SizedBox(height: 36),
                    _primaryBtn('Start verification', _next),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 13, color: AppTheme.textLight),
                        const SizedBox(width: 5),
                        const Text(
                          'Secured by iDenfy · GDPR Compliant',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepRow(IconData icon, String title, String sub) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            Text(sub,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }

  // ── Screen 2: Choose document ───────────────────────────────────────────────

  Widget _buildDocChoice() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _closeBtn(),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Text(
                'Choose document',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1033)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Text(
                'Select a government-issued photo ID',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _docTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final doc = _docTypes[i];
                  final selected = _selectedDoc == doc.$2;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDoc = doc.$2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 17),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primarySurface
                            : const Color(0xFFF7F7F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(doc.$1,
                              size: 24,
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary),
                          const SizedBox(width: 16),
                          Text(doc.$2,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary)),
                          const Spacer(),
                          if (selected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppTheme.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _primaryBtn(
                'Continue',
                _selectedDoc.isNotEmpty ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen 3: Document scan frame (dark) ────────────────────────────────────

  Widget _buildDocScan() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    onPressed: () => setState(() => _step--),
                  ),
                  const Expanded(
                    child: Text(
                      'Front of document',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Position the front of your\ndocument in the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            Expanded(
              child: Center(
                child: CustomPaint(
                  painter: _ScanFramePainter(),
                  child: SizedBox(
                    width: 300,
                    height: 190,
                    child: Center(
                      child: Icon(Icons.credit_card_outlined,
                          size: 48,
                          color: Colors.white.withOpacity(0.12)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      color: Colors.white54, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Ensure good lighting and no glare',
                    style:
                        TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: GestureDetector(
                onTap: () async {
                  setState(() => _processing = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    setState(() {
                      _processing = false;
                      _step++;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A19B5), Color(0xFF8B4FD8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _processing
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        )
                      : const Text('Capture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen 4: Face / liveness recording ────────────────────────────────────

  Widget _buildFaceRecording() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 18),
                    onPressed: () => setState(() => _step--),
                  ),
                  const Expanded(
                    child: Text(
                      'Liveness check',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Look directly at the camera\nand follow the instructions',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Oval outline
                    Container(
                      width: 230,
                      height: 290,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(120),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    // Face silhouette icon
                    Icon(Icons.face_retouching_natural,
                        size: 90, color: Colors.white.withOpacity(0.15)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info_outline, color: Colors.white54, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Remove glasses if you wear them',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: GestureDetector(
                onTap: () async {
                  setState(() => _processing = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    setState(() {
                      _processing = false;
                      _step++;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5A19B5), Color(0xFF8B4FD8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _processing
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          ),
                        )
                      : const Text('Start liveness check',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Screen 5: Verifying ─────────────────────────────────────────────────────

  Widget _buildVerifying() {
    // Auto-advance after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _step == 4) setState(() => _step++);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EEFF),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.schedule_rounded,
                      color: Color(0xFF5A19B5), size: 48),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Verifying Your Identity',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1033)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please wait while we verify your documents. This usually takes less than a minute.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.55),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  color: Color(0xFF5A19B5),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Screen 6: Done ──────────────────────────────────────────────────────────

  Widget _buildDone() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 52),
              ),
              const SizedBox(height: 28),
              const Text(
                'Verification Complete!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1033)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your identity has been successfully verified. Your application will now proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.55),
              ),
              const SizedBox(height: 40),
              _primaryBtn('Continue', () => Navigator.pop(context, true)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _closeBtn() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
        child: IconButton(
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: AppTheme.textSecondary),
          ),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [Color(0xFF5A19B5), Color(0xFF8B4FD8)],
                )
              : null,
          color: onTap == null ? AppTheme.border : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onTap != null ? Colors.white : AppTheme.textLight,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Scan frame painter ────────────────────────────────────────────────────────

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 10.0;
    final w = size.width;
    final h = size.height;

    // Draw dim background rect
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h), const Radius.circular(12)),
        bgPaint);

    // Thin outline
    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h), const Radius.circular(12)),
        outlinePaint);

    // Corner brackets
    void corner(double cx, double cy, bool flipX, bool flipY) {
      final sx = flipX ? -1.0 : 1.0;
      final sy = flipY ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(cx, cy + sy * len)
        ..lineTo(cx, cy + sy * r)
        ..arcToPoint(Offset(cx + sx * r, cy),
            radius: const Radius.circular(r), clockwise: !flipX && !flipY || flipX && flipY)
        ..lineTo(cx + sx * len, cy);
      canvas.drawPath(path, paint);
    }

    corner(0, 0, false, false);
    corner(w, 0, true, false);
    corner(0, h, false, true);
    corner(w, h, true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
