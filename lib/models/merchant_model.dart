import 'outlet_model.dart';

class MerchantApplication {
  // Company Profile
  String companyName;
  String companyId;

  // Business Questionnaire
  String retailType;
  int numberOfOutlets;
  bool customReceiptDesign;
  String acceptanceCurrency;

  // Projected Sales
  String currency;
  double volumeMonthly;
  int transactionsMonthly;
  int transactionsAnnual;
  double avgTransactionValue;
  double maxTransactionValue;
  double minTransactionValue;
  double turnoverMonthly;
  double turnoverAnnual;

  // Outlet Details
  List<OutletDetail> outlets;

  // Contact Details
  String contactCompanyName;
  String tin;
  String contactPerson;
  String phone;
  String email;
  String city;
  String zipCode;
  String address;

  // Submission
  bool isSubmitted;
  DateTime? submittedAt;

  MerchantApplication({
    this.companyName = '',
    this.companyId = '',
    this.retailType = '',
    this.numberOfOutlets = 1,
    this.customReceiptDesign = false,
    this.acceptanceCurrency = 'EUR',
    this.currency = 'EUR',
    this.volumeMonthly = 0,
    this.transactionsMonthly = 0,
    this.transactionsAnnual = 0,
    this.avgTransactionValue = 0,
    this.maxTransactionValue = 0,
    this.minTransactionValue = 0,
    this.turnoverMonthly = 0,
    this.turnoverAnnual = 0,
    List<OutletDetail>? outlets,
    this.contactCompanyName = '',
    this.tin = '',
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.city = '',
    this.zipCode = '',
    this.address = '',
    this.isSubmitted = false,
    this.submittedAt,
  }) : outlets = outlets ?? [OutletDetail()];

  static MerchantApplication demo() {
    return MerchantApplication(
      companyName: 'Apex Retail Solutions Ltd',
      companyId: 'GB12345678',
      retailType: 'Retail – General',
      numberOfOutlets: 3,
      customReceiptDesign: true,
      acceptanceCurrency: 'EUR',
      currency: 'EUR',
      volumeMonthly: 85000,
      transactionsMonthly: 1200,
      transactionsAnnual: 14400,
      avgTransactionValue: 70.83,
      maxTransactionValue: 5000,
      minTransactionValue: 5,
      turnoverMonthly: 85000,
      turnoverAnnual: 1020000,
      outlets: [
        OutletDetail(
          outletName: 'Apex Central',
          retailActivity: 'General Retail',
          address: '12 High Street, London, EC2A 1AB',
          numberOfPos: 3,
          contactPerson: 'James Walker',
          contactPhone: '+44 7700 900123',
        ),
        OutletDetail(
          outletName: 'Apex East',
          retailActivity: 'General Retail',
          address: '45 Brick Lane, London, E1 6RF',
          numberOfPos: 2,
          contactPerson: 'Sarah Green',
          contactPhone: '+44 7700 900456',
        ),
      ],
      contactCompanyName: 'Apex Retail Solutions Ltd',
      tin: 'GB987654321',
      contactPerson: 'Michael Apex',
      phone: '+44 20 7946 0958',
      email: 'onboarding@apexretail.co.uk',
      city: 'London',
      zipCode: 'EC2A 1AB',
      address: '12 High Street, Shoreditch',
      isSubmitted: true,
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
    );
  }
}
