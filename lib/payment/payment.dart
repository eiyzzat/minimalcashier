import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../api.dart';
import 'dart:convert';

import '../menu.dart';
import '../orderPage.dart';
import '../test/cashier.dart';

class Payment extends StatefulWidget {
  const Payment(
      {required this.calculateSubtotal,
      required this.cartOrderId,
      required this.otems,
      Key? key});
  final double calculateSubtotal;
  final String cartOrderId;
  final List<dynamic> otems;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool _isClicked = false;

  bool isCustomTapped = false;
  bool isAccurateTapped = false;

  bool okTapped = false;
  bool showRefresh = false;
  TextEditingController customAmountController = TextEditingController();
  String paid = '';

  @override
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        centerTitle: true,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black),
        ),
        leading: xIcon(),
        actions: [refreshIcon()],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            children: [
              containerBill(),
              cashText(),
              cashCard(),
              // creditText(),
              // creditContainer(),
              // othersText(),
              // othersContainer()
            ],
          ),
        ],
      ),
      bottomNavigationBar: okTapped ? buildButton() : null,
    );
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

  Widget refreshIcon() {
    return isCustomTapped
        ? TextButton(
            onPressed: () {
              setState(() {
                okTapped = true;
              });
            },
            child: const Text(
              'OK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          )
        : IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.grey[200],
              size: 30,
            ),
            onPressed: () {
              setState(() {
                isCustomTapped = true;
              });
            },
          );
  }

  Widget containerBill() {
    num difference =
        paid.isEmpty ? 0 : double.parse(paid) - widget.calculateSubtotal;
    if (okTapped) {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0, right: 15, left: 15),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${double.parse(paid).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      difference.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 15.0, right: 15, left: 15),
        child: Container(
          width: double.infinity,
          height: 74,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total bill',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.calculateSubtotal.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget buildButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (BuildContext context) {
              return SizedBox(
                  height: 750,
                  child: PaymentReceipt(
                    receiptCalculateSubtotal: widget.calculateSubtotal,
                    cartOrderId: widget.cartOrderId,
                    otems: widget.otems,
                  ));
            },
          );
          print(' page confirm payment OrderId: ${widget.cartOrderId}');
        },
        child: const Text(
          'Confirm Payment',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget cashText() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 16),
          child: Row(
            children: [
              Text(
                'Cash',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget cashCard() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isAccurateTapped = true;
                      });
                    },
                    child: Container(
                      width: 106,
                      height: 47,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Center(
                        child: Text(
                          widget.calculateSubtotal.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    width: 106,
                    height: 47,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Center(
                      child: Text(
                        '1,080.00',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        isCustomTapped = true;
                      });
                    },
                    child: Container(
                      width: 106,
                      height: 47,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Center(
                        child: isCustomTapped
                            ? TextField(
                                controller: customAmountController,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    paid = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              )
                            : const Text(
                                'Custom',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////class baru////////////////////////////////////////////////////////////
class PaymentReceipt extends StatefulWidget {
  const PaymentReceipt(
      {required this.receiptCalculateSubtotal,
      required this.cartOrderId,
      required this.otems,
      Key? key});
  final double receiptCalculateSubtotal;
  final String cartOrderId;
  final List<dynamic> otems;

  @override
  State<PaymentReceipt> createState() => _PaymentReceiptState();
}

class _PaymentReceiptState extends State<PaymentReceipt> {
  bool _isClicked = false;
  TextEditingController remarks = TextEditingController();

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
                cashText(),
              ],
            ),
          ],
        ),
        bottomNavigationBar: buildButton());
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

  Widget cashText() {
    return Padding(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total order amount",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                  style: TextStyle(
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
                  style: TextStyle(fontSize: 14, color: Colors.black),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cashier",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          // showModalBottomSheet<void>(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   shape: const RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.vertical(
                          //           top: Radius.circular(20))),
                          //   builder: (BuildContext context) {
                          //     return SizedBox(
                          //         height: 750,
                          //         child: Cashier(
                          //           cartOrderId: widget.cartOrderId,
                          //         ));
                          //   },
                          // );
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
                              child: Text(
                                "No cashier selected",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order remarks",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                      fontSize: 14, color: Colors.black),
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
    );
  }

  Widget buildButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          double sub = widget.receiptCalculateSubtotal;

          print('Check dekat receipt: $storeServiceAndProduct');

          setState(() {
            completeOrder();
          });
        },
        child: const Text(
          'Done',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> completeOrder() async {
    print('Check dekat receipt: ${widget.receiptCalculateSubtotal}');
    print('Check ORDDER ID: ${widget.cartOrderId}');

    var headers = {'token': token, 'Content-Type': 'application/json'};

    var url = Uri.parse(
        'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/complete');

    var collections = [
      {"paymentTypeID": 1, "amount": widget.receiptCalculateSubtotal},
    ];

    // print('Dalam otems receipt: $otems');

    var items = widget.otems.map((item) {
      var priceAmt = widget.receiptCalculateSubtotal;
      return {
        "skuID": item["skuID"],
        "priceAmt": priceAmt,
      };
    }).toList();

    var data = {
      "collections": collections,
      "items": items,
    };

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
