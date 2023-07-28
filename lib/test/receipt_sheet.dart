import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/test/firstPage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import 'dart:convert';
import '../test/cashier.dart';
import 'login.dart';

class ReceiptSheet extends StatefulWidget {
  ReceiptSheet(
      {required this.finalPrice,
      required this.orderId,
      required this.otems,
      required this.cashAmount,
      required this.creditAmount,
      required this.debitAmount,
      required this.roundvalue,
      required this.payments,
      Key? key});

  double finalPrice;
  String orderId;
  final List<dynamic> otems;
  final List<dynamic> payments;
  double cashAmount;
  double creditAmount;
  double debitAmount;
  double roundvalue;

  @override
  State<ReceiptSheet> createState() => _ReceiptSheetState();
}

class _ReceiptSheetState extends State<ReceiptSheet> {
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
                                              widget.finalPrice
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
                                                cartOrderId: widget.orderId,
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // width: double.infinity,
            height: 50,
            color: Colors.white,
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                lastcompleteOrder();
                // double sub = widget.finalPrice;
        
                // print('Check dekat receipt: $storeServiceAndProduct');
        
                // completeOrderBaru(sub);
                // complete(sub);
              },
              // style: ElevatedButton.styleFrom(
              //   minimumSize: Size(double.infinity, 60), // Adjust the height as needed
              // ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 18),
              ),
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

  Future<void> lastcompleteOrder() async {
    var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

    var url = Uri.parse(
        'https://order.tunai.io/carwashloyalty/order/${widget.orderId}/complete');

    var collections = widget.payments.map((payment) {
      var paymentTypeID = payment['paymentTypeID'];
      var amount = payment['amount'];
      return {"paymentTypeID": paymentTypeID, "amount": amount};
    }).toList();

    // Calculate the total amount paid by the user
    var totalPaidAmount =
        widget.cashAmount + widget.creditAmount + widget.debitAmount;

    // Adjust the payment amounts if the user pays more than the final price
    if (totalPaidAmount > widget.finalPrice) {
      var excessAmount = totalPaidAmount - widget.finalPrice;

      // Deduct the excess amount from the payment collections
      for (var collection in collections) {
        var paymentTypeID = collection['paymentTypeID'];
        var currentAmount = collection['amount'] as double;

        if (paymentTypeID == 1 && currentAmount >= excessAmount) {
          collection['amount'] = currentAmount - excessAmount;
          excessAmount = 0;
          break;
        } else if (paymentTypeID == 1) {
          collection['amount'] = 0;
          excessAmount -= currentAmount;
        }
      }
    }

    var items = <Map<String, dynamic>>[];
    for (var item in widget.otems) {
      int quantity = item['quantity'];
      int outstandAmt = item['outstandings'];
      double discount = item['discount'].toDouble();
      var originalPrice = item['price'];

      // Calculate the discounted amount per item
      double discountedAmountPerItem = discount / quantity;

      for (int i = 0; i < quantity; i++) {
        var priceAmt = originalPrice - discountedAmountPerItem - outstandAmt;

        items.add({
          "groupID": item["otemID"],
          "skuID": item["skuID"],
          "priceAmt": priceAmt,
          "outstandAmt": outstandAmt,
          "discountAmt": i == 0 ? discountedAmountPerItem : 0,
        });
      }
    }

    var data = {
      "roundup": widget.roundvalue,
      "collections": collections,
      "items": items,
    };
    print(data);

    var response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print(utf8.decode(response.bodyBytes));
      var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      var saleID = jsonResponse['sales'][0]['saleID'];
      print('Sale ID: $saleID');
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
                onPressed: () async {
                  await generateReceiptPdf(saleID);
                //   Navigator.pop(context);
                //   Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => FirstPage()),
                // );
                },
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Close"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FirstPage()),
                );
              },
            ),
          ],
        ),
      );
      // print("dah settle payment");
      // print("orderID:${widget.orderId}");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> generateReceiptPdf(saleID) async {
    var headers = {'token': tokenGlobal};
    var request = http.Request('GET',
        Uri.parse('https://order.tunai.io/loyalty/sale/$saleID/receipt/pdf'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // Decode the response JSON
      var responseBody = await response.stream.bytesToString();
      var json = jsonDecode(responseBody);

      // Access the "receipt" URL from the JSON
      var receiptUrl = json['sales'][0]['receipt'];

      _launchURL(receiptUrl);

      // Navigate to the receipt URL or do something with it
      print(receiptUrl);
      // Navigate to receiptUrl using your navigation method, e.g., Navigator.push()
    } else {
      print(response.reasonPhrase);
      
    }
  }

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
}

  
}
// Future<void> completeOrderBaru(double sub) async {
//     // print('Check dekat receipt: ${widget.receiptCalculateSubtotal}');
//     // print('Check ORDDER ID: ${widget.cartOrderId}');

//     var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

//     var url = Uri.parse(
//         'https://order.tunai.io/loyalty/order/${widget.orderId}/complete');

//     var roundup = widget.finalPrice.toStringAsFixed(2);

//     var collections = [
//       {"paymentTypeID": 1, "amount": sub.toStringAsFixed(2)},
//     ];

//     var items = <Map<String, dynamic>>[];
//     widget.otems.forEach((item) {
//       int quantity = item['quantity'];
//       int outstandAmt = item['outstandings'];
//       double discount = item['discount'].toDouble();
//       var priceAmt = item['price'] - discount - outstandAmt;
//       for (int i = 0; i < quantity; i++) {
//         items.add({
//           "groupID": item["otemID"],
//           "skuID": item["skuID"],
//           "priceAmt": priceAmt,
//           "outstandAmt": outstandAmt,
//           "discountAmt": discount
//         });
//       }
//     });

//     var data = {
//       "roundup": roundup,
//       "collections": collections,
//       "items": items,
//     };

//     print("data: $data");

//     var response = await http.post(
//       url,
//       headers: headers,
//       body: json.encode(data),
//     );

//     if (response.statusCode == 200) {
//       print(utf8.decode(response.bodyBytes));
//       print('SUCCESS');

//       showCupertinoDialog(
//         context: context,
//         builder: (BuildContext context) => CupertinoAlertDialog(
//           title: const Text("Order Completed"),
//           content: Column(
//             children: [
//               CupertinoDialogAction(
//                 child: const Text("Print receipt"),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               CupertinoDialogAction(
//                 child: const Text("E-receipt"),
//                 onPressed: () {
//                   // Call your print function here
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             CupertinoDialogAction(
//               child: const Text("Close"),
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => FirstPage()),
//                 );
//               },
//             ),
//           ],
//         ),
//       );
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (context) => FirstPage()),
//       // );
//     } else {
//       print(response.reasonPhrase);
//       print('SILA SAMBUNG STRESS');
//     }
//   }

