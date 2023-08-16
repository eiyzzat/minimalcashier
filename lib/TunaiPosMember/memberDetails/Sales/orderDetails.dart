// ignore_for_file: prefer_is_empty, sized_box_for_whitespace, use_build_context_synchronously, prefer_const_constructors, avoid_print, avoid_single_cascade_in_expression_statements

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../../../textFormating.dart';
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import 'addRemarks.dart';
import 'cashier.dart';
import 'date.dart';
import 'itemDetails.dart';
import 'payment.dart';
import 'paymentBreakdown.dart';

class OrderDetails extends StatefulWidget {
  final double amount;
  final int saleID;
  const OrderDetails({super.key, required this.amount, required this.saleID});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  List<dynamic> sales = [];
  List<dynamic> salesCompleted = [];
  List<dynamic> allStaff = [];
  List<dynamic> collections = [];
  List<dynamic> paymentType = [];
  List<dynamic> salesCompletedService = [];
  List<dynamic> salesCompletedProduct = [];
  List<dynamic> salesCompletedPackage = [];
  List<dynamic> salesCompletedDiscount = [];

  late TextEditingController inputRemark = TextEditingController(text: remarks);

  bool showDetails = false;
  bool loadPage = true;
  bool menuVisible = false;

  int saleID = 0;
  int salesDate = 0;
  int voidDate = 0;
  int staffID = 0;

  double saleAmount = 0;
  double discountAmount = 0;
  double outstandingsAmount = 0;
  double redeemAmount = 0;
  double totalSales = 0;
  double redeemCredit = 0;
  double redeemVoucher = 0;
  double totalPayment = 0;
  double totalEffort = 0;
  double totalHof = 0;

  String cashierName = '';
  String remarks = '';

  Future getSaleInfo() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://order.tunai.io/cashregister/sale/${widget.saleID}/detail'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> sale = body;
      sales = sale['sales'];

      collections = [];

      if (sales.isNotEmpty) {
        for (var i = 0; i < sales.length; i++) {
          voidDate = sales[i]['voidDate'];
          salesDate = sales[i]['salesDate'];
          saleAmount = sales[i]['saleAmount'].toDouble();
          discountAmount = sales[i]['discountAmount'].toDouble();
          outstandingsAmount = sales[i]['outstandingsAmount'].toDouble();
          redeemAmount = sales[i]['redeemAmount'].toDouble();
          cashierName = sales[i]['cashier']['name'];
          staffID = sales[i]['cashier']['staffID'];
          saleID = sales[i]['saleID'];
          remarks = sales[i]['remarks'];
          collections = sales[i]['collections'];

          salesCompletedService.clear();
          salesCompletedProduct.clear();
          salesCompletedPackage.clear();
          salesCompletedDiscount.clear();
          allStaff.clear();
          totalEffort = 0;
          totalHof = 0;

          List<dynamic> completeds = sales[i]['completeds'];
          if (completeds.isNotEmpty) {
            for (var i = 0; i < completeds.length; i++) {
              var completed = completeds[i];
              var sku = completed['sku'];

              if (sku['typeID'] == 1) {
                salesCompletedService.add(completed);
              } else if (sku['typeID'] == 2) {
                salesCompletedProduct.add(completed);
              } else if (sku['typeID'] == 3) {
                salesCompletedPackage.add(completed);
              } else if (sku['typeID'] == 4) {
                salesCompletedDiscount.add(completed);
              }
              allStaff.add(completeds[i]['staffs']);
            }
          }
        }
      }

      for (dynamic staffList in allStaff) {
        if (staffList is List<dynamic>) {
          for (int i = 0; i < staffList.length; i++) {
            double effort =
                double.tryParse(staffList[i]['effort'].toString()) ?? 0;
            double hof = double.tryParse(staffList[i]['hof'].toString()) ?? 0;
            totalEffort += effort;
            totalHof += hof;
          }
        }
      }

      totalSales = saleAmount + discountAmount;

      if (widget.amount > 0) {
        redeemCredit = 0;
      } else {
        redeemCredit = widget.amount;
        if (redeemCredit < 0) {
          String amountString = redeemCredit.toString();
          String cleanedAmountString = amountString.replaceAll('-', '');
          redeemCredit = double.parse(cleanedAmountString);
        }
      }
      if (redeemCredit > 0) {
        redeemVoucher = redeemAmount - redeemCredit;
        String amountString = redeemVoucher.toString();
        String cleanedAmountString = amountString.replaceAll('-', '');
        redeemVoucher = double.parse(cleanedAmountString);
      }

      totalPayment = saleAmount - outstandingsAmount - redeemAmount;

      await payment();
    } else {
      print(response.reasonPhrase);
    }
  }

  Future payment() async {
    var headers = {'token': token};
    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/payment'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      paymentType = [];
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> payments = body;
      paymentType = payments['payments'];
    } else {
      print(response.reasonPhrase);
    }
  }

  void updateData() {
    setState(() {
      loadPage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 2.65 / 3,
        child: FutureBuilder(
            future: loadPage ? getSaleInfo() : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                int timestamp = salesDate;
                DateTime dateTime =
                    DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(dateTime);
                int hour = dateTime.hour;
                int minute = dateTime.minute;
                String suffix = (hour >= 12) ? 'PM' : 'AM';
                hour = (hour > 12) ? hour - 12 : hour;
                String hourString = hour.toString().padLeft(2, '0');
                String minuteString = minute.toString().padLeft(2, '0');

                int timestamp1 = voidDate;
                DateTime dateTime1 =
                    DateTime.fromMillisecondsSinceEpoch(timestamp1 * 1000);
                String formattedDate1 =
                    DateFormat('dd/MM/yyyy').format(dateTime);
                int hour1 = dateTime1.hour;
                int minute1 = dateTime1.minute;
                String suffix1 = (hour1 >= 12) ? 'PM' : 'AM';
                hour1 = (hour1 > 12) ? hour1 - 12 : hour1;
                String hourString1 = hour1.toString().padLeft(2, '0');
                String minuteString1 = minute1.toString().padLeft(2, '0');

                inputRemark.text = remarks;

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    )),
                    centerTitle: true,
                    title: const Text(
                      'Order details',
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
                              })),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: voidDate == 0
                            ? GestureDetector(
                                onTap: () {
                                  voidSale();
                                },
                                child: Image.asset(
                                  'icons/TrashRed.png',
                                  scale: 40,
                                ),
                              )
                            : Image.asset(
                                'icons/TrashGrey.png',
                                scale: 40,
                              ),
                      )
                    ],
                  ),
                  body: Container(
                      width: double.infinity,
                      color: const Color(0xFFf3f2f8),
                      child: LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 15, left: 10, right: 10, bottom: 30),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order #${widget.saleID}',
                                              style: const TextStyle(
                                                  color: Color(0xFF878787)),
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (voidDate == 0) {
                                                  showModalBottomSheet<dynamic>(
                                                    enableDrag: false,
                                                    barrierColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    //backgroundColor: Colors.transparent,
                                                    context: context,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .vertical(
                                                      top: Radius.circular(20),
                                                    )),
                                                    builder:
                                                        (BuildContext context) {
                                                      return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            2.65 /
                                                            3,
                                                        child: CreditPaymentBreakdown(
                                                            saleAmount:
                                                                saleAmount,
                                                            discountAmount:
                                                                discountAmount,
                                                            outstandingsAmount:
                                                                outstandingsAmount,
                                                            redeemAmount:
                                                                redeemAmount,
                                                            totalSales:
                                                                totalSales,
                                                            redeemCredit:
                                                                redeemCredit,
                                                            redeemVoucher:
                                                                redeemVoucher,
                                                            totalPayment:
                                                                totalPayment,
                                                            saleID:
                                                                widget.saleID,
                                                            totalEffort:
                                                                totalEffort,
                                                            totalHof: totalHof),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  getVoidAlert();
                                                }
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Amount',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF878787)),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        formatAmount(
                                                            totalSales),
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF1276ff)),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('Details'),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (voidDate == 0) {
                                                    showModalBottomSheet<
                                                        dynamic>(
                                                      enableDrag: false,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                        top:
                                                            Radius.circular(20),
                                                      )),
                                                      builder: (BuildContext
                                                          context) {
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2.65 /
                                                              3,
                                                          child: CreditDate(
                                                            date: dateTime,
                                                            saleID:
                                                                widget.saleID,
                                                            updateData:
                                                                updateData,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    getVoidAlert();
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  color: Colors.white,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Transaction date',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF878787)),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        '$hourString:$minuteString $suffix, $formattedDate',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF1276ff)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5, bottom: 5),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (voidDate == 0) {
                                                    showModalBottomSheet<
                                                        dynamic>(
                                                      enableDrag: false,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                        top:
                                                            Radius.circular(20),
                                                      )),
                                                      builder: (BuildContext
                                                          context) {
                                                        return SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                2.65 /
                                                                3,
                                                            child: Cashier(
                                                                staffID:
                                                                    staffID,
                                                                saleID: saleID,
                                                                updateData:
                                                                    updateData));
                                                      },
                                                    );
                                                  } else {
                                                    getVoidAlert();
                                                  }
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  color: Colors.white,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Cashier (Optional)',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF878787)),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            cashierName == ''
                                                                ? 'No cashier selected'
                                                                : cashierName,
                                                            style: TextStyle(
                                                                color: cashierName ==
                                                                        ''
                                                                    ? const Color(
                                                                        0xFF333333)
                                                                    : const Color(
                                                                        0xFF1276ff)),
                                                          ),
                                                          cashierName == ''
                                                              ? Container()
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    deleteCashier(
                                                                        saleID);
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(right: 10),
                                                                    child: Image
                                                                        .asset(
                                                                      'icons/Refresh.png',
                                                                      scale: 70,
                                                                    ),
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            voidDate == 0 &&
                                                    collections.isNotEmpty
                                                ? Column(
                                                    children: [
                                                      const Divider(
                                                        thickness: 1,
                                                      ),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 5,
                                                                  bottom: 5),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              showModalBottomSheet<
                                                                  dynamic>(
                                                                enableDrag:
                                                                    false,
                                                                barrierColor: Colors
                                                                    .transparent,
                                                                isScrollControlled:
                                                                    true,
                                                                context:
                                                                    context,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20),
                                                                )),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          2.65 /
                                                                          3,
                                                                      child: Payment(
                                                                          totalPayment:
                                                                              totalPayment,
                                                                          collections:
                                                                              collections,
                                                                          paymentType:
                                                                              paymentType,
                                                                          saleID: widget
                                                                              .saleID,
                                                                          updateData:
                                                                              updateData));
                                                                },
                                                              );
                                                            },
                                                            child: ListView
                                                                .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    itemCount:
                                                                        collections
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      String
                                                                          paymentTitle =
                                                                          '';

                                                                      for (int i =
                                                                              0;
                                                                          i < paymentType.length;
                                                                          i++) {
                                                                        if (paymentType[i]['paymentTypeID'] ==
                                                                            collections[index]['payID']) {
                                                                          paymentTitle =
                                                                              capitalizeFirstLetter(paymentType[i]['title']);
                                                                        }
                                                                      }
                                                                      return Column(
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                double.infinity,
                                                                            color:
                                                                                Colors.white,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  'Payment method #${collections[index]['payID']}',
                                                                                  style: TextStyle(color: Color(0xFF878787)),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Text(
                                                                                  '${formatDoubleText(collections[index]['amount'].toDouble())} ($paymentTitle)',
                                                                                  style: TextStyle(color: Color(0xFF1276ff)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          if (index <
                                                                              collections.length - 1)
                                                                            Divider(
                                                                              thickness: 1,
                                                                            )
                                                                        ],
                                                                      );
                                                                    }),
                                                          )),
                                                    ],
                                                  )
                                                : Container(),
                                            voidDate != 0
                                                ? Column(
                                                    children: [
                                                      const Divider(
                                                        thickness: 1,
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        color: Colors.white,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'Void Date',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF878787)),
                                                            ),
                                                            const SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              '$hourString1:$minuteString1 $suffix1, $formattedDate1',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text('Remarks'),
                                    ),
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: Colors.white,
                                      ),
                                      child: Scrollbar(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: TextFormField(
                                            controller: inputRemark,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Type remark here',
                                              border: InputBorder.none,
                                            ),
                                            maxLines: null,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            onTap: () async {
                                              if (voidDate == 0) {
                                                showModalBottomSheet<dynamic>(
                                                  enableDrag: false,
                                                  barrierColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .vertical(
                                                    top: Radius.circular(20),
                                                  )),
                                                  builder:
                                                      (BuildContext context) {
                                                    return SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            2.65 /
                                                            3,
                                                        child: AddSalesRemarks(
                                                            remarks: remarks,
                                                            saleID: saleID,
                                                            updateData:
                                                                updateData));
                                                  },
                                                );
                                              } else {
                                                getVoidAlert();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    voidDate == 0
                                        ? GestureDetector(
                                            onTap: () {
                                              loadPage = false;
                                              setState(() {
                                                showDetails =
                                                    !showDetails; // Toggle the showDetails flag
                                              });
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        showDetails
                                                            ? 'Less details'
                                                            : 'More details',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF1276ff))),
                                                    Icon(
                                                      showDetails
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                      color: const Color(
                                                          0xFF1276ff),
                                                      size: 25,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    if (showDetails) // Render additional details if showDetails is true
                                      getDetails(),
                                  ]),
                            ),
                          ),
                        );
                      })),
                  bottomNavigationBar: Material(
                    elevation: 10,
                    child: Container(
                      height: 70, // Set the desired height here
                      color:
                          Colors.white, // Set the color of the bottom app bar
                      child: Padding(
                        padding: const EdgeInsets.only(right: 25, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton<String>(
                              shape: const ContinuousRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              elevation: 1,
                              offset: const Offset(0, -78),
                              padding: EdgeInsets.zero,
                              child: Image.asset(
                                voidDate == 0
                                    ? 'icons/Receipt (Blue).png'
                                    : 'icons/Print (Grey).png',
                                scale: 40,
                                color: menuVisible
                                    ? Colors.blueAccent.shade100
                                    : null,
                              ),
                              onOpened: () {
                                setState(() {
                                  loadPage = false;
                                  menuVisible = !menuVisible;
                                });
                              },
                              onCanceled: () {
                                setState(() {
                                  loadPage = false;
                                  menuVisible = !menuVisible;
                                });
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                if (voidDate == 0)
                                  PopupMenuItem<String>(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            getEreceipt(widget.saleID);
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'icons/Forgot.png',
                                                  scale: 50,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  'E-receipt',
                                                  style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(
                                          thickness: 1,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            //deleteAllVoucher();
                                          },
                                          child: Container(
                                            color: Colors.white,
                                            width: double.infinity,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'icons/Printer.png',
                                                  scale: 50,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                const Text(
                                                  'Receipt',
                                                  style: TextStyle(
                                                      color: Color(0xFF000000),
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            }));
  }

  Widget getDetails() {
    double screenWidth = MediaQuery.of(context).size.width - 40;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        if (salesCompletedService.length != 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Service'),
              ),
              const SizedBox(
                height: 5,
              ),
              getServiceProductPackageDiscountDesign(salesCompletedService)
            ],
          ),
        if (salesCompletedProduct.length != 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Product'),
              ),
              const SizedBox(
                height: 5,
              ),
              getServiceProductPackageDiscountDesign(salesCompletedProduct)
            ],
          ),
        if (salesCompletedPackage.length != 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Package'),
              ),
              const SizedBox(
                height: 5,
              ),
              getServiceProductPackageDiscountDesign(salesCompletedPackage)
            ],
          ),
        if (salesCompletedDiscount.length != 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text('Discount'),
              ),
              const SizedBox(
                height: 5,
              ),
              getServiceProductPackageDiscountDesign(salesCompletedDiscount)
            ],
          ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text('Staff list'),
        ),
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                        width: screenWidth / 2,
                        child: const Text(
                          'Staff',
                          style: TextStyle(color: Color(0xFF878787)),
                        )),
                    Container(
                        width: screenWidth / 4,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Effort',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ],
                        )),
                    Container(
                        width: screenWidth / 4,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Hands on',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ],
                        ))
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allStaff.length,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> staffInfoList =
                        List.castFrom<dynamic, Map<String, dynamic>>(
                            allStaff[index]);
                    return Column(
                      children: staffInfoList.map((staffInfo) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            children: [
                              Container(
                                  width: screenWidth / 2,
                                  child: Text(staffInfo['name'])),
                              Container(
                                  width: screenWidth / 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(formatDoubleText(
                                              staffInfo['effort'].toDouble())
                                          .toString()),
                                    ],
                                  )),
                              Container(
                                  width: screenWidth / 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(formatDoubleText(
                                              staffInfo['hof'].toDouble())
                                          .toString()),
                                    ],
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  getServiceProductPackageDiscountDesign(List<dynamic> itemList) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          List<dynamic> staff = itemList[index]['staffs'];
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet<dynamic>(
                    enableDrag: false,
                    isScrollControlled: true,
                    barrierColor: Colors.transparent,
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    )),
                    builder: (BuildContext context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 2.65 / 3,
                        child: ItemDetails(
                            skuName: itemList[index]['sku']['name'],
                            priceAmt: itemList[index]['priceAmt'].toDouble(),
                            outstandAmt:
                                itemList[index]['outstandAmt'].toDouble(),
                            discountAmt:
                                itemList[index]['discountAmt'].toDouble(),
                            saleID: saleID,
                            completedID: itemList[index]['completedID'],
                            staff: staff,
                            updateData: updateData),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(itemList[index]['sku']['name'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            staff.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Color(0xFFf5f5f5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(staff[index]['name']),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (staff.isNotEmpty)
                          const SizedBox(
                            height: 10,
                          ),
                        Row(
                          children: [
                            if (itemList[index]['discountAmt'] != 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Color(0xFFf5f5f5),
                                  ),
                                  child: Text(
                                    formatAmount(itemList[index]['discountAmt'])
                                        .toString(),
                                    style: const TextStyle(
                                        color: Color(0xFF28cd41)),
                                  ),
                                ),
                              ),
                            // Padding(
                            //   padding: const EdgeInsets.only(right: 10),
                            //   child: Container(
                            //     padding: EdgeInsets.only(
                            //         left: 10, right: 10, top: 5, bottom: 5),
                            //     decoration: BoxDecoration(
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(5)),
                            //       color: Color(0xFFf5f5f5),
                            //     ),
                            //     child: Text(
                            //       'Credits',
                            //       style: TextStyle(color: Color(0xFFff9502)),
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(right: 10),
                            //   child: Container(
                            //     padding: EdgeInsets.only(
                            //         left: 10, right: 10, top: 5, bottom: 5),
                            //     decoration: BoxDecoration(
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(5)),
                            //       color: Color(0xFFf5f5f5),
                            //     ),
                            //     child: Text(
                            //       'Voucher',
                            //       style: TextStyle(color: Color(0xFFff9502)),
                            //     ),
                            //   ),
                            // ),
                            if (itemList[index]['outstandAmt'] != 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                    color: Color(0xFFf5f5f5),
                                  ),
                                  child: Text(
                                    formatAmount(itemList[index]['outstandAmt'])
                                        .toString(),
                                    style: const TextStyle(
                                        color: Color(0xFFbe2f19)),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatAmount(itemList[index]['priceAmt'])
                                        .toString(),
                                    style: const TextStyle(
                                        color: Color(0xFF1276ff)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          );
        });
  }

  voidSale() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Void Sale'),
          content:
              const Text('Are you sure you would like to void selected order?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                var headers = {'token': token};
                var request = http.Request(
                    'POST',
                    Uri.parse(
                        'https://order.tunai.io/loyalty/sales/${widget.saleID}/void'));

                request.headers.addAll(headers);

                http.StreamedResponse response = await request.send();

                if (response.statusCode == 200) {
                  setState(() {});
                } else {
                  print(response.reasonPhrase);
                }
                successVoid();
              },
              child: const Text(
                'Void',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  successVoid() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Sale voided'),
          content: const Text('Selected sale has been successfully voided.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  getVoidAlert() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Sale voided'),
          content: const Text('This sale has been voided!'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void getEreceipt(int saleID) async {
    var headers = {'token': token};
    var request = http.Request('GET',
        Uri.parse('https://order.tunai.io/loyalty/sale/$saleID/receipt/pdf'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> sale = body;

      List<dynamic> sales = sale['sales'];
      final Uri url = Uri.parse('${sales[0]['receipt']}');

      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
      Navigator.pop(context);
    } else {
      print(response.reasonPhrase);
    }
  }

  deleteCashier(int saleID) async {
    var headers = {'token': token};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/cashregister/sale/$saleID/cashier/delete'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      updateData();
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
