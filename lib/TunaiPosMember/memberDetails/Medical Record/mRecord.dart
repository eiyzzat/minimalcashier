import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../../textFormating.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class MedicalRecord extends StatefulWidget {
  const MedicalRecord({super.key});

  @override
  State<MedicalRecord> createState() => _MedicalRecordState();
}

class _MedicalRecordState extends State<MedicalRecord> {
  List<dynamic> mRecord = [];

  Future getMedicalRecord() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/mrecords'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> mRecords = body;

      mRecord = mRecords['mrecords'];
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 200.0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        )),
        centerTitle: true,
        title: const Text(
          'Medical Record',
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
          child: FutureBuilder(
              future: getMedicalRecord(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (mRecord.isNotEmpty) {
                  return ListView.builder(
                      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                      itemCount: mRecord.length,
                      itemBuilder: (context, index) {
                        List<dynamic> mTag = mRecord[index]['mtag'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(mRecord[index]['title']),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (mRecord[index]['note'] != '')
                                    Text(
                                      mRecord[index]['note'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (mRecord[index]['note'] != '')
                                    SizedBox(
                                      height: 5,
                                    ),
                                  GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          5, // Number of colors per row
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing:
                                          10, // Gap between the columns
                                      mainAxisSpacing:
                                          10, // Gap between the rows
                                    ),
                                    itemCount: mTag.length,
                                    itemBuilder:
                                        (BuildContext context, int tagIndex) {
                                      String tag = mTag[tagIndex]['tag'];

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Color(0xFFf2f1f6),
                                        ),
                                        child: Center(
                                            child: Text(
                                          tag,
                                          style: TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      '${formatTimeText(mRecord[index]['sealDate'])}, ${formatDateText(mRecord[index]['sealDate'])}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        );
                      });
                } else {
                  return Container(
                    color: const Color(0xFFf3f2f8),
                    width: double.infinity,
                    child:  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No Medical Record yet!',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
              })),
    );
  }
}
