class OutletDetail {
  String outletName;
  String retailActivity;
  String address;
  int numberOfPos;
  String contactPerson;
  String contactPhone;

  OutletDetail({
    this.outletName = '',
    this.retailActivity = '',
    this.address = '',
    this.numberOfPos = 1,
    this.contactPerson = '',
    this.contactPhone = '',
  });

  Map<String, dynamic> toMap() => {
    'outletName': outletName,
    'retailActivity': retailActivity,
    'address': address,
    'numberOfPos': numberOfPos,
    'contactPerson': contactPerson,
    'contactPhone': contactPhone,
  };
}
