class Orders {
  late String orderId;
  late String businessName;
  late String orderCategory;
  late String orderValue;
  late String orderWeightage;
  late String customerMobileNumber;
  late String pickupAddress;
  late String deliveryAddress;
  late String status;

  Orders({
    required this.orderId,
    required this.businessName,
    required this.orderCategory,
    required this.orderValue,
    required this.orderWeightage,
    required this.customerMobileNumber,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'businessName': businessName,
      'orderValue': orderValue,
      'orderCategory': orderCategory,
      'orderWeightage': orderWeightage,
      'customerMobileNumber': customerMobileNumber,
      'pickupAddress': pickupAddress,
      'deliveryAddress': deliveryAddress,
      'status': status
    };
  }
  Orders.fromJson(Map<String, dynamic> json){
    orderId = json['orderId'];
    businessName = json['businessName'];
    orderValue =(json['orderValue']);
    orderCategory = json['orderCategory'];
    orderWeightage = json['orderWeightage'];
    customerMobileNumber = json['customerMobileNumber'];
    pickupAddress = json['pickupAddress'];
    deliveryAddress = json['deliveryAddress'];
    status = json['status'] ?? '' ;
  }
}
