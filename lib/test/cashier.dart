import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/testingSelectStaff.dart';
import '../api.dart';
import 'login.dart';

class Cashier extends StatefulWidget {
   Cashier({Key? key, 
  required this.cartOrderId,
  required this.inCashier});

  final String cartOrderId;
  Map<String, dynamic>? inCashier;

  @override
  State<Cashier> createState() => _CashierState();
}

class _CashierState extends State<Cashier> {
  List<dynamic> cashier = [];
  Set<int> _selectedIndices = Set<int>();

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

  @override
  Widget build(BuildContext context) {

    selectedStaffDetails = widget.inCashier;
    
    print("masuk: $selectedStaffDetails");
    print("select");
    print(selectedStaffDetails);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        title: const Text(
          'Select Cashier',
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
            children: [
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Cashier list',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: getStaff(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: cashier.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 2.5,
                                ),
                                itemBuilder: (context, index) {
                                  var cashierDetails = cashier[index];
                                  var name = cashierDetails['name'];
                                  String mobileNumber =
                                      cashierDetails['mobile'].toString();
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
                                        selectedStaffDetails =
                                            getSelectedStaffDetails();
                                        printSelectedStaffDetails();
                                      });
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color:
                                              _selectedIndices.contains(index)
                                                  ? Colors.blue
                                                  : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image(
                                              image: NetworkImage(
                                                  cashier[index]['icon']),
                                              width: 25,
                                              height: 25,
                                            ),
                                            SizedBox(width: 8),
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    formattedNumber,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
              print("dalam cashier: $selectedStaffDetails");
              // print("dalam cashier: ${selectedStaffDetails!['selectedStaff'][0]}");
              addCashier(selectedStaffDetails);
              Navigator.pop(context, selectedStaffDetails, );
            },
            child: const Text('Add'),
          ),
        ),
      ),
    );
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

  Map<String, dynamic>? getSelectedStaffDetails() {
    if (_selectedIndices.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> selectedDetails = [];
    for (int index in _selectedIndices) {
      var cashierDetails = cashier[index];
      var name = cashierDetails['name'];
      var image = cashierDetails['icon'];
      var staffID = cashierDetails['staffID'];
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
        var cashierDetails = cashier[index];
        var name = cashierDetails['name'];
        var image = cashierDetails['icon'];
        var staffID = cashierDetails['staffID'];

        print('Name: $name staffID: $staffID Image: $image ');
      }
    }
  }

  Future getStaff() async {
    var headers = {
      'token': tokenGlobal,
    };

    var request =
        http.Request('GET', Uri.parse('https://staff.tunai.io/loyalty/staff'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      //message untuk save data dalam
      Map<String, dynamic> minimal = body;

      for (var staff in minimal['staffs']) {
        if (staff['cashier']['isCashier'] == 1) {
          var cashierData = {
            'staffID': staff['staffID'],
            'name': staff['name'],
            'mobile': staff['mobile'],
            'image': staff['image'],
            'icon': staff['icon'],
          };
          cashier.add(cashierData);
        }
      }
      return cashier;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> addCashier(Map<String, dynamic>? selectedStaffDetails) async {
    if (selectedStaffDetails == null || selectedStaffDetails.isEmpty) {
      print('selectedStaffDetails is null or empty');
      return; // or handle the case accordingly
    }

    if (selectedStaffDetails['selectedStaff'][0] == null ||
        selectedStaffDetails['selectedStaff'][0]['staffID'] == null) {
      print('Invalid staffID in selectedStaffDetails');
      return; // or handle the case accordingly
    }

    var headers = {
      'token': tokenGlobal,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/orders/${widget.cartOrderId}/cashier/create'));

    var staffID = selectedStaffDetails['selectedStaff'][0]['staffID'];
    var staffIDString = staffID.toString();

    request.bodyFields = {'staffID': staffIDString};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(staffIDString);
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("dah add cashier");
    } else {
      print(response.reasonPhrase);
    }
  }
}
