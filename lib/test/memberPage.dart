import "package:flutter/material.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minimal/test/trialMenu.dart';

import '../api.dart';
import 'login.dart';

class CarMemberPage extends StatefulWidget {
  const CarMemberPage({super.key, required this.updateData});

  final Function updateData;
 
  @override
  State<CarMemberPage> createState() => _CarMemberPageState();
}

class _CarMemberPageState extends State<CarMemberPage>
    with TickerProviderStateMixin {
  final searchController = TextEditingController();
  final now = DateTime.now(); // Get the current month
  var size, height, width;
  var member;
  TabController? tabController; // Declare tabController variable
  List<dynamic> queriedList = [];
  List memberList = [];
  int currentIndex = 0;
  int recentTot = 0;
  int newTot = 0;
  int birthdayTot = 0;
  int outstandingTot = 0;
  bool isMenuVisible = false; // Track the visibility of the menu

  List<dynamic> order = [];

  loadApi() async {
    await getInformation(); // akan pegi dkt getInformation dlk baru akan baca next line kat dibah
    setState(() {
      queriedList = memberList;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController?.addListener(() {
      setState(() {
        currentIndex =
            tabController?.index ?? 0; // Update the currentIndex variable
      });
    });
    loadApi();
  }

  @override
  void dispose() {
    tabController?.dispose(); // Dispose of the tabController
    super.dispose();
  }

  Future<void> getInformation() async {
    var headers = {'token': tokenGlobal};
    var request = http.Request(
        'GET', Uri.parse('https://member.tunai.io/cashregister/member'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      memberList = [];

      member = text["members"];

      for (int i = 0; i < member.length; i++) {
        if (member[i]['deleteDate'] == 0) {
          memberList.add(member[i]);
        }
      }
      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['task'] == 'New Member') {
          newTot++;
        }
      }

      final currentMonth = DateFormat('MM').format(now);
      for (int i = 0; i < memberList.length; i++) {
        if (DateFormat('MM').format(DateTime.parse(memberList[i]['dob'])) ==
            currentMonth) {
          birthdayTot++;
        }
      }

      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['outstandings'] > 0) {
          outstandingTot++;
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Container(
      height: MediaQuery.of(context).size.height * 2.67 / 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: Text(
            'All Member',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Transform.scale(
                scale: 1.4,
                child: CloseButton(
                    color: Color(0xFF1276ff),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
          ),
        ),
        body: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Container(
                height: 5,
                width: width,
                color: Colors.white,
              ),
              Container(
                color: Colors.white,
                width: width,
                child: Column(
                  children: [
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Center(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFebebeb),
                                prefixIcon: Icon(Icons.search),
                                hintText: 'Search',
                                contentPadding: EdgeInsets.all(15.0),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
                                )),
                            onChanged: searchMember,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TabBar(
                          controller: tabController,
                          isScrollable: true,
                          labelPadding: EdgeInsets.symmetric(horizontal: 13),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 4,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.black,
                          tabs: [
                            Tab(
                              text: 'Recent',
                            ),
                            Tab(
                              text: 'New',
                            ),
                            Tab(
                              text: 'Birthday',
                            ),
                            Tab(
                              text: 'Outstanding',
                            ),
                          ]),
                    ),
                    //),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: FutureBuilder(builder: (context, snapshot) {
                  return Container(
                    width: double.infinity,
                    color: Color(0xFFf3f2f8),
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        listRecent(),
                        listNew(),
                        listBirthday(),
                        listOutstanding(),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

/* Recent */
  listRecent() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        int timestamp = queriedList[index]['todayDate'];
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        if ((index == 0 ||
            (index > 0 &&
                DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            queriedList[index - 1]['todayDate'] * 1000)) !=
                    DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            queriedList[index]['todayDate'] * 1000))))) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 15),
                child: Text(
                  formattedDate,
                  style: TextStyle(color: Color(0xFF8a8a8a)),
                ),
              ),
              getMemberBox(index)
            ],
          );
        } else {
          return getMemberBox(index);
        }
      },
    );
  }

/* New */
  listNew() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        if (queriedList[index]['task'] == 'New Member') {
          DateTime createDate = DateTime.fromMillisecondsSinceEpoch(
              queriedList[index]['createDate'] * 1000);
          if (DateFormat('MM').format(createDate) ==
              DateFormat('MM').format(now)) {
            return getMemberBox(index);
          }
        }
        return Container();
      },
    );
  }

/* Birthday */
  listBirthday() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        final currentMonth = DateFormat('MM').format(now);
        if (DateFormat('MM')
                .format(DateTime.parse(queriedList[index]['dob'])) ==
            currentMonth) {
          return getMemberBox(index);
        } else {
          return Container();
        }
      },
    );
  }

/* Outstanding */
  listOutstanding() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        if (queriedList[index]['outstandings'] != 0) {
          return getMemberBox(index);
        } else {
          return Container();
        }
      },
    );
  }

  getMemberBox(int index) {
    getTotalVoucher() async {
      var headers = {'token': tokenGlobal};
      var request = http.Request(
          'GET',
          Uri.parse('https://member.tunai.io/cashregister/member/' +
              queriedList[index]['memberID'].toString() +
              '/summary/total/vouchers'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var decode = await response.stream.bytesToString();

        var text = json.decode(decode);

        int tot = text["total"];
        return tot;
        //print(tot);
      } else {
        print(response.reasonPhrase);
      }
    }

    int timestamp = queriedList[index]['todayDate'];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String suffix = (hour >= 12) ? 'PM' : 'AM';
    hour = (hour > 12) ? hour - 12 : hour;
    String minuteString = minute.toString().padLeft(2, '0');

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: InkWell(
        onTap: () async {
          var memberID = memberList[index]['memberID'];
          final mobile = memberList[index]['mobile'];
          final memberName = memberList[index]['name'];

          await createOrder(memberID.toString());
        //  widget.fetchData();

          var orderID = order[0]['orderID'].toString();

          Navigator.of(context).pop(order);

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => trialMenuPage(
          //             memberMobile: mobile,
          //             memberName: memberName,
          //             orderId: orderID.toString(),
          //           )),
          // );
        },
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.white),
                child: Column(
                  children: [
                    Row(children: [
                      Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 5, top: 20, bottom: 0),
                          child: queriedList[index]['icon'] == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 30,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(queriedList[index]['icon']),
                                  backgroundColor: Color(0xFFf3f2f8),
                                  radius: 30,
                                )),
                      Expanded(
                        flex: 3,
                        child: queriedList[index]['dob'] == '0000-00-00'
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, top: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                          child: queriedList[index]['outstandings'] == 0
                                              ? Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 10),
                                                  child: queriedList[index]['name'] != ''
                                                      ? Text(queriedList[index]['name'].toString(),
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight
                                                                  .w500))
                                                      : Text(
                                                          '(' +
                                                              queriedList[index]['mobile']
                                                                  .substring(0, 4) +
                                                              ') ' +
                                                              queriedList[index]['mobile'].substring(4, 7) +
                                                              '-' +
                                                              queriedList[index]['mobile'].substring(7),
                                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))
                                              : Padding(padding: const EdgeInsets.only(top: 10), child: queriedList[index]['name'] != '' ? Text(queriedList[index]['name'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)) : Text('(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7) + '-' + queriedList[index]['mobile'].substring(7), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            child: queriedList[index]['vip'] ==
                                                    1
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, bottom: 50),
                                                    child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        radius: 7),
                                                  )
                                                : null),
                                        Container(
                                            child: queriedList[index]['vvip'] ==
                                                    1
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, bottom: 50),
                                                    child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.orange,
                                                        radius: 7),
                                                  )
                                                : null),
                                        Container(
                                            child:
                                                queriedList[index]['vvvip'] == 1
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5,
                                                                bottom: 50),
                                                        child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            radius: 7),
                                                      )
                                                    : null),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  bottom: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: queriedList[index]['outstandings'] == 0
                                                    ? Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 5),
                                                        child: queriedList[index]['name'] != ''
                                                            ? Text(queriedList[index]['name'].toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500))
                                                            : Text(
                                                                '(' +
                                                                    queriedList[index]['mobile']
                                                                        .substring(0, 4) +
                                                                    ') ' +
                                                                    queriedList[index]['mobile'].substring(4, 7) +
                                                                    '-' +
                                                                    queriedList[index]['mobile'].substring(7),
                                                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))
                                                    : Padding(padding: const EdgeInsets.only(top: 10), child: queriedList[index]['name'] != '' ? Text(queriedList[index]['name'].toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)) : Text('(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7) + '-' + queriedList[index]['mobile'].substring(7), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
                                            Text(queriedList[index]['dob'])
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              child:
                                                  queriedList[index]['vip'] == 1
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  bottom: 50),
                                                          child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              radius: 7),
                                                        )
                                                      : null),
                                          Container(
                                              child: queriedList[index]
                                                          ['vvip'] ==
                                                      1
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, bottom: 50),
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.orange,
                                                          radius: 7),
                                                    )
                                                  : null),
                                          Container(
                                              child: queriedList[index]
                                                          ['vvvip'] ==
                                                      1
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, bottom: 50),
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          radius: 7),
                                                    )
                                                  : null),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ]),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            child: queriedList[index]['credits'] != 0
                                ? Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: Color(0xFFf3f2f8),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 9,
                                                right: 9,
                                                top: 6,
                                                bottom: 6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                    child: Image.asset(
                                                  'icons/Dollar.png',
                                                  height: 15,
                                                )),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(formatAmount(
                                                        queriedList[index]
                                                            ['credits'])
                                                    .toString()),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )
                                : null),
                        Container(
                            child: queriedList[index]['points'] != 0
                                ? Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: Color(0xFFf3f2f8),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 9,
                                                right: 9,
                                                top: 6,
                                                bottom: 6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                    child: Image.asset(
                                                  'icons/Star.png',
                                                  height: 15,
                                                )),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(queriedList[index]
                                                        ['points']
                                                    .toString()),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )
                                : SizedBox(
                                    width: 10,
                                  )),
                        Container(
                          child: FutureBuilder(
                            future: getTotalVoucher(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // While data is being fetched, show a loading indicator
                                return Text('');
                              } else if (snapshot.hasError) {
                                // If an error occurred while fetching data, display an error message
                                return Text('Error: ${snapshot.error}');
                              } else {
                                // Data has been successfully fetched
                                int voucherValue = snapshot.data ??
                                    0; // Get the voucher value, default to 0 if null
                                if (voucherValue != 0) {
                                  // Show the voucher value
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: Color(0xFFf3f2f8),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 9,
                                              right: 9,
                                              top: 6,
                                              bottom: 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Image.asset(
                                                  'icons/Voucher.png',
                                                  height: 15,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(voucherValue.toString()),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Voucher value is 0, return null
                                  return Text('');
                                }
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, top: 10),
                          child: Text(
                            queriedList[index]['task'].toString(),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10, top: 10),
                          child: Text(
                            '$hour:$minuteString $suffix',
                            // + formattedDate,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  /* Total for each tab bar list */
  getTotalList() {
    if (currentIndex == 0) {
      return Text(
          memberList.length.toString() + '/' + memberList.length.toString());
    } else if (currentIndex == 1) {
      return Text(newTot.toString() + '/' + memberList.length.toString());
    } else if (currentIndex == 2) {
      return Text(birthdayTot.toString() + '/' + memberList.length.toString());
    } else if (currentIndex == 3) {
      return Text(
          outstandingTot.toString() + '/' + memberList.length.toString());
    } else if (currentIndex == 4) {
      return Text(
          outstandingTot.toString() + '/' + memberList.length.toString());
    }
  }

  /* Convert the amount to proper format */
  String formatAmount(dynamic amount) {
    if (amount == 0) {
      return '0.00';
    } else if (amount is int) {
      final format = NumberFormat('#,##0.00');
      return format.format(amount.toDouble());
    } else {
      final format = NumberFormat('#,##0.00');
      return format.format(amount);
    }
  }

  void searchMember(String query) {
    List<dynamic> suggestion;

    if (query.isEmpty) {
      suggestion = memberList;
    } else {
      suggestion = memberList.where((element) {
        List<String> nameParts = element['name'].toString().split(' ');
        bool nameMatch = false;
        for (int i = 0; i < nameParts.length; i++) {
          String namePart = nameParts[i].toLowerCase();
          if (namePart.startsWith(query) || namePart.endsWith(query)) {
            nameMatch = true;
            break;
          }
        }
        bool mobileMatch =
            element['mobile'].toString().toLowerCase().contains(query) ||
                element['mobile'].toString().toLowerCase().endsWith(query);
        return nameMatch || mobileMatch;
      }).toList();
    }

    setState(() {
      queriedList = suggestion;
    });
  }

  Future createOrder(String memberID) async {
    var headers = {
      'token': tokenGlobal,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request =
        http.Request('POST', Uri.parse('https://order.tunai.io/loyalty/order'));

    request.bodyFields = {'memberID': memberID};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      setState(() {
        order = body['orders'];
      });
      widget.updateData();

      // dynamic wOrder = walkinOrder.firstWhere(
      //                           (wOrder) => "21887957" == wOrder['memberID']);
      //                       final walkOrder = wOrder;
      //                       final walkOrderId = walkOrder[0]['orderID'];
    } else {
      print(response.reasonPhrase);
    }
  }
}
