import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/pending.dart';
import 'package:minimal/testingSelectStaff.dart';
import '../function.dart';
import 'constant/token.dart';
import 'discount.dart';

//showModalBottom for edit item in each service & product
class TestingStaff extends StatefulWidget {
  const TestingStaff(
      {required this.cartOrderId,
      required this.otemOtemID,
      required this.otemSkuID,
      required this.staff,
      required this.otem,
      required this.updateRemarks,
      required this.itemData,
      required this.updateQuantity,
      required this.updateDiscount,
      Key? key});

  final String cartOrderId;
  final String otemOtemID;
  final String otemSkuID;
  final List<dynamic> otem;
  final List<dynamic> staff;
  final Map<String, dynamic> itemData;
  final Function(String, String) updateRemarks;
  final Function updateQuantity;
  final Function updateDiscount;

  @override
  State<TestingStaff> createState() => _TestingStaffState();
}

class _TestingStaffState extends State<TestingStaff> {
  TextEditingController remarksController = TextEditingController();
  TextEditingController discController = TextEditingController();

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handsOnControllers = [];
  TextEditingController effortText = TextEditingController();
  TextEditingController handsOnText = TextEditingController();
  String paid = '';

  int? selectedStaffIndex;
  Map<String, Map<String, String>> otemOrderMap = {};
  List<Map<String, dynamic>> updatedStaffDetails = [];

  //untuksimpanselectedDetails
  List<Map<String, dynamic>> selectedStaffDetails = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        centerTitle: true,
        title: const Text(
          'Edit Item',
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

  Widget hi() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Others",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Staff",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 30),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: IconButton(
                                            icon: Image.asset(
                                              "lib/assets/Plus.png",
                                              height: 20,
                                              width: 20,
                                            ),
                                            //siniiiiiiiiiiiiiii
                                            onPressed: () async {
                                              final selectedDetails =
                                                  await showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20))),
                                                      builder: (BuildContext
                                                          context) {
                                                        return SizedBox(
                                                            height: 750,
                                                            child:
                                                                TestSelectStaff(
                                                              cartOrderId: widget
                                                                  .cartOrderId,
                                                              otems:
                                                                  widget.otem,
                                                              // staff:
                                                              //     widget.staff,
                                                            ));
                                                      });
                                              if (selectedDetails != null) {
                                                setState(() {
                                                  // Add the selected details to the selectedStaffDetails list
                                                  selectedStaffDetails
                                                      .addAll(selectedDetails);
                                                  // Initialize the controllers for the newly added details
                                                  for (int i = 0;
                                                      i <
                                                          selectedDetails
                                                              .length;
                                                      i++) {
                                                    effortControllers.add(
                                                        TextEditingController());
                                                    handsOnControllers.add(
                                                        TextEditingController());
                                                  }
                                                  print(
                                                      "Map baru: $selectedStaffDetails");
                                                });
                                              }
                                            },
                                            iconSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(),
                                if (selectedStaffDetails != null)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: selectedStaffDetails.length,
                                    itemBuilder: (context, index) {
                                      final detail =
                                          selectedStaffDetails[index];
                                      var effortText = effortControllers[index];
                                      var handsOnText =
                                          handsOnControllers[index];

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Image.network(
                                                  detail['image'],
                                                  width: 20,
                                                  height: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  detail['name'],
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedStaffDetails
                                                          .removeAt(index);
                                                      print(
                                                          'Latest: ${selectedStaffDetails}');
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.delete,
                                                    size: 15,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedStaffIndex =
                                                            index;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 106,
                                                      height: 57,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    8)),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                const Text(
                                                                  'Effort ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 18,
                                                                  height: 18,
                                                                  decoration:
                                                                      const BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    bottom: 3),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      // Handle tap on Effort text
                                                                    },
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          effortText,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      onChanged:
                                                                          (value) {
                                                                        // Handle changes in Effort value
                                                                      },
                                                                      decoration:
                                                                          const InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedStaffIndex =
                                                            index;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 106,
                                                      height: 57,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Hands on ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: 18,
                                                                  height: 18,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.edit,
                                                                    color: Colors
                                                                        .white,
                                                                    size: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8,
                                                                    bottom: 3),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      // Handle tap on Hands on text
                                                                    },
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          handsOnText,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      onChanged:
                                                                          (value) {
                                                                        // Handle changes in Hands on value
                                                                      },
                                                                      decoration:
                                                                          InputDecoration(
                                                                        isDense:
                                                                            true,
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        border:
                                                                            InputBorder.none,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                Visibility(
                                  visible: selectedStaffDetails.isEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "No staff selected",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Container remarks
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              Text(
                                "0",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              updateDetails();
                            },
                            child: const Text("Save Changes"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }

  void updateDetails() {
    // Create a new list to store the updated staff details
    updatedStaffDetails = [];
    // Iterate over the existing staff details and update the effort and hands-on values
    for (int i = 0; i < selectedStaffDetails.length; i++) {
      var staffDetail = selectedStaffDetails[i];
      var effortText = effortControllers[i];
      var handsOnText = handsOnControllers[i];
      var updatedStaffDetail = {
        'staffID': staffDetail['staffID'],
        'name': staffDetail['name'],
        'image': staffDetail['image'],
        'effort': effortText.text,
        'handson': handsOnText.text,
      };
      updatedStaffDetails.add(updatedStaffDetail);
    }

    print("Updated Staff Details: $updatedStaffDetails");
  }

  Future<void> otemsStaff() async {
    var headers = {'token': token, 'Content-Type': 'application/json'};

    // Check if the widget is still mounted before proceeding
    if (!mounted) {
      return;
    }
    if (selectedStaffDetails == null) {
      print("No staff selected");
      return;
    }
    var request = http.Request(
      'POST',
      Uri.parse(
          'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/servant/set'),
    );

    request.body = json.encode({
      "staffs": selectedStaffDetails.map((staff) {
        return {
          "staffID": staff['staffID'],
          "efforts": staff['efforts'],
          "handson": staff['handson'],
        };
      }).toList(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
      print("GoodLuck");
    }
  }
}
