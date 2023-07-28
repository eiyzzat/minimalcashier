import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/payment/payment.dart';
import 'package:minimal/test/trialReceipt.dart';
import 'dart:convert';

class TrialPaymentPage extends StatefulWidget {
  TrialPaymentPage(
      {required this.calculateSubtotal,
      required this.cartOrderId,
      required this.otems,
      required this.afterroundedNumber,
      Key? key});

  final double calculateSubtotal;
  final String cartOrderId;
  final List<dynamic> otems;
  double afterroundedNumber;

  @override
  State<TrialPaymentPage> createState() => _TrialPaymentPageState();
}

class _TrialPaymentPageState extends State<TrialPaymentPage> {
  Set<int> _selectedIndices = Set<int>();

  bool _isClicked = false;

  bool isCustomTapped = false;
  bool isAccurateTapped = false;
  bool isContainerTapped = false;

  bool isDebitTapped = false;
  bool isCreditTapped = false;

  TextEditingController debitController = TextEditingController();
  TextEditingController creditController = TextEditingController();

  bool okTapped = false;
  bool showRefresh = false;
  TextEditingController customAmountController = TextEditingController();
  double paid = 0;
  double creditpaid = 0;
  double debittpaid = 0;

  int paymentTypeID = 0;

  // double totalPaid = paid + creditpaid;

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

    // num difference =
    //     paid.isEmpty ? 0 : double.parse(paid) +  double.parse(creditpaid) - widget.calculateSubtotal;

    double topay = paid + creditpaid + debittpaid;
    double difference = topay - widget.calculateSubtotal;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          centerTitle: true,
          title: const Text(
            'Payment',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Image.asset(
              "lib/assets/Artboard 40.png",
              height: 30,
              width: 20,
            ),
            onPressed: () => Navigator.pop(context),
            iconSize: 24,
          ),
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
                  padding:
                      const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                  child: Container(
                    width: double.infinity,
                    height: okTapped ? 80 : 74,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                okTapped
                                    ? topay.toStringAsFixed(2)
                                    : widget.calculateSubtotal
                                        .toStringAsFixed(2),
                                style: const TextStyle(
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
                                  isCreditTapped || isDebitTapped
                                      ? 'Total remaining'
                                      : 'Change',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  difference.toStringAsFixed(2),
                                  style: const TextStyle(
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
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Cash',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: possibleValues.length +
                            1, // Add 1 for the additional container
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
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
                                  isContainerTapped = false;

                                  paymentTypeID = 1; 
                                });
                                 print("paymenttype:$paymentTypeID");
                              },
                              child: Container(
                                width: 106,
                                height: 47,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Center(
                                  child: isCustomTapped
                                      ? TextField(
                                          controller: customAmountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.isEmpty) {
                                                value = '0';
                                              }
                                              paid = double.parse(value);
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

                                  paymentTypeID = 1;
                                  // Handle the tap on the grid item here
                                  // Access the value of the tapped container (value)
                                  isContainerTapped = true;
                                  _selectedIndices.clear();
                                  if (_selectedIndices.contains(index)) {
                                    _selectedIndices.remove(
                                        index); // Remove the index if already selected
                                  } else {
                                    _selectedIndices.add(
                                        index); // Add the index if not already selected
                                  }
                                  paid = value;

                                  print('Tapped value: $value');
                                  print("paymenttype:$paymentTypeID");
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedIndices.contains(index)
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
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
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Credit',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  isDebitTapped = false;
                                  isCreditTapped = true;
                                  paymentTypeID = 2; 
                                });
                                 print("paymenttype:$paymentTypeID");
                              },
                              child: Container(
                                height: 47,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCreditTapped
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isCreditTapped
                                      ? TextField(
                                          controller: creditController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              try {
                                                creditpaid =
                                                    double.parse(value);
                                              } catch (e) {
                                                creditpaid =
                                                    0.0; // Set a default value when the parsing fails
                                              }
                                            });
                                          },
                                        )
                                      : const Text(
                                          'Credit Card',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setState(() {
                                  isDebitTapped = true;
                                  isCreditTapped = false;
                                  paymentTypeID = 3; 
                                });
                                print("paymenttype:$paymentTypeID");
                              },
                              child: Container(
                                height: 47,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDebitTapped
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isDebitTapped
                                      ? TextField(
                                          controller: debitController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              try {
                                                debittpaid =
                                                    double.parse(value);
                                              } catch (e) {
                                                debittpaid =
                                                    0.0; // Set a default value when the parsing fails
                                              }
                                            });
                                          },
                                        )
                                      : const Text(
                                          'Debit Card',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: okTapped ? buildButton() : null,
      ),
    );
  }

  Widget refreshIcon() {
    bool anyContainerTapped =
        isContainerTapped || isCreditTapped || isDebitTapped || isCustomTapped;
    return anyContainerTapped
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
                  child: TrialPaymentReceipt(
                    receiptCalculateSubtotal: widget.calculateSubtotal,
                    cartOrderId: widget.cartOrderId,
                    otems: widget.otems,
                    afterroundedNumber: widget.afterroundedNumber,
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
}
