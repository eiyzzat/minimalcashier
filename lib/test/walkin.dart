import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api.dart';
import 'addMember.dart';


class Izzaty extends StatefulWidget {
  const Izzaty({super.key});

  @override
  State<Izzaty> createState() => _IzzatyState();
}

class _IzzatyState extends State<Izzaty> {
  List<dynamic> walkin = [];

  int walkInMemberID = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * 2.67 / 3,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              )),
              centerTitle: true,
              title: Text(
                'Izzaty',
                style: TextStyle(color: Colors.black),
              ),
              elevation: 1,
              backgroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Transform.scale(
                    scale: 1.4,
                    child: CloseButton(
                        color: Color(0xFF1276ff),
                        onPressed: () {
                          Navigator.pop(context);
                        })),
              ),
            ),
            body: Container(
                width: double.infinity,
                color: Color(0xFFf3f2f8),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          Text('Izzaty'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<dynamic>(
                                    isScrollControlled: true,
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    )),
                                    builder: (BuildContext context) {
                                      return AddMember();
                                    },
                                  );
                                },
                                child: Container(
                                  color: Colors.blue,
                                  child: Text('Add Member'),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                // onTap: () {
                                //   showModalBottomSheet<dynamic>(
                                //     isScrollControlled: true,
                                //     context: context,
                                //     shape: const RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.vertical(
                                //       top: Radius.circular(20),
                                //     )),
                                //     builder: (BuildContext context) {
                                //       return CarMemberPage();
                                //     },
                                //   );
                                // },
                                child: Container(
                                  color: Colors.blue,
                                  child: Text('Member'),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  var headers = {'token': token};
                                  var request = http.Request(
                                      'GET',
                                      Uri.parse(
                                          'https://member.tunai.io/cashregister/member/walkin'));

                                  request.headers.addAll(headers);

                                  http.StreamedResponse response =
                                      await request.send();

                                  if (response.statusCode == 200) {
                                    final responsebody =
                                        await response.stream.bytesToString();
                                    var body = json.decode(responsebody);
                                    Map<String, dynamic> _walkin = body;

                                    walkin = _walkin['members'];

                                    if (walkin != null && walkin.isNotEmpty) {
                                      for (var i = 0; i < walkin.length; i++) {
                                        walkInMemberID = walkin[i]['memberID'];
                                      }
                                    }
                                  } else {
                                    print(response.reasonPhrase);
                                  }

                                  print(walkInMemberID);
                                },
                                child: Container(
                                  color: Colors.blue,
                                  child: Text('Walk-In'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  );
                }))));
  }
}
