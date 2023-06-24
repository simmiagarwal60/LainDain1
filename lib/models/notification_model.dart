import 'package:flutter/material.dart';

class Notification {
   String id;
   String title;
   String amount;
   String message;
   bool isAccepted;

  Notification({
    required this.id,
    required this.title,
    required this.amount,
    required this.message,
    required this.isAccepted,
  });

  factory Notification.fromMap(Map<String, dynamic> map, String id) {
    return Notification(
      id: id,
      title: map['title'] as String,
      amount: map['amount'] as String,
      message: map['message'] as String,
      isAccepted: map['isAccepted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'message': message,
      'isAccepted': isAccepted,
    };
  }
}