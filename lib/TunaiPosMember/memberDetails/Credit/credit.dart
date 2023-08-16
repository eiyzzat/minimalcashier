import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../Function/generalFunction.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import '../Sales/orderDetails.dart';

class Credit extends StatefulWidget {
  const Credit({
    super.key,
  });

  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  Map<String, List<dynamic>> groupedCredits = {};

  List<dynamic> credit = [];
  List<dynamic> newCreditdeleteDate0 = [];

  String lastTotalCredit = '';
  
  int saleID = 0;

  Future<Object> getMemberCredit() async {
    newCreditdeleteDate0 = [];
    groupedCredits = {};
    credit = [];

    var headers = {'token': token};

    var request = http.Request(
      'GET',
      Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/credits'),
    );

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> credits = body;

      credit = credits['credits'];

      if (credit.isNotEmpty) {
        for (var i = 0; i < credit.length; i++) {
          if (credit[i]['deleteDate'] == 0) {
            newCreditdeleteDate0.add(credit[i]);
          }
        }
      }

      if (newCreditdeleteDate0.isNotEmpty) {
        int lastIndex = newCreditdeleteDate0.length - 1;

        lastTotalCredit =
            formatAmount(newCreditdeleteDate0[lastIndex]['final']).toString();
      }

      if (newCreditdeleteDate0.isNotEmpty) {
        for (var i = 0; i < newCreditdeleteDate0.length; i++) {
          int timestamp = newCreditdeleteDate0[i]['createDate'];
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          String monthYear = DateFormat('MM-yyyy').format(dateTime);

          if (!groupedCredits.containsKey(monthYear)) {
            groupedCredits[monthYear] = [];
          }

          groupedCredits[monthYear]!.add(newCreditdeleteDate0[i]);
        }
        return groupedCredits;
      }
    }

    return [];
  }

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
          title: const Text(
            'Credits',
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
              future: getMemberCredit(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData &&
                    newCreditdeleteDate0.isNotEmpty) {

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
                              'Balance',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 30),
                            child: Text(
                              lastTotalCredit.toString(),
                              style: const TextStyle(
                                  fontSize: 36, color: Color(0xFF1276ff)),
                            ),
                          ),
                          const Text('Transactions'),
                          const SizedBox(height: 10),
                          Column(
                            children: groupedCredits.keys
                                .toList()
                                .reversed
                                .map((monthYear) {
                              final credits = groupedCredits[monthYear]!;
                              final month =
                                  monthYear.split('-')[0]; // Extract the month
                              final year =
                                  monthYear.split('-')[1]; // Extract the year
                              final formattedMonth = DateFormat.MMMM()
                                  .format(DateTime(
                                      int.parse(year), int.parse(month)))
                                  .toUpperCase();

                              return Column(
                                children: [
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
                                        children:
                                            credits.reversed.map((credit) {
                                          String formatAmount(dynamic amount) {
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

                                          return GestureDetector(
                                            onTap: () {
                                              if (credit['amount'] < 0) {
                                                saleID = credit['consumed']
                                                    ['saleID'];
                                              } else {
                                                saleID = credit['purchased']
                                                    ['saleID'];
                                              }
                                              showModalBottomSheet<dynamic>(
                                                enableDrag: false,
                                                barrierColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                builder:
                                                    (BuildContext context) {
                                                  return OrderDetails(
                                                      amount: credit['amount']
                                                          .toDouble(),
                                                      saleID: saleID);
                                                },
                                              );
                                            },
                                            child: Container(
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
                                                          credit['amount']
                                                                  .toString()
                                                                  .contains('-')
                                                              ? Image.asset(
                                                                  'icons/CreditSquareGrey.png',
                                                                  height: 40,
                                                                )
                                                              : Image.asset(
                                                                  'icons/CreditSquare.png',
                                                                  height: 40,
                                                                ),
                                                          const SizedBox(width: 10),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              credit['amount']
                                                                      .toString()
                                                                      .contains(
                                                                          '-')
                                                                  ? const Text(
                                                                      'Redeem')
                                                                  : const Text(
                                                                      'Top up'),
                                                              Text(
                                                                DateFormat(
                                                                        'hh:mm a, dd-MM-yyyy')
                                                                    .format(
                                                                  DateTime
                                                                      .fromMillisecondsSinceEpoch(
                                                                    credit['createDate'] *
                                                                        1000,
                                                                  ),
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
                                                            (credit['amount']
                                                                        .toString()
                                                                        .contains(
                                                                            '-')
                                                                    ? ''
                                                                    : '+') +
                                                                formatAmount(
                                                                    credit[
                                                                        'amount']),
                                                            style: TextStyle(
                                                              color: credit[
                                                                          'amount']
                                                                      .toString()
                                                                      .contains(
                                                                          '-')
                                                                  ? const Color(
                                                                      0xFFbe2f19)
                                                                  : const Color(
                                                                      0xFF24a828),
                                                            ),
                                                          ),
                                                          Text(
                                                            formatAmount(credit[
                                                                'final']),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  if (credit != credits.first)
                                                    const Divider(
                                                      thickness: 1,
                                                    ),
                                                ],
                                              ),
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
                          'No credit yet!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ));
  }
}
