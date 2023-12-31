import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constant/token.dart';
import 'login.dart';

class Cashier extends StatefulWidget {
  Cashier({Key? key, required this.cartOrderId, required this.inCashier});

  final String cartOrderId;
  Map<String, dynamic>? inCashier;

  @override
  State<Cashier> createState() => _CashierState();
}

class _CashierState extends State<Cashier> {
  List<dynamic> cashier = [];
  int _selectedIndex = -1;

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

  @override
  Widget build(BuildContext context) {
    selectedStaffDetails = widget.inCashier;

    print(widget.cartOrderId);

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
        leading: IconButton(
          icon: Image.asset(
            "lib/assets/Artboard 40.png",
            height: 30,
            width: 20,
          ),
          onPressed: () => Navigator.pop(context),
          iconSize: 24,
        ),
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return GridView.builder(
                                shrinkWrap: true,
                                itemCount: cashier.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        if (_selectedIndex == index) {
                                          // The same cashier is selected again, deselect it
                                          _selectedIndex = -1;
                                        } else {
                                          _selectedIndex =
                                              index; // Set the selected index
                                        }

                                        selectedStaffDetails =
                                            getSelectedStaffDetails();
                                        print(
                                            "selectedStaffDetails: $selectedStaffDetails");
                                        // printSelectedStaffDetails();
                                      });
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: _selectedIndex == index
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
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

              addCashier(selectedStaffDetails);
              Navigator.pop(
                context,
                selectedStaffDetails,
              );
            },
            child: const Text('Add'),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? getSelectedStaffDetails() {
    if (_selectedIndex == -1) {
      return null; // No cashier is selected
    }

    var cashierDetails = cashier[_selectedIndex];
    var name = cashierDetails['name'];
    var image = cashierDetails['icon'];
    var staffID = cashierDetails['staffID'];

    return {
      'selectedStaff': [
        {
          'name': name,
          'image': image,
          'staffID': staffID,
        },
      ],
    };
  }

  // void printSelectedStaffDetails() {
  //   if (_selectedIndices.isEmpty) {
  //     print('No containers selected.');
  //   } else {
  //     print('Selected staff details:');
  //     for (int index in _selectedIndices) {
  //       var cashierDetails = cashier[index];
  //       var name = cashierDetails['name'];
  //       var image = cashierDetails['icon'];
  //       var staffID = cashierDetails['staffID'];

  //       print('Name: $name staffID: $staffID Image: $image ');
  //     }
  //   }
  // }

  Future getStaff() async {
    var headers = {
      'token': token,
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
        if (staff['cashier']['isCashier'] == 1 && staff['deleteDate'] == 0) {
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
      return; 
    }

    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request = http.Request(
      'POST',
      Uri.parse(
          'https://order.tunai.io/loyalty/orders/${widget.cartOrderId}/cashier/create'),
    );

    String staffID =
        selectedStaffDetails['selectedStaff'][0]['staffID'].toString();
    if (staffID == null) {
      print('No staffID found in selectedStaffDetails.');
      return;
    }

    print('staffID: $staffID'); 

    request.bodyFields = {'staffID': staffID};
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("dah add cashier");
    } else {
      print(response.reasonPhrase);
    }
  }
}
