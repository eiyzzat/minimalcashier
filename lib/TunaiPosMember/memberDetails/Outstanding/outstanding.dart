import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class Outstanding extends StatefulWidget {
  const Outstanding({super.key});

  @override
  State<Outstanding> createState() => _OutstandingState();
}

class _OutstandingState extends State<Outstanding> {
  Map<String, List<dynamic>> groupedOutstanding = {};
  List<dynamic> outstanding = [];
  List<dynamic> newOutstandingdeleteDate0 = [];
  String lastTotalOutstanding = '';
  int type = 2;
  Future? future;

  @override
  void initState() {
    future = getMemberOutstanding();
    super.initState();
  }

  Future<Object> getMemberOutstanding() async {
    newOutstandingdeleteDate0 = [];
    groupedOutstanding = {};
    outstanding = [];

    var headers = {'token': token};

    var request = http.Request(
      'GET',
      Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/outstandings'),
    );

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> outstandings = body;

      outstanding = outstandings['outstandings'];

      if (outstanding.isNotEmpty) {
        for (var i = 0; i < outstanding.length; i++) {
          if (outstanding[i]['deleteDate'] == 0) {
            newOutstandingdeleteDate0.add(outstanding[i]);
          }
        }
      }

      if (newOutstandingdeleteDate0.isNotEmpty) {
        int lastIndex = newOutstandingdeleteDate0.length - 1;

        lastTotalOutstanding =
            formatAmount(newOutstandingdeleteDate0[lastIndex]['finalAmount'])
                .toString();
      }

      if (newOutstandingdeleteDate0.isNotEmpty) {
        // Group credits by month and year
        for (var i = 0; i < newOutstandingdeleteDate0.length; i++) {
          int timestamp = newOutstandingdeleteDate0[i]['createDate'];
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          String monthYear = DateFormat('MM-yyyy').format(dateTime);

          if (!groupedOutstanding.containsKey(monthYear)) {
            groupedOutstanding[monthYear] = [];
          }

          groupedOutstanding[monthYear]!.add(newOutstandingdeleteDate0[i]);
        }
        return groupedOutstanding;
      }
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 2.67 / 3,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            )),
            centerTitle: true,
            title: const Text(
              'Outstandings',
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
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFf3f2f8),
            child: FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData &&
                      newOutstandingdeleteDate0.isNotEmpty) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 30, left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 10),
                              child: Text(
                                'Owe',
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, bottom: 30),
                              child: Text(
                                lastTotalOutstanding.toString(),
                                style: const TextStyle(
                                    fontSize: 36, color: Color(0xFF1276ff)),
                              ),
                            ),
                            const Text('Transactions'),
                            Column(
                              children: groupedOutstanding.keys
                                  .toList()
                                  .reversed
                                  .map((monthYear) {
                                final outstandings =
                                    groupedOutstanding[monthYear]!;
                                final month = monthYear
                                    .split('-')[0]; // Extract the month
                                final year =
                                    monthYear.split('-')[1]; // Extract the year
                                final formattedMonth = DateFormat.MMMM()
                                    .format(DateTime(
                                        int.parse(year), int.parse(month)))
                                    .toUpperCase();

                                return Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        '$formattedMonth $year',
                                        style:
                                            const TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: outstandings.reversed
                                              .map((outstanding) {
                                            String formatAmount(
                                                dynamic amount) {
                                              if (amount == 0) {
                                                return '0.00';
                                              } else if (amount is int) {
                                                final format =
                                                    NumberFormat('#,##0.00');
                                                return format
                                                    .format(amount.toDouble());
                                              } else {
                                                final format =
                                                    NumberFormat('#,##0.00');
                                                return format.format(amount);
                                              }
                                            }

                                            return Container(
                                              width: double.infinity,
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          outstanding['amount']
                                                                  .toString()
                                                                  .contains('-')
                                                              ? Image.asset(
                                                                  'icons/CreditSquareGrey.png',
                                                                  height: 40,
                                                                )
                                                              : Image.asset(
                                                                  'icons/Outstanding1.png',
                                                                  height: 40,
                                                                ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              outstanding['amount']
                                                                      .toString()
                                                                      .contains(
                                                                          '-')
                                                                  ? const Text(
                                                                      'Payback')
                                                                  : const Text(
                                                                      'Outstanding'),
                                                              Text(
                                                                DateFormat(
                                                                        'hh:mm a, dd-MM-yyyy')
                                                                    .format(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                      outstanding[
                                                                              'createDate'] *
                                                                          1000),
                                                                ),
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFFc6c6c6)),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            (outstanding['amount']
                                                                        .toString()
                                                                        .contains(
                                                                            '-')
                                                                    ? ''
                                                                    : '+') +
                                                                formatAmount(
                                                                    outstanding[
                                                                        'amount']),
                                                            style: TextStyle(
                                                              color: outstanding[
                                                                          'amount']
                                                                      .toString()
                                                                      .contains(
                                                                          '-')
                                                                  ? const Color(
                                                                      0xFF24a828)
                                                                  : const Color(
                                                                      0xFFbe2f19),
                                                            ),
                                                          ),
                                                          Text(
                                                            formatAmount(
                                                                outstanding[
                                                                    'finalAmount']),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  if (outstanding !=
                                                      outstandings.first)
                                                    const Divider(
                                                      thickness: 1,
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      color: const Color(0xFFf3f2f8),
                      width: double.infinity,
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No outstanding yet!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }
                }),
          )),
    );
  }
}
