// ignore_for_file: sized_box_for_whitespace, avoid_print
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Function/generalFunction.dart';
import '../Function/memberDetails.dart';
import '../../../constant/token.dart';
import '../responsiveMember/mobile_scaffold.dart';
import 'Appointment/appointment.dart';
import 'Broadcast/broadcastHistory.dart';
import 'Car/car.dart';
import 'Credit/credit.dart';
import 'Medical Record/mRecord.dart';
import 'Message/messageHistory.dart';
import 'Outstanding/outstanding.dart';
import 'Points/point.dart';
import 'Recent/recent.dart';
import 'Referral/referral.dart';
import 'Remarks/remarks.dart';
import 'Sales/sales.dart';
import 'Voucher/voucher.dart';
import 'checklist.dart';
import 'notes.dart';
import 'photos.dart';
import 'profile.dart';

class MemberDetails extends StatefulWidget {
  final VoidCallback updateData;
  const MemberDetails({super.key, required this.updateData});

  @override
  State<MemberDetails> createState() => _MemberDetailsState();
}

class _MemberDetailsState extends State<MemberDetails> {
  List<dynamic> member = [];
  List<dynamic> sales = [];
  List<dynamic> recent = [];

  int totVoucher = 0;
  int totPoint = 0;

  double totCredit = 0;
  double totOutstanding = 0;

  String recentName = '';

  @override
  void initState() {
    super.initState();
    getInformation();
  }

  Future getInformation() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET', Uri.parse('https://member.tunai.io/cashregister/member'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      List<dynamic> member = text['members'];

      for (int i = 0; i < member.length; i++) {
        if (int.parse(memberIDglobal) == member[i]['memberID']) {
          setState(() {
            memberNameDetails = member[i]['name'];
            memberMobile = member[i]['mobile'];
          });
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getMemberDetails() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/detail'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      Map<String, dynamic> member1 = text;

      member = member1['members'];

      return member;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getMemberSales() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/sales'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      Map<String, dynamic> member1 = text;

      sales = member1['sales'];

      return sales;
    } else {
      print(response.reasonPhrase);
    }
    print(sales);
  }

  Future getRecentSales() async {
    List<dynamic> completeds = [];
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/completed'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      Map<String, dynamic> member1 = text;

      recent = member1['skus'];
      completeds = member1['completeds'];

      for (int i = 0; i < recent.length; i++) {
        if (recent[i]['skuID'] == completeds.last['skuID']) {
          recentName = recent[i]['name'];
        }
      }
      return recent;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getTotalCredit() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/summary/credits'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      totCredit = text["total"].toDouble();
      return totCredit;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getTotalPoint() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/summary/points'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      totPoint = text["total"];
      return totPoint;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getTotalVoucher() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/summary/total/vouchers'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      totVoucher = text["total"];
      return totVoucher;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getTotalOutstanding() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/summary/outstandings'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      totOutstanding = text["total"].toDouble();
      return totOutstanding;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            widget.updateData();
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
            size: 30,
          ),
        ),
        elevation: 1,
        centerTitle: true,
        title: memberNameDetails == ''
            ? Text(
                '(${memberMobile.substring(0, 4)})${memberMobile.substring(4, 7)}-${memberMobile.substring(7)}',
                style: const TextStyle(color: Colors.black),
              )
            : Text(
                memberNameDetails,
                style: const TextStyle(color: Colors.black),
              ),
      ),
      body: FutureBuilder(
          future: getMemberDetails(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('');
            } else {
              return Container(
                color: const Color(0xFFf3f2f8),
                child: ListView.builder(
                    itemCount: member.length,
                    itemBuilder: (context, index) {
                      //memberNameDetails = member[index]['name'];
                      return Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Member details',
                                  style: TextStyle(color: Color(0xFF878787)),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Profile.png',
                                  'Profile',
                                  (context) => Profile(updateData: updateData),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Photo.png',
                                  'Gallery',
                                  (context) => const Photos(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Remarks.png',
                                  'Remarks',
                                  (context) => const Remark(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Notes.png',
                                  'Notes',
                                  (context) => const Notes(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Checklist.png',
                                  'Check List',
                                  (context) => const CheckList(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Car.png',
                                  'Car',
                                  (context) => const Car(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Available',
                                  style: TextStyle(color: Color(0xFF878787)),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Credit.png',
                                  'Credit',
                                  (context) => const Credit(),
                                  additionalChild: getTotCredit(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Pt.png',
                                  'Point',
                                  (context) => const Point(),
                                  additionalChild: getTotPoint(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Voucher 2.png',
                                  'Voucher',
                                  (context) => const Voucher(),
                                  additionalChild: getTotVoucher(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Outstanding.png',
                                  'Outstanding',
                                  (context) => const Outstanding(),
                                  additionalChild: getTotOutstanding(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'History',
                                  style: TextStyle(color: Color(0xFF878787)),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Recent.png',
                                  'Recent',
                                  (context) => const Recent(),
                                  additionalChild: getRecent(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Sales.png',
                                  'Sales',
                                  (context) => const Sales(),
                                  additionalChild: getSales(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Appt.png',
                                  'Appointment',
                                  (context) => const Appointment(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Broadcast.png',
                                  'Broadcast',
                                  (context) => const BroadcastHistory(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Message 2.png',
                                  'Message',
                                  (context) => const MessageHistory(),
                                ),
                                const SizedBox(width: 10),
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Referral.png',
                                  'Referral',
                                  (context) => const Referral(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              children: [
                                memberDetailsContainerDesign(
                                  context,
                                  'icons/Appt.png',
                                  'Medical Record',
                                  (context) => const MedicalRecord(),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    }),
              );
            }
          }),
    );
  }
  getTotCredit() {
    return FutureBuilder(
        future: getTotalCredit(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (totCredit == 0) {
            return const Text(
              'Credit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  formatAmount(totCredit).toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ));
          }
        });
  }

  getTotPoint() {
    return FutureBuilder(
        future: getTotalPoint(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (totPoint == 0) {
            return const Text(
              'Point',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  '$totPoint pt',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ));
          }
        });
  }

  getTotVoucher() {
    return FutureBuilder(
        future: getTotalVoucher(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (totVoucher == 0) {
            return const Text(
              'Voucher',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  totVoucher.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ));
          }
        });
  }

  getTotOutstanding() {
    return FutureBuilder(
        future: getTotalOutstanding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (totOutstanding == 0) {
            return const Text(
              'Outstanding',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  formatAmount(totOutstanding).toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ));
          }
        });
  }

  getRecent() {
    return FutureBuilder(
        future: getRecentSales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (recent.isEmpty) {
            return const Text(
              'Recent',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  recentName.length > 15
                      ? "${recentName.substring(0, 15)}..."
                      : recentName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                ));
          }
        });
  }

  getSales() {
    return FutureBuilder(
        future: getMemberSales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('');
          } else if (sales.isEmpty) {
            return const Text(
              'Sales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            );
          } else {
            return Container(
                height: 28,
                width: double.infinity,
                child: Text(
                  formatAmount(sales[sales.length - 1]['saleAmount'])
                      .toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ));
          }
        });
  }

  updateData() {
    setState(() {
      getInformation();
    });
  }
}
