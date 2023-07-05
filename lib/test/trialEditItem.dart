import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/testingSelectStaff.dart';
import '../api.dart';
import '../cart.dart';
import '../function.dart';

//showModalBottom for edit item in each service & product
class TrialEditItem extends StatefulWidget {
  const TrialEditItem(
      {required this.cartOrderId,
      required this.otemOtemID,
      required this.otemSkuID,
      required this.staff,
      required this.otem,
      required this.itemData,
      required this.updateQuantity,
      required this.updateRemarks,
      required this.updateDiscount,
      
      Key? key});

  final String cartOrderId;
  final String otemOtemID;
  final String otemSkuID;
  final List<dynamic> otem;
  final List<dynamic> staff;
  final Map<String, dynamic> itemData;
  final Function updateQuantity;
  final Function updateRemarks;
  final Function updateDiscount;
  

  @override
  State<TrialEditItem> createState() => _TrialEditItemState();
}

class _TrialEditItemState extends State<TrialEditItem> {
  TextEditingController remarksController = TextEditingController();
  TextEditingController discController = TextEditingController();
  TextEditingController discPercentageController = TextEditingController();

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handsOnControllers = [];

  String paid = '';

  int? selectedStaffIndex;
  Map<String, Map<String, String>> otemOrderMap = {};
  List<Map<String, dynamic>> updatedStaffDetails = [];

  //untuksimpanselectedDetails
  List<dynamic> selectedStaffDetails = [];
  double latestDiscount = 0;

  @override
  void initState() {
    super.initState();
    getStaffs();
    // Future staffData = APIFunctions.getStaff();
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

  void getStaffs() {
    //pass itemData untuk pass specific otemID
    dynamic otem = widget.otem.firstWhere(
      (otem) => otem['otemID'] == widget.itemData['otemID'],
    );
    List<int> staffIDs =
        otem['staffs'].map<int>((staff) => staff['staffID'] as int).toList();
    setState(() {
      selectedStaffDetails = otem['staffs']
          .where((staff) => staffIDs.contains(staff['staffID']))
          .toList();
    });
  }

  Widget hi() {
    print("masuk balik: $selectedStaffDetails");

    print(widget.otem);
    print(widget.staff);

    final totalSub = calSub(widget.itemData);

    discController.text = widget.itemData['discount'].toString();
    remarksController.text = widget.itemData['remarks'].toString();

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
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.itemData['itemName'].toString(),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(width: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: IconButton(
                                    icon: Image.asset(
                                      "lib/assets/Minus.png",
                                      height: 20,
                                      width: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        int quantity = int.parse(widget
                                                .itemData[
                                            'quantity']); // Parse the quantity as an int
                                        quantity--; // Increment the quantity by 1
                                        widget.itemData['quantity'] = quantity
                                            .toString(); // Convert the quantity back to a string
                                        print(widget.itemData['quantity']);
                                      });
                                    },
                                    iconSize: 24,
                                  ),
                                ),
                                Text(
                                  widget.itemData['quantity'].toString(),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: IconButton(
                                    icon: Image.asset(
                                      "lib/assets/Plus.png",
                                      height: 20,
                                      width: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        int quantity = int.parse(widget
                                                .itemData[
                                            'quantity']); // Parse the quantity as an int
                                        quantity++; // Increment the quantity by 1
                                        widget.itemData['quantity'] = quantity
                                            .toString(); // Convert the quantity back to a string
                                        print(widget.itemData['quantity']);
                                      });
                                    },
                                    iconSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Container(
                                    width: 80,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 10),
                                        Text(
                                          widget.itemData['price']
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Others",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),

                Container(
                  height: 165,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SingleChildScrollView(
                    physics: const ScrollPhysics(),
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
                                                    builder:
                                                        (BuildContext context) {
                                                      return SizedBox(
                                                          height: 750,
                                                          child:
                                                              TestSelectStaff(
                                                            cartOrderId: widget
                                                                .cartOrderId,
                                                            otems: widget.otem,
                                                            staff: widget.staff,
                                                          ));
                                                    });
                                            if (selectedDetails != null) {
                                              setState(() {
                                                // Add the selected details to the selectedStaffDetails list
                                                selectedStaffDetails
                                                    .addAll(selectedDetails);
                                                // Initialize the controllers for the newly added details
                                                for (int i = 0;
                                                    i < selectedDetails.length;
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
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: selectedStaffDetails.length,
                                itemBuilder: (context, index) {
                                  final detail = selectedStaffDetails[index];
                                  // var effortText = effortControllers[index];
                                  // var handsOnText =
                                  //     handsOnControllers[index];

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "lib/assets/Artboard 40 copy 2.png",
                                              width: 30,
                                              height: 30,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              detail['staffID'].toString(),
                                              style:
                                                  const TextStyle(fontSize: 12),
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
                                                    selectedStaffIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: 106,
                                                  height: 57,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(8)),
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
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
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
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                              child: const Icon(
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
                                                                  // controller:
                                                                  //     effortText,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                                        EdgeInsets
                                                                            .zero,
                                                                    border:
                                                                        InputBorder
                                                                            .none,
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
                                                    selectedStaffIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  width: 106,
                                                  height: 57,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
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
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
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
                                                                color:
                                                                    Colors.blue,
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
                                                                  // controller:
                                                                  //     handsOnText,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                                        EdgeInsets
                                                                            .zero,
                                                                    border:
                                                                        InputBorder
                                                                            .none,
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
                // Container remarks
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Remarks",
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 29,
                                      child: TextField(
                                        controller: remarksController,
                                        decoration: InputDecoration(
                                          labelText:widget.itemData[
                                                              'remarks'] !=
                                                          null
                                                      ? widget
                                                          .itemData['remarks']
                                                          .toString()
                                                      : 'Type here',
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.never,
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Adjustment",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                //container discount
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Discount",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 29,
                                              child: TextField(
                                                
                                                controller: discController,
                                                decoration: InputDecoration(
                                                  labelText: widget.itemData[
                                                              'discount'] !=
                                                          null
                                                      ? widget
                                                          .itemData['discount']
                                                          .toString()
                                                      : 'Type here',
                                                      
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  // Update the value when the text changes
                                                  // double discValue =
                                                  //     double.tryParse(value) ??
                                                  //         0.0;
                                                  // print(discValue);

                                                  // int discountPercentage =
                                                  //     ((totalSub -
                                                  //                 (totalSub -
                                                  //                     discValue)) *
                                                  //             100)
                                                  //         .toInt();
                                                  // discPercentageController
                                                  //         .text =
                                                  //     discountPercentage
                                                  //         .toString(); // Update the discPercentageController value
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Discount%",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 29,
                                              child: TextField(
                                                controller:
                                                    discPercentageController,
                                                decoration: InputDecoration(
                                                  labelText: '0.00',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                enabled:
                                                    false, // Disable editing
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                                totalSub.toStringAsFixed(2),
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
                              int newquantity =
                                  int.parse(widget.itemData['quantity']);

                              changeQty(
                                  widget.otemOtemID.toString(), newquantity);

                              String remarks = remarksController.text;
                              changeRemark(
                                  widget.otemOtemID.toString(), remarks);

                              String discountText = discController.text;
                              double discount =
                                  0.0; // Default value if the input is empty

                              if (discountText.isNotEmpty) {
                                discount = double.tryParse(discountText) ?? 0.0;
                              }
                              changeDiscount(discount);

                              updateDetails();
                              otemsStaff(updatedStaffDetails);

                              Navigator.pop(context);
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
      // var effortText = effortControllers[i];
      // var handsOnText = handsOnControllers[i];
      var updatedStaffDetail = {
        'staffID': staffDetail['staffID'],
        'name': staffDetail['name'],
        'image': staffDetail['image'],
        // 'effort': effortText.text,
        // 'handson': handsOnText.text,
      };
      updatedStaffDetails.add(updatedStaffDetail);
    }

    print("Updated Staff Details: $updatedStaffDetails");
  }

  Future<void> otemsStaff(
      List<Map<String, dynamic>> updatedStaffDetails) async {
    var headers = {'token': token, 'Content-Type': 'application/json'};

    // Check if the widget is still mounted before proceeding
    if (!mounted) {
      return;
    }
    if (updatedStaffDetails == null) {
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
          "image": staff['image'],
          "efforts": staff['efforts'],
          "handson": staff['handson'],
        };
      }).toList(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print("dalam api: $selectedStaffDetails");

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
      print("GoodLuck");
    }
  }

  double calSub(Map<String, dynamic> itemData) {
    final int quantity = int.parse(itemData['quantity'].toString());
    final double price = double.parse(itemData['price'].toString());
    return quantity * price;
  }

  Future changeQty(String otemID, int quantity) async {
    var headers = {
      'token': token,
    };
    var url =
        'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/quantity';

    var response = await http.post(Uri.parse(url), headers: headers, body: {
      'quantity': quantity.toString(),
    });

    if (response.statusCode == 200) {
      print(response.body);
      if (mounted) {
        setState(() {
          // Find the index of the map with the corresponding otemID
          final index =
              widget.otem.indexWhere((element) => element['otemID'] == otemID);
          if (index != -1) {
            // Update the quantity value in the map
            widget.otem[index]['quantity'] = quantity.toString();
          }
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    widget.updateQuantity();
  }

  Future<void> changeRemark(String otemID, String remarks) async {
    var headers = {
      'token': token,
    };
    var url =
        'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/remarks';

    var response = await http.post(Uri.parse(url), headers: headers, body: {
      'remarks': remarks,
    });

    if (response.statusCode == 200) {
      print(response.body);
      if (mounted) {
        setState(() {
          widget.itemData['remarks'] = remarks;
          widget.updateRemarks(otemID, widget.itemData['remarks']);
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> changeDiscount(
    double discount,
  ) async {
    // Check if the widget is still mounted before proceeding
    if (!mounted) {
      return;
    }
    var headers = {
      'token': token,
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/discount'));

    request.bodyFields = {'discount': discount.toString()};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("Dah masuk");
    } else {
      print(response.reasonPhrase);
    }

    // Call the updateDiscount method to update the discount value in the cart page
    widget.updateDiscount();
  }
}
