import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/pending.dart';
import '../api.dart';
import '../cart.dart';
import '../function.dart';
import 'discount.dart';

class TestSelectStaff extends StatefulWidget {
  const TestSelectStaff(
      {Key? key,
      required this.cartOrderId,
      required this.staff,
      required this.otems});

  final String cartOrderId;

  final List<dynamic> otems;
  final List<dynamic> staff;

  @override
  State<TestSelectStaff> createState() => _TestSelectStaffState();
}

class _TestSelectStaffState extends State<TestSelectStaff> {
  Set<int> _selectedIndices = Set<int>();

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

  List<dynamic> simpanStaff = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          title: const Text(
            'Select Staff',
            style: TextStyle(color: Colors.black),
          ),
          leading: xIcon(),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[200],
            ),
            Column(
              children: [hi()],
            ),
          ],
        ),
        bottomNavigationBar: addButton());
  }

  Widget xIcon() {
    return IconButton(
      icon: Image.asset(
        "lib/assets/Artboard 40.png",
        height: 30,
        width: 20,
      ),
      onPressed: () => Navigator.pop(context),
      iconSize: 24,
    );
  }

  Widget hi() {
    print("masuk balik: $selectedStaffDetails");
    Future staffData = APIFunctions.getStaff();
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Staff list',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: staffData,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: staff.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.5,
                      ),
                      itemBuilder: (context, index) {
                        var staffDetails = staff[index];
                        var name = staffDetails['name'];
                        String mobileNumber = staffDetails['mobile'].toString();
                        String formattedNumber =
                            '(${mobileNumber.substring(0, 4)}) ${mobileNumber.substring(4, 7)}-${mobileNumber.substring(7)}';

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedIndices.contains(index)) {
                                _selectedIndices.remove(index);
                              } else {
                                _selectedIndices.add(index);
                              }
                              selectedStaffDetails = getStaffDetails();
                              printSelectedStaffDetails();
                            });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: _selectedIndices.contains(index)
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image(
                                    image: NetworkImage(staff[index]['icon']),
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          formattedNumber,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Map<String, dynamic>? getStaffDetails() {
    if (_selectedIndices.isEmpty) {
      return null;
    }
    List< dynamic> selectedDetails = [];
    for (int index in _selectedIndices) {
      var staffDetails = staff[index];
      var name = staffDetails['name'];
      var image = staffDetails['icon'];
      var staffID = staffDetails['staffID'];
      selectedDetails.add({
        'name': name,
        'image': image,
        'staffID': staffID,
      });
    }
    return {
      'selectedStaff': selectedDetails,
    };
  }

  void printSelectedStaffDetails() {
    if (_selectedIndices.isEmpty) {
      print('No containers selected.');
    } else {
      print('Selected staff details:');
      for (int index in _selectedIndices) {
        var staffDetails = staff[index];
        var name = staffDetails['name'];
        var image = staffDetails['icon'];
        var staffID = staffDetails['staffID'];

        print('Name: $name staffID: $staffID Image: $image ');
      }
    }
  }

  Widget addButton() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0,
          bottom: 25.0,
        ),
        child: ElevatedButton(
          onPressed: () {
            if (_selectedIndices.isNotEmpty) {
              List<Map<String, dynamic>> selectedDetails = [];
              for (int index in _selectedIndices) {
                var staffDetails = staff[index];
                var staffID = staffDetails['staffID'];
                var name = staffDetails['name'];
                var image = staffDetails['icon'];
                selectedDetails.add({
                  'staffID': staffID,
                  'name': name,
                  'image': image,
                });
                 print("Testing select staff: $selectedDetails");
              }
              Navigator.pop(context,
                  selectedDetails); 
                // Pass the selectedDetails as the result
            } else {
              Navigator.pop(context); // If no selection, simply pop the page
            }
          },
          child: const Text('Add'),
        ),
      ),
    );
  }
}