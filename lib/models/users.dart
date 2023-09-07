class Users {
  late String fullName;
  late String phoneNumber;
  late String fcmToken;
  late String userId;
  late String image;

  Users({
    required this.fullName,
    required this.phoneNumber,
    required this.fcmToken,
    required this.userId,
    required this.image
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['fcmToken'] = fcmToken;
    data['userId'] = userId;
    data['image'] = image;

    return data;
  }

  Users.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'] ?? '';
    phoneNumber = json['phoneNumber'] ?? '';
    fcmToken = json['fcmToken'] ?? '';
    userId = json['userId'] ?? '';
    image = json['image'] ?? '';
  }
}
