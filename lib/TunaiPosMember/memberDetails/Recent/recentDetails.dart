// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import '../Sales/orderDetails.dart';

class RecentDetails extends StatefulWidget {
  final Map<String, List<dynamic>> groupItem;
  final Map<String, List<dynamic>> groupStaff;
  final String itemName;
  const RecentDetails(
      {super.key,
      required this.groupItem,
      required this.itemName,
      required this.groupStaff});

  @override
  State<RecentDetails> createState() => _RecentDetailsState();
}

class _RecentDetailsState extends State<RecentDetails> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: Text(
            widget.itemName,
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Transform.scale(
              scale: 1.4,
              child: CloseButton(
                color: Color(0xFF1276ff),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: Container(
            color: Color(0xFFf3f2f8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 15, bottom: 10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(235, 235, 235, 1.0),
                        borderRadius: BorderRadius.circular(8.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TabBar(
                          indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0)),
                          labelColor: Color(0xFF1276ff),
                          labelPadding:
                              EdgeInsets.zero, // Adjust the padding here
                          unselectedLabelColor:
                              Color.fromRGBO(170, 170, 170, 1.0),
                          tabs: [
                            Tab(
                              text: 'Month',
                            ),
                            Tab(
                              text: 'Staff',
                            ),
                          ]),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: TabBarView(
                      children: [getlMonth(), getStaff()],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }

  Widget getlMonth() {
    double screenWidth = MediaQuery.of(context).size.width - 40;
    double width = screenWidth / 4;
    return SingleChildScrollView(
      child: Column(
        children: widget.groupItem.entries.map((entry) {
          final String monthYear = entry.key;
          final List<dynamic> items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                child: Text(
                  monthYear,
                  style: TextStyle(color: Color(0xFF8a8a8a)),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final dynamic item = items[index];
                  final int timestamp = item['salesDate'];
                  final DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                  final String formattedDate =
                      DateFormat('hh:mm a, dd-MM-yyyy').format(dateTime);

                  double totalPaid = item['priceAmt'].toDouble() -
                      item['outstandAmt'].toDouble();

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          List<dynamic> credit = [];
                          double amount = 0;

                          var headers = {'token': token};
                          var request = http.Request(
                              'GET',
                              Uri.parse(
                                  'https://member.tunai.io/cashregister/member/' +
                                      memberIDglobal +
                                      '/credits'));

                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

                          if (response.statusCode == 200) {
                            final responsebody =
                                await response.stream.bytesToString();
                            var body = json.decode(responsebody);

                            Map<String, dynamic> creditss = body;

                            credit = creditss['credits'];
                            for (int i = 0; i < credit.length; i++) {
                              if (credit[i]['consumed']['saleID'] ==
                                  items[index]['saleID']) {
                                amount = credit[i]['amount'].toDouble();
                              }
                            }
                          } else {
                            print(response.reasonPhrase);
                          }

                          showModalBottomSheet<dynamic>(
                            enableDrag: false,
                            barrierColor: Colors.transparent,
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            )),
                            builder: (BuildContext context) {
                              return OrderDetails(
                                  amount: amount.toDouble(),
                                  saleID: items[index]['saleID']);
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Order #' +
                                          items[index]['saleID'].toString(),
                                      style:
                                          TextStyle(color: Color(0xFF878787)),
                                    ),
                                    Spacer(),
                                    Text(
                                      formattedDate,
                                      style:
                                          TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                                Divider(),
                                Row(
                                  children: [
                                    if (items[index]['discountAmt'] != 0)
                                      SizedBox(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Discount',
                                              style: TextStyle(
                                                  color: Color(0xFF878787)),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              formatAmount(items[index]
                                                      ['discountAmt'])
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Color(0xFF28cd41)),
                                            )
                                          ],
                                        ),
                                      ),
                                    if (items[index]['outstandAmt'] != 0)
                                      SizedBox(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Outstanding',
                                              style: TextStyle(
                                                  color: Color(0xFF878787)),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              formatAmount(items[index]
                                                      ['outstandAmt'])
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Color(0xFFbe2f19)),
                                            )
                                          ],
                                        ),
                                      ),
                                    if (items[index]['redeemAmount'] != 0)
                                      SizedBox(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment: items[index]
                                                          ['discountAmt'] !=
                                                      0 ||
                                                  items[index]['outstandAmt'] !=
                                                      0
                                              ? CrossAxisAlignment.center
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Redeem',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  formatAmount(items[index]
                                                          ['redeemAmount'])
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFff9502)),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (totalPaid != 0)
                                      SizedBox(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment: items[index]
                                                          ['discountAmt'] !=
                                                      0 ||
                                                  items[index]['outstandAmt'] !=
                                                      0 ||
                                                  items[index]
                                                          ['redeemAmount'] !=
                                                      0
                                              ? items[index]['outstandAmt'] != 0
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Item price',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  formatAmount(items[index]
                                                          ['priceAmt'])
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFF1276ff)),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  );
                },
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget getStaff() {
    double screenWidth = MediaQuery.of(context).size.width - 40;
    double width = screenWidth / 4;
    final sortedKeys = widget.groupStaff.keys.toList()..sort();
    return SingleChildScrollView(
      child: Column(
        children: sortedKeys.map((staffName) {
          final List<dynamic> items = widget.groupStaff[staffName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                child: Text(
                  staffName,
                  style: TextStyle(color: Color(0xFF8a8a8a)),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final dynamic item = items[index];
                  final int timestamp = item['salesDate'];
                  final DateTime dateTime =
                      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                  final String formattedDate =
                      DateFormat('hh:mm a, dd-MM-yyyy').format(dateTime);

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          List<dynamic> credit = [];
                          double amount = 0;

                          var headers = {'token': token};
                          var request = http.Request(
                              'GET',
                              Uri.parse(
                                  'https://member.tunai.io/cashregister/member/' +
                                      memberIDglobal +
                                      '/credits'));

                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

                          if (response.statusCode == 200) {
                            final responsebody =
                                await response.stream.bytesToString();
                            var body = json.decode(responsebody);

                            Map<String, dynamic> creditss = body;

                            credit = creditss['credits'];
                            for (int i = 0; i < credit.length; i++) {
                              if (credit[i]['consumed']['saleID'] ==
                                  items[index]['saleID']) {
                                amount = credit[i]['amount'].toDouble();
                              }
                            }
                          } else {
                            print(response.reasonPhrase);
                          }

                          showModalBottomSheet<dynamic>(
                            enableDrag: false,
                            barrierColor: Colors.transparent,
                            isScrollControlled: true,
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            )),
                            builder: (BuildContext context) {
                              return OrderDetails(
                                  amount: amount.toDouble(),
                                  saleID: items[index]['saleID']);
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Order #' +
                                        items[index]['saleID'].toString(),
                                    style: TextStyle(color: Color(0xFF878787)),
                                  ),
                                  Spacer(),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(color: Color(0xFF878787)),
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  if (items[index]['effort'] != 0)
                                    SizedBox(
                                      width: width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Effort',
                                            style: TextStyle(
                                                color: Color(0xFF878787)),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            formatAmount(items[index]['effort'])
                                                .toString(),
                                            style: TextStyle(
                                                color: Color(0xFF333333)),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (items[index]['hof'] != 0)
                                    SizedBox(
                                      width: width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Hands on',
                                            style: TextStyle(
                                                color: Color(0xFF878787)),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            formatAmount(items[index]['hof'])
                                                .toString(),
                                            style: TextStyle(
                                                color: Color(0xFF333333)),
                                          )
                                        ],
                                      ),
                                    ),
                                  if (items[index]['itemPrice'] != 0)
                                    SizedBox(
                                      width: width,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Item price',
                                                style: TextStyle(
                                                    color: Color(0xFF878787)),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                formatAmount(items[index]
                                                        ['itemPrice'])
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  );
                },
              ),
              SizedBox(
                height: 10,
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}
