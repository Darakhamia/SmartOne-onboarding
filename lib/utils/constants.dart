class AppConstants {
  static const String appName = 'SmartOne';
  static const String appTagline = 'Merchant Onboarding Platform';

  // Routes
  static const String routeWelcome = '/';
  static const String routeMain = '/main';
  static const String routeApplication = '/application';
  static const String routeDocuments = '/documents';
  static const String routeKyc = '/kyc';
  static const String routeContract = '/contract';
  static const String routeAdmin = '/admin';

  // Mock KYC URL
  static const String kycMockUrl = 'https://ivs.idenfy.com/api/v2/redirect?authToken=demo';

  // Onboarding step names
  static const List<String> stepNames = [
    'Application Form Submitted',
    'Documents Upload',
    'KYC Verification',
    'AML Review',
    'Submitted to Paynetics',
    'Paynetics Approval',
    'Contract Signing',
    'Submitted to DNA',
    'Terminal Preparation',
    'Terminal Handover',
    'Onboarding Complete',
  ];

  static const List<String> stepDescriptions = [
    'Business application form reviewed and submitted',
    'All required compliance documents uploaded',
    'Identity verification completed via iDenfy',
    'Anti-money laundering review in progress',
    'Application forwarded to Paynetics for review',
    'Paynetics has approved the merchant account',
    'Merchant agreement signed and countersigned',
    'Terminal request submitted to DNA Payments',
    'POS terminal being configured and tested',
    'Terminal delivered to merchant location',
    'Merchant is fully onboarded and operational',
  ];

  static const List<String> requiredDocuments = [
    'Certificate of Incorporation',
    'Company Registry Extract',
    'UBO Declaration',
    'Director Passport',
    'Proof of Address',
    'Bank Account Confirmation',
  ];

  static const List<String> documentDescriptions = [
    'Official certificate from Companies House',
    'Current extract from business registry',
    'Ultimate Beneficial Owners declaration form',
    'Valid passport of company director(s)',
    'Utility bill or bank statement (< 3 months)',
    'Bank letter or voided cheque',
  ];

  static const List<String> currencies = ['EUR', 'GBP', 'USD', 'PLN', 'CZK', 'HUF'];
  static const List<String> retailTypes = [
    'Retail – General',
    'Food & Beverage',
    'Healthcare',
    'Education',
    'Travel & Transport',
    'Entertainment',
    'Professional Services',
    'E-commerce',
    'Other',
  ];
}
