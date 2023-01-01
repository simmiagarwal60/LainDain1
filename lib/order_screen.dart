import 'package:flutter/material.dart';

class OrderScreeen extends StatefulWidget {
  const OrderScreeen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OrderScreenState();
  }
}
class OrderScreenState extends State<OrderScreeen> {
   late String _orderValue;
   late String _orderWeightage;
   late String _mobileNumber;
   late String _pkupAddr;
   late String _delAddr;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildov() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'ORDER VALUE',
        icon: Icon(Icons.shopping_cart_sharp),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _orderValue = value!;
      },
    );
  }

  Widget _buildow() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'ORDER WEIGHTAGE',
        icon: Icon(Icons.anchor_outlined),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _orderWeightage = value!;
      },
    );
  }

  Widget _buildMobileNumber() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'CUSTOMER MOBILE NUMBER',
        icon: Icon(Icons.phone),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      maxLength: 10,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _mobileNumber = value!;
      },
    );
  }

  Widget _buildPkupAddr() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'PICK-UP ADDRESS',
         icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }

        return null;
      },
      onSaved: (value) {
        _pkupAddr = value!;
      },
    );
  }

  Widget _buildDelAddr() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'DELHIVERY ADDRESS',
        icon: Icon(Icons.location_city),
        iconColor: Color.fromARGB(255, 67, 160, 71),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Field is Required';
        }
        
        return null;
      },
      onSaved: (value) {
        _delAddr= value!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LainDain"),
        backgroundColor: const Color.fromARGB(255, 67, 160, 71),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildov(),
                _buildow(),
                _buildMobileNumber(),
                _buildPkupAddr(),
                _buildDelAddr(),
                const SizedBox(height: 100),
                RaisedButton(
                  child: const Text(
                    'PROCEED TO CHECKOUT',
                    style: TextStyle(color: Color.fromARGB(255, 67, 160, 71), fontSize: 16),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    _formKey.currentState!.save();
                    print(_orderValue);
                    print(_orderWeightage);
                    print(_mobileNumber);
                    print(_pkupAddr);
                    print(_delAddr);
                    //Send to API
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}