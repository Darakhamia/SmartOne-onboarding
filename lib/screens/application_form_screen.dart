import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/merchant_model.dart';
import '../models/outlet_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  int _currentSection = 0;

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

  @override
  void initState() {
    super.initState();
    _addOutlet();
    // Pre-fill with demo data if available
    final merchant = context.read<OnboardingProvider>().merchant;
    if (merchant.companyName.isNotEmpty) {
      _companyNameCtrl.text = merchant.companyName;
      _companyIdCtrl.text = merchant.companyId;
      _selectedRetailType = merchant.retailType.isNotEmpty ? merchant.retailType : AppConstants.retailTypes.first;
      _numberOfOutletsCtrl.text = merchant.numberOfOutlets.toString();
      _customReceipt = merchant.customReceiptDesign;
      _acceptanceCurrency = merchant.acceptanceCurrency;
      _currency = merchant.currency;
      _volumeMonthlyCtrl.text = merchant.volumeMonthly > 0 ? merchant.volumeMonthly.toStringAsFixed(0) : '';
      _txMonthlyCtrl.text = merchant.transactionsMonthly > 0 ? merchant.transactionsMonthly.toString() : '';
      _txAnnualCtrl.text = merchant.transactionsAnnual > 0 ? merchant.transactionsAnnual.toString() : '';
      _avgTxCtrl.text = merchant.avgTransactionValue > 0 ? merchant.avgTransactionValue.toStringAsFixed(2) : '';
      _maxTxCtrl.text = merchant.maxTransactionValue > 0 ? merchant.maxTransactionValue.toStringAsFixed(2) : '';
      _minTxCtrl.text = merchant.minTransactionValue > 0 ? merchant.minTransactionValue.toStringAsFixed(2) : '';
      _turnoverMonthlyCtrl.text = merchant.turnoverMonthly > 0 ? merchant.turnoverMonthly.toStringAsFixed(0) : '';
      _turnoverAnnualCtrl.text = merchant.turnoverAnnual > 0 ? merchant.turnoverAnnual.toStringAsFixed(0) : '';
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
        for (final ctrl in _outletControllers[index].values) {
          ctrl.dispose();
        }
        _outletControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
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

  final List<String> _sections = [
    'Company Profile',
    'Business',
    'Sales',
    'Outlets',
    'Contact',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Application Form'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (context.read<OnboardingProvider>().merchant.isSubmitted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppTheme.success),
                  SizedBox(width: 4),
                  Text('Submitted', style: TextStyle(fontSize: 12, color: AppTheme.success, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSectionTabs(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                children: [
                  if (_currentSection == 0) _buildCompanyProfile(),
                  if (_currentSection == 1) _buildBusinessQuestionnaire(),
                  if (_currentSection == 2) _buildProjectedSales(),
                  if (_currentSection == 3) _buildOutletDetails(),
                  if (_currentSection == 4) _buildContactDetails(),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      height: 48,
      color: AppTheme.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _sections.length,
        itemBuilder: (ctx, i) {
          final selected = _currentSection == i;
          return GestureDetector(
            onTap: () => setState(() => _currentSection = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Center(
                child: Text(
                  _sections[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Company Profile', icon: Icons.business_outlined),
        _field('European Company Name', _companyNameCtrl, hint: 'e.g. Apex Retail Solutions Ltd'),
        const SizedBox(height: 14),
        _field('Company ID / Registration Number', _companyIdCtrl, hint: 'e.g. GB12345678'),
      ],
    );
  }

  Widget _buildBusinessQuestionnaire() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Business Questionnaire', icon: Icons.quiz_outlined),
        const Text('Retail Type & Business Model', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRetailType,
          decoration: const InputDecoration(),
          items: AppConstants.retailTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (v) => setState(() => _selectedRetailType = v!),
        ),
        const SizedBox(height: 14),
        _field('Number of Outlets', _numberOfOutletsCtrl, hint: '1', keyboardType: TextInputType.number),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Custom Receipt Design', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('Branded receipt with your logo', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              Switch(
                value: _customReceipt,
                onChanged: (v) => setState(() => _customReceipt = v),
                activeColor: AppTheme.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Acceptance Currency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        _currencyDropdown(_acceptanceCurrency, (v) => setState(() => _acceptanceCurrency = v!)),
      ],
    );
  }

  Widget _buildProjectedSales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Projected Sales', icon: Icons.trending_up_outlined),
        const Text('Currency', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        _currencyDropdown(_currency, (v) => setState(() => _currency = v!)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field('Volume Monthly', _volumeMonthlyCtrl, hint: '85,000', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _field('Transactions Monthly', _txMonthlyCtrl, hint: '1,200', keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field('Transactions Annual', _txAnnualCtrl, hint: '14,400', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _field('Avg Transaction', _avgTxCtrl, hint: '70.83', keyboardType: TextInputType.numberWithOptions(decimal: true))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field('Max Transaction', _maxTxCtrl, hint: '5,000', keyboardType: TextInputType.numberWithOptions(decimal: true))),
          const SizedBox(width: 12),
          Expanded(child: _field('Min Transaction', _minTxCtrl, hint: '5.00', keyboardType: TextInputType.numberWithOptions(decimal: true))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field('Turnover Monthly', _turnoverMonthlyCtrl, hint: '85,000', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _field('Turnover Annual', _turnoverAnnualCtrl, hint: '1,020,000', keyboardType: TextInputType.number)),
        ]),
      ],
    );
  }

  Widget _buildOutletDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const FormSectionHeader(title: 'Outlet Details', icon: Icons.store_outlined),
            TextButton.icon(
              onPressed: _addOutlet,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Outlet'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ],
        ),
        ..._outletControllers.asMap().entries.map((entry) {
          final i = entry.key;
          final ctrls = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Outlet ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    if (_outletControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error, size: 20),
                        onPressed: () => _removeOutlet(i),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _field('Outlet Name', ctrls['name']!, hint: 'e.g. Main Branch'),
                const SizedBox(height: 10),
                _field('Retail Activity', ctrls['activity']!, hint: 'e.g. General Retail'),
                const SizedBox(height: 10),
                _field('Outlet Address', ctrls['address']!, hint: 'Full address'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _field('Number of POS', ctrls['pos']!, hint: '1', keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Contact Person', ctrls['contact']!, hint: 'Name')),
                ]),
                const SizedBox(height: 10),
                _field('Contact Phone', ctrls['phone']!, hint: '+44 7700 900000', keyboardType: TextInputType.phone),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionHeader(title: 'Contact Details', icon: Icons.contact_mail_outlined),
        _field('Company Name', _contactCompanyCtrl, hint: 'Legal company name'),
        const SizedBox(height: 14),
        _field('TIN / Tax Number', _tinCtrl, hint: 'e.g. GB987654321'),
        const SizedBox(height: 14),
        _field('Contact Person', _contactPersonCtrl, hint: 'Full name'),
        const SizedBox(height: 14),
        _field('Phone', _phoneCtrl, hint: '+44 20 0000 0000', keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        _field('Email', _emailCtrl, hint: 'contact@company.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _field('City', _cityCtrl, hint: 'London')),
          const SizedBox(width: 12),
          Expanded(child: _field('Zip Code', _zipCtrl, hint: 'EC2A 1AB')),
        ]),
        const SizedBox(height: 14),
        _field('Address', _addressCtrl, hint: 'Street address'),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final isLast = _currentSection == _sections.length - 1;
    final isFirst = _currentSection == 0;

    return Column(
      children: [
        if (isLast) ...[
          PrimaryButton(
            label: 'Submit Application',
            icon: Icons.send_rounded,
            loading: _loading,
            onPressed: _submitForm,
          ),
          const SizedBox(height: 10),
        ] else ...[
          PrimaryButton(
            label: 'Next: ${_sections[_currentSection + 1]}',
            icon: Icons.arrow_forward,
            onPressed: () => setState(() => _currentSection++),
          ),
          const SizedBox(height: 10),
        ],
        if (!isFirst)
          SecondaryButton(
            label: 'Back',
            icon: Icons.arrow_back,
            onPressed: () => setState(() => _currentSection--),
          ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _currencyDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(),
      items: AppConstants.currencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
    );
  }

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
    context.read<OnboardingProvider>().submitApplication(application);

    setState(() => _loading = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.success, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Application Submitted!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text(
              'Your merchant application has been received. Next step is to upload your compliance documents.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
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
    );
  }
}
