// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, duplicate_ignore, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'recentDetails.dart';

class Recent extends StatefulWidget {
  const Recent({super.key});

  @override
  State<Recent> createState() => _RecentState();
}

class _RecentState extends State<Recent> {
  List<dynamic> allSales = [];
  List<dynamic> service = [];
  List<dynamic> product = [];
  List<dynamic> package = [];
  List<dynamic> discount = [];
  List<dynamic> completeds = [];

  Map<String, List<dynamic>> serviceGroup = {};
  Map<String, List<dynamic>> productGroup = {};
  Map<String, List<dynamic>> packageGroup = {};
  Map<String, List<dynamic>> discountGroup = {};

  String randomImage =
      'https://img.tunai.io/image/s3-c522e6fd-c5f2-44ce-ae3a-96ef54ed1296.jpeg';

  Future getAllSales() async {
    allSales = [];
    service = [];
    product = [];
    package = [];
    discount = [];
    serviceGroup = {};
    productGroup = {};
    packageGroup = {};
    discountGroup = {};

    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/sales'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      serviceGroup = {};
      productGroup = {};
      packageGroup = {};
      discountGroup = {};

      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> allSale = body;

      allSales = allSale['sales'];

      //called it faster
      List<Future<void>> futures = [];
      for (int i = 0; i < allSales.length; i++) {
        if (allSales[i]['voidDate'] == 0) {
          futures.add(getRecentCompleted(allSales[i]['saleID'], i));
        }
      }
      await Future.wait(futures);

      service.forEach((item) {
        String serviceName = item['sku']['name'];

        if (!serviceGroup.containsKey(serviceName)) {
          serviceGroup[serviceName] = [];
        }
        serviceGroup[serviceName]!.add(item);
      });

      product.forEach((item) {
        String productName = item['sku']['name'];

        if (!productGroup.containsKey(productName)) {
          productGroup[productName] = [];
        }
        productGroup[productName]!.add(item);
      });

      package.forEach((item) {
        String packageName = item['sku']['name'];

        if (!packageGroup.containsKey(packageName)) {
          packageGroup[packageName] = [];
        }
        packageGroup[packageName]!.add(item);
      });

      discount.forEach((item) {
        String discountName = item['sku']['name'];

        if (!discountGroup.containsKey(discountName)) {
          discountGroup[discountName] = [];
        }
        discountGroup[discountName]!.add(item);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  getRecentCompleted(int saleID, int i) async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://order.tunai.io/cashregister/sales/${saleID.toString()}/completed'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> completedss = body;

      completeds = completedss['completeds'];

      completeds.forEach((completed) {
        completed['saleID'] = allSales[i]['saleID'];
        completed['salesDate'] = allSales[i]['salesDate'];
        completed['redeemAmount'] = allSales[i]['redeemAmount'];
      });

      for (int i = 0; i < completeds.length; i++) {
        if (completeds[i]['sku']['typeID'] == 1) {
          service.add(completeds[i]);
        } else if (completeds[i]['sku']['typeID'] == 2) {
          product.add(completeds[i]);
        } else if (completeds[i]['sku']['typeID'] == 3) {
          package.add(completeds[i]);
        } else if (completeds[i]['sku']['typeID'] == 4) {
          discount.add(completeds[i]);
        }
      }
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
              'Items',
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
              future: getAllSales(),
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
                                    labelPadding: EdgeInsets
                                        .zero, // Adjust the padding here
                                    indicator: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    labelColor: Color(0xFF1276ff),
                                    unselectedLabelColor:
                                        Color.fromRGBO(170, 170, 170, 1.0),
                                    tabs: [
                                      Tab(
                                        text: 'Service',
                                      ),
                                      Tab(
                                        text: 'Product',
                                      ),
                                      Tab(
                                        text: 'Package',
                                      ),
                                      Tab(
                                        text: 'Discount',
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                getService(serviceGroup),
                                getProduct(productGroup),
                                getPackage(packageGroup),
                                getDiscount(discountGroup)
                              ],
                            ),
                          )
                        ],
                      ));
                }
              })),
    );
  }

  getService(Map<String, List<dynamic>> serviceGroup) {
    return getDesign(serviceGroup);
  }

  getProduct(Map<String, List<dynamic>> productGroup) {
    return getDesign(productGroup);
  }

  getPackage(Map<String, List<dynamic>> packageGroup) {
    return getDesign(packageGroup);
  }

  getDiscount(Map<String, List<dynamic>> discountGroup) {
    return getDesign(discountGroup);
  }

  getDesign(Map<String, List<dynamic>> mapList) {
    final sortedGroups = List.from(mapList.entries)
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        // Sort the service items by createDate in descending order
        itemsA.sort((a, b) => b['salesDate'].compareTo(a['salesDate']));
        itemsB.sort((a, b) => b['salesDate'].compareTo(a['salesDate']));

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['salesDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['salesDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      });
    String previousDate = '';
    return ListView(
      children: sortedGroups.map((entry) {
        final String itemName = entry.key;
        final List<dynamic> items = entry.value;

        final latestItem = items.first;
        final int latestTimestamp = latestItem['salesDate'];
        final DateTime latestDateTime =
            DateTime.fromMillisecondsSinceEpoch(latestTimestamp * 1000);
        final String latestFormattedDate =
            DateFormat('dd/MM/yyyy').format(latestDateTime);

        String itemPrice = latestItem['priceAmt'].toString();

        Widget dateWidget;

        if (previousDate != latestFormattedDate) {
          dateWidget = Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  latestFormattedDate,
                  style: TextStyle(color: Color(0xFF8a8a8a)),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
          previousDate = latestFormattedDate;
        } else {
          dateWidget = SizedBox(
            height: 10,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateWidget,
              GestureDetector(
                onTap: () {
                  Map<String, List<dynamic>> groupItem = {};
                  Map<String, List<dynamic>> groupStaff = {};

                  for (int i = 0; i < items.length; i++) {
                    List<dynamic> staff = items[i]['staffs'];
                    var itemPrice = items[i]['priceAmt'];
                    var saleID = items[i]['saleID'];
                    var salesDate = items[i]['salesDate'];
                    for (int j = 0; j < staff.length; j++) {
                      String staffName = staff[j]['name'];
                      if (!groupStaff.containsKey(staffName)) {
                        groupStaff[staffName] = [];
                      }
                      staff[j]['itemPrice'] = itemPrice;
                      staff[j]['saleID'] = saleID;
                      staff[j]['salesDate'] = salesDate;
                      groupStaff[staffName]!.add(staff[j]);
                    }
                  }

                  items.forEach((item) {
                    final int unixTimestamp = item['salesDate'];
                    final DateTime dateTime =
                        DateTime.fromMillisecondsSinceEpoch(
                            unixTimestamp * 1000);
                    final String formattedDate =
                        DateFormat('MMMM yyyy').format(dateTime);
                    final String itemSalesDate = formattedDate;

                    if (!groupItem.containsKey(itemSalesDate)) {
                      groupItem[itemSalesDate] = [];
                    }
                    groupItem[itemSalesDate]!.add(item);
                  });

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
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 2.65 / 3,
                          child: RecentDetails(
                              groupItem: groupItem,
                              groupStaff: groupStaff,
                              itemName: latestItem['sku']['name']));
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.network(
                              randomImage,
                              scale: 6,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(itemName),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  formatAmount(double.parse(itemPrice)),
                                  style: TextStyle(color: Color(0xFF878787)),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('x ' + items.length.toString(),
                                style: TextStyle(color: Color(0xFF1276ff))),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: Color(0xFF878787),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
