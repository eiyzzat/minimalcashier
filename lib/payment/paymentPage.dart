import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/payment/payment.dart';
import '../api.dart';
import 'dart:convert';

import '../menu.dart';
import '../orderPage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage(
      {required this.calculateSubtotal,
      required this.cartOrderId,
      required this.otems,
      Key? key});

  final double calculateSubtotal;
  final String cartOrderId;
  final List<dynamic> otems;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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

  @override
  Widget build(BuildContext context) {
    List<int> denominations = [1, 5, 10, 50, 100];
    List<double> possibleValues =
        generatePossibleValues(widget.calculateSubtotal, denominations);

    num difference =
        paid.isEmpty ? 0 : double.parse(paid) - widget.calculateSubtotal;

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
              Padding(
                padding: const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                child: Container(
                  width: double.infinity,
                  height: okTapped ? 80 : 74,
                  decoration: BoxDecoration(
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
                              okTapped ? 'Paid' : 'Total bill',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              okTapped
                                  ? '${double.parse(paid).toStringAsFixed(2)}'
                                  : widget.calculateSubtotal.toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blue,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (okTapped)
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
              ),
              cashText(),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: possibleValues.length +
                          1, // Add 1 for the additional container
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == possibleValues.length) {
                          // Render the additional container
                          return GestureDetector(
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Center(
                                child: isCustomTapped
                                    ? TextField(
                                        controller: customAmountController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
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
                          );
                        } else {
                          // Render the grid item
                          final value = possibleValues[index];

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                // Handle the tap on the grid item here
                                // Access the value of the tapped container (value)
                                print('Tapped value: $value');
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  value.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
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
}
