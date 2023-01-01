// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'order_screen.dart';

class FormScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return FormScreenState();
  }
}

class FormScreenState extends State<FormScreen> {
   late String _pan;
   late String _firstName;
   late String _lastName;
   late String _businessName;
   late String _pkupAddress;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget _buildPan() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'PAN NUMBER',
         icon: Icon(Icons.payment),
         iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      maxLength: 10,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _pan = value!;
      },
    );
  }

  Widget _buildFirstName() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'FIRST NAME',
        focusColor: Color.fromARGB(255, 67, 160, 71),
         icon: Icon(Icons.person),
         iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _firstName = value!;
      },
    );
  }

  Widget _buildLastName() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'LAST NAME',
        icon: Icon(Icons.person),
        iconColor: Color.fromARGB(255, 67, 160, 71),
        ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _lastName = value!;
      },
    );
  }

  Widget _buildBusinessName() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'BUSINESS NAME',
        icon: Icon(Icons.business_center_sharp),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _businessName = value!;
      },
    );
  }

  Widget _buildPkupAdd() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'PICK-UP ADDRESS',
        icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
        
      ),
      keyboardType: TextInputType.streetAddress,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _pkupAddress = value!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("LainDain"),
        backgroundColor: Color.fromARGB(255, 67, 160, 71),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildPan(),
                _buildFirstName(),
                _buildLastName(),
                _buildBusinessName(),
                _buildPkupAdd(),
                const SizedBox(height: 100),
                RaisedButton(
                  child: const Text(
                    'PROCEED',
                    style: TextStyle(color: Color.fromARGB(255, 67, 160, 71), fontSize: 16),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                      }
                      {                      
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderScreeen()),
                        );
                      }

                    _formKey.currentState!.save();

                    print(_pan);
                    print(_firstName);
                    print(_lastName);
                    print(_businessName);
                    print(_pkupAddress);
                    //Send to API
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}