import 'orders_model.dart';

class UserOrders {
  late String userId;
  late Orders order;

  UserOrders({
    required this.userId,
    required this.order
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['userId'] = userId;
    data['order'] = order;

    return data;
  }

  UserOrders.fromJson(Map<String, dynamic> json) {
    userId = json['userId'] ?? '';
    order = json['order'] ?? '';
  }
}
