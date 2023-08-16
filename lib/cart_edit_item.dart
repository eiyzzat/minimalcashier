import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/testingSelectStaff.dart';
import 'constant/token.dart';
import 'login.dart';

//showModalBottom for edit item in each service & product
class CartEditItem extends StatefulWidget {
  CartEditItem(
      {required this.cartOrderId,
      required this.otemOtemID,
      required this.otemSkuID,
      required this.staff,
      required this.otem,
      required this.itemData,
      required this.updateQuantity,
      required this.updateRemarks,
      required this.updateDiscount,
      required this.updateCart,
      Key? key});

  final String cartOrderId;
  final String otemOtemID;
  final String otemSkuID;
  final List<dynamic> otem;
  List<dynamic> staff;
  final Map<String, dynamic> itemData;
  final Function updateQuantity;
  final Function updateRemarks;
  final Function updateDiscount;
  final Function updateCart;

  @override
  State<CartEditItem> createState() => _CartEditItemState();
}

class _CartEditItemState extends State<CartEditItem> {
  var detail = {};

  late TextEditingController remarksController =
      TextEditingController(text: widget.itemData['remarks']);

  // late TextEditingController discController =
  //     TextEditingController(text: widget.itemData['discount'].toString());
  // TextEditingController discPercentageController = TextEditingController();

  TextEditingController discController = TextEditingController();
  TextEditingController discPercentageController = TextEditingController();

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handonControllers = [];

  String paid = '';

  int? selectedStaffIndex;
  Map<String, Map<String, String>> otemOrderMap = {};
  List<Map<String, dynamic>> updatedStaffDetails = [];
  List<dynamic> getData = [];

  Map<String, dynamic> mapEdit = {};

  //untuksimpanselectedDetails
  List<dynamic> selectedStaffDetails = [];
  double latestDiscount = 0;

  @override
  void initState() {
    super.initState();
    double discount = (widget.itemData['discount'] ?? 0).toDouble();
    double totalPrice = widget.itemData['price'].toDouble() *
        double.parse(widget.itemData['quantity']);
    double discountPercentage = (discount / totalPrice) * 100;

    discController.text = discount.toStringAsFixed(2);
    discPercentageController.text = discountPercentage.toStringAsFixed(2);

    detail['discount'] = discount;
    getStaffs();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          centerTitle: true,
          title: const Text(
            'Edit Item',
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
              children: [hi()],
            ),
          ],
        ),
      ),
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
    print("masuk balik: $selectedStaffDetails"); //staffID,effort,handson
    // print(widget.otem);
    // print(widget.staff); //staffID,name,mobile

    final totalSub = calSub(widget.itemData);

    // double totalPrice = widget.itemData['price'].toDouble() *
    //     double.parse(widget.itemData['quantity']);
    // double discountPercentage =
    //     (widget.itemData['discount'] / totalPrice) * 100;
    // double afterDisc = discountPercentage.toDouble();

    discController.selection = TextSelection.fromPosition(
        TextPosition(offset: discController.text.length));
    // discPercentageController.text = afterDisc.toStringAsFixed(2);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                        borderRadius:
                                            BorderRadius.circular(15.0),
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
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: Container(
                                        width: 80,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(5.0),
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
                    //bahagian staff
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
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: IconButton(
                                              icon: Image.asset(
                                                "lib/assets/Plus.png",
                                                height: 30,
                                                width: 30,
                                              ),
                                              onPressed: () async {
                                                final selectedDetails =
                                                    await showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
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
                                                                // staff: widget
                                                                //     .staff,
                                                              ));
                                                        });
                                                if (selectedDetails != null) {
                                                  setState(() {
                                                    // Add the selected details to the selectedStaffDetails list
                                                    selectedStaffDetails.addAll(
                                                        selectedDetails);
                                                    // Initialize the controllers for the newly added details
                                                    // for (int i = 0;
                                                    //     i <
                                                    //         selectedStaffDetails
                                                    //             .length;
                                                    //     i++) {
                                                    //   testeffortController.add(
                                                    //       TextEditingController());
                                                    //   testhandsonController.add(
                                                    //       TextEditingController());
                                                    // }
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
                                      detail = selectedStaffDetails[index];

                                      // print("Detail: $detail");
                                      int destaff = detail['staffID'];
                                      dynamic theStaff =
                                          widget.staff.firstWhere(
                                        (theStaff) =>
                                            theStaff['staffID'] == destaff,
                                        orElse: () => null,
                                      );

                                      //bahagian untuk assign effort ke first staff

                                      if (selectedStaffDetails.isNotEmpty) {
                                        // Step 2: Update the 'effort' field for the first staffID.
                                        selectedStaffDetails[0]['effort'] =
                                            widget.itemData['price'];
                                      }

                                      // print("thestaff: $theStaff");

                                      // final displayStaffName = theStaff;
                                      final theName = theStaff['name'];
                                      final iconStaff = theStaff['icon'];
                                      // Create TextEditingController instances for each effort and handon field
                                      TextEditingController effortController =
                                          TextEditingController(
                                              text: (detail['effort'] ?? '0')
                                                  .toString());
                                      effortController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: effortController
                                                      .text.length));

                                      TextEditingController handonController =
                                          TextEditingController(
                                              text: (detail['handon'] ?? '0')
                                                  .toString());
                                      handonController.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: handonController
                                                      .text.length));

                                      // Store the controllers in their respective lists
                                      effortControllers.add(effortController);
                                      handonControllers.add(handonController);

                                      // effortController = TextEditingController(text: detail['effort'].toString());
                                      // handsoncontroller = TextEditingController(text: detail['handon'].toString());

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Image(
                                                  image: NetworkImage(
                                                      theStaff['icon']),
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  theName.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily:
                                                        'SFProDisplay', // Use the specified font family
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedStaffDetails
                                                          .removeAt(index);
                                                      effortControllers
                                                          .removeAt(index);
                                                      handonControllers
                                                          .removeAt(index);
                                                      print(
                                                          'Latest: $selectedStaffDetails');
                                                    });
                                                  },
                                                  child: const Image(
                                                    image: AssetImage(
                                                        'lib/assets/remove.jpg'), 
                                                    width: 22,
                                                    height:
                                                        22, 
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 12),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Container(
                                                    width: 106,
                                                    height: 57,
                                                    decoration: BoxDecoration(
                                                      //edit warna kotak effort
                                                      color: Colors.white,
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
                                                                  fontFamily:
                                                                      'SFProDisplay', // Use the specified font family
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                              Expanded(child: StatefulBuilder(builder:
                                                                  (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                return TextFormField(
                                                                  controller:
                                                                      effortControllers[
                                                                          index],
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'SFProDisplay',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: Colors
                                                                        .black,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
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
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      detail['effort'] =
                                                                          value;
                                                                    });
                                                                  },
                                                                );
                                                              })),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const Divider(),
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
                                                      decoration: const BoxDecoration(
                                                        //edit warna kotak handson
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
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
                                                                  'Hands on ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'SFProDisplay', // Use the specified font family
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
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
                                                                  child: StatefulBuilder(builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                    return TextFormField(
                                                                      controller:
                                                                          handonControllers[
                                                                              index],
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontFamily:
                                                                            'SFProDisplay', // Use the specified font family
                                                                        fontWeight:
                                                                            FontWeight.normal,
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
                                                                        setState(
                                                                            () {
                                                                          detail['handon'] =
                                                                              value;
                                                                        });
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
                                                                    );
                                                                  }),
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
                                          const Divider(),
                                        ],
                                      );
                                    },
                                  ),
                                  Visibility(
                                    visible: selectedStaffDetails.isEmpty,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Remarks",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
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
                                width: 165,
                                height: 56,
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
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'SFProDisplay',
                                              fontWeight: FontWeight.normal,
                                            ),
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
                                                  height: 15,
                                                  child: TextField(
                                                    controller: discController,
                                                    decoration: InputDecoration(
                                                      // labelText: widget.itemData['discount'] != null
                                                      //     ? widget.itemData['discount'].toString()
                                                      //     : 'Type here',
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .never,
                                                      border: InputBorder.none,
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value.isEmpty) {
                                                          value = '0';
                                                        }
                                                        double discount =
                                                            double.parse(value);
                                                        double totalPrice = widget
                                                                .itemData[
                                                                    'price']
                                                                .toDouble() *
                                                            double.parse(widget
                                                                    .itemData[
                                                                'quantity']);
                                                        double
                                                            discountPercentage =
                                                            (discount /
                                                                    totalPrice) *
                                                                100;
                                                        discPercentageController
                                                                .text =
                                                            discountPercentage
                                                                .toStringAsFixed(
                                                                    2);
                                                        detail['discount'] =
                                                            discount;
                                                      });
                                                    },
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'SFProDisplay',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    // onChanged: inDiscount,
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
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                width: 165,
                                height: 56,
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
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'SFProDisplay',
                                              fontWeight: FontWeight.normal,
                                            ),
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
                                                  height: 20,
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
                                                    onChanged: (value) {
                                                      setState(() {
                                                        double
                                                            discountPercentage =
                                                            0; // Default to 0
                                                        if (value.isNotEmpty) {
                                                          discountPercentage =
                                                              double.parse(
                                                                  value);
                                                        }
                                                        double totalPrice = widget
                                                                .itemData[
                                                                    'price']
                                                                .toDouble() *
                                                            double.parse(widget
                                                                    .itemData[
                                                                'quantity']);
                                                        double discount =
                                                            (discountPercentage /
                                                                    100) *
                                                                totalPrice;
                                                        discController.text =
                                                            discount
                                                                .toStringAsFixed(
                                                                    2);
                                                        detail['discount'] =
                                                            discountPercentage;
                                                      });
                                                    },
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'SFProDisplay',
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    enabled:
                                                        true, // Disable editing
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
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
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
                                onPressed: () async {
                                  int newquantity =
                                      int.parse(widget.itemData['quantity']);

                                  await changeQty(widget.otemOtemID.toString(),
                                      newquantity);

                                  widget.updateCart();

                                  String remarks = remarksController.text;
                                  changeRemark(
                                      widget.otemOtemID.toString(), remarks);

                                  int quantity =
                                      int.parse(widget.itemData['quantity']);
                                  double price = 0.0;
                                  if (widget.itemData['price'] != null) {
                                    price = double.tryParse(widget
                                            .itemData['price']
                                            .toString()) ??
                                        0.0;
                                  }
                                  changeDiscount(price, quantity);

                                  updateDetails();
                                  await otemsStaff(updatedStaffDetails);
                                  widget.updateCart();

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
              ),
            ))
          ],
        ),
      ),
    );
  }

  void inDiscount(String value) {
    setState(() {
      widget.itemData['discount'] = int.tryParse(value) ?? 0;
    });
  }

  void updateDetails() {
    // Create a new list to store the updated staff details
    updatedStaffDetails = [];
    // print("dalam update: $selectedStaffDetails");
    // Iterate over the existing staff details and update the effort and hands-on values
    for (int i = 0; i < selectedStaffDetails.length; i++) {
      var staffDetail = selectedStaffDetails[i];
      // var effortText = effortControllers[i];
      // var handsOnText = handsOnControllers[i];
      var updatedStaffDetail = {
        'staffID': staffDetail['staffID'],
        'name': staffDetail['name'],
        'image': staffDetail['image'],
        'effort': effortControllers[i].text,
        'handson': handonControllers[i].text,
        // 'effort': effortText.text,
        // 'handson': handsoncontroller.text,
      };
      updatedStaffDetails.add(updatedStaffDetail);
    }
    // print("after update: $updatedStaffDetails");
  }

  Future<void> otemsStaff(
      List<Map<String, dynamic>> updatedStaffDetails) async {
    var headers = {'token': token, 'Content-Type': 'application/json'};

    print("dalam otem: $updatedStaffDetails");

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
      "staffs": updatedStaffDetails.map((staff) {
        return {
          "staffID": staff['staffID'],
          "image": staff['image'],
          "efforts": staff['effort'],
          "handson": staff['handson'],
        };
      }).toList(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    print("dalam api: $updatedStaffDetails");

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
      print("GoodLuck");
    }
  }

  double calSub(Map<String, dynamic> itemData) {
    final int quantity = int.parse(itemData['quantity'].toString());
    final double price = double.parse(itemData['price'].toString());

    double disc = 0; // Default to 0
    String discText =
        discController.text.trim(); // Remove leading/trailing whitespaces

    if (discText.isNotEmpty) {
      // Check if the text is not empty and only contains digits and a maximum of one decimal point
      if (RegExp(r'^\d*\.?\d*$').hasMatch(discText)) {
        disc = double.parse(discText);
      }
    }

    return (quantity * price) - disc;
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
      // print(response.body);
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
      // print(response.body);
      if (mounted) {
        setState(() {
          widget.itemData['remarks'] = remarks;
          widget.updateRemarks(otemID, widget.itemData['remarks']);
        });
      }
    } else {
      // print(response.reasonPhrase);
    }
  }

  Future<void> changeDiscount(double price, int quantity) async {
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

    String discountValue;
    if (discController.text.isNotEmpty) {
      // "Discount" container has a value
      discountValue = discController.text;
    } else if (discPercentageController.text.isNotEmpty) {
      // "Discount%" container has a value

      double discountPercentage = double.parse(discPercentageController.text);
      double totalPrice = (price * quantity) / 1.0;
      double discount = totalPrice * discountPercentage / 100;
      discountValue = discount.toStringAsFixed(2);
    } else {
      return; // Neither container has a value, do nothing
    }

    request.bodyFields = {'discount': discountValue.toString()};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      // print("Dah masuk");
    } else {
      // print(response.reasonPhrase);
    }

    // Call the updateDiscount method to update the discount value in the cart page
    widget.updateDiscount();
  }
}
//code untuk container ke bawah
//  AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       height: 100.0 + (selectedStaffDetails.length * 57.0),
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: SingleChildScrollView(
//                           physics: const ScrollPhysics(),
//                           child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           const Text(
//                                             "Staff",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey),
//                                           ),
//                                           const SizedBox(width: 30),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Container(
//                                                 width: 30,
//                                                 height: 30,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.white,
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           15.0),
//                                                 ),
//                                                 child: IconButton(
//                                                   icon: Image.asset(
//                                                     "lib/assets/Plus.png",
//                                                     height: 30,
//                                                     width: 30,
//                                                   ),
//                                                   onPressed: () async {
//                                                     final selectedDetails =
//                                                         await showModalBottomSheet(
//                                                       context: context,
//                                                       isScrollControlled: true,
//                                                       shape:
//                                                           const RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .vertical(
//                                                           top: Radius.circular(
//                                                               20),
//                                                         ),
//                                                       ),
//                                                       builder: (BuildContext
//                                                           context) {
//                                                         return SizedBox(
//                                                           height: 750,
//                                                           child:
//                                                               TestSelectStaff(
//                                                             cartOrderId: widget
//                                                                 .cartOrderId,
//                                                             otems: widget.otem,
//                                                           ),
//                                                         );
//                                                       },
//                                                     );
//                                                     if (selectedDetails !=
//                                                         null) {
//                                                       setState(() {
//                                                         // Add the selected details to the selectedStaffDetails list
//                                                         selectedStaffDetails
//                                                             .addAll(
//                                                                 selectedDetails);
//                                                       });
//                                                     }
//                                                   },
//                                                   iconSize: 24,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                       const Divider(),
//                                       if (selectedStaffDetails.isEmpty)
//                                         const Padding(
//                                           padding: EdgeInsets.all(8.0),
//                                           child: Text(
//                                             "No staff selected",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: selectedStaffDetails.map((detail) {
//                                     // Access the data from the detail map
//                                     String staffName = detail['name'];
//                                     int staffId = detail['staffID'];
//                                     // You can use the data to create a custom widget or Text widget
//                                     return Text(
//                                         '$staffName - Staff ID: $staffId');
//                                   }).toList(),
//                                 ),
//                               ])),
//                     ),