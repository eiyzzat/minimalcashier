import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:minimal/test/receipt_sheet.dart';

import 'login.dart';

class PaymentSheet extends StatefulWidget {
  final double finalPrice;
  final String orderId;
  final List<dynamic> otems;
  final double roundvalue;
  final double roundedPrice;

  const PaymentSheet({
    Key? key,
    required this.finalPrice,
    required this.roundedPrice,
    required this.roundvalue,
    required this.orderId,
    required this.otems,
  }) : super(key: key);

  @override
  PaymentSheetState createState() => PaymentSheetState();
}

class PaymentSheetState extends State<PaymentSheet> {
  final TextEditingController customController = TextEditingController();
  final TextEditingController creditController = TextEditingController();
  final TextEditingController debitController = TextEditingController();
  final TextEditingController otherController = TextEditingController();

  List<dynamic> payments = [];
  List<dynamic> othersPayment = [];

  bool isUnfocused = true;
  bool isTextForm = false;
  double cashAmount = 0.0;
  double creditAmount = 0.0;
  double debitAmount = 0.0;
  double customAmount = 0.0;
  double otherAmount = 0.0;
  double debitMaxAllowedAmount = 0.0;
  double creditMaxAllowedAmount = 0.0;

  bool isCustomContainerSelected = false;
  bool isOptionSelectedCash = false;

  bool isSelectedCard1 = false;
  bool isSelectedCard2 = false;
  bool isOptionSelectedCard = false;
  bool isContainerSelected = false;
  bool isOtherSelected = false;

  FocusNode customNode = FocusNode();
  FocusNode creditNode = FocusNode();
  FocusNode debitNode = FocusNode();
  List<FocusNode> otherNode = [];

  @override
  void initState() {
    super.initState();
    OthersPayment();
  }

  void resetPage() {
    setState(() {
      isCustomContainerSelected = false;
      isOptionSelectedCard = false;
      isOptionSelectedCash = false;
      isSelectedCard1 = false;
      isSelectedCard2 = false;
      isContainerSelected = false;
      otherAmount = 0.0;
      cashAmount = 0.0;
      creditAmount = 0.0;
      debitAmount = 0.0;
      customAmount = 0.0;
      debitMaxAllowedAmount = 0.0;
      creditMaxAllowedAmount = 0.0;
      customController.clear();
      creditController.clear();
      debitController.clear();
      customNode.unfocus();
      creditNode.unfocus();
      debitNode.unfocus();
      payments = [];
    });
  }

  void DoneKeyboard() {
    setState(() {
      customNode.unfocus();
      creditNode.unfocus();
      debitNode.unfocus();
      otherNode.forEach((node) => node.unfocus());
      isUnfocused = true;
    });
  }

  List<double> generatePossibleValues(double price, List<int> denominations) {
    List<double> possibleValues = [];
    possibleValues.add(price);
    for (int denomination in denominations) {
      double nearestPrice =
          (denomination * (price ~/ denomination)).round() / 1.0;
      if (nearestPrice < price) {
        nearestPrice += denomination;
      }
      possibleValues.add(nearestPrice);
    }

    possibleValues = possibleValues.toSet().toList(); // Remove duplicates

    return possibleValues;
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Internet connection is available
    } else {
      return false; // No internet connection
    }
  }

  Future<void> completeOrder() async {
    bool isConnected = await checkConnectivity();
    if (isConnected) {
      var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

      var url = Uri.parse(
          'https://order.tunai.io/carwashloyalty/order/${widget.orderId}/complete');

      var collections = payments.map((payment) {
        var paymentTypeID = payment['paymentTypeID'];
        var amount = payment['amount'];
        return {"paymentTypeID": paymentTypeID, "amount": amount};
      }).toList();

      // Calculate the total amount paid by the user
      var totalPaidAmount = cashAmount + creditAmount + debitAmount;

      // Adjust the payment amounts if the user pays more than the final price
      if (totalPaidAmount > widget.roundedPrice) {
        var excessAmount = totalPaidAmount - widget.roundedPrice;

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
        showModalBottomSheet<dynamic>(
          isScrollControlled: true,
          isDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return GestureDetector(
              onVerticalDragDown: (_) {}, // Disable vertical drag gesture
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.880,
                child: ReceiptSheet(
                  finalPrice: widget.roundedPrice,
                  // saleId: saleID,
                  orderId: widget.orderId,
                  otems: widget.otems,
                  cashAmount: cashAmount,
                  creditAmount: creditAmount,
                  debitAmount: debitAmount,
                  roundvalue: widget.roundvalue, payments: payments,
                ),
              ),
            );
          },
        );
        print("dah settle payment");
        print("orderID:${widget.orderId}");
      } else {
        print(response.reasonPhrase);
      }
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('You Are Offline'),
            content: Text(
              'Turn off Airplane Mode or connect to Wi-Fi/Mobile Data to proceed',
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 8.0),
                child: TextButton(
                  child: Text('OK', style: TextStyle(color: Colors.white)),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> OthersPayment() async {
    var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};
    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/payment'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> json = jsonDecode(responseBody);
      List<dynamic> allPayments = json['payments'];

      List<dynamic> filteredPayments = allPayments.where((payment) {
        final excludedTitles = [
          'store credits',
          'store points',
          'outstandings',
          'credits redeem',
          'package redeem',
          'online'
        ];

        if (payment['paymentTypeID'] < 4 ||
            payment['title'] == null ||
            payment['title'].toString().isEmpty) {
          return false;
        }

        final title = payment['title'].toString().toLowerCase();
        return !excludedTitles.contains(title);
      }).toList();

      setState(() {
        othersPayment = filteredPayments;
        otherNode = List.generate(
          othersPayment.length,
          (index) => FocusNode(),
        );
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('hahahaha ${widget.otems}');
    List<int> denominations = [1, 5, 10, 50, 100];
    List<double> possibleValues =
        generatePossibleValues(widget.roundedPrice, denominations);
    double totalAmount = cashAmount + debitAmount + creditAmount + otherAmount;
    double balance = totalAmount - widget.roundedPrice;
    double cardAmount = creditAmount + debitAmount;
    double maxAllowedAmount = widget.roundedPrice;
    double debitMaxAllowedAmount = widget.roundedPrice;
    double creditMaxAllowedAmount = widget.roundedPrice;
    for (var payment in payments) {
      maxAllowedAmount -= payment['amount'];
      if (payment['paymentTypeID'] != 3) {
        debitMaxAllowedAmount -= payment['amount'];
         print("debitMaxAllowedAmount:$debitMaxAllowedAmount");
           print("creditMaxAllowedAmount:$creditMaxAllowedAmount");
      }
      if (payment['paymentTypeID'] != 2) {
        creditMaxAllowedAmount -= payment['amount'];
        //  print("creditMaxAllowedAmount:$creditMaxAllowedAmount");
      }

      print("maxALLOWED:$maxAllowedAmount");
    } // Calculate the maximum allowed amount
    return Scaffold(
      // backgroundColor: Colors.grey[200],
      backgroundColor: Colors.transparent,
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            size: 40,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          if (isUnfocused)
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 30,
                color: Colors.grey,
              ),
              onPressed: () async {
                resetPage();
              },
            )
          else
            TextButton(
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                DoneKeyboard();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.950,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10),
                        bottom: Radius.circular(10),
                      ),
                    ),
                    height: creditAmount != 0 ||
                            debitAmount != 0 ||
                            cashAmount != 0 ||
                            otherAmount != 0
                        ? 140
                        : 100,
                    width: 400,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                          child: creditAmount != 0 ||
                                  debitAmount != 0 ||
                                  cashAmount != 0 ||
                                  otherAmount != 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 10),
                                    Text(
                                      'Paid by Cash',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Paid by Card',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Paid by Others',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Total Paid',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Change',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Total bill',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 5, 16, 2),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: creditAmount != 0 ||
                                      debitAmount != 0 ||
                                      cashAmount != 0 ||
                                      otherAmount != 0
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                          cashAmount.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          cardAmount.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          otherAmount.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          totalAmount.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Text(
                                          balance.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      widget.roundedPrice.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Container(
                      width: 400,
                      child: const Text(
                        'Cash',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: possibleValues.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == possibleValues.length) {
                        return GestureDetector(
                          onTap: () async {
                            bool isConnected = await checkConnectivity();
                            if (isConnected) {
                              setState(() {
                                isCustomContainerSelected = true;
                                isOptionSelectedCash = true;
                                cashAmount = 0.0;
                                customNode.requestFocus();
                                customAmount = 0;
                                customController.clear();
                              });
                            } else {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('You Are Offline'),
                                    content: Text(
                                      'Turn off Airplane Mode or connect to Wi-Fi/Mobile Data to proceed',
                                    ),
                                    actions: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        child: TextButton(
                                          child: Text('OK',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.blue),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              border: Border.all(
                                color: isCustomContainerSelected
                                    ? Colors.blue
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: isCustomContainerSelected
                                  ? Focus(
                                      onFocusChange: (value) {
                                        setState(() {
                                          isUnfocused = false;
                                        });
                                        if (!value) {
                                          if (customAmount == 0) {
                                            setState(() {
                                              isCustomContainerSelected = false;
                                              payments = [];
                                            });
                                          }
                                        }
                                      },
                                      child: TextField(
                                          controller: customController,
                                          inputFormatters: <TextInputFormatter>[
                                            maxValueTextInputFormatter(50000),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'))
                                          ],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          focusNode: customNode,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          onChanged: (value) async {
                                            double enteredAmount =
                                                double.tryParse(value) ?? 0.0;

                                            dynamic cashPayment =
                                                payments.firstWhere(
                                              (payment) =>
                                                  payment['paymentTypeID'] == 1,
                                              orElse: () => null,
                                            );
                                            if (cashPayment == null) {
                                              payments.add({
                                                'paymentTypeID': 1,
                                                'amount': enteredAmount,
                                              });
                                            } else {
                                              cashPayment['amount'] =
                                                  enteredAmount;
                                            }

                                            setState(() {
                                              customAmount = enteredAmount;
                                              cashAmount =
                                                  isCustomContainerSelected
                                                      ? customAmount
                                                      : 0.0;
                                              totalAmount = customAmount +
                                                  creditAmount +
                                                  debitAmount;
                                              isContainerSelected = true;
                                            });
                                          }),
                                    )
                                  : Text(
                                      'Custom',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      } else {
                        double value = possibleValues[index];
                        bool isSelected = isCustomContainerSelected
                            ? false
                            : value == cashAmount;
                        return GestureDetector(
                          onTap: () async {
                            dynamic cashPayment = payments.firstWhere(
                              (payment) => payment['paymentTypeID'] == 1,
                              orElse: () => null,
                            );
                            if (cashPayment == null) {
                              payments.add({
                                'paymentTypeID': 1,
                                'amount': value,
                              });
                            } else {
                              cashPayment['amount'] = value;
                            }
                            setState(() {
                              isCustomContainerSelected = false;
                              isOptionSelectedCash = true;
                              cashAmount = value;
                              customAmount = 0;
                              customController.clear();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected ? Colors.white : Colors.white,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                value.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Container(
                      width: 400,
                      child: const Text(
                        'Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (creditMaxAllowedAmount > 0) {
                                setState(() {
                                  isUnfocused = false;

                                  isSelectedCard1 = !isSelectedCard1;
                                  isOptionSelectedCard = true;
                                  creditNode.requestFocus();
                                });
                              }
                            },
                            child: Container(
                              height: 75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelectedCard1
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelectedCard1
                                  ? Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                      child: Focus(
                                        onFocusChange: (value) {
                                          if (!value) {
                                            if (creditAmount == 0) {
                                              setState(() {
                                                isSelectedCard1 = false;
                                              });
                                            }
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              "Credit Card",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            TextField(
                                              focusNode: creditNode,
                                              controller: creditController,
                                              keyboardType: const TextInputType
                                                      .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                maxValueTextInputFormatter(
                                                    creditMaxAllowedAmount),
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}'))
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  isUnfocused = false;
                                                  creditAmount =
                                                      double.tryParse(value) ??
                                                          0.0;
                                                  dynamic creditPayment =
                                                      payments.firstWhere(
                                                    (p) =>
                                                        p['paymentTypeID'] == 2,
                                                    orElse: () => null,
                                                  );
                                                  if (creditPayment == null) {
                                                    payments.add({
                                                      'paymentTypeID': 2,
                                                      'amount': creditAmount,
                                                    });
                                                  } else {
                                                    creditPayment['amount'] =
                                                        creditAmount;
                                                  }
                                                  totalAmount = cashAmount +
                                                      creditAmount +
                                                      debitAmount +
                                                      customAmount;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Credit Card',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: creditMaxAllowedAmount > 0
                                              ? Colors.black
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (debitMaxAllowedAmount > 0) {
                                setState(() {
                                  isUnfocused = false;
                                  isSelectedCard2 = !isSelectedCard2;
                                  isOptionSelectedCard = true;
                                  debitNode.requestFocus();
                                });
                              }
                            },
                            child: Container(
                             height: 75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelectedCard2
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: isSelectedCard2
                                  ? Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                      child: Focus(
                                        onFocusChange: (value) {
                                          if (!value) {
                                            if (debitAmount == 0) {
                                              setState(() {
                                                isSelectedCard2 = false;
                                              });
                                            }
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Text(
                                              "Debit Card",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            TextField(
                                              focusNode: debitNode,
                                              controller: debitController,
                                              keyboardType: const TextInputType
                                                      .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                maxValueTextInputFormatter(
                                                    creditMaxAllowedAmount),
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}'))
                                              ],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              onChanged: (value) async {
                                                setState(() {
                                                  debitAmount =
                                                      double.tryParse(value) ??
                                                          0;
                                                  dynamic debitPayment =
                                                      payments.firstWhere(
                                                    (p) =>
                                                        p['paymentTypeID'] == 3,
                                                    orElse: () => null,
                                                  );
                                                  if (debitPayment == null) {
                                                    payments.add({
                                                      'paymentTypeID': 3,
                                                      'amount': debitAmount,
                                                    });
                                                  } else {
                                                    debitPayment['amount'] =
                                                        debitAmount;
                                                  }
                                                  totalAmount = cashAmount +
                                                      creditAmount +
                                                      debitAmount +
                                                      customAmount;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Debit Card',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: creditMaxAllowedAmount > 0
                                              ? Colors.black
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Container(
                      width: 400,
                      child: const Text(
                        'Others',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: othersPayment.length,
                    itemBuilder: (BuildContext context, int index) {
                      var payment = othersPayment[index];
                      String title = payment['title'];
                      int paymentTypeID = payment['paymentTypeID'];

                      // Check if the payment is selected
                      bool isSelected = payments.any((payment) =>
                          payment['paymentTypeID'] == paymentTypeID);

                      // Get the index of the selected payment (if exists)
                      int selectedPaymentIndex = payments.indexWhere(
                          (payment) =>
                              payment['paymentTypeID'] == paymentTypeID);

                      // Get the amount for the selected payment (if exists)
                      double selectedAmount = selectedPaymentIndex != -1
                          ? payments[selectedPaymentIndex]['amount']
                          : 0.0;

                      double otherMaxValue = widget.roundedPrice;

                      for (var payment in payments) {
                        if (paymentTypeID != payment['paymentTypeID']) {
                          otherMaxValue -= payment['amount'];
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (otherMaxValue > 0) {
                            otherNode[index].requestFocus();
                            isUnfocused = false;
                            if (selectedPaymentIndex != -1 &&
                                selectedAmount == 0) {
                              // If the selected payment exists and its amount is 0, remove it
                              payments.removeAt(selectedPaymentIndex);
                              setState(() {});
                            } else {
                              // Create a new payment map with the paymentTypeID and amount
                              Map<String, dynamic> newPayment = {
                                'paymentTypeID': paymentTypeID,
                                'amount': 0.0, // Set the initial amount to 0
                              };
                              // Remove any existing payment with amount 0
                              payments.removeWhere(
                                  (payment) => payment['amount'] == 0.0);
                              payments.add(newPayment);
                              setState(() {});
                            }
                            setState(() {});
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: selectedPaymentIndex != -1
                              ? Focus(
                                  onFocusChange: (hasFocus) {
                                    if (!hasFocus) {
                                      setState(() {
                                        payments.removeWhere((payment) =>
                                            payment['paymentTypeID'] ==
                                                paymentTypeID &&
                                            payment['amount'] == 0.0);
                                      });
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(17),
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          focusNode: otherNode[index],
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          onChanged: (value) {
                                            double amount =
                                                double.tryParse(value) ?? 0.0;
                                            payments[selectedPaymentIndex]
                                                ['amount'] = amount;
                                            setState(() {});
                                            payments.removeWhere((payment) =>
                                                payment['amount'] == 0.0);
                                            double allAmount = 0.0;
                                            for (var payment in payments) {
                                              int paymentTypeID =
                                                  payment["paymentTypeID"];
                                              double amount = payment["amount"];

                                              if (paymentTypeID != 1 &&
                                                  paymentTypeID != 2 &&
                                                  paymentTypeID != 3) {
                                                allAmount += amount;
                                              }
                                            }
                                            setState(() {
                                              otherAmount = allAmount;
                                            });
                                            print('total : $otherAmount');
                                          },
                                          inputFormatters: <TextInputFormatter>[
                                            // maxValueTextInputFormatter(
                                            //     otherMaxValue),
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}'))
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(8),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 8, 0, 20),
                                        child: Text(
                                          title.split(' ').map((word) {
                                            if (word.isNotEmpty) {
                                              return word[0].toUpperCase() +
                                                  word.substring(1);
                                            } else {
                                              return '';
                                            }
                                          }).join(' '),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: otherMaxValue > 0
                                                ? Colors.black
                                                : Colors.grey,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    title.split(' ').map((word) {
                                      if (word.isNotEmpty) {
                                        return word[0].toUpperCase() +
                                            word.substring(1);
                                      } else {
                                        return '';
                                      }
                                    }).join(' '),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: otherMaxValue > 0
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    maxLines: 2,
                                  ),
                                ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: totalAmount >= widget.roundedPrice
            ? () async {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: 750,
                      child: ReceiptSheet(
                        finalPrice: widget.roundedPrice,
                        orderId: widget.orderId,
                        otems: widget.otems,
                        cashAmount: cashAmount,
                        creditAmount: creditAmount,
                        debitAmount: debitAmount,
                        roundvalue: widget.roundvalue,
                        payments: payments,
                      ),
                    );
                  },
                );
              }
            : null,
        child: Padding(
          // padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0),
          padding: const EdgeInsets.only(bottom:20,left: 10,right: 10),
          child: Container(
            // width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: totalAmount >= widget.roundedPrice
                  ? Colors.blue
                  : Colors.grey[200],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8),
                bottom: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                'Confirm Payment',
                style: TextStyle(
                  color: totalAmount >= widget.roundedPrice
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  TextInputFormatter maxValueTextInputFormatter(double maxValue) {
  return TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isNotEmpty) {
        final input = double.tryParse(newValue.text) ?? 0.0;
        if (input > maxValue) {
          // If the input value is greater than maxValue, reset it to maxValue
          return TextEditingValue(
            text: maxValue.toStringAsFixed(2),
            selection: TextSelection.collapsed(
                offset: maxValue.toStringAsFixed(2).length),
          );
        }
      }
      return newValue;
    },
  );
}
  
}
