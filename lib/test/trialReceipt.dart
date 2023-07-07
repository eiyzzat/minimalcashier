import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api.dart';
import 'dart:convert';

import '../menu.dart';
import '../orderPage.dart';
import '../test/cashier.dart';

class TrialPaymentReceipt extends StatefulWidget {
  const TrialPaymentReceipt(
      {required this.receiptCalculateSubtotal,
      required this.cartOrderId,
      required this.otems,
      Key? key});
  final double receiptCalculateSubtotal;
  final String cartOrderId;
  final List<dynamic> otems;

  @override
  State<TrialPaymentReceipt> createState() => _TrialPaymentReceiptState();
}

class _TrialPaymentReceiptState extends State<TrialPaymentReceipt> {
  bool _isClicked = false;
  TextEditingController remarks = TextEditingController();

  Map<String, dynamic>? inCashier;

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
            'Receipt details',
            style: TextStyle(color: Colors.black),
          ),
          leading: xIcon(),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[200],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total order amount",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 29,
                                            child: Text(
                                              widget.receiptCalculateSubtotal
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Additional Info",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Cashier",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      inCashier = await showModalBottomSheet<
                                          Map<String, dynamic>>(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20))),
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                              height: 750,
                                              child: Cashier(
                                                cartOrderId: widget.cartOrderId,
                                                inCashier: inCashier,
                                              ));
                                        },
                                      );

                                      if (inCashier != null) {
                                        // Process the returned data here
                                        print('Incashier: $inCashier');
                                        // Use the following code to display the cashier name
                                        Text(
                                          inCashier!['selectedStaff'][0]
                                              ['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        );
                                      } else {
                                        // Display the text "No cashier selected"
                                        Text(
                                          "No cashier selected",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        );
                                      }
                                      setState(() {
                                        // Update the value of inCashier
                                      });
                                    },
                                    child: Image.asset(
                                      "lib/assets/Plus.png",
                                      height: 14,
                                      width: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 29,
                                          child: inCashier != null
                                              ? Text(
                                                  inCashier!['selectedStaff'][0]
                                                      ['name'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                )
                                              : Text(
                                                  "No cashier selected",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      //order remarks
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Order remarks",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 29,
                                            child: Text(
                                              "Type here",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              double sub = widget.receiptCalculateSubtotal;

              print('Check dekat receipt: $storeServiceAndProduct');

              completeOrder(sub);
              // complete(sub);
            },
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ));
  }

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

  Future<void> completeOrder(double sub) async {
    print('Check dekat receipt: ${widget.receiptCalculateSubtotal}');
    print('Check ORDDER ID: ${widget.cartOrderId}');

    var headers = {'token': token, 'Content-Type': 'application/json'};

    var url = Uri.parse(
        'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/complete');

    var collections = [
      {"paymentTypeID": 1, "amount": sub.toStringAsFixed(2)},
    ];

    var items = widget.otems.map((item) {
      return {
        "skuID": item['skuID'],
        "priceAmt": item['price'] - item['discount'],
      };
    }).toList();

    var data = {
      "collections": collections,
      "items": items,
    };

    print("data: $data");

    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print(utf8.decode(response.bodyBytes));
      print('SUCCESS');

      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text("Order Completed"),
          content: Column(
            children: [
              CupertinoDialogAction(
                child: const Text("Print receipt"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text("E-receipt"),
                onPressed: () {
                  // Call your print function here
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Close"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => orderPage()),
                );
              },
            ),
          ],
        ),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => orderPage()),
      // );
    } else {
      print(response.reasonPhrase);
      print('SILA SAMBUNG STRESS');
    }
  }
}
