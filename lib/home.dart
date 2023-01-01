import 'package:lain_dain/buyer-form.dart';
import 'package:lain_dain/seller-form.dart';
import 'package:lain_dain/widget/button_widget.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  static const String title = 'LainDain';


  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: title,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
        
        home: MainPage(),
      );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
          backgroundColor: Color.fromARGB(255, 67, 160, 71),
          elevation: 50.0,
       /* leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu Icon',
          onPressed: () {
            
          },
        ),*/
          centerTitle: true,
        ),
         drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 67, 160, 71),
              ),
              child: Text('LainDain'),
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
        
        body: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: [
              Text("I am a", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
              ),
              SizedBox(
                height: 25,
              ),

              ButtonWidget(
                text: 'Seller',
                onClicked: (){
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormScreen()),
                        );
                },
              ),
              const SizedBox(height: 16),
              ButtonWidget(
                text: 'Buyer',
                onClicked: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuyerFormScreen()),
                    );
                },
              ),
            ],
          ),
        )
  );
}