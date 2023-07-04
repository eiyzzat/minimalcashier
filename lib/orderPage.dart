import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

import 'ordersPending.dart';

class orderPage extends StatefulWidget {
  const orderPage({super.key});

  @override
  State<orderPage> createState() => _orderPage();
}

class _orderPage extends State<orderPage> {
  //untuk connection
  late ConnectivityResult result;
  late StreamSubscription subscription;
  var isConnected = false;
  @override
  void initState() {
    super.initState();
    startStreaming();
  }

  checkInternet() async {
    result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none) {
      isConnected = true;
    } else {
      isConnected = false;
      showDialogBox();
    }
    setState(() {});
  }

  showDialogBox() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: const Text("NO INTERNET"),
              content: const Text("Please check your internet connection"),
              actions: [
                CupertinoButton.filled(
                    child: const Text("Retry"),
                    onPressed: () {
                      Navigator.pop(context);
                      checkInternet();
                    }),
              ],
            ));
  }

  startStreaming() {
    subscription = Connectivity().onConnectivityChanged.listen((event) async {
      checkInternet();
    });
  }

//bottom navigation bar
  Widget bottomNavigationBar() {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Image.asset(
              "lib/assets/Trash.png",
              height: 20,
              width: 20,
            ),
            onPressed: () {
              // Handle navigation to the settings screen.
            },
            iconSize: 24.0,
          ),
          Container(
            height: 48.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Image.asset(
                    "lib/assets/Persons.png",
                    height: 30,
                    width: 30,
                  ),
                  onPressed: () {
                    // Handle navigation to the home screen.
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    "lib/assets/Discount.png",
                    height: 28,
                    width: 30,
                  ),
                  onPressed: () {
                    // Handle navigation to the orders screen.
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    "lib/assets/Sort.png",
                    height: 22,
                    width: 30,
                  ),
                  onPressed: () {
                    // Handle navigation to the profile screen.
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget containerOrder() {
    return Container(
      margin: EdgeInsets.all(12),
      height: 120,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Image.asset(
            "lib/assets/Artboard 40 copy 2.png",
            width: 80,
            height: 80,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16), // Add padding to the left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'No member selected yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selected member will be displayed here',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget centerText1() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Text(
          'No orders yet!',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }

  Widget centerText2() {
    return Padding(
      padding: const EdgeInsets.only(top: 150),
      child: Center(
        child: Text(
          'Once you do,orders will',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

  Widget centerText3() {
    return Padding(
      padding: const EdgeInsets.only(top: 190),
      child: Center(
        child: Text(
          'appear here',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

//body
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Order',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Image.asset(
            "lib/assets/Artboard 40.png",
            height: 30,
            width: 20,
          ),
          onPressed: () {},
          iconSize: 24,
        ),
        actions: [
          IconButton(
            icon: Image.asset("lib/assets/Printer.png"),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset("lib/assets/Pending.png"),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (BuildContext context) {
                  return SizedBox(height: 750, child: OrdersPending());
                },
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            children: [containerOrder()],
          ),
          centerText1(),
          centerText2(),
          centerText3(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

//fetch the pending order from api
  Future<List<dynamic>> fetchPending() async {
    var headers = {
      'token': token,
    };

    var request = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      List<dynamic> pending = body['orders'];
      return pending;
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

//use to create order using member
  Future addMember() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request =
        http.Request('POST', Uri.parse('https://order.tunai.io/loyalty/order'));
    request.bodyFields = {'memberID': '18799091'};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    } else {
      print(response.reasonPhrase);
    }
  }
}
