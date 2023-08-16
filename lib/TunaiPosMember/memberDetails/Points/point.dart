import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';


class Point extends StatefulWidget {
  const Point({super.key});

  @override
  State<Point> createState() => _PointState();
}

class _PointState extends State<Point> {
  Map<String, List<dynamic>> groupedPoints = {};

  List<dynamic> point = [];
  List<dynamic> newPointdeleteDate0 = [];
  
  String lastTotalPoint = '';

  Future<Object> getMemberPoint() async {
    newPointdeleteDate0 = [];
    groupedPoints = {};
    point = [];

    var headers = {'token': token};

    var request = http.Request(
      'GET',
      Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/points'),
    );

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> points = body;

      point = points['points'];

      if (point.isNotEmpty) {
        for (var i = 0; i < point.length; i++) {
          if (point[i]['deleteDate'] == 0) {
            newPointdeleteDate0.add(point[i]);
          }
        }
      }

      if (newPointdeleteDate0.isNotEmpty) {
        int lastIndex = newPointdeleteDate0.length - 1;
        lastTotalPoint = newPointdeleteDate0[lastIndex]['final'].toString();
      }

      if (newPointdeleteDate0.isNotEmpty) {
        for (var i = 0; i < newPointdeleteDate0.length; i++) {
          int timestamp = newPointdeleteDate0[i]['createDate'];
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
          String monthYear = DateFormat('MM-yyyy').format(dateTime);

          if (!groupedPoints.containsKey(monthYear)) {
            groupedPoints[monthYear] = [];
          }

          groupedPoints[monthYear]!.add(newPointdeleteDate0[i]);
        }
        return groupedPoints;
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
            'Points',
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
              future: getMemberPoint(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && newPointdeleteDate0.isNotEmpty) {
                  //List<dynamic> groupedCredits = groupCreditsByMonth(snapshot.data);
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
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 30),
                            child: Text(
                              '$lastTotalPoint pt',
                              style: const TextStyle(
                                  fontSize: 36, color: Color(0xFF1276ff)),
                            ),
                          ),
                          const Text('Transactions'),
                          Column(
                            children: groupedPoints.keys
                                .toList()
                                .reversed
                                .map((monthYear) {
                              final points = groupedPoints[monthYear]!;
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
                                        children: points.reversed.map((point) {
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      point['amount']
                                                              .toString()
                                                              .contains('-')
                                                          ? Image.asset(
                                                              'icons/Pt2.png',
                                                              height: 40,
                                                            )
                                                          : Image.asset(
                                                              'icons/Point.png',
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
                                                          point['amount']
                                                                  .toString()
                                                                  .contains('-')
                                                              ? const Text('Redeem')
                                                              : const Text('Collect'),
                                                          Text(
                                                            DateFormat(
                                                                    'hh:mm a, dd-MM-yyyy')
                                                                .format(
                                                              DateTime.fromMillisecondsSinceEpoch(
                                                                  point['createDate'] *
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
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        '${point['amount']
                                                                    .toString()
                                                                    .contains(
                                                                        '-')
                                                                ? ''
                                                                : '+'}${point['amount']} pt',
                                                        style: TextStyle(
                                                          color: point['amount']
                                                                  .toString()
                                                                  .contains('-')
                                                              ? const Color(
                                                                  0xFFbe2f19)
                                                              : const Color(
                                                                  0xFF24a828),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${point['final']} pt',
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              if (point != points.first)
                                                const Divider(
                                                  thickness: 1,
                                                ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  )
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
                          'No point yet!',
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
