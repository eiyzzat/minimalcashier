// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../../../textFormating.dart';
import '../../Function/generalFunction.dart';

class CreditPaymentBreakdown extends StatefulWidget {
  final double saleAmount;
  final double discountAmount;
  final double outstandingsAmount;
  final double redeemAmount;
  final double totalSales;
  final double redeemCredit;
  final double redeemVoucher;
  final double totalPayment;
  final int saleID;
  final double totalEffort;
  final double totalHof;
  const CreditPaymentBreakdown(
      {super.key,
      required this.saleAmount,
      required this.discountAmount,
      required this.outstandingsAmount,
      required this.redeemAmount,
      required this.totalSales,
      required this.redeemCredit,
      required this.redeemVoucher,
      required this.totalPayment,
      required this.saleID,
      required this.totalEffort,
      required this.totalHof});

  @override
  State<CreditPaymentBreakdown> createState() => _CreditPaymentBreakdownState();
}

class _CreditPaymentBreakdownState extends State<CreditPaymentBreakdown> {
  List<dynamic> sales = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: Text(
            'Payment breakdown',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Transform.scale(
                scale: 1.4,
                child: CloseButton(
                    color: Color(0xFF1276ff),
                    onPressed: () {
                      Navigator.pop(context);
                    })),
          ),
        ),
        body: Container(
            color: Color(0xFFf3f2f8),
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
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${widget.saleID}',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                              Divider(
                                thickness: 1,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Sales'),
                                        Text(
                                          formatAmount(widget.totalSales)
                                              .toString(),
                                          style: TextStyle(
                                              color: Color(0xFF333333)),
                                        ),
                                      ],
                                    ),
                                    widget.discountAmount != 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Discount'),
                                                Text(
                                                  formatAmount(
                                                          widget.discountAmount)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFF28cd41)),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    widget.outstandingsAmount != 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Outstanding'),
                                                Text(
                                                  formatAmount(widget
                                                          .outstandingsAmount)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFbe2f19)),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    widget.redeemCredit != 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Redeem (Credits)'),
                                                Text(
                                                  formatAmount(
                                                          widget.redeemCredit)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFff9502)),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    widget.redeemVoucher != 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Redeem (Vouchers)'),
                                                Text(
                                                  formatAmount(
                                                          widget.redeemVoucher)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFff9502)),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    widget.redeemAmount != 0
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('Total Redeem'),
                                                Text(
                                                  formatAmount(
                                                          widget.redeemAmount)
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Color(0xFFff9502)),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total payment',
                                    style: TextStyle(color: Color(0xFF000000)),
                                  ),
                                  Text(
                                    formatAmount(widget.totalPayment)
                                        .toString(),
                                    style: TextStyle(color: Color(0xFF000000)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Staff performance',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                              Divider(
                                thickness: 1,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Effort'), Text(formatDoubleText(widget.totalEffort).toString())],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Hands-on'), Text(formatDoubleText(widget.totalHof).toString())],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ));
            })));
  }
}
