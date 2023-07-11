import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'api.dart';

import 'ordersPending.dart';

class orderPage extends StatefulWidget {
  const orderPage({super.key});

  @override
  State<orderPage> createState() => _orderPage();
}

class _orderPage extends State<orderPage> {
  List<dynamic> orders = [];
  List<dynamic> members = [];
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
                    orders[0]['memberID'],
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
    //  dynamic sku = order.firstWhere((sku) =>
    //                                 sku[0]['memberID'] == member[0]['memberID'].toString());
    // final item = sku;

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
              showModalBottomSheet(
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
            children: [
              FutureBuilder(
                future: fetchPendingAndMembers(),
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    Map<String, dynamic>? data = snapshot.data;
                    if (data == null) {
                      return Center(
                        child: Text('No data available.'),
                      );
                    }

                    orders = data['pending'] ?? [];
                    members = data['members'] ?? [];

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const ScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (BuildContext context, int index) {
                        var order = orders[index];
                        var memberID = order['memberID'].toString();
                        final orderId = order['orderID'];

                        // Find the member with matching memberID
                        var memberData = members.firstWhere(
                            (member) =>
                                member['memberID'].toString() == memberID,
                            orElse: () => null);

                        var memberName =
                            memberData != null ? memberData['name'] : 'N/A';
                        var memberMobile =
                            memberData != null ? memberData['mobile'] : 'N/A';

                        String formattedNumber =
                            '(${memberMobile.substring(0, 4)}) ${memberMobile.substring(4, 7)}-${memberMobile.substring(7)}';

                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 5.0, left: 8.0, right: 8.0),
                          child: Card(
                            child: Column(children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Image.asset(
                                      "lib/assets/Artboard 40 copy 2.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                    ), // Add padding to the left
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          memberName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          formattedNumber,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            DateFormat('dd-MM-yyyy').format(
                                                DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        order['createDate'] *
                                                            1000)),
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            order['amount'].toStringAsFixed(2),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ]),
                          ),
                        );
                      },
                    );
                  }
                },
              )
            ],
          ),
          centerText1(),
          centerText2(),
          centerText3(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  // getMember() async {
  //   var headers = {'token': token};
  //   var request = http.Request(
  //       'GET', Uri.parse('https://member.tunai.io/loyalty/member'));

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     final responsebody = await response.stream.bytesToString();
  //     final body = json.decode(responsebody);
  //     print(await response.stream.bytesToString());

  //     member = body;
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  // Future getOrder() async {
  //   var headers = {'token': token};
  //   var request = http.Request(
  //       'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     final responsebody = await response.stream.bytesToString();
  //     final body = json.decode(responsebody);

  //     if (body != null) {
  //       order = body;
  //       print(order);
  //       return order;
  //     } else {
  //       print('No orders found.');
  //       return null;
  //     }
  //   } else {
  //     // Handle the response status code if needed
  //   }
  // }

  Future<Map<String, dynamic>> fetchPendingAndMembers() async {
    var headers = {
      'token': token,
    };

    var pendingRequest = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );
    pendingRequest.headers.addAll(headers);

    var membersRequest = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );
    membersRequest.headers.addAll(headers);

    var pendingResponse = await http.Client().send(pendingRequest);
    var membersResponse = await http.Client().send(membersRequest);

    if (pendingResponse.statusCode == 200 &&
        membersResponse.statusCode == 200) {
      final pendingResponseBody = await pendingResponse.stream.bytesToString();
      final membersResponseBody = await membersResponse.stream.bytesToString();
      final pendingBody = json.decode(pendingResponseBody);
      final membersBody = json.decode(membersResponseBody);

      orders = pendingBody['orders'];
      members = membersBody['members'];

      Map<String, dynamic> result = {
        'pending': orders,
        'members': members,
      };
      // print('In the result: $result');
      return result;
    } else {
      print(pendingResponse.reasonPhrase);
      print(membersResponse.reasonPhrase);
      return {};
    }
  }
}
