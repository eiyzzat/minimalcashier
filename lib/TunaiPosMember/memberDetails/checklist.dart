// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../responsiveMember/mobile_scaffold.dart';

class CheckList extends StatefulWidget {
  const CheckList({super.key});

  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  Map<String, List<dynamic>> groupedChecklist = {};

  List<dynamic> checklist = [];
  List<dynamic> memberchecklist = [];
  
  bool hasChanges =
      false; // Track whether changes have been made to the checklist

  Future getChecklist() async {
    groupedChecklist = {};
    checklist = [];

    var headers = {'token': token};

    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/checklist'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> checklists = body;

      checklist = checklists['checklist'];

      if (checklist.isNotEmpty) {
        for (var i = 0; i < checklist.length; i++) {
          String category = checklist[i]['category'];
          if (!groupedChecklist.containsKey(category)) {
            groupedChecklist[category] = [];
          }

          groupedChecklist[category]!.add(checklist[i]);
        }
        return groupedChecklist;
      }
    }
    return [];
  }

  Future getMemberChecklist() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/members/$memberIDglobal/mchecklist'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> checklists = body;

      memberchecklist = checklists['mchecklists'];
    }
  }

  Future<void> updateMemberChecklist(List<dynamic> updatedChecklist) async {
    var headers = {
      'token': token,
      'Content-Type': 'application/json',
    };

    var request = http.Request(
      'POST',
      Uri.parse(
          'https://member.tunai.io/cashregister/members/$memberIDglobal/mchecklist/update'),
    );

    request.headers.addAll(headers);
    request.body = json.encode({
      "checklists": updatedChecklist,
    });

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await getMemberChecklist();
      setState(() {
        hasChanges =
            true; // Reset the flag after successfully updating the checklist
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
                    })),
          ),
          actions: [
            if (hasChanges)
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1175fc),
                    ),
                  ),
                ),
              )
          ],
          title: const Text(
            'Checklist',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: FutureBuilder(
            future: getChecklist(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return FutureBuilder(
                    future:
                        getMemberChecklist(), // Corrected line to call getMemberChecklist()
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Container(
                            color: const Color(0xFFf3f2f8),
                            width: double.infinity,
                            child: ListView.builder(
                                itemCount: groupedChecklist.length,
                                itemBuilder: (context, index) {
                                  String category =
                                      groupedChecklist.keys.toList()[index];
                                  List<dynamic> categoryItems =
                                      groupedChecklist[category]!;

                                  int totalSelected = 0;
                                  for (var i = 0;
                                      i < categoryItems.length;
                                      i++) {
                                    dynamic checklistItem = categoryItems[i];
                                    bool isSelected = memberchecklist.any(
                                      (item) =>
                                          item['category'] == category &&
                                          item['title'] ==
                                              checklistItem['title'],
                                    );
                                    if (isSelected) {
                                      totalSelected++;
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Add a header for the category
                                            Row(
                                              children: [
                                                Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '$totalSelected/${categoryItems.length}',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFFc6c6c6)),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              thickness: 1,
                                            ),
                                            // Display the checklist items for the category
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: categoryItems.length,
                                              itemBuilder: (context, index) {
                                                dynamic checklistItem =
                                                    categoryItems[index];
                                                bool isSelected =
                                                    memberchecklist.any(
                                                        (item) =>
                                                            item['category'] ==
                                                                category &&
                                                            item['title'] ==
                                                                checklistItem[
                                                                    'title']);

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      isSelected = !isSelected;
                                                      if (isSelected) {
                                                        memberchecklist.add({
                                                          'checkID':
                                                              checklistItem[
                                                                  'checkID'],
                                                        });
                                                      } else {
                                                        memberchecklist
                                                            .removeWhere((item) =>
                                                                item['category'] ==
                                                                    category &&
                                                                item['title'] ==
                                                                    checklistItem[
                                                                        'title']);
                                                      }
                                                      updateMemberChecklist(
                                                          memberchecklist);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .rectangle,
                                                            color: isSelected
                                                                ? Colors.blue
                                                                : null,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          checklistItem[
                                                              'title'],
                                                          style: TextStyle(
                                                            color: isSelected
                                                                ? Colors.black
                                                                : Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }));
                      }
                    });
              }
            }));
  }
}
