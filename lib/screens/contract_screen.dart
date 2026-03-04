import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../widgets/custom_button.dart';

class ContractScreen extends StatelessWidget {
  const ContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: const Text('Contract Signing'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: provider.contractSigned
                ? _buildSigned(context)
                : _buildContractReady(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildContractReady(BuildContext context, OnboardingProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.primarySurface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.description_outlined, size: 48, color: AppTheme.primary),
        ),
        const SizedBox(height: 24),
        const Text(
          'Merchant Agreement Ready',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your merchant agreement has been prepared by SmartOne. Please review and sign the contract to proceed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 32),
        _buildContractPreview(),
        const SizedBox(height: 24),
        _buildContractTerms(),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Open & Sign Contract',
          icon: Icons.draw_outlined,
          onPressed: () => _openContract(context, provider),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: AppTheme.textLight),
            SizedBox(width: 6),
            Text(
              'Signed electronically via DocuSign',
              style: TextStyle(fontSize: 12, color: AppTheme.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContractPreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, size: 20, color: AppTheme.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'SmartOne Merchant Agreement',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.warning),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _contractRow('Document Type', 'Merchant Service Agreement'),
          _contractRow('Prepared by', 'SmartOne Ltd'),
          _contractRow('Date Issued', _today()),
          _contractRow('Validity', '3 years'),
          _contractRow('Processing Partner', 'Paynetics AD'),
          _contractRow('Terminal Provider', 'DNA Payments Ltd'),
        ],
      ),
    );
  }

  Widget _buildContractTerms() {
    final terms = [
      'Processing fees as per agreed rate schedule',
      'Monthly reporting via SmartOne dashboard',
      'PCI DSS Level 1 compliance required',
      'Dispute resolution within 30 business days',
      'Termination with 90 days written notice',
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'Key Terms Summary',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...terms.map((term) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, size: 14, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(term, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSigned(BuildContext context) {
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
          child: const Icon(Icons.task_alt, color: AppTheme.success, size: 56),
        ),
        const SizedBox(height: 28),
        const Text(
          'Contract Signed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'The Merchant Agreement has been signed electronically. Your application is now submitted to DNA Payments for terminal preparation.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.success.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              _signedRow(Icons.description_outlined, 'Document', 'Merchant Agreement'),
              const Divider(height: 20),
              _signedRow(Icons.draw_outlined, 'Signed by', 'Merchant (You)'),
              const Divider(height: 20),
              _signedRow(Icons.business_center_outlined, 'Countersigned by', 'SmartOne Ltd'),
              const Divider(height: 20),
              _signedRow(Icons.calendar_today_outlined, 'Date Signed', _today()),
              const Divider(height: 20),
              _signedRow(Icons.fingerprint, 'Reference', 'MSA-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Back to Dashboard',
          icon: Icons.dashboard_outlined,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _contractRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _signedRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.success),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  Future<void> _openContract(BuildContext context, OnboardingProvider provider) async {
    // Show mock contract viewer
    final signed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _MockContractViewer()),
    );
    if (signed == true) {
      provider.signContract();
    }
  }
}

class _MockContractViewer extends StatefulWidget {
  const _MockContractViewer();

  @override
  State<_MockContractViewer> createState() => _MockContractViewerState();
}

class _MockContractViewerState extends State<_MockContractViewer> {
  bool _scrolledToBottom = false;
  bool _agreed = false;
  bool _signing = false;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 50) {
        if (!_scrolledToBottom) setState(() => _scrolledToBottom = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Merchant Agreement'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(24),
              child: _buildContractText(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: const Border(top: BorderSide(color: AppTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _agreed,
                      onChanged: _scrolledToBottom ? (v) => setState(() => _agreed = v!) : null,
                      activeColor: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'I have read and agree to the Merchant Service Agreement',
                        style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_agreed && !_signing) ? _sign : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: AppTheme.border,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _signing
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Sign Contract', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
                if (!_scrolledToBottom)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Please scroll to the bottom to enable signing',
                      style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractText() {
    const style = TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.7);
    const headingStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'MERCHANT SERVICE AGREEMENT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 1),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Reference: MSA-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 24),
        const Text('1. PARTIES', style: headingStyle),
        const SizedBox(height: 8),
        const Text('This Merchant Service Agreement ("Agreement") is entered into between SmartOne Ltd, a company registered in England and Wales ("SmartOne", "we", "us"), and the merchant identified in the onboarding application ("Merchant", "you").', style: style),
        const SizedBox(height: 16),
        const Text('2. SERVICES', style: headingStyle),
        const SizedBox(height: 8),
        const Text('SmartOne agrees to provide merchant acquiring services, including but not limited to: POS terminal provisioning via DNA Payments, card payment processing through Paynetics AD, transaction reporting and reconciliation, and dispute management services.', style: style),
        const SizedBox(height: 16),
        const Text('3. FEES AND CHARGES', style: headingStyle),
        const SizedBox(height: 8),
        const Text('The Merchant agrees to pay fees as set forth in the Rate Schedule attached hereto as Exhibit A. Fees may include: transaction processing fees, monthly service fees, hardware rental or purchase costs, chargeback handling fees, and PCI DSS compliance fees.', style: style),
        const SizedBox(height: 16),
        const Text('4. COMPLIANCE', style: headingStyle),
        const SizedBox(height: 8),
        const Text('The Merchant shall at all times comply with: Payment Card Industry Data Security Standard (PCI DSS), Anti-Money Laundering (AML) regulations, Know Your Customer (KYC) requirements, GDPR and applicable data protection laws, and all Card Scheme rules (Visa, Mastercard, etc.).', style: style),
        const SizedBox(height: 16),
        const Text('5. TERM AND TERMINATION', style: headingStyle),
        const SizedBox(height: 8),
        const Text('This Agreement shall commence on the date of signing and continue for a period of three (3) years, automatically renewing annually thereafter. Either party may terminate with ninety (90) days written notice.', style: style),
        const SizedBox(height: 16),
        const Text('6. LIMITATION OF LIABILITY', style: headingStyle),
        const SizedBox(height: 8),
        const Text('SmartOne\'s aggregate liability under this Agreement shall not exceed the total fees paid by the Merchant in the preceding twelve (12) months. SmartOne shall not be liable for indirect, consequential, or incidental damages.', style: style),
        const SizedBox(height: 16),
        const Text('7. GOVERNING LAW', style: headingStyle),
        const SizedBox(height: 8),
        const Text('This Agreement shall be governed by and construed in accordance with the laws of England and Wales. Any disputes shall be subject to the exclusive jurisdiction of the courts of England and Wales.', style: style),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIGNATURE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1)),
              SizedBox(height: 8),
              Text('By signing electronically, you confirm that you have read, understood, and agree to be bound by the terms of this Agreement.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sign() async {
    setState(() => _signing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context, true);
  }
}
