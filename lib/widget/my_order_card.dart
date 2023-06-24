import 'package:flutter/material.dart';

class MyOrderCard extends StatelessWidget {
  final String businessName;
  final String orderValue;
  const MyOrderCard({Key? key, required this.businessName, required this.orderValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(businessName, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Amount: $orderValue", style: const TextStyle(color: Colors.black54, fontSize: 16),),
                Row(
                  children: [
                    ElevatedButton(onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 67, 160, 71),

                    ),
                      child: const Text("ACCEPT"),),
                    const SizedBox(width: 10,),
                    ElevatedButton(onPressed: (){},
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
  }
}
