// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'addReferrer.dart';

class Referral extends StatefulWidget {
  const Referral({super.key});

  @override
  State<Referral> createState() => _ReferralState();
}

class _ReferralState extends State<Referral>
    with SingleTickerProviderStateMixin {
  List<dynamic> referralBy = [];
  List<dynamic> referralFor = [];

  Map<String, List<dynamic>> referralByGroup = {};
  Map<String, List<dynamic>> referralForGroup = {};

  int currentTabIndex = 0;
  bool loadAPI = true;

  @override
  void initState() {
    super.initState();
    getReferral();
  }

  Future getReferral() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/referral'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      referralByGroup = {};
      referralForGroup = {};
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> referral = body;

      referralBy = referral['by'];
      referralFor = referral['for'];

      referralBy.forEach((item) {
        int createDateTimestamp = item['createDate'];

        DateTime createDate =
            DateTime.fromMillisecondsSinceEpoch(createDateTimestamp * 1000);
        String formattedCreateDate =
            DateFormat('dd-MM-yyyy').format(createDate);

        if (!referralByGroup.containsKey(formattedCreateDate)) {
          referralByGroup[formattedCreateDate] = [];
        }
        referralByGroup[formattedCreateDate]!.add(item);
      });

      referralFor.forEach((item) {
        int createDateTimestamp = item['createDate'];

        DateTime createDate =
            DateTime.fromMillisecondsSinceEpoch(createDateTimestamp * 1000);
        String formattedCreateDate =
            DateFormat('dd-MM-yyyy').format(createDate);

        if (!referralForGroup.containsKey(formattedCreateDate)) {
          referralForGroup[formattedCreateDate] = [];
        }
        referralForGroup[formattedCreateDate]!.add(item);
      });
    } else {
      print(response.reasonPhrase);
    }
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
            'Referral',
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
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 20),
                  child: FutureBuilder(
                      future: loadAPI ? getReferral() : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text('Refer by'),
                              ),
                              if (referralByGroup.isEmpty)
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
                                        return SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2.65 /
                                                3,
                                            child: AddReferrer(
                                              updateData: updateData,
                                            ));
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(8)),
                                        color: Colors.white,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0xFF1276ff),
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              getDesignBy(referralByGroup),
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Text('Referrer for'),
                              ),
                              getDesignFor(referralForGroup),
                            ],
                          );
                        }
                      }),
                ),
              ));
            })));
  }

  getDesignBy(Map<String, List<dynamic>> mapList) {
    final sortedGroups = List.from(mapList.entries)
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        // Sort the service items by createDate in descending order
        itemsA.sort((a, b) => b['createDate'].compareTo(a['createDate']));
        itemsB.sort((a, b) => b['createDate'].compareTo(a['createDate']));

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['createDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['createDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      });
    return ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: sortedGroups.map((entry) {
          final String date = entry.key;
          final List<dynamic> items = entry.value;

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5, top: 10),
                  child: Text(
                    date,
                    style: const TextStyle(color: Color(0xFF8a8a8a)),
                  ),
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final int timestamp = items[index]['createDate'];
                      final DateTime dateTime =
                          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                      final String formattedDate =
                          DateFormat('hh:mm a, dd/MM/yyyy').format(dateTime);

                      String mobile =
                          '${'(' + items[index]['mobile'].substring(0, 4) + ') ' + items[index]['mobile'].substring(4, 7)}-' +
                              items[index]['mobile'].substring(7);

                      return Column(
                        children: [
                          Dismissible(
                            key: Key(items[index]['referByMemberID']
                                .toString()), // use a unique key for each item
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) async {
                              final referByMemberID = int.parse(memberIDglobal);
                              deletereferByMemberID(referByMemberID);
                            },

                            background: Container(
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.red,
                              ),
                              child:  Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ]),
                              ),
                            ),
                            child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                items[index]['icon'] != ''
                                    ? CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFf3f2f8),
                                        backgroundImage:
                                            NetworkImage(items[index]['icon']),
                                        radius: 25,
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        radius: 25,
                                      ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              items[index]['name'] != ''
                                                  ? items[index]['name']
                                                  : mobile,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formattedDate,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(mobile),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      );
                    })
              ]);
        }).toList());
  }

  getDesignFor(Map<String, List<dynamic>> mapList) {
    final sortedGroups = List.from(mapList.entries)
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        // Sort the service items by createDate in descending order
        itemsA.sort((a, b) => b['createDate'].compareTo(a['createDate']));
        itemsB.sort((a, b) => b['createDate'].compareTo(a['createDate']));

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['createDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['createDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      });
    return ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: sortedGroups.map((entry) {
          final String date = entry.key;
          final List<dynamic> items = entry.value;

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5, top: 10),
                  child: Text(
                    date,
                    style: const TextStyle(color: Color(0xFF8a8a8a)),
                  ),
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final int timestamp = items[index]['createDate'];
                      final DateTime dateTime =
                          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                      final String formattedDate =
                          DateFormat('hh:mm a, dd/MM/yyyy').format(dateTime);

                      String mobile =
                          '${'(' + items[index]['mobile'].substring(0, 4) + ') ' + items[index]['mobile'].substring(4, 7)}-' +
                              items[index]['mobile'].substring(7);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                items[index]['icon'] != ''
                                    ? CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFf3f2f8),
                                        backgroundImage:
                                            NetworkImage(items[index]['icon']),
                                        radius: 25,
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        radius: 25,
                                      ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              items[index]['name'] != ''
                                                  ? items[index]['name']
                                                  : mobile,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formattedDate,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(mobile),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    })
              ]);
        }).toList());
  }

  deletereferByMemberID(int deletereferByMemberID) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Refer By'),
          content: const Text(
              'Are you sure you would like to delete the selected member refer by?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                deletereferByMemberIDFromAPI(deletereferByMemberID);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletereferByMemberIDFromAPI(int deletereferByMemberID) async {
    var headers = {'token': token};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$deletereferByMemberID/referral/delete'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      print(response.reasonPhrase);
    }
  }

  void updateData() {
    setState(() {});
  }
}
