import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minimal/test/addMember.dart';
import 'package:minimal/test/memberPage.dart';
import 'package:minimal/test/trialMenu.dart';
import 'package:minimal/test/walkin.dart';
import 'api.dart';
import 'dart:convert';
import 'intro.dart';
import 'menu.dart';

class OrdersPending extends StatefulWidget {
  const OrdersPending({
    Key? key,
  }) : super(key: key);

  @override
  State<OrdersPending> createState() => _OrdersPendingState();
}

class _OrdersPendingState extends State<OrdersPending> {
  List<dynamic> orders = [];
  List<dynamic> members = [];

  Widget xIcon() {
    return IconButton(
      icon: Image.asset(
        "lib/assets/Artboard 40.png",
        height: 30,
        width: 20,
      ),
      onPressed: () => Navigator.pop(context),
      iconSize: 24,
    );
  }

  Widget pendingIcon() {
    return IconButton(
        icon: Image.asset("lib/assets/Pending.png"),
        onPressed: () {
          // Implement onPressed action
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        title: const Text(
          'Pending Order',
          style: TextStyle(color: Colors.black),
        ),
        leading: xIcon(),
        actions: [pendingIcon()],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: Colors.grey[200],
            ),
            Column(
              children: [
                // toDisplay()
                inPending()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget toDisplay() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            children: [
              //ni box add member
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const intro()),
                  );
                },
                child: Container(
                  width: 160,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/Add Member.png',
                        height: 30,
                        width: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'New',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Row(
                children: [
                  //ni box member
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 160,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/assets/Member.png',
                            height: 23,
                            width: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Member',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        displayPending()
      ],
    );
  }

  Widget inPending() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 95,
            width: double.infinity,
            color: Colors.grey[200]?.withOpacity(0.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const intro()),
                            );
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/3.png',
                                  height: 19,
                                  width: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'New',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AddMember()),
                            );
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/1.png',
                                  height: 19,
                                  width: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Walk-in',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CarMemberPage()),
                        );
                      },
                      child: Container(
                        height: 35,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/2.png',
                              height: 19,
                              width: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Search member',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Order list',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
        displayPending(),
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'System will automatically delete orders older than 2 days.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget displayPending() {
    return FutureBuilder(
      future: fetchPendingAndMembers(),
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
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
                  (member) => member['memberID'].toString() == memberID,
                  orElse: () => null);

              var memberName = memberData != null ? memberData['name'] : 'N/A';
              var memberMobile =
                  memberData != null ? memberData['mobile'] : 'N/A';

              String formattedNumber =
                  '(${memberMobile.substring(0, 4)}) ${memberMobile.substring(4, 7)}-${memberMobile.substring(7)}';

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoTheme(
                        data: CupertinoThemeData(
                          primaryContrastingColor: Colors.white,
                        ),
                        child: CupertinoAlertDialog(
                          title: Text('Switch customer'),
                          content: Text('Switch to $memberName\'s order?'),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Dismiss the dialog
                                Navigator.of(context)
                                    .push(
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            //sini pakai testMenuPage
                                            trialMenuPage(
                                          orderId: orderId.toString(),
                                          // memberId: (orders[index] as Map<
                                          //         String, dynamic>)['memberID']
                                          //     .toString(),
                                          memberName: memberName,
                                          memberMobile: formattedNumber,
                                        ),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(0,
                                                  1), // Start the transition from bottom
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                      ),
                                    )
                                    .then((value) => setState(() {}));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 5.0, left: 8.0, right: 8.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            order['createDate'] * 1000)),
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
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
                ),
              );
            },
          );
        }
      },
    );
  }

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