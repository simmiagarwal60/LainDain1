class Aadhaardata {
  final String? clientId;
  final String? otpSentStatus;
  final String? validAadhaar;
  Aadhaardata({this.clientId, this.otpSentStatus, this.validAadhaar});

  factory Aadhaardata.fromJson(Map<String, dynamic> json) {
    return Aadhaardata(
      clientId: json["client_id"] as String,
    );
  }
}