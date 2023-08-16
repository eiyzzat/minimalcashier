// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sized_box_for_whitespace, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'orderDetails.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  List<dynamic> sales = [];
  List<dynamic> _less30days = [];
  List<dynamic> _less180days = [];
  List<dynamic> _more180days = [];
  
  Map<String, List<dynamic>> groupedLess30days = {};
  Map<String, List<dynamic>> groupedLess180days = {};
  Map<String, List<dynamic>> groupedMore180days = {};
  Map<String, List<dynamic>> groupedAll = {};

  Future getSales() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/sales'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _less30days = [];
      _less180days = [];
      _more180days = [];
      groupedLess30days = {};
      groupedLess180days = {};
      groupedMore180days = {};
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> sale = body;

      sales = sale['sales'];
      sales.sort((a, b) => b['salesDate'].compareTo(a['salesDate']));

      DateTime currentDate = DateTime.now();

      if (sales.isNotEmpty) {
        // Filter the sales items less than 30 days from the current date
        List<dynamic> less30days = sales.where((item) {
          int postedTimestamp = item['salesDate'];
          DateTime createDate =
              DateTime.fromMillisecondsSinceEpoch(postedTimestamp * 1000);
          Duration difference = currentDate.difference(createDate);
          return difference.inDays < 30;
        }).toList();

        // Filter the sales items between 30 and 180 days from the current date
        List<dynamic> less180days = sales.where((item) {
          int postedTimestamp = item['salesDate'];
          DateTime createDate =
              DateTime.fromMillisecondsSinceEpoch(postedTimestamp * 1000);
          Duration difference = currentDate.difference(createDate);
          return difference.inDays < 180;
        }).toList();

        // Filter the sales items between 30 and 180 days from the current date
        List<dynamic> more180days = sales.where((item) {
          int postedTimestamp = item['salesDate'];
          DateTime createDate =
              DateTime.fromMillisecondsSinceEpoch(postedTimestamp * 1000);
          Duration difference = currentDate.difference(createDate);
          return difference.inDays > 180;
        }).toList();

        // Add the filtered items to the respective lists
        _less30days.addAll(less30days);
        _less180days.addAll(less180days);
        _more180days.addAll(more180days);
      }

      Map<String, List<dynamic>> groupByMonthYear(List<dynamic> items) {
        Map<String, List<dynamic>> groupedItems = {};

        for (var item in items) {
          int postedTimestamp = item['salesDate'];
          DateTime createDate =
              DateTime.fromMillisecondsSinceEpoch(postedTimestamp * 1000);
          String formattedMonthYear =
              DateFormat('MMMM yyyy').format(createDate);

          if (groupedItems.containsKey(formattedMonthYear)) {
            groupedItems[formattedMonthYear]!.add(item);
          } else {
            groupedItems[formattedMonthYear] = [item];
          }
        }

        return groupedItems;
      }

      // Group the items in _less30days
      groupedLess30days = groupByMonthYear(_less30days);

      // Group the items in _less180days
      groupedLess180days = groupByMonthYear(_less180days);

      // Group the items in _more180days
      groupedMore180days = groupByMonthYear(_more180days);

      // Group all items
      groupedAll = groupByMonthYear(sales);
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            )),
            centerTitle: true,
            title: Text(
              'Sales',
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
          body: FutureBuilder(
              future: getSales(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container(
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
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    labelColor: Color(0xFF1276ff),
                                    labelPadding: EdgeInsets
                                        .zero, // Adjust the padding here
                                    unselectedLabelColor:
                                        Color.fromRGBO(170, 170, 170, 1.0),
                                    tabs: [
                                      Tab(
                                        text: '<30 days',
                                      ),
                                      Tab(
                                        text: '<180 days',
                                      ),
                                      Tab(
                                        text: '>180 days',
                                      ),
                                      Tab(
                                        text: 'All',
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: TabBarView(
                                children: [
                                  getless30days(),
                                  getless180days(),
                                  getmore180days(),
                                  getall(),
                                ],
                              ),
                            ),
                          )
                        ],
                      ));
                }
              })),
    );
  }

  Widget getless30days() {
    return getDesign(groupedLess30days);
  }

  Widget getless180days() {
    return getDesign(groupedLess180days);
  }

  Widget getmore180days() {
    return getDesign(groupedMore180days);
  }

  Widget getall() {
    return getDesign(groupedAll);
  }

  Widget getDesign(Map<String, List<dynamic>> group) {
    double screenWidth = MediaQuery.of(context).size.width - 40;
    double width = screenWidth / 4;
    return SingleChildScrollView(
      child: Column(
        children: group.entries.map((entry) {
          final String monthYear = entry.key;
          final List<dynamic> items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
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

                  double totalPaid = item['saleAmount'].toDouble() -
                      item['outstandingsAmount'].toDouble() -
                      item['redeemAmount'].toDouble();

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
                                  'https://member.tunai.io/cashregister/member/$memberIDglobal/credits'));

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
                            isScrollControlled: true,
                            barrierColor: Colors.transparent,
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
                                      'Order #${items[index]['saleID']}',
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
                                    if (items[index]['discountAmount'] != 0)
                                      Container(
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
                                                      ['discountAmount'])
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Color(0xFF28cd41)),
                                            )
                                          ],
                                        ),
                                      ),
                                    if (items[index]['outstandingsAmount'] != 0)
                                      Container(
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
                                                      ['outstandingsAmount'])
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Color(0xFFbe2f19)),
                                            )
                                          ],
                                        ),
                                      ),
                                    if (items[index]['redeemAmount'] != 0)
                                      Container(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment: items[index]
                                                          ['discountAmount'] !=
                                                      0 ||
                                                  items[index][
                                                          'outstandingsAmount'] !=
                                                      0
                                              ? CrossAxisAlignment.end
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
                                      Container(
                                        width: width,
                                        child: Column(
                                          crossAxisAlignment: items[index]
                                                          ['discountAmount'] !=
                                                      0 ||
                                                  items[index][
                                                          'outstandingsAmount'] !=
                                                      0 ||
                                                  items[index]
                                                          ['redeemAmount'] !=
                                                      0
                                              ? items[index][
                                                          'outstandingsAmount'] ==
                                                      0
                                                  ? CrossAxisAlignment.start
                                                  : CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Paid',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  formatAmount(totalPaid)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFF1276ff)),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
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
}
