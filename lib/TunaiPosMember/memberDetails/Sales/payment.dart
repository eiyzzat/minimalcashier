// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../../textFormating.dart';
import 'paymentMethod.dart';

class Payment extends StatefulWidget {
  final double totalPayment;
  final List<dynamic> collections;
  final List<dynamic> paymentType;
  final VoidCallback updateData;
  final int saleID;
  const Payment(
      {super.key,
      required this.totalPayment,
      required this.collections,
      required this.paymentType,
      required this.saleID,
      required this.updateData});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  List<TextEditingController> paymentTypeAmount = [];

  List<dynamic> collections = [];

  bool edit = false;

  double totalCollection = 0;
  double remainingTotal = 0;

  String buttonText = 'Edit';

  @override
  void initState() {
    collections = widget.collections;
    totalCollection = 0;
    for (int i = 0; i < collections.length; i++) {
      totalCollection += collections[i]['amount'];
    }
    super.initState();
  }

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
            'Payment',
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
                  widget.updateData();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: TextButton(
                  onPressed: totalCollection == widget.totalPayment
                      ? () {
                          setState(() {
                            edit = !edit;
                            buttonText = edit ? 'Save' : 'Edit';
                          });
                          if (totalCollection == widget.totalPayment) {
                            updateAPIPayment();
                          }
                        }
                      : null, // Disable the button if amountTrue is false
                  child: Text(buttonText,
                      style: TextStyle(
                          fontSize: 20,
                          color: !edit
                              ? Color(0xFF1175fc)
                              : totalCollection == widget.totalPayment
                                  ? Color(0xFF1175fc)
                                  : Color(0xFFc6c6c6)))),
            )
          ]),
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
                  padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Text(
                          'Order total',
                          style: TextStyle(color: Color(0xFF333333)),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 10, right: 10, bottom: 5),
                        child: Text(
                          formatDoubleText(widget.totalPayment).toString(),
                          style: TextStyle(
                            fontSize: 36,
                            color: Color(0xFF1276ff),
                          ),
                        ),
                      ),
                      Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 30),
                          child: Text(
                            'Difference :' +
                                formatDoubleText(remainingTotal).toString(),
                            style: TextStyle(color: Color(0xFF878787)),
                          )),
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: collections.length,
                          itemBuilder: (context, index) {
                            String paymentTitle = '';
                            double remainingAmount = widget.totalPayment;

                            for (int i = 0;
                                i < widget.paymentType.length;
                                i++) {
                              if (widget.paymentType[i]['paymentTypeID'] ==
                                  collections[index]['payID']) {
                                paymentTitle = capitalizeFirstLetter(
                                    widget.paymentType[i]['title']);
                              }
                            }
                            if (index >= paymentTypeAmount.length) {
                              paymentTypeAmount.add(TextEditingController(
                                  text: formatDoubleText(collections[index]
                                          ['amount']
                                      .toDouble())));
                            }

                            for (var payment in collections) {
                              remainingAmount -= payment['amount'];
                            }

                            int emptyControllers = paymentTypeAmount
                                .where((controller) => controller.text.isEmpty)
                                .length;

                            double remainingAmountDivide =
                                remainingAmount / emptyControllers;

                            const double epsilon = 1e-10;
                            if (remainingAmount.abs() < epsilon) {
                              remainingAmount = 0.0;
                            }

                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Payment method #${collections[index]['payID']}',
                                              style: TextStyle(
                                                  color: Color(0xFF878787)),
                                            ),
                                            if (edit)
                                              GestureDetector(
                                                onTap: () {
                                                  // showModalBottomSheet<
                                                  //     dynamic>(
                                                  //   enableDrag: false,
                                                  //   barrierColor:
                                                  //       Colors.transparent,
                                                  //   isScrollControlled: true,
                                                  //   context: context,
                                                  //   shape:
                                                  //       RoundedRectangleBorder(
                                                  //           borderRadius:
                                                  //               BorderRadius
                                                  //                   .vertical(
                                                  //     top:
                                                  //         Radius.circular(20),
                                                  //   )),
                                                  //   builder: (BuildContext
                                                  //       context) {
                                                  //     return Container(
                                                  //         height: MediaQuery.of(
                                                  //                     context)
                                                  //                 .size
                                                  //                 .height *
                                                  //             2.65 /
                                                  //             3,
                                                  //         child: PaymentMethod(
                                                  //             paymentType: widget
                                                  //                 .paymentType,
                                                  //             collections:
                                                  //                 collections));
                                                  //   },
                                                  // );
                                                  deletePaymentMethod(index);
                                                },
                                                child: Image.asset(
                                                  'icons/TrashRed.png',
                                                  scale: 70,
                                                ),
                                              )
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(paymentTitle),
                                            !edit
                                                ? Text(
                                                    '${formatDoubleText(collections[index]['amount'].toDouble())}')
                                                : Center(
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints
                                                              .tightFor(
                                                                  width: 70),
                                                      child: TextFormField(
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              10), // Limit input to 5 characters
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'^\d+\.?\d{0,2}')),
                                                        ],
                                                        textAlign:
                                                            TextAlign.center,
                                                        controller:
                                                            paymentTypeAmount[
                                                                index],
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              formatDoubleText(
                                                                      remainingAmountDivide)
                                                                  .toString(),
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.all(7),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide: BorderSide(
                                                                width: 0.5,
                                                                color: Color(
                                                                    0xFFF3F5F9)),
                                                          ),
                                                        ),
                                                        onChanged: (newValue) {
                                                          String numericPart =
                                                              newValue.replaceAll(
                                                                  RegExp(
                                                                      r'[^\d.]'),
                                                                  '');
                                                          double amount =
                                                              double.tryParse(
                                                                      numericPart) ??
                                                                  0.0;
                                                          updatePayment(
                                                              index, amount);
                                                        },
                                                        onTap: () {
                                                          setState(() {
                                                            edit = true;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                )
                              ],
                            );
                          }),
                      const SizedBox(
                        height: 10,
                      ),
                      if (edit)
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
                                // Filter out payment types that already exist in collections
                                final remainingPaymentTypes =
                                    widget.paymentType.where((paymentType) {
                                  final paymentTypeID =
                                      paymentType['paymentTypeID'];
                                  return !collections.any((collection) =>
                                      collection['payID'] == paymentTypeID);
                                }).toList();
                                return Container(
                                    height: MediaQuery.of(context).size.height *
                                        2.65 /
                                        3,
                                    child: PaymentMethod(
                                      paymentType: remainingPaymentTypes,
                                      collections: collections,
                                    ));
                              },
                            ).then((updateCollections) {
                              if (updateCollections != null) {
                                setState(() {
                                  collections = updateCollections;
                                  paymentTypeAmount.clear();
                                  remainingTotal = widget.totalPayment;
                                  totalCollection = 0;
                                });
                              }
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Colors.white,
                            ),
                            child:  Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Color(0xFF1276ff),
                                    ),
                                    Text(
                                      ' Add payment method',
                                      style:
                                          TextStyle(color: Color(0xFF1276ff)),
                                    )
                                  ],
                                )),
                          ),
                        )
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

  void deletePaymentMethod(int index) {
    double amount = double.tryParse(paymentTypeAmount[index].text) ?? 0.0;

    setState(() {
      // Remove the payment method from collections
      collections.removeAt(index);
      // Remove the corresponding TextEditingController
      paymentTypeAmount.removeAt(index);
      // Update totalCollection
      totalCollection -= amount;
      // Recalculate remainingTotal
      remainingTotal = widget.totalPayment - totalCollection;
    });
  }

  void updatePayment(int index, double amount) {
    setState(() {
      collections[index]['amount'] = amount;
      totalCollection = 0;
      for (int i = 0; i < collections.length; i++) {
        totalCollection += collections[i]['amount'];
      }
      remainingTotal = widget.totalPayment - totalCollection;
    });
  }

  updateAPIPayment() async {
    var headers = {'token': token, 'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/cashregister/sale/${widget.saleID.toString()}/collections'));
    request.body = json.encode({"payments": collections});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    } else {
      print(response.reasonPhrase);
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
