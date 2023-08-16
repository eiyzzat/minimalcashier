// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'availableRedeemedExpired.dart';

class Voucher extends StatefulWidget {
  const Voucher({super.key});

  @override
  State<Voucher> createState() => _VoucherState();
}

String serviceNameGlobal = '';
/* Used to display the name for specific service when we click on that service */
// VoucherService

class _VoucherState extends State<Voucher> {
  bool loadAPI = true;
  String randomImage =
      'https://img.tunai.io/image/s3-c522e6fd-c5f2-44ce-ae3a-96ef54ed1296.jpeg';

  Map<String, List<dynamic>> serviceGroups = {};
  Map<String, List<dynamic>> productGroups = {};
  
  List<dynamic> skus = [];
  List<dynamic> voucher = [];
  List<dynamic> newSkusdeleteDate0 = [];
  List<dynamic> newVoucherdeleteDate0 = [];
  List<dynamic> service = [];
  List<dynamic> product = [];

  Future<Object> getMemberVoucher() async {
    serviceGroups = {};
    productGroups = {};
    skus = [];
    voucher = [];
    newSkusdeleteDate0 = [];
    newVoucherdeleteDate0 = [];
    service = [];
    product = [];

    var headers = {'token': token};

    var request = http.Request(
      'GET',
      Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/vouchers'),
    );

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> vouchers = body;

      skus = vouchers['skus'];

      if (skus.isNotEmpty) {
        for (var i = 0; i < skus.length; i++) {
          if (skus[i]['deleteDate'] == 0) {
            newSkusdeleteDate0.add(skus[i]);
          }
        }
      }

      voucher = vouchers['vouchers'];

      if (voucher.isNotEmpty) {
        for (var i = 0; i < voucher.length; i++) {
          if (voucher[i]['deleteDate'] == 0) {
            newVoucherdeleteDate0.add(voucher[i]);
          }
        }
      }

      for (var i = 0; i < newVoucherdeleteDate0.length; i++) {
        var voucherSkuID = newVoucherdeleteDate0[i]['skuID'];

        if (newSkusdeleteDate0.any((skus) => skus['skuID'] == voucherSkuID)) {
          var sku = newSkusdeleteDate0
              .firstWhere((skus) => skus['skuID'] == voucherSkuID);

          if (sku['typeID'] == 1) {
            service.add({
              ...sku,
              'createDate': newVoucherdeleteDate0[i]['createDate'],
              'price': newVoucherdeleteDate0[i]['price'],
              'expiryDate': newVoucherdeleteDate0[i]['expiryDate'],
              'redeemDate': newVoucherdeleteDate0[i]['redeemDate'],
              'expiredDate': newVoucherdeleteDate0[i]['expiredDate'],
              'purchasedsaleID': newVoucherdeleteDate0[i]['purchased']
                  ['saleID'],
              'consumedsaleID': newVoucherdeleteDate0[i]['consumed']['saleID']
            });
          } else if (sku['typeID'] == 2) {
            product.add({
              ...sku,
              'createDate': newVoucherdeleteDate0[i]['createDate'],
              'price': newVoucherdeleteDate0[i]['price'],
              'expiryDate': newVoucherdeleteDate0[i]['expiryDate'],
              'redeemDate': newVoucherdeleteDate0[i]['redeemDate'],
              'expiredDate': newVoucherdeleteDate0[i]['expiredDate'],
              'purchasedsaleID': newVoucherdeleteDate0[i]['purchased']
                  ['saleID'],
              'consumedsaleID': newVoucherdeleteDate0[i]['consumed']['saleID']
            });
          }
        }
      }

      service.forEach((item) {
        String serviceName = item['name'];

        if (!serviceGroups.containsKey(serviceName)) {
          serviceGroups[serviceName] = [];
        }
        serviceGroups[serviceName]!.add(item);
      });

      product.forEach((item) {
        String productName = item['name'];
        if (!productGroups.containsKey(productName)) {
          productGroups[productName] = [];
        }
        productGroups[productName]!.add(item);
      });
    }

    return [];
  }

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
            title: const Text(
              'Voucher',
              style: TextStyle(color: Colors.black),
            ),
            elevation: 1,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(
                left: 10,
              ),
              child: Transform.scale(
                scale: 1.4,
                child: CloseButton(
                  color: const Color(0xFF1276ff),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
          body: FutureBuilder(
              future: loadAPI ? getMemberVoucher() : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container(
                      color: const Color(0xFFf3f2f8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 15, bottom: 10),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                  color: const Color.fromRGBO(235, 235, 235, 1.0),
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TabBar(
                                    indicator: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    labelColor: const Color(0xFF1276ff),
                                    unselectedLabelColor:
                                        const Color.fromRGBO(170, 170, 170, 1.0),
                                    tabs: [
                                      const Tab(
                                        text: 'Service',
                                      ),
                                      const Tab(
                                        text: 'Product',
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                getService(serviceGroups),
                                getProduct(productGroups)
                              ],
                            ),
                          )
                        ],
                      ));
                }
              })),
    );
  }

  getService(Map<String, List<dynamic>> serviceGroups) {
    loadAPI = false;
    final sortedServiceGroups = List.from(serviceGroups.entries)
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        // Sort the service items by createDate in descending order
        itemsA.sort((a, b) => b['createDate'].compareTo(a['createDate']));
        itemsB.sort((a, b) => b['createDate'].compareTo(a['createDate']));

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['createDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['createDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      });
    String previousDate = '';
    return ListView(
      children: sortedServiceGroups.map((entry) {
        final String serviceName = entry.key;
        final List<dynamic> serviceItems = entry.value;
        int totalItems = 0;

        for (var i = 0; i < serviceItems.length; i++) {
          if (serviceItems[i]['redeemDate'] == 0 &&
              serviceItems[i]['expiredDate'] == 0) {
            totalItems++;
          }
        }

        final latestItem = serviceItems.first;
        final int latestTimestamp = latestItem['createDate'];
        final DateTime latestDateTime =
            DateTime.fromMillisecondsSinceEpoch(latestTimestamp * 1000);
        final String latestFormattedDate =
            DateFormat('MM/dd/yyyy').format(latestDateTime);

        String servicePrice = latestItem['price'].toString();

        Widget dateWidget;

        if (previousDate != latestFormattedDate) {
          dateWidget = Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  latestFormattedDate,
                  style: const TextStyle(color: Color(0xFF8a8a8a)),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
          previousDate = latestFormattedDate;
        } else {
          dateWidget = const SizedBox(
            height: 10,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dateWidget,
                  GestureDetector(
                    onTap: () {
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
                          return Container(
                            height:
                                MediaQuery.of(context).size.height * 2.65 / 3,
                            child: AvailableRedemeedExpired(
                                serviceName: serviceName,
                                serviceItems: serviceItems),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
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
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(serviceName),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      formatAmount(double.parse(servicePrice)),
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('x $totalItems',
                                    style: const TextStyle(color: Color(0xFF1276ff))),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
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
            ],
          ),
        );
      }).toList(),
    );
  }

  getProduct(Map<String, List<dynamic>> productGroups) {
    loadAPI = false;
    final sortedProductGroups = productGroups.entries.toList()
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['createDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['createDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      });

    String previousDate = '';

    return ListView(
      children: sortedProductGroups.map((entry) {
        final String productName = entry.key;
        final List<dynamic> productItems = entry.value;
        int totalItems = 0;

        for (var i = 0; i < productItems.length; i++) {
          if (productItems[i]['redeemDate'] == 0 &&
              productItems[i]['expiredDate'] == 0) {
            totalItems++;
          }
        }

        // Sort the service items by createDate in descending order
        productItems.sort((a, b) => b['createDate'].compareTo(a['createDate']));

        final latestItem = productItems.first;
        final int latestTimestamp = latestItem['createDate'];
        final DateTime latestDateTime =
            DateTime.fromMillisecondsSinceEpoch(latestTimestamp * 1000);
        final String latestFormattedDate =
            DateFormat('MM/dd/yyyy').format(latestDateTime);

        String productPrice = latestItem['price'].toString();

        Widget dateWidget;

        if (previousDate != latestFormattedDate) {
          dateWidget = Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  latestFormattedDate,
                  style: const TextStyle(color: Color(0xFF8a8a8a)),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
          previousDate = latestFormattedDate;
        } else {
          dateWidget = const SizedBox(
            height: 10,
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dateWidget, //$hour12Format:$minuteString $suffix
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                    onTap: () {
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
                          return Container(
                            height:
                                MediaQuery.of(context).size.height * 2.65 / 3,
                            child: AvailableRedemeedExpired(
                                serviceName: productName,
                                serviceItems: productItems),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
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
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productName),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      formatAmount(double.parse(productPrice)),
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('x $totalItems',
                                    style: const TextStyle(color: Color(0xFF1276ff))),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
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
            ],
          ),
        );
      }).toList(),
    );
  }
}
