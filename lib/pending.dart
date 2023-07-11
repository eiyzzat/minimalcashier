import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/test/staffItem.dart';
import 'package:minimal/testingSelectStaff.dart';
import '../api.dart';
import '../cart.dart';
import '../function.dart';
import 'discount.dart';

//showModalBottom for edit item in each service & product
class EditItem extends StatefulWidget {
  const EditItem(
      {required this.cartOrderId,
      required this.otemOtemID,
      required this.otemSkuID,
      required this.staff,
      required this.otem,
      required this.updateRemarks,
      required this.itemData,
      required this.updateQuantity,
      required this.updateDiscount,
      required this.updateStaffValues,
      required this.refresh,
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
  final Function updateStaffValues;
  final Function refresh;

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  TextEditingController remarksController = TextEditingController();

  TextEditingController discController = TextEditingController();
  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handsOnControllers = [];

  String paid = '';

  int? selectedStaffIndex;
  Map<String, Map<String, String>> otemOrderMap = {};
  List<Map<String, dynamic>> updatedStaffDetails = [];

  //untuksimpanselectedDetails
  List<dynamic> selectedStaffDetails = [];

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

                Expanded(
                  child: Container(
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
                                                              staff:
                                                                  widget.staff,
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
                                                                  fontSize: 12,
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
                                                                      border: InputBorder
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
                                                                  fontSize: 12,
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
                                                                      border: InputBorder
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
                                          labelText:
                                              widget.itemData['remarks'] != null
                                                  ? remarksController.text
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
                                                                  'discount']
                                                              .toString() !=
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
                                                    TextInputType.text,
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
                                                controller: discController,
                                                decoration: InputDecoration(
                                                  labelText: 'Type here',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .never,
                                                  border: InputBorder.none,
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
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
                              widget.refresh();
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
      setState(() {
        widget.itemData['remarks'] = remarks;
        widget.updateRemarks(otemID, widget.itemData['remarks']);
        Navigator.pop(context);
      });
    } else {
      print(response.reasonPhrase);
    }
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
    widget.refresh();
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

//showModalBottom for staff in editItem
class StaffInEditItem extends StatefulWidget {
  const StaffInEditItem(
      {Key? key,
      required this.cartOrderId,
      required this.staff,
      required this.otems});

  final String cartOrderId;

  final List<dynamic> otems;
  final List<dynamic> staff;

  @override
  State<StaffInEditItem> createState() => _StaffInEditItemState();
}

class _StaffInEditItemState extends State<StaffInEditItem> {
  Set<int> _selectedIndices = Set<int>();

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

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
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: staff.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
    List<Map<String, dynamic>> selectedDetails = [];
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
              }
              Navigator.pop(context,
                  selectedDetails); // Pass the selectedDetails as the result
            } else {
              Navigator.pop(context); // If no selection, simply pop the page
            }
          },
          child: Text('Add'),
        ),
      ),
    );
  }
}
//showModalBottom for staff button in cart

class StaffPart extends StatefulWidget {
  const StaffPart(
      {Key? key,
      required this.cartOrderId,
      required this.otems,
      required this.skus});

  final String cartOrderId;

  final List<dynamic> otems;
  final List<dynamic> skus;

  @override
  State<StaffPart> createState() => _StaffPartState();
}

class _StaffPartState extends State<StaffPart> {
  Set<int> _selectedIndices = Set<int>();

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

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
            children: [
              hi(), // Call hi() method here to display the staff list
            ],
          ),
        ],
      ),
      bottomNavigationBar: addButton(),
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
    Future staffData = APIFunctions.getStaff();

    print("otem dalam staff : ${otems}");

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
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: staff.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              selectedStaffDetails = getSelectedStaffDetails();
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

  Map<String, dynamic>? getSelectedStaffDetails() {
    if (_selectedIndices.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> selectedDetails = [];
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
            Navigator.pop(context);
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
              }

              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 750,
                    child: SpecificStaff(
                      staffID: selectedstaffID,
                      staffDetails:
                          selectedDetails.isNotEmpty ? selectedDetails : null,
                      otems: widget.otems,
                      cartOrderId: widget.cartOrderId,
                      skus: widget.skus,
                    ),
                  );
                },
              );
            }
          },
          child: Text('Add'),
        ),
      ),
    );
  }
}
//showModalBottom for 'Add' button to show specific staff added from StaffPart

class SpecificStaff extends StatefulWidget {
  const SpecificStaff(
      {required this.staffID,
      required this.staffDetails,
      required this.otems,
      required this.skus,
      required this.cartOrderId,
      Key? key});

  final String staffID;
  final List<Map<String, dynamic>>? staffDetails;
  final List<dynamic> otems;
  final List<dynamic> skus;
  final String cartOrderId;

  @override
  State<SpecificStaff> createState() => _SpecificStaffState();
}

class _SpecificStaffState extends State<SpecificStaff> {
  Map<String, Map<String, String>> otemOrderMap = {};
  // List<Map<String, dynamic>> updatedStaffDetails = [];
  int? selectedItemCount;
  int? selectedStaffIndex;
  Map<String, String> selectedSkus = {};

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handsOnControllers = [];

  // TextEditingController effortText = TextEditingController();
  // TextEditingController handsOnText = TextEditingController();

  void handleSkusSelected(Map<String, String> skus) {
    setState(() {
      selectedSkus = skus;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize the effort and hands-on controllers for each staff detail
    for (int i = 0; i < widget.staffDetails!.length; i++) {
      effortControllers.add(TextEditingController());
      handsOnControllers.add(TextEditingController());
    }
  }

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
            "Staff Added",
            style: TextStyle(color: Colors.black),
          ),
          leading: xIcon(),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                color: Colors.grey[200],
              ),
              Column(
                children: [hi()],
              ),
            ],
          ),
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
    print("Dalam specific staff: ${widget.otems}");
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              widget.staffDetails != null ? widget.staffDetails!.length : 0,
          itemBuilder: (context, index) {
            var staffDetail = widget.staffDetails![index];

            TextEditingController effortTextController =
                effortControllers[index];
            TextEditingController handsOnTextController =
                handsOnControllers[index];

            effortControllers.add(effortTextController);
            handsOnControllers.add(handsOnTextController);

            // var effortText = effortControllers[index];
            // var handsOnText = handsOnControllers[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 155,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Staff',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Image.network(
                            staffDetail['image'],
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            staffDetail['name'],
                            style: TextStyle(fontSize: 12),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.staffDetails!.removeAt(index);
                                print('Latest: ${widget.staffDetails}');
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
                          SizedBox(width: 20),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Effort ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, bottom: 3),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // Handle tap on Effort text
                                              },
                                              child: TextFormField(
                                                controller:
                                                    effortTextController,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  // Handle changes in Effort value
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Hands on ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, bottom: 3),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // Handle tap on Hands on text
                                              },
                                              child: TextFormField(
                                                controller:
                                                    handsOnTextController,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  // Handle changes in Hands on value
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  border: InputBorder.none,
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
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 70,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        'Apply to ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<int>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20))),
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 750,
                                child: TrialSelectItem(
                                  otems: widget.otems,
                                  onSkusSelected: handleSkusSelected,
                                  skus: widget.skus,
                                ),
                              );
                            },
                          ).then((selectedCount) {
                            if (selectedCount != null) {
                              setState(() {
                                selectedItemCount = selectedCount;
                              });
                            }
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${selectedItemCount ?? 0} item',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void matchingValue() {
    // Create a new map to store otemID and orderID
    for (Map<String, dynamic> otem in widget.otems) {
      String skuID = otem['skuID'].toString();
      if (selectedSkus.containsValue(skuID)) {
        String otemID = otem['otemID'].toString();
        String orderID = otem['orderID'].toString();

        // Create a new map to store orderID and otemID
        Map<String, String> orderMap = {
          'orderID': orderID,
          'otemID': otemID,
        };

        // Store the orderMap in the otemOrderMap using otemID as the key
        otemOrderMap[otemID] = orderMap;
      }
    }

    // Perform actions with the otemOrderMap
    print('Otem Order Map: $otemOrderMap');
    print('Selected SKUs: $selectedSkus');
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
            List<Map<String, dynamic>> updatedStaffDetails = [];
            for (int i = 0; i < widget.staffDetails!.length; i++) {
              var staffDetail = widget.staffDetails![i];
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
              print("testtttttt");
              print(updatedStaffDetails);
            }
            setState(() {
              matchingValue();
              //  updateDetails();
              //  print("Updated Staff Details: $updatedStaffDetails");
              // otemsStaff(otemOrderMap, updatedStaffDetails);
              trialotemsStaff(selectedSkus, updatedStaffDetails);
            });
          },
          child: const Text('Apply'),
        ),
      ),
    );
  }

  // void updateDetails() {
  //   // Create a new list to store the updated staff details
  //   // updatedStaffDetails = [];

  //   // Iterate over the existing staff details and update the effort and hands-on values
  //   for (int i = 0; i < widget.staffDetails!.length; i++) {
  //     var staffDetail = widget.staffDetails![i];
  //     var effortText = effortControllers[i];
  //     var handsOnText = handsOnControllers[i];
  //     var updatedStaffDetail = {
  //       'staffID': staffDetail['staffID'],
  //       'name': staffDetail['name'],
  //       'image': staffDetail['image'],
  //       'effort': effortText.text,
  //       'handson': handsOnText.text,
  //     };
  //     updatedStaffDetails.add(updatedStaffDetail);
  //     print("testtttttt");
  //     print(updatedStaffDetails);
  //   }
  // }

  Future<void> otemsStaff(Map<String, Map<String, String>> otemOrderMap,
      List<Map<String, dynamic>> updatedStaffDetails) async {
    var orderID = otemOrderMap.values.map((map) => map['orderID']).toList();
    var otemIDs = otemOrderMap.values.map((map) => map['otemID']).toList();

    print("Dalam otemStaff: $otemOrderMap $orderID $otemIDs");
    print("Dalam otemStaff: $updatedStaffDetails");
    print("Dalam otemStaff: ${widget.cartOrderId}");

    var headers = {'token': token, 'Content-Type': 'application/json'};

    for (var i = 0; i < otemIDs.length; i++) {
      // Check if the widget is still mounted before proceeding
      // if (!mounted) {
      //   return;
      // }
      var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/${orderID[i]}/otems/${otemIDs[i]}/servant/set'),
      );

      request.body = json.encode({
        "staffs": updatedStaffDetails.map((staff) {
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
        print(otemIDs);
        print(await response.stream.bytesToString());
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        print(response.reasonPhrase);
        print("GoodLuck");
      }
    }
  }

  Future<void> trialotemsStaff(Map<String, String> selectedSkus,
      List<Map<String, dynamic>> updatedStaffDetails) async {
    List<String> itemIDs = selectedSkus.values.map((value) {
      return value.split(':').last;
    }).toList();

    print("itemIDs: $itemIDs");

    var headers = {'token': token, 'Content-Type': 'application/json'};

    for (var i = 0; i < itemIDs.length; i++) {
      // Check if the widget is still mounted before proceeding
      // if (!mounted) {
      //   return;
      // }
      var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${itemIDs[i]}/servant/set'),
      );

      request.body = json.encode({
        "staffs": updatedStaffDetails.map((staff) {
          return {
            "staffID": staff['staffID'],
            "efforts": staff['effort'],
            "handson": staff['handson'],
          };
        }).toList(),
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        print(response.reasonPhrase);
        print("GoodLuck");
      }
    }
  }
}

//showModalBottom for discount button in cart

// class Discount extends StatefulWidget {
//   const Discount(
//       {Key? key,
//       required this.orderId,
//       required this.otems,
//       required this.skus,
//       required this.updateDiscount});

//   final String orderId;
//   final List<dynamic> otems;
//   final List<dynamic> skus;
//   final Function updateDiscount;

//   @override
//   State<Discount> createState() => _DiscountState();
// }

// class _DiscountState extends State<Discount> {

//   bool isCustomTapped = false;
//   bool okTapped = false;
//   bool showRefresh = false;

//   int? selectedItemCount;

//   Map<String, String> selectedSkus = {};
//   Map<String, Map<String, String>> discItemMap = {};

//   TextEditingController discController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//           centerTitle: true,
//           title: const Text(
//             'Discount',
//             style: TextStyle(color: Colors.black),
//           ),
//           leading: xIcon(),
//         ),
//         body: Stack(
//           children: [
//             Container(
//               color: Colors.grey[200],
//             ),
//             Column(
//               children: [hi2()],
//             ),
//           ],
//         ),
//         bottomNavigationBar: addButton());
//   }

//   Widget xIcon() {
//     return IconButton(
//       icon: Image.asset(
//         "lib/assets/Artboard 40.png",
//         height: 30,
//         width: 20,
//       ),
//       onPressed: () => Navigator.pop(context),
//       iconSize: 24,
//     );
//   }

//   void handleSkusSelected(Map<String, String> skus) {
//     setState(() {
//       selectedSkus = skus;
//     });
//   }

//   Widget hi2() {
//     return Column(children: [
//       Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Row(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Container(
//                   width: double.infinity,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Discount",
//                               style: TextStyle(fontSize: 14, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: SizedBox(
//                                     height: 29,
//                                     child: TextField(
//                                       controller: discController,
//                                       decoration: const InputDecoration(
//                                         labelText: 'Type here',
//                                         floatingLabelBehavior:
//                                             FloatingLabelBehavior.never,
//                                         border: InputBorder.none,
//                                       ),
//                                       keyboardType: TextInputType.text,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "Discount%",
//                             style: TextStyle(fontSize: 14, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 29,
//                                   child: TextField(
//                                     controller: discController,
//                                     decoration: InputDecoration(
//                                       labelText: 'Type here',
//                                       floatingLabelBehavior:
//                                           FloatingLabelBehavior.never,
//                                       border: InputBorder.none,
//                                     ),
//                                     keyboardType: TextInputType.text,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Container(
//           height: 70,
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     const Text(
//                       'Apply to ',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet<int>(
//                           context: context,
//                           isScrollControlled: true,
//                           builder: (BuildContext context) {
//                             return SizedBox(
//                               height: 750,
//                               child: SelectItemForDiscount(
//                                 otems: widget.otems,
//                                 onSkusSelected: handleSkusSelected, skus: widget.skus,
//                               ),
//                             );
//                           },
//                         ).then((selectedCount) {
//                           if (selectedCount != null) {
//                             setState(() {
//                               selectedItemCount = selectedCount;
//                             });
//                           }
//                         });
//                       },
//                       child: Container(
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.blue,
//                         ),
//                         child: Icon(
//                           Icons.edit,
//                           color: Colors.white,
//                           size: 15,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       '${selectedItemCount ?? 0} item',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.blue,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     ]);
//   }

//   void matchingValue() {
//     // Create a new map to store otemID and orderID
//     for (Map<String, dynamic> otem in widget.otems) {
//       String skuID = otem['skuID'].toString();
//       if (selectedSkus.containsValue(skuID)) {
//         String otemID = otem['otemID'].toString();
//         String orderID = otem['orderID'].toString();

//         // Create a new map to store orderID and otemID
//         Map<String, String> orderMap = {
//           'orderID': orderID,
//           'otemID': otemID,
//         };

//         // Store the orderMap in the otemOrderMap using otemID as the key
//         discItemMap[otemID] = orderMap;
//       }
//     }

//     // Perform actions with the otemOrderMap
//     print('Otem Order Map: $discItemMap');
//     print('Selected SKUs: $selectedSkus');
//   }

//   Widget addButton() {
//     return Container(
//       color: Colors.grey[200],
//       child: Padding(
//         padding: const EdgeInsets.only(
//           top: 8.0,
//           left: 8.0,
//           right: 8.0,
//           bottom: 25.0,
//         ),
//         child: ElevatedButton(
//           onPressed: () {
//             setState(() {
//               // Navigator.pop(context);
//               matchingValue();
//               print("disc text: ${discController.text}");
//               String thediscount = discController.text;
//               changeDiscount(discItemMap, thediscount);
//               popWithData(discItemMap, thediscount, selectedSkus);
//             });
//           },
//           child: Text('Apply'),
//         ),
//       ),
//     );
//   }

//   void popWithData(Map<String, Map<String, String>> discItemMap,
//       String discount, Map<String, String> selectedSkus) {
//     Navigator.pop(context, {
//       'discItemMap': discItemMap,
//       'discount': discount,
//       'selectedSkus': selectedSkus
//     });
//   }

//   Future<void> changeDiscount(
//     Map<String, Map<String, String>> discItemMap,
//     String discount,
//   ) async {
//     for (var entry in discItemMap.entries) {
//       String otemID = entry.key;
//       var orderID = entry.value['orderID'];

//       // Find the index of the corresponding otem in the otems list
//       int index = widget.otems.indexWhere(
//           (item) => item['otemID'] == otemID && item['orderID'] == orderID);
//       if (index != -1) {
//         // Set the new discount for the otem
//         widget.otems[index]['discount'] = discount;
//       }
//     }

//     // Call your existing API code to update the discounts
//     var orderID = discItemMap.values.map((map) => map['orderID']).toList();
//     var otemIDs = discItemMap.values.map((map) => map['otemID']).toList();

//     for (var i = 0; i < otemIDs.length; i++) {
//       // Check if the widget is still mounted before proceeding
//       if (!mounted) {
//         return;
//       }
//       var headers = {
//         'token': token,
//       };
//       var request = http.Request(
//           'POST',
//           Uri.parse(
//               'https://order.tunai.io/loyalty/order/${widget.orderId}/otems/${otemIDs[i]}/discount'));

//       request.bodyFields = {'discount': discount};
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         print(await response.stream.bytesToString());
//         print("Dah masuk");
//       } else {
//         print(response.reasonPhrase);
//       }
//     }

//     // Call the updateDiscount method to update the discount value in the cart page
//     widget.updateDiscount();
//   }
// }

//showModalBottom for 'Apply to' icon to show item selected to give discount
class SelectItemForDiscount extends StatefulWidget {
  const SelectItemForDiscount({
    Key? key,
    required this.otems,
    required this.skus,
    required this.onSkusSelected,
  });
  final List<dynamic> otems;
  final List<dynamic> skus;

  final Function(Map<String, String>) onSkusSelected;

  @override
  State<SelectItemForDiscount> createState() => _SelectItemForDiscountState();
}

class _SelectItemForDiscountState extends State<SelectItemForDiscount> {
  Map<String, String> selectedSkus = {};

  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;
  Set<int> selectedItems = {};
  int selectedItemCount = 0;
  bool isAllItemsSelected = false;

  void updateSelectedItems(Set<int> updatedSelectedItems) {
    setState(() {
      selectedItems = updatedSelectedItems;
      selectedItemCount = selectedItems.length;

      // Update selectedSkus map
      selectedSkus.clear();
      for (int index in selectedItems) {
        final sku = widget.skus[index];
        selectedSkus['skuID'] = sku['skuID'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          title: Text(
            "Select Items ${selectedItems.length}",
            style: const TextStyle(color: Colors.black),
          ),
          leading: xIcon(),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                color: Colors.grey[200],
              ),
              Column(
                children: [hi()],
              ),
            ],
          ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.skus.length,
            itemBuilder: (context, index) {
              final sku = widget.skus[index];
              final isSelected = selectedItems.contains(index);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedItems.contains(index)) {
                      selectedItems.remove(index);
                      selectedSkus.remove(index.toString());
                    } else {
                      selectedItems.add(index);
                      final sku = widget.skus[index];
                      selectedSkus[index.toString()] = sku['skuID'].toString();
                    }
                    print(selectedSkus);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sku['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${sku['selling'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
            setState(() {});
            widget.onSkusSelected(selectedSkus);
            Navigator.pop(context, selectedItems.length);
            print('Pass total selected container: $selectedItems');
          },
          child: Text('Ok'),
        ),
      ),
    );
  }
}

//showModalBottom for 'Apply to' icon to show item selected for the staff from SpecificStaff class
class SelectItem extends StatefulWidget {
  const SelectItem({
    Key? key,
    required this.otems,
    required this.skus,
    required this.onSkusSelected,
  });
  final List<dynamic> otems;
  final List<dynamic> skus;
  final Function(Map<String, String>) onSkusSelected;

  @override
  State<SelectItem> createState() => _SelectItemState();
}

class _SelectItemState extends State<SelectItem> {
  Map<String, String> selectedSkus = {};

  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;
  Set<int> selectedItems = {};
  int selectedItemCount = 0;
  bool isAllItemsSelected = false;

  void updateSelectedItems(Set<int> updatedSelectedItems) {
    setState(() {
      selectedItems = updatedSelectedItems;
      selectedItemCount = selectedItems.length;

      // Update selectedSkus map
      selectedSkus.clear();
      for (int index in selectedItems) {
        final sku = skus[index];
        selectedSkus['skuID'] = sku['skuID'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        title: Text(
          "Select Items ${selectedItems.length}",
          style: TextStyle(color: Colors.black),
        ),
        leading: xIcon(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: selectAllItems,
              child: Text(
                'Select All',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: Colors.grey[200],
            ),
            Column(
              children: [hi()],
            ),
          ],
        ),
      ),
      bottomNavigationBar: addButton(),
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

  void selectAllItems() {
    setState(() {
      if (isAllItemsSelected) {
        selectedItems = {};
        selectedSkus = {};
      } else {
        selectedItems =
            Set<int>.from(List.generate(skus.length, (index) => index));
        selectedSkus = Map.fromIterables(
          selectedItems.map((index) => index.toString()),
          skus.map((sku) => sku['skuID'].toString()),
        );
      }
      isAllItemsSelected = !isAllItemsSelected;
    });
  }

  Widget hi() {
    print("dalam select item: ${widget.skus}");
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.skus.length,
            itemBuilder: (context, index) {
              final sku = widget.skus[index];
              final isSelected =
                  isAllItemsSelected || selectedItems.contains(index);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedItems.contains(index)) {
                      selectedItems.remove(index);
                      selectedSkus.remove(index.toString());
                    } else {
                      selectedItems.add(index);
                      final sku = widget.skus[index];
                      selectedSkus[index.toString()] = sku['skuID'].toString();
                    }
                    print(selectedSkus);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sku['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${sku['selling'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isSelected)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
            setState(() {});
            widget.onSkusSelected(selectedSkus);
            Navigator.pop(context, selectedItems.length);
            print('Pass total selected container: $selectedItems');
          },
          child: Text('Ok'),
        ),
      ),
    );
  }
}
