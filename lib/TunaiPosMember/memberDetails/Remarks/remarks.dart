// ignore_for_file: avoid_function_literals_in_foreach_calls, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../../textFormating.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import '../Sales/updateRemark.dart';
import 'addRemarks.dart';

class Remark extends StatefulWidget {
  const Remark({super.key});

  @override
  State<Remark> createState() => _RemarkState();
}
class _RemarkState extends State<Remark> {
  List<dynamic> remark = [];
  List<dynamic> newRemarkdeleteDate0 = [];
  Map<String, List<dynamic>> remarkGroup = {};

  Future getRemarksList() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/remark'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> remarks = body;

      remark = remarks['remarks'];
      newRemarkdeleteDate0 = [];
      if (remark.isNotEmpty) {
        for (var i = 0; i < remark.length; i++) {
          if (remark[i]['deleteDate'] == 0) {
            newRemarkdeleteDate0.add(remark[i]);
          }
        }
      }

      newRemarkdeleteDate0.sort((a, b) {
        int createDateTimestampA =
            a['updateDate'] != 0 ? a['updateDate'] : a['createDate'];
        int createDateTimestampB =
            b['updateDate'] != 0 ? b['updateDate'] : b['createDate'];
        return createDateTimestampB.compareTo(createDateTimestampA);
      });

      remarkGroup = {};

      newRemarkdeleteDate0.forEach((item) {
        int createDateTimestamp = 0;

        if (item['updateDate'] != 0) {
          createDateTimestamp = item['updateDate'];
        } else {
          createDateTimestamp = item['createDate'];
        }

        DateTime createDate =
            DateTime.fromMillisecondsSinceEpoch(createDateTimestamp * 1000);
        String formattedCreateDate = DateFormat('MMMM yyyy').format(createDate);

        if (!remarkGroup.containsKey(formattedCreateDate)) {
          remarkGroup[formattedCreateDate] = [];
        }
        remarkGroup[formattedCreateDate]!.add(item);
      });

      List<MapEntry<String, List<dynamic>>> sortedEntries =
          remarkGroup.entries.toList()
            ..sort((a, b) {
              int createDateTimestampA = a.value[0]['updateDate'] != 0
                  ? a.value[0]['updateDate']
                  : a.value[0]['createDate'];
              int createDateTimestampB = b.value[0]['updateDate'] != 0
                  ? b.value[0]['updateDate']
                  : b.value[0]['createDate'];

              return createDateTimestampB.compareTo(createDateTimestampA);
            });

      remarkGroup = Map.fromEntries(sortedEntries);
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        )),
        centerTitle: true,
        title: const Text(
          'Remarks',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: () {
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
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * 2.65 / 3,
                        child: const AddRemarks());
                  },
                ).then((value) {
                  if (value != null && value == 'refresh') {
                    setState(() {});
                  }
                });
              },
              icon: const Icon(Icons.add),
              color: const Color(0xFF1276ff),
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: Container(
          width: double.infinity,
          color: const Color(0xFFf3f2f8),
          child: FutureBuilder(
              future: getRemarksList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (remarkGroup.isNotEmpty) {
                  return ListView(
                    children: remarkGroup.entries.map(
                      (entry) {
                        final String date = entry.key;
                        final List<dynamic> items = entry.value;

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, bottom: 5, top: 10),
                                child: Text(
                                  date,
                                  style:
                                      const TextStyle(color: Color(0xFF8a8a8a)),
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    // Build and return a widget for each item in the list
                                    final item = items[index];

                                    String createDate =
                                        formatDateText(item['createDate']);
                                    String createTime =
                                        formatTimeText(item['createDate']);
                                    String updateDate =
                                        formatDateText(item['updateDate']);
                                    String updateTime =
                                        formatTimeText(item['updateDate']);

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10, right: 10),
                                      child: IntrinsicHeight(
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet<dynamic>(
                                              enableDrag: false,
                                              barrierColor: Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              )),
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      2.65 /
                                                      3,
                                                  child: UpdateRemark(
                                                      remarkID:
                                                          item['remarkID'], remark: item['remarks']),
                                                );
                                              },
                                            ).then((value) {
                                              if (value != null &&
                                                  value == 'refresh') {
                                                setState(() {});
                                              }
                                            });
                                          },
                                          child: Scrollbar(
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
                                                child: Stack(children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (item['bookID'] == 0 &&
                                                          item['remarks'] !=
                                                              null &&
                                                          !item['remarks']
                                                              .contains(
                                                                  'Service') &&
                                                          !item['remarks']
                                                              .contains(
                                                                  'Product'))
                                                        const Text(
                                                          'Remark',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      if (item['bookID'] != 0)
                                                        const Text(
                                                          'Appointment',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      if (item['remarks'] !=
                                                              null &&
                                                          item['remarks']
                                                              .contains(
                                                                  'Service'))
                                                        const Text('Service',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      if (item['remarks'] !=
                                                              null &&
                                                          item['remarks']
                                                              .contains(
                                                                  'Product'))
                                                        const Text('Product',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      const SizedBox(height: 10),
                                                      Text(item['remarks'] ??
                                                          ''),
                                                      const SizedBox(height: 30),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            '$createTime, $createDate',
                                                            textAlign:
                                                                TextAlign.end,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          item['updateDate'] !=
                                                                  0
                                                              ? Text(
                                                                  '$updateTime, $updateDate',
                                                                  style: const TextStyle(
                                                                      color: Color(
                                                                          0xFFff9502)),
                                                                )
                                                              : Container()
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  if (item['bookID'] != 0)
                                                    const Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Icon(
                                                        Icons.info,
                                                        size: 20,
                                                        color:
                                                            Color(0xFF1276ff),
                                                      ),
                                                    ),
                                                ]),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                            ]);
                      },
                    ).toList(),
                  );
                } else {
                  return Container(
                    color: const Color(0xFFf3f2f8),
                    width: double.infinity,
                    child:  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No remarks yet!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'You can add remark'
                          's'
                          ' using the + icon',
                          style: TextStyle(color: Color(0xFF878787)),
                        ),
                        Text('& the remarks will display here when added',
                            style: TextStyle(color: Color(0xFF878787)))
                      ],
                    ),
                  );
                }
              })),
    );
  }
}
