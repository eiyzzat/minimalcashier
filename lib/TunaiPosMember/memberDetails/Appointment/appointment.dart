// ignore_for_file: avoid_function_literals_in_foreach_calls, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';


class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  Map<String, List<dynamic>> upComingGroup = {};
  Map<String, List<dynamic>> pastGroup = {};

  List<dynamic> upComing = [];
  List<dynamic> past = [];
  List<dynamic> combineToday = [];
  List<dynamic> combineUpcoming = [];
  List<dynamic> combinePast = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool isLoading = true;

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    await getAppointmentToday();
    await getAppointmentUpcoming();
    await getAppointmentPast();
    getGroup();

    setState(() {
      isLoading = false;
    });
  }

  Future getAppointmentToday() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/books?type=today'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> books = [];
      List<dynamic> skus = [];
      List<dynamic> members = [];
      List<dynamic> staffs = [];
      List<dynamic> colors = [];

      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> today = body;

      books = today['books'];
      skus = today['skus'];
      members = today['members'];
      staffs = today['staffs'];
      colors = today['colors'];

      for (int i = 0; i < books.length; i++) {
        combineToday.add(books[i]);
        for (int j = 0; j < skus.length; j++) {
          if (skus[j]['skuID'] == books[i]['skuID']) {
            combineToday.last['itemName'] = skus[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < members.length; j++) {
          if (members[j]['memberID'] == books[i]['memberID']) {
            combineToday.last['memberName'] = members[j]['name'];
            combineToday.last['memberMobile'] = members[j]['mobile'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < staffs.length; j++) {
          if (staffs[j]['staffID'] == books[i]['staffID']) {
            combineToday.last['staffName'] = staffs[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < colors.length; j++) {
          if (colors[j]['colorID'] == books[i]['colorID']) {
            combineToday.last['colorHex'] = colors[j]['hex'];
            break; // Exit the loop once a match is found
          }
        }
      }
      for (int i = 0; i < combineToday.length; i++) {
        if (combineToday[i]['completedDate'] == 0) {
          upComing.add(combineToday[i]);
        } else {
          past.add(combineToday[i]);
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getAppointmentUpcoming() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/books?type=future'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> books = [];
      List<dynamic> skus = [];
      List<dynamic> members = [];
      List<dynamic> staffs = [];
      List<dynamic> colors = [];

      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> upcoming = body;

      books = upcoming['books'];
      skus = upcoming['skus'];
      members = upcoming['members'];
      staffs = upcoming['staffs'];
      colors = upcoming['colors'];

      for (int i = 0; i < books.length; i++) {
        combineUpcoming.add(books[i]);
        for (int j = 0; j < skus.length; j++) {
          if (skus[j]['skuID'] == books[i]['skuID']) {
            combineUpcoming.last['itemName'] = skus[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < members.length; j++) {
          if (members[j]['memberID'] == books[i]['memberID']) {
            combineUpcoming.last['memberName'] = members[j]['name'];
            combineUpcoming.last['memberMobile'] = members[j]['mobile'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < staffs.length; j++) {
          if (staffs[j]['staffID'] == books[i]['staffID']) {
            combineUpcoming.last['staffName'] = staffs[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < colors.length; j++) {
          if (colors[j]['colorID'] == books[i]['colorID']) {
            combineUpcoming.last['colorHex'] = colors[j]['hex'];
            break; // Exit the loop once a match is found
          }
        }
      }
      for (int i = 0; i < combineUpcoming.length; i++) {
        if (combineUpcoming[i]['completedDate'] == 0) {
          upComing.add(combineUpcoming[i]);
        } else {
          past.add(combineUpcoming[i]);
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getAppointmentPast() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/books?type=past'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      List<dynamic> books = [];
      List<dynamic> skus = [];
      List<dynamic> members = [];
      List<dynamic> staffs = [];
      List<dynamic> colors = [];

      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> pasts = body;

      books = pasts['books'];
      skus = pasts['skus'];
      members = pasts['members'];
      staffs = pasts['staffs'];
      colors = pasts['colors'];

      for (int i = 0; i < books.length; i++) {
        combinePast.add(books[i]);
        for (int j = 0; j < skus.length; j++) {
          if (skus[j]['skuID'] == books[i]['skuID']) {
            combinePast.last['itemName'] = skus[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < members.length; j++) {
          if (members[j]['memberID'] == books[i]['memberID']) {
            combinePast.last['memberName'] = members[j]['name'];
            combinePast.last['memberMobile'] = members[j]['mobile'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < staffs.length; j++) {
          if (staffs[j]['staffID'] == books[i]['staffID']) {
            combinePast.last['staffName'] = staffs[j]['name'];
            break; // Exit the loop once a match is found
          }
        }
        for (int j = 0; j < colors.length; j++) {
          if (colors[j]['colorID'] == books[i]['colorID']) {
            combinePast.last['colorHex'] = colors[j]['hex'];
            break; // Exit the loop once a match is found
          }
        }
      }
      setState(() {
        past = List.from(combinePast); // Assign combinePast to past
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  getGroup() {
    upComing.forEach((item) {
      int createDateTimestamp = item['arrivalDate'];

      DateTime createDate =
          DateTime.fromMillisecondsSinceEpoch(createDateTimestamp * 1000);
      String formattedCreateDate = DateFormat('dd-MM-yyyy').format(createDate);

      if (!upComingGroup.containsKey(formattedCreateDate)) {
        upComingGroup[formattedCreateDate] = [];
      }
      upComingGroup[formattedCreateDate]!.add(item);
    });

    past.forEach((item) {
      int createDateTimestamp = item['arrivalDate'];

      DateTime createDate =
          DateTime.fromMillisecondsSinceEpoch(createDateTimestamp * 1000);
      String formattedCreateDate = DateFormat('dd-MM-yyyy').format(createDate);

      if (!pastGroup.containsKey(formattedCreateDate)) {
        pastGroup[formattedCreateDate] = [];
      }
      pastGroup[formattedCreateDate]!.add(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              )),
              centerTitle: true,
              title: const Text(
                'Appointment',
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
                color: const Color(0xFFf3f2f8),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 15, bottom: 10),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(235, 235, 235, 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TabBar(
                              labelPadding:
                                  EdgeInsets.zero, // Adjust the padding here
                              indicator: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0)),
                              labelColor: const Color(0xFF1276ff),
                              unselectedLabelColor:
                                  const Color.fromRGBO(170, 170, 170, 1.0),
                              tabs: const [
                                Tab(
                                  text: 'Upcoming',
                                ),
                                Tab(
                                  text: 'Past',
                                ),
                              ]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [getUpcoming(), getPast()],
                      ),
                    )
                  ],
                ))));
  }

  Widget getUpcoming() {
    return getDesign(upComingGroup);
  }

  Widget getPast() {
    final pastSortedGroup = Map.fromEntries(pastGroup.entries.toList()
      ..sort((a, b) {
        final List<dynamic> itemsA = a.value;
        final List<dynamic> itemsB = b.value;

        // Sort the service items by salesDate in descending order
        itemsA.sort((a, b) => b['arrivalDate'].compareTo(a['arrivalDate']));
        itemsB.sort((a, b) => b['arrivalDate'].compareTo(a['arrivalDate']));

        final int latestDateA =
            itemsA.isNotEmpty ? itemsA.first['arrivalDate'] : 0;
        final int latestDateB =
            itemsB.isNotEmpty ? itemsB.first['arrivalDate'] : 0;

        return latestDateB.compareTo(latestDateA);
      }));

    return getDesign(pastSortedGroup);
  }

  getDesign(Map<String, List<dynamic>> listGroup) {
    return ListView(
            children: listGroup.entries.map((entry) {
              final String date = entry.key;
              final List<dynamic> items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 5, top: 10),
                    child: Text(
                      date,
                      style: const TextStyle(color: Color(0xFF8a8a8a)),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      // Build and return a widget for each item in the list
                      final item = items[index];

                      // Extract the time from the Unix timestamp
                      final arrivalTimestamp = item['arrivalDate'];
                      final arrivalDate = DateTime.fromMillisecondsSinceEpoch(
                          arrivalTimestamp * 1000);
                      final formattedTime =
                          DateFormat('hh:mm a').format(arrivalDate);

                      final duration = item['duration']; // Duration in minutes
                      final endTime =
                          arrivalDate.add(Duration(minutes: duration));
                      final formattedEndTime =
                          DateFormat('hh:mm a').format(endTime);
                      String colorHex =
                          item['colorHex'].toString().replaceAll('#', '');
                      Color color = Color(int.parse('0xFF$colorHex'));

                      return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            updateAppointmentBottomSheet(context, item, date,
                                formattedTime, formattedEndTime, color),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
  }

  GestureDetector updateAppointmentBottomSheet(BuildContext context, item,
      String date, String formattedTime, String formattedEndTime, Color color) {
    return GestureDetector(
      onTap: () {
        // showModalBottomSheet<dynamic>(
        //   enableDrag: false,
        //   barrierColor: Colors.transparent,
        //   isScrollControlled: true,
        //   context: context,
        //   shape: const RoundedRectangleBorder(
        //       borderRadius: BorderRadius.vertical(
        //     top: Radius.circular(20),
        //   )),
        //   builder: (BuildContext context) {
        //     return Container(
        //         height: MediaQuery.of(context).size.height * 2.65 / 3,
        //         child: UpdateAppointment(
        //             memberName: item['memberName'],
        //             memberMobile: item['memberMobile'],
        //             date: date,
        //             itemName: item['itemName'],
        //             formattedTime: formattedTime,
        //             formattedEndTime: formattedEndTime,
        //             duration: item['duration'],
        //             staffName: item['staffName'],
        //             remarks: item['remarks']));
        //   },
        // );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: color,
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            // Other decoration properties
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$formattedTime - $formattedEndTime'),
                const SizedBox(
                  height: 5,
                ),
                Text(item['itemName']),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(item['staffName']),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
