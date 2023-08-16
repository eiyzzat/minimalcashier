// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class AddReferrer extends StatefulWidget {
  final VoidCallback updateData;
  const AddReferrer({super.key, required this.updateData});

  @override
  State<AddReferrer> createState() => _AddReferrerState();
}

class _AddReferrerState extends State<AddReferrer> {
  List<dynamic> member = [];
  List<dynamic> memberdelete0 = [];
  List<dynamic> queriedList = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadApi();
  }

  loadApi() async {
    await getMember();
    setState(() {
      queriedList = memberdelete0;
    });
  }

  Future getMember() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET', Uri.parse('https://member.tunai.io/cashregister/member'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      memberdelete0 = [];
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> members = body;

      member = members['members'];

      for (int i = 0; i < member.length; i++) {
        if (member[i]['deleteDate'] == 0) {
          memberdelete0.add(member[i]);
        }
      }
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
          title: Text(
            'Add Referrer',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Transform.scale(
              scale: 1.4,
              child: CloseButton(
                color: Color(0xFF1276ff),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: FutureBuilder(builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Container(
              color: Color(0xFFf3f2f8),
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 10, bottom: 0),
                    child: Center(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFebebeb),
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search',
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: searchMember,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 20),
                      child: ListView.builder(
                        itemCount: queriedList.length,
                        itemBuilder: (context, index) {
                          String mobile = '(' +
                              queriedList[index]['mobile'].substring(0, 4) +
                              ') ' +
                              queriedList[index]['mobile'].substring(4, 7) +
                              '-' +
                              queriedList[index]['mobile'].substring(7);
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  int memberID = queriedList[index]['memberID'];
                                  getAddRefferer(memberID);
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        queriedList[index]['icon'] != ''
                                            ? CircleAvatar(
                                                backgroundColor:
                                                    Color(0xFFf3f2f8),
                                                backgroundImage: NetworkImage(
                                                    queriedList[index]['icon']),
                                                radius: 25,
                                              )
                                            : CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                radius: 25),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                queriedList[index]['name'] != ''
                                                    ? queriedList[index]['name']
                                                    : mobile,
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(mobile)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }));
  }

  void searchMember(String query) {
    List<dynamic> suggestion;

    if (query.isEmpty) {
      suggestion = memberdelete0;
    } else {
      suggestion = queriedList.where((element) {
        List<String> nameParts = element['name'].toString().split(' ');
        bool nameMatch = false;
        for (int i = 0; i < nameParts.length; i++) {
          String namePart = nameParts[i].toLowerCase();
          if (namePart.startsWith(query) || namePart.endsWith(query)) {
            nameMatch = true;
            break;
          }
        }
        bool mobileMatch =
            element['mobile'].toString().toLowerCase().contains(query) ||
                element['mobile'].toString().toLowerCase().endsWith(query);
        return nameMatch || mobileMatch;
      }).toList();
    }

    setState(() {
      queriedList = suggestion;
    });
  }

  Future<void> getAddRefferer(int memberID) async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST',
        Uri.parse('https://member.tunai.io/cashregister/members/' +
            memberIDglobal +
            '/referral'));
    request.bodyFields = {'referByMemberID': memberID.toString()};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      widget.updateData();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      print(response.reasonPhrase);
    }
  }
}
