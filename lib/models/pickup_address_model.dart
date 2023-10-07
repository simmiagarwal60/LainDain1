class PickupAddress {
  late String id;
  late String fullName;
  late String pincode;
  late String city;
  late String state;
  late String houseNumber;

  PickupAddress({required this.id,required this.fullName, required this.pincode,required this.houseNumber, required this.city, required this.state});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'pincode': pincode,
      'city': city,
      'state': state,
      'houseNumber': houseNumber,
    };
  }
  PickupAddress.fromJson(Map<String, dynamic> json){
    fullName = json['fullName'] ?? '';
    id = json['id']?? '' ;
    pincode = json['pincode']?? '' ;
    city = json['city'] ?? '';
    state = json['state'] ?? '';
    houseNumber = json['houseNumber'] ?? '' ;


  }


}