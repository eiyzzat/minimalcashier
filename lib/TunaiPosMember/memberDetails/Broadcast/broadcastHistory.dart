// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class BroadcastHistory extends StatefulWidget {
  const BroadcastHistory({super.key});

  @override
  State<BroadcastHistory> createState() => _BroadcastHistoryState();
}

class _BroadcastHistoryState extends State<BroadcastHistory> {
  List<dynamic> bcast = [];
  List<dynamic> days = [];
  
  bool loadAPI = true;

  Future getBroadcast() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/mcasts'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      bcast = [];
      days = [];
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> bcasts = body;
      bcast = bcasts['bcasts'];

      if (bcast.isNotEmpty) {
        DateTime currentDate = DateTime.now();

        // Sort the bcast list based on the postedDate in descending order
        bcast.sort((a, b) {
          int timestampA = a['postedDate'];
          int timestampB = b['postedDate'];
          DateTime postedDateA =
              DateTime.fromMillisecondsSinceEpoch(timestampA * 1000);
          DateTime postedDateB =
              DateTime.fromMillisecondsSinceEpoch(timestampB * 1000);
          return postedDateB.compareTo(postedDateA); // Compare in reverse order
        });

        // Filter the bcast items that are less than 30 days from the current date
        List<dynamic> filteredBcast = bcast.where((item) {
          int postedTimestamp = item['postedDate'];
          DateTime postedDate =
              DateTime.fromMillisecondsSinceEpoch(postedTimestamp * 1000);
          Duration difference = currentDate.difference(postedDate);
          return difference.inDays < 30;
        }).toList();

        // Add the filtered bcast items to the days list
        days.addAll(filteredBcast);
      }
    } else {
      print(response.reasonPhrase);
    }
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
              'Broadcast History',
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
          body: FutureBuilder(
              future: loadAPI ? getBroadcast() : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container(
                      color: const Color(0xFFf3f2f8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    indicator: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    labelColor: const Color(0xFF1276ff),
                                    unselectedLabelColor:
                                        const Color.fromRGBO(170, 170, 170, 1.0),
                                    tabs: const [
                                      Tab(
                                        text: '<30 days',
                                      ),
                                      Tab(
                                        text: 'All',
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 15, right: 10),
                            child: Text('Recent broadcast'),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: TabBarView(
                                children: [getDesign(days), getDesign(bcast)],
                              ),
                            ),
                          )
                        ],
                      ));
                }
              })),
    );
  }

  getDesign(List<dynamic> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        int timestamp = list[index]['postedDate'];
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
        int hour = dateTime.hour;
        int minute = dateTime.minute;
        String suffix = (hour >= 12) ? 'PM' : 'AM';
        hour = (hour > 12) ? hour - 12 : hour;
        String hourString = hour.toString().padLeft(2, '0');
        String minuteString = minute.toString().padLeft(2, '0');

        bool showFullCaption = list[index]['showFullCaption'] ?? false;

        // Inside the itemBuilder function
        final fullCaptionTextWidget = Text(
          list[index]['caption'],
          style: const TextStyle(fontSize: 14),
        );
        final textPainter = TextPainter(
          text: TextSpan(
              text: list[index]['caption'], style: const TextStyle(fontSize: 14)),
          textDirection: Directionality.of(
              context), // Pass the textDirection from the context
        );
        textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 95);
        double fullCaptionHeight = textPainter.size.height;

        return Dismissible(
          key: Key(list[index]['bcastID']
              .toString()), // Use a unique key for each item
          background: Container(
            color: Colors.red,
            child:  Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onDismissed: (direction) {
            // Remove the item from the 'days' list when swiped to delete
            setState(() {
              list.removeAt(index);
            });
            // You can also perform any additional actions here, such as deleting the item from the API/database
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          list[index]['image'],
                          scale: 7,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list[index]['topic'],
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$hourString:$minuteString $suffix, $formattedDate',
                              ),
                              const SizedBox(height: 20),
                              showFullCaption
                                  ? Text(
                                      list[index]['caption'],
                                      style:
                                          const TextStyle(color: Color(0xFFc6c6c6)),
                                    )
                                  : Text(
                                      list[index]['caption'],
                                      style:
                                          const TextStyle(color: Color(0xFFc6c6c6)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              const SizedBox(
                                height: 5,
                              ),
                              if (fullCaptionHeight >
                                  2 * fullCaptionTextWidget.style!.fontSize!)
                                InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        showFullCaption
                                            ? "View less"
                                            : "View more",
                                        style: const TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      loadAPI = false;
                                      bcast[index]['showFullCaption'] =
                                          !showFullCaption;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
