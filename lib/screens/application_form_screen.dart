import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/merchant_model.dart';
import '../models/outlet_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  int _step = 0; // 0-based step index across all steps
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // ── Controllers ───────────────────────────────────────────────────────────
  final _companyNameCtrl = TextEditingController();
  final _companyIdCtrl = TextEditingController();
  String _retailType = AppConstants.retailTypes.first;
  final _outletsCtrl = TextEditingController(text: '1');
  bool _customReceipt = false;
  final _turnoverMonthlyCtrl = TextEditingController();
  final _turnoverAnnualCtrl = TextEditingController();
  final _volumeMonthlyCtrl = TextEditingController();
  final _txMonthlyCtrl = TextEditingController();
  final _txAnnualCtrl = TextEditingController();
  final _avgTxCtrl = TextEditingController();
  final _maxTxCtrl = TextEditingController();
  final _minTxCtrl = TextEditingController();
  List<Map<String, TextEditingController>> _outlets = [];
  final _contactCompanyCtrl = TextEditingController();
  final _tinCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // Steps definition: title, subtitle, builder
  late final List<_Step> _steps;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _addOutlet();

    _steps = [
      _Step(title: 'Company\nName', subtitle: 'Enter your legal registered company name.', build: _stepCompanyName),
      _Step(title: 'Registration\nNumber', subtitle: 'Your official company ID or registration number.', build: _stepCompanyId),
      _Step(title: 'Business\nType', subtitle: 'Select the category that best describes your business.', build: _stepRetailType),
      _Step(title: 'Outlets &\nReceipts', subtitle: 'How many locations will you operate from?', build: _stepOutletsConfig),
      _Step(title: 'Monthly\nTurnover', subtitle: 'Expected monthly and annual revenue (EUR).', build: _stepTurnover),
      _Step(title: 'Transaction\nVolume', subtitle: 'How many transactions do you expect per month?', build: _stepVolume),
      _Step(title: 'Transaction\nValues', subtitle: 'Average, maximum and minimum transaction amounts.', build: _stepTxValues),
      _Step(title: 'Outlet\nDetails', subtitle: 'Add your business location(s) where POS will be installed.', build: _stepOutlets),
      _Step(title: 'Contact\nDetails', subtitle: 'Primary contact and legal entity information.', build: _stepContact),
    ];

    // Pre-fill demo data
    final m = context.read<OnboardingProvider>().merchant;
    if (m.companyName.isNotEmpty) {
      _companyNameCtrl.text = m.companyName;
      _companyIdCtrl.text = m.companyId;
      _retailType = m.retailType.isNotEmpty ? m.retailType : AppConstants.retailTypes.first;
      _outletsCtrl.text = m.numberOfOutlets.toString();
      _customReceipt = m.customReceiptDesign;
      _turnoverMonthlyCtrl.text = m.turnoverMonthly > 0 ? m.turnoverMonthly.toStringAsFixed(0) : '';
      _turnoverAnnualCtrl.text = m.turnoverAnnual > 0 ? m.turnoverAnnual.toStringAsFixed(0) : '';
      _volumeMonthlyCtrl.text = m.volumeMonthly > 0 ? m.volumeMonthly.toStringAsFixed(0) : '';
      _txMonthlyCtrl.text = m.transactionsMonthly > 0 ? m.transactionsMonthly.toString() : '';
      _txAnnualCtrl.text = m.transactionsAnnual > 0 ? m.transactionsAnnual.toString() : '';
      _avgTxCtrl.text = m.avgTransactionValue > 0 ? m.avgTransactionValue.toStringAsFixed(2) : '';
      _maxTxCtrl.text = m.maxTransactionValue > 0 ? m.maxTransactionValue.toStringAsFixed(2) : '';
      _minTxCtrl.text = m.minTransactionValue > 0 ? m.minTransactionValue.toStringAsFixed(2) : '';
      _contactCompanyCtrl.text = m.contactCompanyName;
      _tinCtrl.text = m.tin;
      _contactPersonCtrl.text = m.contactPerson;
      _phoneCtrl.text = m.phone;
      _emailCtrl.text = m.email;
      _cityCtrl.text = m.city;
      _zipCtrl.text = m.zipCode;
      _addressCtrl.text = m.address;
    }
  }

  void _addOutlet() {
    setState(() {
      _outlets.add({
        'name': TextEditingController(),
        'activity': TextEditingController(),
        'address': TextEditingController(),
        'pos': TextEditingController(text: '1'),
        'contact': TextEditingController(),
        'phone': TextEditingController(),
      });
    });
  }

  void _removeOutlet(int i) {
    if (_outlets.length > 1) {
      setState(() {
        for (final c in _outlets[i].values) c.dispose();
        _outlets.removeAt(i);
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [
      _companyNameCtrl, _companyIdCtrl, _outletsCtrl,
      _turnoverMonthlyCtrl, _turnoverAnnualCtrl, _volumeMonthlyCtrl,
      _txMonthlyCtrl, _txAnnualCtrl, _avgTxCtrl, _maxTxCtrl, _minTxCtrl,
      _contactCompanyCtrl, _tinCtrl, _contactPersonCtrl, _phoneCtrl,
      _emailCtrl, _cityCtrl, _zipCtrl, _addressCtrl,
    ]) c.dispose();
    for (final o in _outlets) for (final c in o.values) c.dispose();
    super.dispose();
  }

  void _next() {
    _animCtrl.forward(from: 0);
    setState(() => _step++);
  }

  void _back() {
    _animCtrl.forward(from: 0);
    setState(() => _step--);
  }

  // ── Step content builders ─────────────────────────────────────────────────

  Widget _stepCompanyName() => _SingleField(
    label: 'Company Name',
    hint: 'e.g. Apex Retail Solutions Ltd',
    controller: _companyNameCtrl,
  );

  Widget _stepCompanyId() => _SingleField(
    label: 'Registration Number',
    hint: 'e.g. GB12345678',
    controller: _companyIdCtrl,
  );

  Widget _stepRetailType() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: AppConstants.retailTypes.map((type) {
      final selected = _retailType == type;
      return GestureDetector(
        onTap: () => setState(() => _retailType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primarySurface : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(type,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    )),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 20),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _stepOutletsConfig() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CleanField(
        label: 'Number of Outlets',
        hint: '1',
        controller: _outletsCtrl,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: () => setState(() => _customReceipt = !_customReceipt),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: _customReceipt ? AppTheme.primarySurface : const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _customReceipt ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Custom Receipt Design',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _customReceipt ? AppTheme.primary : AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    const Text('Branded receipt with your logo',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Switch(
                value: _customReceipt,
                onChanged: (v) => setState(() => _customReceipt = v),
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _stepTurnover() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _CurrencyBadge(),
      const SizedBox(height: 20),
      _CleanField(
        label: 'Monthly Turnover',
        hint: '85,000',
        controller: _turnoverMonthlyCtrl,
        prefix: 'EUR',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _CleanField(
        label: 'Annual Turnover',
        hint: '1,020,000',
        controller: _turnoverAnnualCtrl,
        prefix: 'EUR',
        keyboardType: TextInputType.number,
      ),
    ],
  );

  Widget _stepVolume() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CleanField(
        label: 'Monthly Volume (EUR)',
        hint: '85,000',
        controller: _volumeMonthlyCtrl,
        prefix: 'EUR',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _CleanField(
        label: 'Transactions per Month',
        hint: '1,200',
        controller: _txMonthlyCtrl,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _CleanField(
        label: 'Transactions per Year',
        hint: '14,400',
        controller: _txAnnualCtrl,
        keyboardType: TextInputType.number,
      ),
    ],
  );

  Widget _stepTxValues() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CleanField(
        label: 'Average Transaction',
        hint: '70.83',
        controller: _avgTxCtrl,
        prefix: 'EUR',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),
      _CleanField(
        label: 'Maximum Transaction',
        hint: '5,000',
        controller: _maxTxCtrl,
        prefix: 'EUR',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      const SizedBox(height: 16),
      _CleanField(
        label: 'Minimum Transaction',
        hint: '5.00',
        controller: _minTxCtrl,
        prefix: 'EUR',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    ],
  );

  Widget _stepOutlets() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ..._outlets.asMap().entries.expand((entry) {
        final i = entry.key;
        final c = entry.value;
        return [
          if (i > 0) ...[
            const Divider(height: 32),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Outlet ${i + 1}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ),
              const Spacer(),
              if (_outlets.length > 1)
                GestureDetector(
                  onTap: () => _removeOutlet(i),
                  child: const Text('Remove',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _CleanField(label: 'Outlet Name', hint: 'e.g. Main Branch', controller: c['name']!),
          const SizedBox(height: 12),
          _CleanField(label: 'Retail Activity', hint: 'e.g. General Retail', controller: c['activity']!),
          const SizedBox(height: 12),
          _CleanField(label: 'Address', hint: 'Full address', controller: c['address']!),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _CleanField(label: 'POS Units', hint: '1', controller: c['pos']!, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: _CleanField(label: 'Contact Person', hint: 'Name', controller: c['contact']!)),
          ]),
          const SizedBox(height: 12),
          _CleanField(label: 'Phone', hint: '+44 7700 900000', controller: c['phone']!, keyboardType: TextInputType.phone),
        ];
      }),
      const SizedBox(height: 16),
      GestureDetector(
        onTap: _addOutlet,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.35), width: 1.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, size: 18, color: AppTheme.primary),
              SizedBox(width: 6),
              Text('Add Another Outlet',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _stepContact() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CleanField(label: 'Legal Company Name', hint: 'Legal name', controller: _contactCompanyCtrl),
      const SizedBox(height: 12),
      _CleanField(label: 'TIN / Tax Number', hint: 'e.g. GB987654321', controller: _tinCtrl),
      const SizedBox(height: 12),
      _CleanField(label: 'Contact Person', hint: 'Full name', controller: _contactPersonCtrl),
      const SizedBox(height: 12),
      _CleanField(label: 'Phone', hint: '+44 20 0000 0000', controller: _phoneCtrl, keyboardType: TextInputType.phone),
      const SizedBox(height: 12),
      _CleanField(label: 'Email', hint: 'contact@company.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _CleanField(label: 'City', hint: 'London', controller: _cityCtrl)),
        const SizedBox(width: 12),
        SizedBox(width: 110, child: _CleanField(label: 'Postcode', hint: 'EC2A 1AB', controller: _zipCtrl)),
      ]),
      const SizedBox(height: 12),
      _CleanField(label: 'Street Address', hint: 'Street address', controller: _addressCtrl),
    ],
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = _steps[_step];
    final isLast = _step == _steps.length - 1;
    final progress = (_step + 1) / _steps.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: _step == 0 ? () => Navigator.pop(context) : _back,
                    color: AppTheme.textPrimary,
                  ),
                  const Spacer(),
                  Text('${_step + 1} of ${_steps.length}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 3,
                ),
              ),
            ),
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  children: [
                    Text(s.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.15,
                          letterSpacing: -1,
                        )),
                    const SizedBox(height: 8),
                    Text(s.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        )),
                    const SizedBox(height: 32),
                    s.build(),
                    const SizedBox(height: 40),
                    _BigBtn(
                      label: isLast ? 'Submit Application' : 'Continue',
                      icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      loading: _loading,
                      onPressed: isLast ? _submit : _next,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));

    final outlets = _outlets.map((c) => OutletDetail(
      outletName: c['name']!.text,
      retailActivity: c['activity']!.text,
      address: c['address']!.text,
      numberOfPos: int.tryParse(c['pos']!.text) ?? 1,
      contactPerson: c['contact']!.text,
      contactPhone: c['phone']!.text,
    )).toList();

    final app = MerchantApplication(
      companyName: _companyNameCtrl.text,
      companyId: _companyIdCtrl.text,
      retailType: _retailType,
      numberOfOutlets: int.tryParse(_outletsCtrl.text) ?? 1,
      customReceiptDesign: _customReceipt,
      acceptanceCurrency: 'EUR',
      currency: 'EUR',
      volumeMonthly: double.tryParse(_volumeMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      transactionsMonthly: int.tryParse(_txMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      transactionsAnnual: int.tryParse(_txAnnualCtrl.text.replaceAll(',', '')) ?? 0,
      avgTransactionValue: double.tryParse(_avgTxCtrl.text) ?? 0,
      maxTransactionValue: double.tryParse(_maxTxCtrl.text) ?? 0,
      minTransactionValue: double.tryParse(_minTxCtrl.text) ?? 0,
      turnoverMonthly: double.tryParse(_turnoverMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      turnoverAnnual: double.tryParse(_turnoverAnnualCtrl.text.replaceAll(',', '')) ?? 0,
      outlets: outlets,
      contactCompanyName: _contactCompanyCtrl.text,
      tin: _tinCtrl.text,
      contactPerson: _contactPersonCtrl.text,
      phone: _phoneCtrl.text,
      email: _emailCtrl.text,
      city: _cityCtrl.text,
      zipCode: _zipCtrl.text,
      address: _addressCtrl.text,
    );

    if (!mounted) return;
    context.read<OnboardingProvider>().submitApplication(app);
    setState(() => _loading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: AppTheme.success, size: 42),
              ),
              const SizedBox(height: 24),
              const Text('All done!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              const Text(
                'Your application has been received. Next: upload your compliance documents.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(context, AppConstants.routeMain);
                  },
                  child: const Text('Go to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _Step {
  final String title;
  final String subtitle;
  final Widget Function() build;
  const _Step({required this.title, required this.subtitle, required this.build});
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.euro_rounded, size: 16, color: AppTheme.primary),
          SizedBox(width: 6),
          Text('Currency: EUR',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _SingleField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _SingleField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) {
    return _CleanField(label: label, hint: hint, controller: controller, keyboardType: keyboardType);
  }
}

class _CleanField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? prefix;

  const _CleanField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            )),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            prefixText: prefix != null ? '$prefix  ' : null,
            prefixStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            hintStyle: const TextStyle(
                fontSize: 14, color: AppTheme.textLight, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

class _BigBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;
  const _BigBtn({required this.label, required this.icon, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }
}
