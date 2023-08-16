import 'package:flutter/material.dart';

import '../constant/token.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

class addOrder extends StatefulWidget {
  const addOrder({super.key, required this.title});

  final String title;

  @override
  State<addOrder> createState() => _addOrderState();
}

class _addOrderState extends State<addOrder> {
  //TextEditingController memberIDcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              ElevatedButton(
                  onPressed: () {
                    addMember();
                  },
                  child: const Text('Create'))
            ],
          ),
        ),
      ),
    );
  }

  void addMember() async {
    var headers = {
      'token':token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request =
        http.Request('POST', Uri.parse('https://order.tunai.io/loyalty/order'));
    request.bodyFields = {'memberID': '20630137'};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Order',)),
              ); 
      });
     
    } else {
      print(response.reasonPhrase);
    }
  }
}
