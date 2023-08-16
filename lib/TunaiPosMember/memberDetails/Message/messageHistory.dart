// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';

class MessageHistory extends StatefulWidget {
  const MessageHistory({super.key});

  @override
  State<MessageHistory> createState() => _MessageHistoryState();
}

class _MessageHistoryState extends State<MessageHistory> {
  List<dynamic> message = [];
  List<dynamic> days = [];

  Future<void> getMessage() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/18600771/messages'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      message = [];
      days = [];
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> responseBody = body;
      message = responseBody['messages'];

      if (message.isNotEmpty) {
        DateTime currentDate = DateTime.now();
        message.sort((a, b) {
          int timestampA = a['createDate'];
          int timestampB = b['createDate'];
          DateTime createDateA =
              DateTime.fromMillisecondsSinceEpoch(timestampA * 1000);
          DateTime createDateB =
              DateTime.fromMillisecondsSinceEpoch(timestampB * 1000);
          return createDateB.compareTo(createDateA);
        });

        List<dynamic> filteredMessage = message.where((item) {
          int createTimestamp = item['createDate'];
          DateTime createDate =
              DateTime.fromMillisecondsSinceEpoch(createTimestamp * 1000);
          Duration difference = currentDate.difference(createDate);
          return difference.inDays < 30;
        }).toList();

        days.addAll(filteredMessage);
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
                'Message History',
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
              actions: const [
                // Padding(
                //   padding: const EdgeInsets.only(right: 5),
                //   child: IconButton(
                //     onPressed: () {
                //       showModalBottomSheet<dynamic>(
                //         enableDrag: false,
                //         barrierColor: Colors.transparent,
                //         isScrollControlled: true,
                //         context: context,
                //         shape: const RoundedRectangleBorder(
                //             borderRadius: BorderRadius.vertical(
                //           top: Radius.circular(20),
                //         )),
                //         builder: (BuildContext context) {
                //           return Container(
                //               height:
                //                   MediaQuery.of(context).size.height * 2.65 / 3,
                //               child: AddMessage());
                //         },
                //       );
                //     },
                //     icon: Icon(Icons.add),
                //     color: Color(0xFF1276ff),
                //     iconSize: 35,
                //   ),
                // ),
              ],
            ),
            body: FutureBuilder(
                future: getMessage(),
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
                              padding:
                                  EdgeInsets.only(left: 15, right: 10),
                              child: Text('Recent Message'),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: TabBarView(
                                  children: [get30days(), getAll()],
                                ),
                              ),
                            )
                          ],
                        ));
                  }
                })));
  }

  get30days() {
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        String message = days[index]['message'];
        int receivedIndex = message.indexOf('received');
        bool containsReceived = receivedIndex != -1;

        // Add a SizedBox with a height of 15 after the word "received"
        String messageWithSizedBox = message.replaceRange(
          receivedIndex + 8, // Index after the word "received"
          receivedIndex + 8, // Index after the word "received"
          '\n${' ' * 20}', // A newline followed by 15 spaces (height 15)
        );

        int timestamp = days[index]['createDate'];
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
        int hour = dateTime.hour;
        int minute = dateTime.minute;
        String suffix = (hour >= 12) ? 'PM' : 'AM';
        hour = (hour > 12) ? hour - 12 : hour;
        String hourString = hour.toString().padLeft(2, '0');
        String minuteString = minute.toString().padLeft(2, '0');

        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    containsReceived
                        ? Text(messageWithSizedBox)
                        : Text(message),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$hourString:$minuteString $suffix, $formattedDate',
                          style:
                              const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  getAll() {
    return ListView.builder(
      itemCount: message.length,
      itemBuilder: (context, index) {
        String messages = message[index]['message'];
        int receivedIndex = messages.indexOf('received');
        bool containsReceived = receivedIndex != -1;

        // Add a SizedBox with a height of 15 after the word "received"
        String messageWithSizedBox = messages.replaceRange(
          receivedIndex + 8, // Index after the word "received"
          receivedIndex + 8, // Index after the word "received"
          '\n${' ' * 20}', // A newline followed by 15 spaces (height 15)
        );

        int timestamp = message[index]['createDate'];
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
        int hour = dateTime.hour;
        int minute = dateTime.minute;
        String suffix = (hour >= 12) ? 'PM' : 'AM';
        hour = (hour > 12) ? hour - 12 : hour;
        String hourString = hour.toString().padLeft(2, '0');
        String minuteString = minute.toString().padLeft(2, '0');

        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    containsReceived
                        ? Text(messageWithSizedBox)
                        : Text(messages),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$hourString:$minuteString $suffix, $formattedDate',
                          style:
                              const TextStyle(fontSize: 12, color: Color(0xFF333333)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
