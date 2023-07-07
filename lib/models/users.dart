class Users {
  late String phoneNumber;
  late String userRole;
  late String fcmToken;
  late String userId;

  Users({
    required this.phoneNumber,
    required this.fcmToken,
    required this.userId,
    required this.userRole,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['phoneNumber'] = phoneNumber;
    data['fcmToken'] = fcmToken;
    data['userId'] = userId;
    data['userRole'] = userRole;

    return data;
  }

  Users.fromJson(Map<String, dynamic> json) {
    phoneNumber = json['phoneNumber'] ?? '';
    fcmToken = json['fcmToken'] ?? '';
    userId = json['userId'] ?? '';
    userRole = json['userRole'] ?? '';
  }
}
