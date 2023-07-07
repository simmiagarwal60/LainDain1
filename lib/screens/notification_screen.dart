import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lain_dain/screens/payment_page.dart';
import 'package:lain_dain/widget/my_order_card.dart';
import 'package:lain_dain/models/notification_model.dart' as notify;

class NotificationScreen extends StatefulWidget {
  final String info;
  const NotificationScreen({Key? key, required this.info}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
 // Notification notification = Notification();

  Stream<List<dynamic>> getNotificationStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) =>doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: Column(
        children: [
      StreamBuilder<List<dynamic>>(
      stream: getNotificationStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<dynamic> data = snapshot.data!;
          List<notify.Notification> notifications = data.map((item) {
            return notify.Notification(
              id: item['id'],
              title: item['title'],
              amount: item['amount'],
              message: item['message'],
              isAccepted: item['false'],
              // Extract other properties from 'item' and assign them to Notification object
            );
          }).toList().cast<notify.Notification>();

          return Expanded(
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 20),
                itemCount: notifications.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  notify.Notification notification = notifications[index];
                  return SizedBox(
                    height: 150,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(notification.title, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(notification.message, style: const TextStyle(color: Colors.black54, fontSize: 16),),
                              Row(
                                children: [
                                  ElevatedButton(onPressed: (){
                                    acceptOrder(notification);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentScreen(
                                          businessName: notification.title,
                                          orderId:notification.id,
                                          amount: notification.amount.toString(), // Replace with the actual order amount
                                        ),
                                      ),
                                    );
                                  },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 67, 160, 71),

                                    ),
                                    child: const Text("ACCEPT"),),
                                  const SizedBox(width: 10,),
                                  ElevatedButton(onPressed: (){
                                    rejectOrder(notification);
                                    FirebaseFirestore.instance.collection('notifications').doc(notifications[index].id).delete();
                                  },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 67, 160, 71),),
                                      child: const Text("REJECT")),],
                              )

                              // ButtonWidget(text: "REJECT", onClicked: (){})
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          );
          // Rest of the code...
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    )

        ],
      ),
    );
  }
  void acceptOrder(notify.Notification notification) {
    // Handle the logic when the order is accepted
    // ...
    // Update the notification status
    notification.isAccepted = true;
    updateNotification(notification);
  }

  void rejectOrder(notify.Notification notification) {
    // Handle the logic when the order is rejected
    // ...
    // Update the notification status
    notification.isAccepted = false;
    updateNotification(notification);
  }

  void updateNotification(notify.Notification notification) async {
    CollectionReference notificationsRef = FirebaseFirestore.instance.collection('notifications');
    await notificationsRef.doc(notification.id).update(notification.toMap());
  }

}
