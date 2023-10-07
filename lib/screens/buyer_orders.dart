import 'package:flutter/material.dart';
import 'package:lain_dain/widget/accepted_order.dart';
import 'package:lain_dain/widget/pending_orders_razorpay.dart';
import 'package:lain_dain/widget/rejected_orders.dart';

class BuyerOrder extends StatefulWidget {
  const BuyerOrder({super.key});

  @override
  State<BuyerOrder> createState() => _BuyerOrderState();
}

class _BuyerOrderState extends State<BuyerOrder> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0 );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: "Pending",
            ),
            Tab(
              text: "Accepted",
            ),
            Tab(
              text: "Rejected",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingOrdersRP(),
          AcceptedOrders(),
          RejectedOrders(),
        ],
      ),
    );
  }
}
