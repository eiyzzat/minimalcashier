// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class PaymentMethod extends StatefulWidget {
  final List<dynamic> paymentType;
  final List<dynamic> collections;
  const PaymentMethod(
      {super.key, required this.paymentType, required this.collections});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  List<dynamic> selectedPaymentIndices = [];
  double amount = 0;
  bool addPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Payment method',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
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
        actions: addPayment
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      updateCollectionsWithSelectedPayments();
                      Navigator.pop(context, widget.collections);
                      addPayment =
                          false; // Set doneUpdate to false to hide the button
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1175fc),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFf3f2f8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                        itemCount: widget.paymentType.length,
                        itemBuilder: (context, index) {
                          if (widget.paymentType[index]['title'].isEmpty) {
                            return SizedBox
                                .shrink(); // Skip rendering empty titles
                          }
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                final paymentTypeID =
                                    widget.paymentType[index]['paymentTypeID'];
                                final existingPaymentIndex =
                                    selectedPaymentIndices.indexWhere((item) =>
                                        item['paymentTypeID'] == paymentTypeID);

                                if (existingPaymentIndex != -1) {
                                  selectedPaymentIndices
                                      .removeAt(existingPaymentIndex);
                                } else {
                                  selectedPaymentIndices.add({
                                    'paymentTypeID': paymentTypeID,
                                    'amount': amount,
                                  });
                                }
                                if (selectedPaymentIndices.isNotEmpty) {
                                  addPayment = true;
                                } else {
                                  addPayment = false;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                                border: Border.all(
                                  color: selectedPaymentIndices.any((item) =>
                                          item['paymentTypeID'] ==
                                          widget.paymentType[index]
                                              ['paymentTypeID'])
                                      ? Color(0xFF1276FF)
                                      : Colors.white,
                                ),
                              ),
                              width: double.infinity,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    capitalizeFirstLetter(
                                        widget.paymentType[index]['title']),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void updateCollectionsWithSelectedPayments() {
    for (var payment in selectedPaymentIndices) {
      var paymentTypeID = payment['paymentTypeID'];
      var existingPaymentIndex = widget.collections
          .indexWhere((item) => item['payID'] == paymentTypeID);

      if (existingPaymentIndex != -1) {
        // Update the amount if the payment type already exists
        widget.collections[existingPaymentIndex]['amount'] = payment['amount'];
      } else {
        // Add the payment type if it doesn't exist
        widget.collections.add({
          'payID': paymentTypeID,
          'amount': payment['amount'],
        });
      }
    }

    // Set amount to 0.0 for all elements in widget.collections
    for (var collection in widget.collections) {
      collection['amount'] = 0.0;
    }
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    List<String> words = input.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }
    return words.join(' ');
  }
}
