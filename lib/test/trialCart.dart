import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/pending.dart';
import 'package:minimal/test/trialEditItem.dart';
import 'package:minimal/test/trialPayment.dart';
import '../api.dart';
import 'dart:convert';

import '../discount.dart';

class TrialCart extends StatefulWidget {
  TrialCart(
      {Key? key,
      required this.cartName,
      required this.cartOrderId,
      required this.otems,
      required this.totalItems,
      required this.totalPrice})
      : super(key: key);

  final String cartName;
  final String cartOrderId;
  List<dynamic> otems;

  int totalItems;
  double totalPrice;

  @override
  State<TrialCart> createState() => _TrialCart();
}

Map<String, List<Map<String, dynamic>>> typeIDMap = {};

String selectedstaffID = '';
// List<dynamic> otemsDalanCart = [];
List<dynamic> skus = [];

double newTotalPrice = 0.0;
double newDiscount = 0.0;
int newTotalItem = 0;

bool isItemDeleted = false;

class _TrialCart extends State<TrialCart> {
  List<dynamic> service = [];
  List<dynamic> products = [];
  List<dynamic> staff = [];

  int staffCount = 0;
  int nakDisplayQuantity = 0;

  TextEditingController remarksController = TextEditingController();

  int? selectedStaffIndex;
  double latestDiscount = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    double totalDiscount = 0.0;

    double calcDisc(List<dynamic> otems) {
      double disc = 0;

      for (var itemData in otems) {
        final discount = itemData['discount'];
        if (discount != null) {
          disc += discount;
        }
      }

      // return disc + latestDiscount;
      return latestDiscount;
    }

    updateDiscount() {
      setState(() {
        newDiscount = calcDisc(widget.otems);
        totalDiscount = widget.otems.fold(
            0, (sum, otems) => sum + int.parse(otems['discount'].toString()));
      });
      // print("Total Disc dalam update: $totalDiscount");
    }

    // var disc = updateDiscount();
    // var displayDisc = disc;

    int nakDisplayQuantity = widget.otems
        .fold(0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));

    totalDiscount = widget.otems
        .fold(0, (sum, otems) => sum + int.parse(otems['discount'].toString()));

    double totalSubtotal = widget.otems
        .fold(0, (sum, otems) => sum + otems['price'] * otems['quantity']);

    double allDiscount = totalDiscount;

    double allTotal = totalSubtotal - allDiscount;

    // print("Dalam otems dr menu: ${widget.otems}");
    // print("total quantity: $nakDisplayQuantity");
    // print("total Discount: $totalDiscount");
    // print("total semua: $totalSubtotal");
    // print("total bayar: $allTotal");

    // print(widget.totalItems);
    print(widget.totalPrice);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            widget.cartName,
            style: const TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Image.asset(
              "lib/assets/Artboard 40.png",
              height: 20,
              width: 20,
            ),
            onPressed: () => Navigator.pop(context),
            iconSize: 24,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete,
                size: 40,
                color: Colors.red,
              ),
              onPressed: () {
                deleteAll(widget.otems);
                setState(() {});
              },
            ),
            IconButton(
                icon: Image.asset("lib/assets/Pending.png"), onPressed: () {})
          ],
        ),
        //in case tak nampak, coding body di siniiiii
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                color: Colors.grey[200],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: FutureBuilder(
                          future: fetchData(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              // print("abd");
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              typeIDMap.clear();

                              // print(skus);
                              // print(widget.otems);

                              for (int i = 0; i < widget.otems.length; i++) {
                                dynamic sku = skus.firstWhere((sku) =>
                                    sku['skuID'] == widget.otems[i]['skuID']);
                                final item2 = sku;
                                final typeID = item2['typeID'].toString();

                                // List<Map<String, dynamic>> otems =
                                //     List<Map<String, dynamic>>.from(
                                //         widget.otems);

                                // if (typeIDMap.containsKey(typeID)) {
                                //   typeIDMap[typeID]!.addAll(otems);
                                // } else {
                                //   typeIDMap[typeID] = otems;
                                // }

                                if (!typeIDMap.containsKey(typeID)) {
                                  typeIDMap[typeID] = [];
                                }

                                if (widget.otems[i]['deleteDate'] == 0) {
                                  typeIDMap[typeID]!.add({
                                    'itemName': item2['name'].toString(),
                                    'otemID': widget.otems[i]['otemID'],
                                    'skuID': item2['skuID'],
                                    'quantity':
                                        widget.otems[i]['quantity'].toString(),
                                    'discount': widget.otems[i]['discount'],
                                    'price': widget.otems[i]['price'],
                                    'remarks':
                                        widget.otems[i]['remarks'].toString(),
                                    'deleteDate':
                                        widget.otems[i]['deleteDate'].toString()
                                  });
                                }
                                // print("TypeIDMAp:");

                                // print(typeIDMap);
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: typeIDMap.length,
                                itemBuilder: (context, index) {
                                  final typeID = typeIDMap.keys.toList()[index];
                                  final typeName = getTypeName(typeID);
                                  final itemList = typeIDMap[typeID]!;

                                  // print("itemList:");

                                  // print(itemList);

                                  if (itemList.isEmpty) {
                                    return Container();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          typeName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: itemList.length,
                                        itemBuilder: (context, index) {
                                          print("itemlist $itemList");
                                          final itemData = itemList[index];
                                          var otemID =
                                              itemData['otemID'].toString();

                                          // Create a list to hold the staffCount and staffName for each otems item
                                          List<int> staffCounts = [];
                                          List<String> staffNames = [];

                                          // for (var otem in widget.otems) {
                                          //   var staffCount =
                                          //       otem["staffs"].length;
                                          //   print(
                                          //       "otemID: ${otem['otemID']}, Staff Count: $staffCount");
                                          // }

                                          // Iterate over each otems item
                                          for (var i = 0;
                                              i < widget.otems.length;
                                              i++) {
                                            var otemID =
                                                widget.otems[i]['otemID'];
                                            var staffCount = widget
                                                .otems[i]['staffs'].length;
                                            var staffName = '';

                                            print("staff");

                                            print(widget.otems[i]['staffs']);

                                            if (staffCount == 1) {
                                              var staffID = widget.otems[i]
                                                  ['staffs'][0]['staffID'];
                                              var staffInfo = staff.firstWhere(
                                                (staffInfo) =>
                                                    staffInfo['staffID'] ==
                                                    staffID,
                                                orElse: () => {},
                                              );
                                              staffName =
                                                  staffInfo['name'].toString();
                                            } else if (staffCount > 1) {
                                              staffName = '$staffCount staffs';
                                            }

                                            // Add the staffCount and staffName to the respective lists
                                            staffCounts.add(staffCount);
                                            staffNames.add(staffName);
                                          }

                                          return Builder(
                                            builder: (context) => Dismissible(
                                              key: Key(otemID),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                color: Colors.red,
                                                child: const Icon(Icons.delete,
                                                    color: Colors.white),
                                              ),
                                              onDismissed: (direction) async {
                                                await deleteItem(otemID);
                                                fetchData();
                                                print(otemID);
                                              },
                                              child: InkWell(
                                                onTap: () async {
                                                  final updatedItemData =
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
                                                        child: TrialEditItem(
                                                          cartOrderId: widget
                                                              .cartOrderId,
                                                          otemOtemID:
                                                              itemData['otemID']
                                                                  .toString(),
                                                          otemSkuID:
                                                              itemData['skuID']
                                                                  .toString(),
                                                          itemData: itemData,
                                                          staff: staff,
                                                          otem: widget.otems,
                                                          updateQuantity:
                                                              updateQuantity,
                                                          updateRemarks:
                                                              updateRemarks,
                                                          updateDiscount:
                                                              updateDiscount,
                                                        ),
                                                      );
                                                    },
                                                  );

                                                  if (updatedItemData != null) {
                                                    final index = widget.otems
                                                        .indexWhere((item) =>
                                                            item['otemID'] ==
                                                            updatedItemData[
                                                                'otemID']);
                                                    if (index != -1) {
                                                      setState(() {
                                                        widget.otems[index] =
                                                            updatedItemData;
                                                      });
                                                    }
                                                  }
                                                  print("updatedItemData");
                                                  print(updatedItemData);
                                                },
                                                child: Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              itemData[
                                                                      'itemName']
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 30),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  itemData[
                                                                          'quantity']
                                                                      .toString(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 120,
                                                                  height: 30,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        200],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.0),
                                                                  ),
                                                                  /////////displaystaffcount
                                                                  child: staffCounts[
                                                                              index] >
                                                                          0
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Image.asset(
                                                                              'lib/assets/Staff.png',
                                                                              height: 25,
                                                                              width: 30,
                                                                            ),
                                                                            const SizedBox(width: 10),
                                                                            Text(
                                                                              staffCounts[index] == 0 ? 'Staffs' : staffNames[index],
                                                                              style: const TextStyle(
                                                                                fontSize: 16,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Image
                                                                          .asset(
                                                                          'lib/assets/Staff.png',
                                                                          height:
                                                                              25,
                                                                          width:
                                                                              30,
                                                                        ),
                                                                ),

                                                                const SizedBox(
                                                                    width: 10),
                                                                Visibility(
                                                                  visible: itemData[
                                                                          'discount'] !=
                                                                      0,
                                                                  child:
                                                                      Container(
                                                                    width: 80,
                                                                    height: 30,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          '- ' +
                                                                              itemData['discount'].toStringAsFixed(2),
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.green,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Spacer(), // Added Spacer widget
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right:
                                                                          8.0),
                                                                  child: Text(
                                                                    itemData[
                                                                            'price']
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .blue,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 8.0),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Visibility(
                                                                    visible: itemData[
                                                                            'remarks']
                                                                        .toString()
                                                                        .isNotEmpty,
                                                                    child:
                                                                        const Divider(),
                                                                  ),
                                                                  Visibility(
                                                                    visible: itemData[
                                                                            'remarks']
                                                                        .toString()
                                                                        .isNotEmpty,
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        '* ' +
                                                                            itemData['remarks'].toString(),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black,
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
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        //botommmmmmmmmm
        bottomNavigationBar: SizedBox(
          height: 300,
          child: BottomAppBar(
            elevation: 0,
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20))),
                              builder: (BuildContext context) {
                                return SizedBox(
                                    height: 750,
                                    child: StaffPart(
                                      cartOrderId: widget.cartOrderId,
                                      otems: widget.otems,
                                      skus: skus,
                                    ));
                              },
                            ).then((value) {});
                          },
                          child: Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Staff.png',
                                  height: 25,
                                  width: 30,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Staff',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Container Discount
                        InkWell(
                          onTap: () async {
                            final result = await showModalBottomSheet<
                                Map<String, dynamic>>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20))),
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 750,
                                  child: Discount(
                                    orderId: widget.cartOrderId,
                                    otems: widget.otems,
                                    skus: skus,
                                    updateDiscount: updateDiscount,
                                  ),
                                );
                              },
                            );

                            if (result != null) {
                              Map<String, Map<String, String>> discItemMap =
                                  result['discItemMap'];
                              String discount = result['discount'];
                              latestDiscount = double.parse(result['discount']);

                              // Process the returned data here
                              print('Discount Item Map: $discItemMap');
                              print('Discount: $discount');
                              // Perform further actions with the data as needed
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Discount.png',
                                  height: 25,
                                  width: 30,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Discount',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Container Printer
                        GestureDetector(
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoAlertDialog(
                                title: const Text("Print order"),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("Cancel"),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text("Print"),
                                    onPressed: () {
                                      // Call your print function here
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 120,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Printer.png',
                                  height: 25,
                                  width: 30,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Print',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //display quantity,roundup,subtotal,discount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Quantity',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          nakDisplayQuantity.toString(),
                          //  widget.totalItems.toString(),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Subtotal',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          totalSubtotal.toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: widget.otems.any((item) => item['discount'] != 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Discount',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '-${totalDiscount.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // print(calcDisc(widget.otems));
                          print("what's in otem: ${widget.otems}");

                          // print(newTotalItem);
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20))),
                            builder: (BuildContext context) {
                              return SizedBox(
                                  height: 750,
                                  child: TrialPaymentPage(
                                    calculateSubtotal: allTotal,
                                    cartOrderId: widget.cartOrderId,
                                    otems: widget.otems,
                                  ));
                            },
                          );
                        },
                        child: Text(
                          'Payment: ' + allTotal.toStringAsFixed(2),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void updateQuantity() {
    print("Update Quantity: ");

    setState(() {
      nakDisplayQuantity = widget.otems.fold(
          0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));
    });
    print(" ${widget.totalItems} ");
    print(" $nakDisplayQuantity ");
  }

  Future fetchData() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://order.tunai.io/loyalty/order/ ' +
            widget.cartOrderId +
            '/otems'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);

      if (mounted) {
        // setState(() {
        widget.otems =
            body['otems'].where((item) => item['deleteDate'] == 0).toList();
        skus = body['skus'];
        staff = body['staffs'];
        // });
      }

      print("otems fetchData: ${widget.otems}");

      return widget.otems;
    } else {
      print(response.reasonPhrase);
    }
  }

  Future deleteItem(String otemID) async {
    // int otemInt = int.parse(otemID);
    var headers = {'token': '$token'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print(widget.cartOrderId);
      print("done");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future deleteAll(List<dynamic> otems) async {
    for (int i = 0; i < otems.length; i++) {
      var otemID = otems[i]['otemID'];

      print(otemID);

      var headers = {'token': '$token'};
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        print(widget.cartOrderId);
        print("done");
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  String getTypeName(String typeID) {
    switch (typeID) {
      case '1':
        return 'Service';
      case '2':
        return 'Product';
      default:
        return 'Other';
    }
  }

  void updateRemarks(String otemID, String newRemarks) {
    setState(() {
      for (var itemData in widget.otems) {
        if (itemData['otemID'].toString() == otemID) {
          itemData['remarks'] = newRemarks;
          break;
        }
      }
    });
  }

  void updateStaffValues(String otemID, int newEffort, int newHandon) {
    setState(() {
      for (var itemData in widget.otems) {
        if (itemData['otemID'].toString() == otemID) {
          // Find the staff object within the staffs array
          var staffs = itemData['staffs'];
          for (var staff in staffs) {
            if (staff['staffID'] == 30988) {
              staff['effort'] = newEffort;
              staff['handon'] = newHandon;
              break;
            }
          }
          break;
        }
      }
    });
  }
}
