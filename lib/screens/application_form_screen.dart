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
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  int _currentSection = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Company Profile
  final _companyNameCtrl = TextEditingController();
  final _companyIdCtrl = TextEditingController();

  // Business Questionnaire
  String _selectedRetailType = AppConstants.retailTypes.first;
  final _numberOfOutletsCtrl = TextEditingController(text: '1');
  bool _customReceipt = false;
  String _acceptanceCurrency = 'EUR';

  // Projected Sales
  String _currency = 'EUR';
  final _volumeMonthlyCtrl = TextEditingController();
  final _txMonthlyCtrl = TextEditingController();
  final _txAnnualCtrl = TextEditingController();
  final _avgTxCtrl = TextEditingController();
  final _maxTxCtrl = TextEditingController();
  final _minTxCtrl = TextEditingController();
  final _turnoverMonthlyCtrl = TextEditingController();
  final _turnoverAnnualCtrl = TextEditingController();

  // Outlet Details
  List<Map<String, TextEditingController>> _outletControllers = [];

  // Contact Details
  final _contactCompanyCtrl = TextEditingController();
  final _tinCtrl = TextEditingController();
  final _contactPersonCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  static const _sections = [
    _SectionMeta(
      title: 'Company\nProfile',
      subtitle: 'Your company\'s legal registration details.',
      icon: Icons.business_rounded,
    ),
    _SectionMeta(
      title: 'Business\nDetails',
      subtitle: 'Tell us about your business model and outlets.',
      icon: Icons.storefront_rounded,
    ),
    _SectionMeta(
      title: 'Projected\nSales',
      subtitle: 'Expected transaction volumes and turnover.',
      icon: Icons.trending_up_rounded,
    ),
    _SectionMeta(
      title: 'Outlet\nDetails',
      subtitle: 'Locations where POS terminals will be installed.',
      icon: Icons.location_on_rounded,
    ),
    _SectionMeta(
      title: 'Contact\nDetails',
      subtitle: 'Primary contact and legal entity information.',
      icon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _addOutlet();
    final merchant = context.read<OnboardingProvider>().merchant;
    if (merchant.companyName.isNotEmpty) {
      _companyNameCtrl.text = merchant.companyName;
      _companyIdCtrl.text = merchant.companyId;
      _selectedRetailType = merchant.retailType.isNotEmpty
          ? merchant.retailType
          : AppConstants.retailTypes.first;
      _numberOfOutletsCtrl.text = merchant.numberOfOutlets.toString();
      _customReceipt = merchant.customReceiptDesign;
      _acceptanceCurrency = merchant.acceptanceCurrency;
      _currency = merchant.currency;
      _volumeMonthlyCtrl.text =
          merchant.volumeMonthly > 0 ? merchant.volumeMonthly.toStringAsFixed(0) : '';
      _txMonthlyCtrl.text =
          merchant.transactionsMonthly > 0 ? merchant.transactionsMonthly.toString() : '';
      _txAnnualCtrl.text =
          merchant.transactionsAnnual > 0 ? merchant.transactionsAnnual.toString() : '';
      _avgTxCtrl.text =
          merchant.avgTransactionValue > 0 ? merchant.avgTransactionValue.toStringAsFixed(2) : '';
      _maxTxCtrl.text =
          merchant.maxTransactionValue > 0 ? merchant.maxTransactionValue.toStringAsFixed(2) : '';
      _minTxCtrl.text =
          merchant.minTransactionValue > 0 ? merchant.minTransactionValue.toStringAsFixed(2) : '';
      _turnoverMonthlyCtrl.text =
          merchant.turnoverMonthly > 0 ? merchant.turnoverMonthly.toStringAsFixed(0) : '';
      _turnoverAnnualCtrl.text =
          merchant.turnoverAnnual > 0 ? merchant.turnoverAnnual.toStringAsFixed(0) : '';
      _contactCompanyCtrl.text = merchant.contactCompanyName;
      _tinCtrl.text = merchant.tin;
      _contactPersonCtrl.text = merchant.contactPerson;
      _phoneCtrl.text = merchant.phone;
      _emailCtrl.text = merchant.email;
      _cityCtrl.text = merchant.city;
      _zipCtrl.text = merchant.zipCode;
      _addressCtrl.text = merchant.address;
    }
  }

  void _addOutlet() {
    setState(() {
      _outletControllers.add({
        'name': TextEditingController(),
        'activity': TextEditingController(),
        'address': TextEditingController(),
        'pos': TextEditingController(text: '1'),
        'contact': TextEditingController(),
        'phone': TextEditingController(),
      });
    });
  }

  void _removeOutlet(int index) {
    if (_outletControllers.length > 1) {
      setState(() {
        for (final ctrl in _outletControllers[index].values) ctrl.dispose();
        _outletControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _companyNameCtrl.dispose();
    _companyIdCtrl.dispose();
    _numberOfOutletsCtrl.dispose();
    _volumeMonthlyCtrl.dispose();
    _txMonthlyCtrl.dispose();
    _txAnnualCtrl.dispose();
    _avgTxCtrl.dispose();
    _maxTxCtrl.dispose();
    _minTxCtrl.dispose();
    _turnoverMonthlyCtrl.dispose();
    _turnoverAnnualCtrl.dispose();
    _contactCompanyCtrl.dispose();
    _tinCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _addressCtrl.dispose();
    for (final ctrls in _outletControllers) {
      for (final ctrl in ctrls.values) ctrl.dispose();
    }
    super.dispose();
  }

  void _goNext() {
    _animCtrl.forward(from: 0);
    setState(() => _currentSection++);
  }

  void _goBack() {
    _animCtrl.forward(from: 0);
    setState(() => _currentSection--);
  }

  @override
  Widget build(BuildContext context) {
    final meta = _sections[_currentSection];
    final isLast = _currentSection == _sections.length - 1;
    final isFirst = _currentSection == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    onPressed: isFirst ? () => Navigator.pop(context) : _goBack,
                    color: AppTheme.textPrimary,
                  ),
                  const Spacer(),
                  Text(
                    '${_currentSection + 1} / ${_sections.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_currentSection + 1) / _sections.length,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 3,
                ),
              ),
            ),

            // ── Content ────────────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    children: [
                      // Section heading
                      Text(
                        meta.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.15,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meta.subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Fields for current section
                      if (_currentSection == 0) ..._companyProfileFields(),
                      if (_currentSection == 1) ..._businessFields(),
                      if (_currentSection == 2) ..._salesFields(),
                      if (_currentSection == 3) ..._outletFields(),
                      if (_currentSection == 4) ..._contactFields(),

                      const SizedBox(height: 40),

                      // ── Continue / Submit button ────────────────────────
                      _BigButton(
                        label: isLast ? 'Submit Application' : 'Continue',
                        icon: isLast
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        loading: _loading,
                        onPressed: isLast ? _submitForm : _goNext,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section field builders ──────────────────────────────────────────────

  List<Widget> _companyProfileFields() => [
        _Field(
          label: 'Company Name',
          hint: 'e.g. Apex Retail Solutions Ltd',
          controller: _companyNameCtrl,
        ),
        const SizedBox(height: 16),
        _Field(
          label: 'Registration Number',
          hint: 'e.g. GB12345678',
          controller: _companyIdCtrl,
        ),
      ];

  List<Widget> _businessFields() => [
        _Label('Retail Type'),
        const SizedBox(height: 8),
        _StyledDropdown<String>(
          value: _selectedRetailType,
          items: AppConstants.retailTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _selectedRetailType = v!),
        ),
        const SizedBox(height: 16),
        _Field(
          label: 'Number of Outlets',
          hint: '1',
          controller: _numberOfOutletsCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _Label('Acceptance Currency'),
        const SizedBox(height: 8),
        _StyledDropdown<String>(
          value: _acceptanceCurrency,
          items: AppConstants.currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _acceptanceCurrency = v!),
        ),
        const SizedBox(height: 16),
        _ToggleTile(
          label: 'Custom Receipt Design',
          subtitle: 'Branded receipt with your logo',
          value: _customReceipt,
          onChanged: (v) => setState(() => _customReceipt = v),
        ),
      ];

  List<Widget> _salesFields() => [
        _Label('Currency'),
        const SizedBox(height: 8),
        _StyledDropdown<String>(
          value: _currency,
          items: AppConstants.currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _currency = v!),
        ),
        const SizedBox(height: 24),
        _GroupLabel(label: 'Turnover', color: AppTheme.primary),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'Monthly',
                  hint: '85,000',
                  controller: _turnoverMonthlyCtrl,
                  prefix: _currency,
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _Field(
                  label: 'Annual',
                  hint: '1,020,000',
                  controller: _turnoverAnnualCtrl,
                  prefix: _currency,
                  keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 24),
        _GroupLabel(label: 'Volume & Transactions', color: AppTheme.accent),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'Vol. Monthly',
                  hint: '85,000',
                  controller: _volumeMonthlyCtrl,
                  prefix: _currency,
                  keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(
              child: _Field(
                  label: 'Txns / Month',
                  hint: '1,200',
                  controller: _txMonthlyCtrl,
                  keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        _Field(
            label: 'Transactions Annual',
            hint: '14,400',
            controller: _txAnnualCtrl,
            keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        _GroupLabel(label: 'Transaction Values', color: AppTheme.warning),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'Average',
                  hint: '70.83',
                  controller: _avgTxCtrl,
                  prefix: _currency,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
          const SizedBox(width: 12),
          Expanded(
              child: _Field(
                  label: 'Maximum',
                  hint: '5,000',
                  controller: _maxTxCtrl,
                  prefix: _currency,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'Minimum',
                  hint: '5.00',
                  controller: _minTxCtrl,
                  prefix: _currency,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true))),
          const Expanded(child: SizedBox()),
        ]),
      ];

  List<Widget> _outletFields() => [
        ..._outletControllers.asMap().entries.expand((entry) {
          final i = entry.key;
          final ctrls = entry.value;
          return [
            if (i > 0) const SizedBox(height: 24),
            Row(
              children: [
                Text('Outlet ${i + 1}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                if (_outletControllers.length > 1)
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
            const SizedBox(height: 12),
            _Field(
                label: 'Outlet Name',
                hint: 'e.g. Main Branch',
                controller: ctrls['name']!),
            const SizedBox(height: 12),
            _Field(
                label: 'Retail Activity',
                hint: 'e.g. General Retail',
                controller: ctrls['activity']!),
            const SizedBox(height: 12),
            _Field(
                label: 'Outlet Address',
                hint: 'Full address',
                controller: ctrls['address']!),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _Field(
                      label: 'POS Count',
                      hint: '1',
                      controller: ctrls['pos']!,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Field(
                      label: 'Contact Person',
                      hint: 'Name',
                      controller: ctrls['contact']!)),
            ]),
            const SizedBox(height: 12),
            _Field(
                label: 'Contact Phone',
                hint: '+44 7700 900000',
                controller: ctrls['phone']!,
                keyboardType: TextInputType.phone),
            if (i < _outletControllers.length - 1)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Divider(),
              ),
          ];
        }),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _addOutlet,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.3),
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
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
      ];

  List<Widget> _contactFields() => [
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'Company Name',
                  hint: 'Legal name',
                  controller: _contactCompanyCtrl)),
          const SizedBox(width: 12),
          Expanded(
              child: _Field(
                  label: 'TIN / Tax No.',
                  hint: 'GB987654321',
                  controller: _tinCtrl)),
        ]),
        const SizedBox(height: 16),
        _Field(
            label: 'Contact Person',
            hint: 'Full name',
            controller: _contactPersonCtrl),
        const SizedBox(height: 16),
        _Field(
            label: 'Phone',
            hint: '+44 20 0000 0000',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _Field(
            label: 'Email',
            hint: 'contact@company.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: _Field(
                  label: 'City', hint: 'London', controller: _cityCtrl)),
          const SizedBox(width: 12),
          SizedBox(
              width: 110,
              child: _Field(
                  label: 'Postcode',
                  hint: 'EC2A 1AB',
                  controller: _zipCtrl)),
        ]),
        const SizedBox(height: 16),
        _Field(
            label: 'Street Address',
            hint: 'Street address',
            controller: _addressCtrl),
      ];

  // ── Submit ─────────────────────────────────────────────────────────────

  Future<void> _submitForm() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));

    final outlets = _outletControllers.map((ctrls) {
      return OutletDetail(
        outletName: ctrls['name']!.text,
        retailActivity: ctrls['activity']!.text,
        address: ctrls['address']!.text,
        numberOfPos: int.tryParse(ctrls['pos']!.text) ?? 1,
        contactPerson: ctrls['contact']!.text,
        contactPhone: ctrls['phone']!.text,
      );
    }).toList();

    final application = MerchantApplication(
      companyName: _companyNameCtrl.text,
      companyId: _companyIdCtrl.text,
      retailType: _selectedRetailType,
      numberOfOutlets: int.tryParse(_numberOfOutletsCtrl.text) ?? 1,
      customReceiptDesign: _customReceipt,
      acceptanceCurrency: _acceptanceCurrency,
      currency: _currency,
      volumeMonthly:
          double.tryParse(_volumeMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      transactionsMonthly:
          int.tryParse(_txMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      transactionsAnnual:
          int.tryParse(_txAnnualCtrl.text.replaceAll(',', '')) ?? 0,
      avgTransactionValue: double.tryParse(_avgTxCtrl.text) ?? 0,
      maxTransactionValue: double.tryParse(_maxTxCtrl.text) ?? 0,
      minTransactionValue: double.tryParse(_minTxCtrl.text) ?? 0,
      turnoverMonthly:
          double.tryParse(_turnoverMonthlyCtrl.text.replaceAll(',', '')) ?? 0,
      turnoverAnnual:
          double.tryParse(_turnoverAnnualCtrl.text.replaceAll(',', '')) ?? 0,
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
    context.read<OnboardingProvider>().submitApplication(application);
    setState(() => _loading = false);
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppTheme.success, size: 42),
              ),
              const SizedBox(height: 24),
              const Text('All done!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
              const SizedBox(height: 10),
              const Text(
                'Your application has been received. Next step is uploading your compliance documents.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeMain);
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

// ── Reusable UI components ────────────────────────────────────────────────────

class _SectionMeta {
  final String title;
  final String subtitle;
  final IconData icon;
  const _SectionMeta(
      {required this.title, required this.subtitle, required this.icon});
}

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? prefix;

  const _Field({
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            prefixText: prefix != null ? '$prefix  ' : null,
            prefixStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            hintStyle: const TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _GroupLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppTheme.textSecondary, size: 20),
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF7F7F8),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          borderRadius: BorderRadius.circular(12),
          border: value
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  const _BigButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }
}
