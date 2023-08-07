import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/payment_sheet.dart';
import 'package:minimal/cart_edit_item.dart';
import 'package:minimal/textFormating.dart';
import 'dart:convert';
import 'cart_display_staff.dart';
import 'discount.dart';
import 'login.dart';

class Cart extends StatefulWidget {
  Cart(
      {Key? key,
      required this.cartName,
      required this.cartOrderId,
      required this.otems,
      required this.totalItems,
      required this.totalPrice,
      required this.fetchData})
      : super(key: key);

  final String cartName;
  final String cartOrderId;
  List<dynamic> otems;
  final Function fetchData;

  int totalItems;
  double totalPrice;

  @override
  State<Cart> createState() => _TrialCart();
}

Map<String, List<Map<String, dynamic>>> typeIDMap = {};

String selectedstaffID = '';
List<dynamic> skus = [];

double newTotalPrice = 0.0;
double newDiscount = 0.0;
int newTotalItem = 0;

bool isItemDeleted = false;

class _TrialCart extends State<Cart> {
  List<dynamic> service = [];
  List<dynamic> products = [];
  List<dynamic> staff = [];

  int staffCount = 0;
  int nakDisplayQuantity = 0;

  TextEditingController remarksController = TextEditingController();

  int? selectedStaffIndex;
  double latestDiscount = 0;

  double afterroundedNumber = 0.0;
  double cartFinalPRice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchData();
    updateCart();
    apigetStaff();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.otems);
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
        totalDiscount = widget.otems.fold(0,
            (sum, otems) => sum + double.parse(otems['discount'].toString()));
      });
      // print("Total Disc dalam update: $totalDiscount");
    }

    // var disc = updateDiscount();
    // var displayDisc = disc;

    int nakDisplayQuantity = widget.otems
        .fold(0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));

    totalDiscount = widget.otems.fold(
        0, (sum, otems) => sum + double.parse(otems['discount'].toString()));

    double totalSubtotal = widget.otems
        .fold(0, (sum, otems) => sum + otems['price'] * otems['quantity']);

    double allDiscount = totalDiscount;

    double allTotal = totalSubtotal - allDiscount;

    double testRounded = roundToNearestFiveCents(allTotal);
    double resultRounded = testRounded - allTotal;

    // double roundedNumber = 0.0;

    // print(widget.totalPrice);

    double screenWidth = MediaQuery.of(context).size.width - 30;
    double width = screenWidth / 3;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            widget.cartName.isNotEmpty ? widget.cartName : "Walk-in",
            style: const TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: Image.asset(
              "lib/assets/Artboard 40.png",
              height: 20,
              width: 20,
            ),
            onPressed: () => Navigator.pop(context, widget.fetchData()),
            iconSize: 24,
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete,
                size: 35,
                color: Colors.red,
              ),
              onPressed: () async {
                await deleteAll(widget.otems);
                updateCart();
              },
            ),
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
                              for (int i = 0; i < widget.otems.length; i++) {
                                dynamic sku = skus.firstWhere((sku) =>
                                    sku['skuID'] == widget.otems[i]['skuID']);
                                final item2 = sku;
                                final typeID = item2['typeID'].toString();

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
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: typeIDMap.length,
                                itemBuilder: (context, index) {
                                  final typeID = typeIDMap.keys.toList()[index];
                                  final typeName = getTypeName(typeID);
                                  final itemList = typeIDMap[typeID]!;

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
                                          final itemData = itemList[index];
                                          var otemID =
                                              itemData['otemID'].toString();

                                          // Create a list to hold the staffCount and staffName for each otems item
                                          List<int> staffCounts = [];
                                          List<String> staffNames = [];

                                          for (var i = 0;
                                              i < widget.otems.length;
                                              i++) {
                                            var otemID =
                                                widget.otems[i]['otemID'];
                                            var staffCount = widget
                                                .otems[i]['staffs'].length;

                                            var staffName = '';

                                            // print("staff");

                                            // print(widget.otems[i]['staffs']);

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
                                            builder: (context) {
                                              String namez = '';
                                              int realOtemId =
                                                  int.parse(otemID);

                                              dynamic otem = widget.otems
                                                  .firstWhere((otem) =>
                                                      otem['otemID'] ==
                                                      realOtemId);

                                              int numOfStaff =
                                                  otem['staffs'].length;

                                              int?
                                                  firstStaffID; // Make 'firstStaffID' nullable by adding '?'

                                              if (otem['staffs'] != null &&
                                                  otem['staffs'].isNotEmpty) {
                                                firstStaffID = otem['staffs'][0]
                                                    ['staffID'];
                                              } else {
                                                // print(
                                                //     'No staff available for the current otem.');
                                              }

                                              Map<String, dynamic>?
                                                  firstStaff; // Make 'firstStaff' nullable by adding '?'
                                              for (var staffEntry in staff) {
                                                if (staffEntry['staffID'] ==
                                                    firstStaffID) {
                                                  firstStaff = staffEntry;
                                                  break;
                                                }
                                              }

                                              String?
                                                  firstName; // Make 'firstName' nullable by adding '?'
                                              if (firstStaff != null) {
                                                firstName = firstStaff['name'];
                                                // print(
                                                //     'Name of the staff with staffID $firstStaffID: $firstName');
                                              } else {
                                                // print(
                                                //     'Staff with staffID $firstStaffID not found.');
                                              }
                                              // print(
                                              //     "First staffID for otemID $realOtemId: $firstStaffID");

                                              // print("check staff: $otem");
                                              //  print("staff: $staff");
                                              // if (otem != null) {
                                              //   List<dynamic> staffsList =
                                              //       otem['staffs'];

                                              //   for (int i = 0;
                                              //       i < staffsList.length;
                                              //       i++) {
                                              //     int idStaff =
                                              //         staffsList[i]['staffID'];

                                              //     var staffInfo =
                                              //         staff.firstWhere(
                                              //       (staffInfo) =>
                                              //           staffInfo['staffID'] ==
                                              //           idStaff,
                                              //       orElse: () => null,
                                              //     );
                                              //     namez =
                                              //     staffInfo['name'].toString();

                                              //     print(idStaff);
                                              //     print(staffInfo);
                                              //      print(namez);

                                              //   }
                                              // }

                                              // for (int i = 0;
                                              //     i < otem.length;
                                              //     i++) {
                                              //   int idstaff = otem[i]['staffs']
                                              //       [0]['staffID'];
                                              //   print(idstaff);
                                              // }

                                              // final toPrint = otem['staffs']['staffID'];
                                              // print("dalam builder: ${toPrint}");

                                              return Dismissible(
                                                key: Key(otemID),
                                                direction:
                                                    DismissDirection.endToStart,
                                                background: Container(
                                                  color: Colors.red,
                                                  child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white),
                                                ),
                                                // onDismissed: (direction) async {
                                                //   await deleteItem(otemID);
                                                //   updateCart();
                                                //   // fetchData();
                                                //   print(otemID);
                                                // },
                                                confirmDismiss:
                                                    (direction) async {
                                                  return await showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return CupertinoAlertDialog(
                                                        title: const Text(
                                                            "Confirmation"),
                                                        content: const Text(
                                                            "Are you sure you want to delete this service / product?"),
                                                        actions: [
                                                          CupertinoDialogAction(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(
                                                                        false), // No button
                                                            child: const Text(
                                                                "No"),
                                                          ),
                                                          CupertinoDialogAction(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(
                                                                        true), // Yes button
                                                            child: const Text(
                                                                "Yes"),
                                                            isDestructiveAction:
                                                                true,
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                onDismissed: (direction) async {
                                                  await deleteItem(otemID);
                                                  updateCart();
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
                                                      builder: (BuildContext
                                                          context) {
                                                        return SizedBox(
                                                          height: 750,
                                                          child: CartEditItem(
                                                            cartOrderId: widget
                                                                .cartOrderId,
                                                            otemOtemID: itemData[
                                                                    'otemID']
                                                                .toString(),
                                                            otemSkuID: itemData[
                                                                    'skuID']
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
                                                            updateCart:
                                                                updateCart,
                                                          ),
                                                        );
                                                      },
                                                    );

                                                    if (updatedItemData !=
                                                        null) {
                                                      print("updatedItemData");
                                                      print(updatedItemData);
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
                                                  },
                                                  child: Card(
                                                    elevation: 0,
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                                    child: numOfStaff >
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
                                                                              Expanded(
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 5.0), // Add horizontal padding
                                                                                  child: FittedBox(
                                                                                    fit: BoxFit.scaleDown,
                                                                                    alignment: Alignment.centerLeft,
                                                                                    child: Text(
                                                                                      numOfStaff == 1 ? '$firstName' : '$numOfStaff Staffs',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 16,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ),
                                                                                  ),
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
                                                                      width:
                                                                          10),
                                                                  Visibility(
                                                                    visible:
                                                                        itemData['discount'] !=
                                                                            0,
                                                                    child:
                                                                        Container(
                                                                      width: 80,
                                                                      height:
                                                                          30,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        borderRadius:
                                                                            BorderRadius.circular(5.0),
                                                                      ),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            '- ' +
                                                                                itemData['discount'].toStringAsFixed(2),
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.green,
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
                                                                        top:
                                                                            8.0),
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
                                                                            const EdgeInsets.all(8.0),
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
                                              );
                                            },
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
            // elevation: 0,
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
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                      updateCart: updateCart,
                                    ));
                              },
                            ).then((value) {});
                          },
                          //container staff
                          child: Container(
                            width: width,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Staff.png',
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Staff',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        //Container Discount
                        InkWell(
                          onTap: () async {
                            final result = await showModalBottomSheet<
                                Map<String, dynamic>>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8))),
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 750,
                                  child: Discount(
                                    orderId: widget.cartOrderId,
                                    otems: widget.otems,
                                    skus: skus,
                                    updateDiscount: updateDiscount,
                                    updateCart: updateCart,
                                  ),
                                );
                              },
                            );

                            if (result != null) {
                              Map<String, Map<String, String>> discItemMap =
                                  result['discItemMap'];
                              setState(() {
                                String discount = result['discount'];
                                latestDiscount =
                                    double.parse(result['discount']);
                                widget.otems;
                              });

                              // Process the returned data here
                              // print('Discount Item Map: $discItemMap');
                              // print('Discount: $discount');
                              // Perform further actions with the data as needed
                            }
                          },
                          child: Container(
                            width: width,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Discount.png',
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Discount',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
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
                            width: width,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'lib/assets/Printer.png',
                                  height: 18,
                                  width: 18,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Print',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
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
                          // totalSubtotal.toStringAsFixed(2),
                          // allTotal.toStringAsFixed(2),
                          formatDoubleText(allTotal),
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
                  Visibility(
                     visible: widget.otems.any((item) => item['discount'] != 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Roundup', // Change 'Discount' to 'Roundup'
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            resultRounded.toStringAsFixed(
                                2), // Use roundToNearestFiveCents function
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // print(calcDisc(widget.otems));
                          // print("what's in otem: ${widget.otems}");

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
                                  child: PaymentSheet(
                                    finalPrice:
                                        testRounded, //yg display dekat payment
                                    orderId: widget.cartOrderId,
                                    roundedPrice: testRounded,
                                    otems: widget.otems,
                                    roundvalue: resultRounded, //nilai rounded
                                  ));

                              // child: TrialPaymentPage(
                              //   calculateSubtotal: testRounded,
                              //   cartOrderId: widget.cartOrderId,
                              //   otems: widget.otems, afterroundedNumber: resultRounded,
                              // ));
                            },
                          );
                        },
                        child: Text(
                          // 'Payment: ${finalPrice(allTotal).toStringAsFixed(2)}',
                          'Payment: ${formatDoubleText(testRounded)}',
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

  // double roundToNearestFiveCents(double allTotal) {
  //   setState(() {
  //     double roundedNumber = (allTotal * 20).roundToDouble() / 20;
  //     // afterroundedNumber = allTotal - roundedNumber;
  //       afterroundedNumber = roundedNumber;
  //   });
  //   print("value ru: $afterroundedNumber");
  //   return afterroundedNumber;
  // }

  double roundToNearestFiveCents(double allTotal) {
    double roundedNumber = (allTotal * 20).roundToDouble() / 20;
    return roundedNumber;
  }

  double finalPrice(allTotal) {
    setState(() {
      cartFinalPRice = allTotal - afterroundedNumber;
    });

    return cartFinalPRice;
  }

  updateQuantity() {
    print("Update Quantity: ");

    setState(() {
      nakDisplayQuantity = widget.otems.fold(
          0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));
    });
  }

  Future fetchData() async {
    var headers = {'token': tokenGlobal};
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
        // staff = body['staffs'];
        // });
      }

      return widget.otems;
    } else {
      print(response.reasonPhrase);
    }
  }

  updateCart() async {
    await fetchData();
    setState(() {});
  }

  Future deleteItem(String otemID) async {
    // int otemInt = int.parse(otemID);
    var headers = {'token': '$tokenGlobal'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      // print(widget.cartOrderId);
      // print("done");
    } else {
      print(response.reasonPhrase);
    }
  }

  Future deleteAll(List<dynamic> otems) async {
    for (int i = 0; i < otems.length; i++) {
      var otemID = otems[i]['otemID'];
      var headers = {'token': '$tokenGlobal'};
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        // print(await response.stream.bytesToString());
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

  Future<void> apigetStaff() async {
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

      setState(() {
        staff = body['staffs'];
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}
