// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../constant/token.dart';

class Staff extends StatefulWidget {
  final List<dynamic> saleStaff;
  const Staff({super.key, required this.saleStaff});

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  List<dynamic> staff = [];
  List<dynamic> availableStaff = [];
  List<Map<String, dynamic>> selectedStaffIDs = [];

  bool loadAPI = true;
  bool addStaff = false;

  Future getStaff() async {
    staff.clear();

    var headers = {'token': token};
    var request =
        http.Request('GET', Uri.parse('https://staff.tunai.io/loyalty/staff'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      availableStaff.clear();
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> staffs = body;
      staff = staffs['staffs'];

      for (int i = 0; i < staff.length; i++) {
        if (staff[i]['deleteDate'] == 0) {
          int staffID = staff[i]['staffID'];
          bool found =
              false; // Flag to check if staffID is found in widget.saleStaff
          for (int j = 0; j < widget.saleStaff.length; j++) {
            if (staffID == widget.saleStaff[j]['staffID']) {
              found = true;
              break; // No need to continue the inner loop if staffID is found
            }
          }
          if (!found) {
            availableStaff.add(staff[i]);
          }
        }
      }
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
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Staff',
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
              },
            ),
          ),
        ),
        actions: addStaff
            ? [
                TextButton(
                  onPressed: () {
                    List<Map<String, dynamic>> copiedSelectedStaffIDs =
                        List.from(selectedStaffIDs);
                    for (final staff in copiedSelectedStaffIDs) {
                      widget.saleStaff.add(staff);
                    }
                    setState(() {
                      Navigator.pop(context, widget.saleStaff);
                      addStaff =
                          false; // Set doneUpdate to false to hide the button
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1175fc),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: FutureBuilder(
          future: loadAPI ? getStaff() : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                  width: double.infinity,
                  color: const Color(0xFFf3f2f8),
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 10, right: 10),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Select staff'),
                                      const SizedBox(height: 10),
                                      GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                2, // Number of colors per row
                                            childAspectRatio: aspectRatio,
                                            crossAxisSpacing:
                                                10, // Gap between the columns
                                            mainAxisSpacing:
                                                10, // Gap between the rows
                                          ),
                                          itemCount: availableStaff.length,
                                          itemBuilder: (context, index) {
                                            final bool isSelected =
                                                selectedStaffIDs.any((staff) =>
                                                    staff['staffID'] ==
                                                    availableStaff[index]
                                                        ['staffID']);

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  loadAPI = false;
                                                  int staffID =
                                                      availableStaff[index]
                                                          ['staffID'];
                                                  String staffName =
                                                      availableStaff[index]
                                                          ['name'];
                                                  String staffEmoji =
                                                      availableStaff[index]
                                                          ['icon'];
                                                  if (isSelected) {
                                                    selectedStaffIDs
                                                        .removeWhere((staff) =>
                                                            staff['staffID'] ==
                                                            staffID);
                                                  } else {
                                                    selectedStaffIDs.add({
                                                      'staffID': staffID,
                                                      'name': staffName,
                                                      'emoji': staffEmoji,
                                                      'hof': 0.0,
                                                      'effort': 0.0,
                                                    });
                                                  }
                                                  if (selectedStaffIDs
                                                      .isNotEmpty) {
                                                    addStaff = true;
                                                  } else {
                                                    addStaff = false;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                    color: Colors.white,
                                                    border: isSelected
                                                        ? Border.all(
                                                            color: Colors.blue,
                                                            width: 2,
                                                          )
                                                        : null,
                                                  ),
                                                  padding: EdgeInsets.only(
                                                      left: 10, right: 10),
                                                  child: Row(
                                                    children: [
                                                      availableStaff[index]
                                                                  ['image'] !=
                                                              ''
                                                          ? CircleAvatar(
                                                              backgroundImage: NetworkImage(
                                                                  availableStaff[
                                                                          index]
                                                                      [
                                                                      'image']),
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFFf3f2f8),
                                                              radius: 30,
                                                            )
                                                          : CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      availableStaff[
                                                                              index]
                                                                          [
                                                                          'icon']),
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFFf3f2f8),
                                                              radius: 30,
                                                            ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                                child: Text(
                                                                    availableStaff[
                                                                            index]
                                                                        [
                                                                        'name'])),
                                                            Text(
                                                              '${'(' + availableStaff[index]['mobile'].substring(0, 4) + ')' + availableStaff[index]['mobile'].substring(4, 7)}-' +
                                                                  availableStaff[
                                                                              index]
                                                                          [
                                                                          'mobile']
                                                                      .substring(
                                                                          7),
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xFF878787)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })
                                    ]))));
                  }));
            }
          }),
    );
  }
}
