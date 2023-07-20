// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:minimal/pending.dart';
// import 'package:minimal/testingstaff.dart';
// import 'api.dart';
// import 'dart:convert';
// import 'menu.dart';
// import 'payment/payment.dart';

// class cartPage extends StatefulWidget {
//   cartPage(
//       {Key? key,
//       required this.cartName,
//       required this.cartOrderId,
//       required this.totalItems,
//       required this.totalPrice})
//       : super(key: key);

//   final String cartName;
//   final String cartOrderId;

//   int totalItems;
//   double totalPrice;

//   @override
//   State<cartPage> createState() => _cartPage();
// }

// Map<String, List<Map<String, dynamic>>> typeIDMap = {};

// String selectedstaffID = '';
// List<dynamic> otems = [];
// List<dynamic> skus = [];

// double newTotalPrice = 0.0;
// double newDiscount = 0.0;
// int newTotalItem = 0;


// class _cartPage extends State<cartPage> {

//   List<dynamic> service = [];
//   List<dynamic> products = [];
//   List<dynamic> staff = [];

//   int staffCount = 0;

//   TextEditingController remarksController = TextEditingController();

//   int? selectedStaffIndex;
//   double latestDiscount = 0;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     //widget.totalItems = calTotalQuantity(otems);
//     newTotalPrice = calSub(otems);
//   }


//   int calTotalQuantity(List<dynamic> otems) {
//     return otems.fold(
//         0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));
//   }

  

//   void updateQuantity() {
//     print("function");
//     print(calTotalQuantity(otems));
//     setState(() {
//       widget.totalItems = calTotalQuantity(otems);
//     });
//   }

//   double calSub(List<dynamic> otems) {
//     double sum = 0;
//     for (var item in otems) {
//       if (item != null && item['price'] != null && item['quantity'] != null) {
//         try {
//           double price = double.parse(item['price'].toString());
//           int quantity = int.parse(item['quantity'].toString());
//           sum += price * quantity;
//         } catch (e) {
//           print('Error calculating price: $e');
//         }
//       }
//     }
//     return sum;
//   }

//   void updateSubtotal() {
//     setState(() {
//       newTotalPrice = calSub(otems);
//       print("newsubtotal: $newTotalPrice");
//     });
//   }

//   double lastTotal() {
//     double subTotal = calSub(otems);
//     double totalDiscount = calcDisc(otems);
//     double allTotal = subTotal - totalDiscount;
//     return allTotal;
//   }

//   double calcDisc(List<dynamic> otems) {
//     double disc = 0;

//     for (var itemData in otems) {
//       final discount = itemData['discount'];
//       if (discount != null) {
//         disc += discount;
//       }
//     }

//     // return disc + latestDiscount;
//     return latestDiscount;
//   }

//   void updateDiscount() {
//     setState(() {
//       newDiscount = calcDisc(otems);
//     });
//   }

//   double calcRoundUp(List<dynamic> otems) {
//     double subtotal = calSub(otems);
//     double roundedUp = (subtotal.ceil() - subtotal);

//     return roundedUp;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print(widget.totalItems);
//      print(widget.totalPrice);
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           title: Text(
//             widget.cartName,
//             style: const TextStyle(color: Colors.black),
//           ),
//           leading: IconButton(
//             icon: Image.asset(
//               "lib/assets/Artboard 40.png",
//               height: 20,
//               width: 20,
//             ),
//             onPressed: () => Navigator.pop(context),
//             iconSize: 24,
//           ),
//           actions: [
//             IconButton(
//                 icon: Image.asset("lib/assets/Pending.png"), onPressed: () {})
//           ],
//         ),
//         //in case tak nampak, coding body di siniiiii
//         body: SingleChildScrollView(
//           child: Stack(
//             children: [
//               Container(
//                 color: Colors.grey[200],
//               ),
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [Expanded(child: otemsDisplay())],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: bottomContainerCalculation());
//   }

//   Future fetchData() async {
//     var headers = {'token': token};
//     var request = http.Request(
//         'GET',
//         Uri.parse('https://order.tunai.io/loyalty/order/ ' +
//             widget.cartOrderId +
//             '/otems'));

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       final responsebody = await response.stream.bytesToString();
//       final body = json.decode(responsebody);

//       otems = body['otems'].where((item) => item['deleteDate'] == 0).toList();
//       skus = body['skus'];
//       staff = body['staffs'];
//       staffCount = staff.length;

//       return otems;
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

//   Widget otemsDisplay() {
//     print(otems);
//     return FutureBuilder(
//       future: fetchData(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else {
//           typeIDMap.clear();

//           for (int i = 0; i < skus.length; i++) {
//             final item2 = skus[i];
//             final typeID = item2['typeID'].toString();

//             if (!typeIDMap.containsKey(typeID)) {
//               typeIDMap[typeID] = [];
//             }
//             typeIDMap[typeID]!.add({
//               'itemName': item2['name'].toString(),
//               'otemID': otems[i]['otemID'],
//               'skuID': skus[i]['skuID'],
//               'quantity': otems[i]['quantity'].toString(),
//               'discount': otems[i]['discount'],
//               'price': otems[i]['price'],
//               'remarks': otems[i]['remarks'].toString(),
//             });

//             print(typeIDMap);
//             print("newsubtotal: $newTotalPrice");
//           }

//           return ListView.builder(
//             shrinkWrap: true,
//             itemCount: typeIDMap.length,
//             itemBuilder: (context, index) {
//               final typeID = typeIDMap.keys.toList()[index];
//               final typeName = getTypeName(typeID);
//               final itemList = typeIDMap[typeID]!;

//               if (itemList.isEmpty) {
//                 return Container();
//               }

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       typeName,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: itemList.length,
//                     itemBuilder: (context, itemIndex) {
//                       final itemData = itemList[itemIndex];
                     

//                       // Create a list to hold the staffCount and staffName for each otems item
//                       List<int> staffCounts = [];
//                       List<String> staffNames = [];

//                       // Iterate over each otems item
//                       for (var i = 0; i < otems.length; i++) {
//                         var staffCount = otems[i]['staffs'].length;
//                         var staffName = '';

//                         if (staffCount == 1) {
//                           var staffID = otems[i]['staffs'][0]['staffID'];
//                           var staffInfo = otems[i]['staffs'].firstWhere(
//                             (staff) => staff['staffID'] == staffID,
//                             orElse: () => {},
//                           );
//                           staffName = staffInfo['staffID'].toString();
//                         } else if (staffCount > 1) {
//                           staffName = '$staffCount staffs';
//                         }

//                         // Add the staffCount and staffName to the respective lists
//                         staffCounts.add(staffCount);
//                         staffNames.add(staffName);
//                       }

//                       return InkWell(
//                         onTap: () async {
//                           final updatedItemData = await showModalBottomSheet(
                            
//                             context: context,
//                             isScrollControlled: true,
//                             shape: const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(20))),
//                             builder: (BuildContext context) {
//                               return SizedBox(
//                                 height: 750,
//                                 child: EditItem(
//                                   cartOrderId: widget.cartOrderId,
//                                   otemOtemID: itemData['otemID'].toString(),
//                                   otemSkuID: itemData['skuID'].toString(),
//                                   itemData: itemData,
//                                   staff: staff,
//                                   otem: otems,
//                                   updateRemarks: (otemID, newRemarks) {
//                                     updateRemarks(otemID, newRemarks);
//                                   },
//                                   updateQuantity: updateQuantity,
//                                   updateDiscount: updateDiscount,
//                                   updateStaffValues: updateStaffValues,
//                                 ),
//                               );
//                             },
//                           );

//                           if (updatedItemData != null) {
//                             final index = otems.indexWhere((item) =>
//                                 item['otemID'] == updatedItemData['otemID']);
//                             if (index != -1) {
//                               setState(() {
//                                 otems[index] = updatedItemData;
//                               });
//                             }
//                           }
//                           print("updatedItemData");
//                           print(updatedItemData);
//                         },
//                         child: Card(
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       itemData['itemName'].toString(),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 30),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           itemData['quantity'].toString(),
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Container(
//                                           width: 120,
//                                           height: 30,
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey[200],
//                                             borderRadius:
//                                                 BorderRadius.circular(5.0),
//                                           ),
//                                           child: staffCounts[itemIndex] > 0
//                                               ? Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     Image.asset(
//                                                       'lib/assets/Staff.png',
//                                                       height: 25,
//                                                       width: 30,
//                                                     ),
//                                                     const SizedBox(width: 10),
//                                                     Text(
//                                                       staffCounts[itemIndex] ==
//                                                               0
//                                                           ? 'Staffs'
//                                                           : staffNames[
//                                                               itemIndex],
//                                                       style: const TextStyle(
//                                                         fontSize: 16,
//                                                         color: Colors.black,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 )
//                                               : Image.asset(
//                                                   'lib/assets/Staff.png',
//                                                   height: 25,
//                                                   width: 30,
//                                                 ),
//                                         ),

//                                         const SizedBox(width: 10),
//                                         Visibility(
//                                           visible: itemData['discount'] !=
//                                               0, // Check if discount is not zero
//                                           child: Container(
//                                             width: 80,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               color: Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(5.0),
//                                             ),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 const SizedBox(width: 10),
//                                                 Text(
//                                                   '- ' +
//                                                       itemData['discount']
//                                                           .toStringAsFixed(2),
//                                                   style: const TextStyle(
//                                                     fontSize: 16,
//                                                     color: Colors.green,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Spacer(), // Added Spacer widget
//                                         Padding(
//                                           padding:
//                                               const EdgeInsets.only(right: 8.0),
//                                           child: Text(
//                                             itemData['price']
//                                                 .toStringAsFixed(2),
//                                             style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Visibility(
//                                             visible: itemData['remarks']
//                                                 .toString()
//                                                 .isNotEmpty,
//                                             child: const Divider(),
//                                           ),
//                                           Visibility(
//                                             visible: itemData['remarks']
//                                                 .toString()
//                                                 .isNotEmpty,
//                                             child: Padding(
//                                               padding:
//                                                   const EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 '* ' +
//                                                     itemData['remarks']
//                                                         .toString(),
//                                                 style: const TextStyle(
//                                                   fontSize: 16,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               );
//             },
//           );
//         }
//       },
//     );
//   }

//   String getTypeName(String typeID) {
//     switch (typeID) {
//       case '1':
//         return 'Service';
//       case '2':
//         return 'Product';
//       default:
//         return 'Other';
//     }
//   }

//   void updateRemarks(String otemID, String newRemarks) {
//     setState(() {
//       for (var itemData in otems) {
//         if (itemData['otemID'].toString() == otemID) {
//           itemData['remarks'] = newRemarks;
//           break;
//         }
//       }
//     });
//   }

//   // List<dynamic> otems = [];

//   void updateStaffValues(String otemID, int newEffort, int newHandon) {
//     setState(() {
//       for (var itemData in otems) {
//         if (itemData['otemID'].toString() == otemID) {
//           // Find the staff object within the staffs array
//           var staffs = itemData['staffs'];
//           for (var staff in staffs) {
//             if (staff['staffID'] == 30988) {
//               staff['effort'] = newEffort;
//               staff['handon'] = newHandon;
//               break;
//             }
//           }
//           break;
//         }
//       }
//     });
//   }

//   void deleteOtems(String otemID) async {
//     var headers = {'token': token};

//     final url = Uri.parse(
//         'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete');
//     final request = http.Request('POST', url)..headers.addAll(headers);

//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order $otemID has been deleted')),
//       );

//       setState(() {
//         otems.removeWhere((item) => item['otemID'] == otemID);
//         for (var entry in storeServiceAndProduct.entries) {
//           var itemData = entry.value;
//           itemData.removeWhere(
//               (key, value) => value['otemID'].toString() == otemID);
//         }
//       });

//       print('After delete: $otems');
//       print(responseBody);
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

//   Future<void> deleteItem(String otemID) async {
//     var headers = {'token': token};
//     var request = http.Request(
//       'POST',
//       Uri.parse(
//           'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/delete'),
//     );

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Order $otemID has been deleted')),
//       );
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

// //semua yang display kat bottom
//   Widget bottomContainerCalculation() {

//     final totalAdam = otems.fold(
//         0, (sum, otems) => sum + int.parse(otems['quantity'].toString()));
        
//     final totalQuantity = calTotalQuantity(otems);
//     final totalSub = calSub(otems);
//     final disc = calcDisc(otems);
//     final roundup = calcRoundUp(otems);
//     final thetotal = lastTotal();
//     return SizedBox(
//       height: 300,
//       child: BottomAppBar(
//         elevation: 0,
//         child: Container(
//           width: double.infinity,
//           height: 300,
//           color: Colors.white,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         showModalBottomSheet<void>(
//                           context: context,
//                           isScrollControlled: true,
//                           shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(20))),
//                           builder: (BuildContext context) {
//                             return SizedBox(
//                                 height: 750,
//                                 child: StaffPart(
//                                   cartOrderId: widget.cartOrderId,
//                                   otems: otems,
//                                 ));
//                           },
//                         ).then((value) {});
//                       },
//                       child: Container(
//                         width: 120,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'lib/assets/Staff.png',
//                               height: 25,
//                               width: 30,
//                             ),
//                             const SizedBox(width: 10),
//                             const Text(
//                               'Staff',
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     //Container Discount
//                     InkWell(
//                       onTap: () async {
//                         final result =
//                             await showModalBottomSheet<Map<String, dynamic>>(
//                           context: context,
//                           isScrollControlled: true,
//                           shape: const RoundedRectangleBorder(
//                               borderRadius: BorderRadius.vertical(
//                                   top: Radius.circular(20))),
//                           builder: (BuildContext context) {
//                             return SizedBox(
//                               height: 750,
//                               child: Discount(
//                                 orderId: widget.cartOrderId,
//                                 otems: otems,
//                                 updateDiscount: updateDiscount,
//                               ),
//                             );
//                           },
//                         );

//                         if (result != null) {
//                           Map<String, Map<String, String>> discItemMap =
//                               result['discItemMap'];
//                           String discount = result['discount'];
//                           latestDiscount = double.parse(result['discount']);

//                           // Process the returned data here
//                           print('Discount Item Map: $discItemMap');
//                           print('Discount: $discount');
//                           // Perform further actions with the data as needed
//                         }
//                       },
//                       child: Container(
//                         width: 120,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'lib/assets/Discount.png',
//                               height: 25,
//                               width: 30,
//                             ),
//                             const SizedBox(width: 10),
//                             const Text(
//                               'Discount',
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     //Container Printer
//                     GestureDetector(
//                       onTap: () {
//                         showCupertinoDialog(
//                           context: context,
//                           builder: (BuildContext context) =>
//                               CupertinoAlertDialog(
//                             title: const Text("Print order"),
//                             actions: [
//                               CupertinoDialogAction(
//                                 child: const Text("Cancel"),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               CupertinoDialogAction(
//                                 child: const Text("Print"),
//                                 onPressed: () {
//                                   // Call your print function here
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                       child: Container(
//                         width: 120,
//                         height: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(5.0),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'lib/assets/Printer.png',
//                               height: 25,
//                               width: 30,
//                             ),
//                             const SizedBox(width: 10),
//                             const Text(
//                               'Print',
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.black),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       'Quantity',
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8.0),
//                     child: Text(
//                     totalAdam.toString(),
//                       style: const TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Text(
//                       'Subtotal',
//                       style: TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(right: 8.0),
//                     child: Text(
//                       widget.totalPrice.toStringAsFixed(2),
//                       style: const TextStyle(fontSize: 16, color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: roundup != 0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Roundup',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Text(
//                         roundup.toStringAsFixed(2),
//                         style:
//                             const TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Visibility(
//                 visible: disc != 0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Text(
//                         'Discount',
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Text(
//                         '-${newDiscount.toStringAsFixed(2)}',
//                         style: TextStyle(fontSize: 16, color: Colors.green),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   width: double.infinity,
//                   height: 44,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       print(calcDisc(otems));
//                       print("what's in otem: $otems");

//                       print(newTotalItem);
//                       showModalBottomSheet<void>(
//                         context: context,
//                         isScrollControlled: true,
//                         shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                                 top: Radius.circular(20))),
//                         builder: (BuildContext context) {
//                           return SizedBox(
//                               height: 750,
//                               child: Payment(
//                                 calculateSubtotal: thetotal,
//                                 cartOrderId: widget.cartOrderId,
//                                 otems: otems,
//                               ));
//                         },
//                       );
//                     },
//                     child: Text(
//                       'Payment: ' + widget.totalPrice.toStringAsFixed(2),
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// typeIDMap[typeID]!.add({
//                                   'itemName': item2['name'].toString(),
//                                   'otemID': widget.otems.isNotEmpty &&
//                                           i < widget.otems.length
//                                       ? widget.otems[i]['otemID']
//                                       : '',
//                                   'skuID': skus[i]['skuID'],
//                                   'quantity': widget.otems.isNotEmpty &&
//                                           i < widget.otems.length
//                                       ? widget.otems[i]['quantity']
//                                       : '',
//                                   'discount': widget.otems.isNotEmpty &&
//                                           i < widget.otems.length
//                                       ? widget.otems[i]['discount']
//                                       : 0,
//                                   'price': widget.otems.isNotEmpty &&
//                                           i < widget.otems.length
//                                       ? widget.otems[i]['price']
//                                       : 0,
//                                   'remarks': widget.otems.isNotEmpty &&
//                                           i < widget.otems.length
//                                       ? widget.otems[i]['remarks']
//                                       : '',
//                                 });


/////backup OrdersPending
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:minimal/test/addMember.dart';
// import 'package:minimal/test/firstPage.dart';
// import 'package:minimal/test/memberPage.dart';
// import 'package:minimal/test/trialMenu.dart';
// import 'package:minimal/test/walkin.dart';
// import 'api.dart';
// import 'dart:convert';
// import 'intro.dart';
// import 'menu.dart';

// class OrdersPending extends StatefulWidget {
//   const OrdersPending({
//     required this.getLatest,
//     Key? key,
//   }) : super(key: key);

//   final Function getLatest;

//   @override
//   State<OrdersPending> createState() => _OrdersPendingState();
// }

// class _OrdersPendingState extends State<OrdersPending> {
//   List<dynamic> orders = [];
//   List<dynamic> members = [];

//   List<dynamic> testorders = [];
//   List<dynamic> testmembers = [];
//   List simpan = [];

//   List<dynamic> walkin = [];
//   List<dynamic> walkinOrder = [];
//   String memberName = "Walk-In";
//   String mobile = "0000000000";

//   int walkInMemberID = 0;

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

//   Widget pendingIcon() {
//     return IconButton(
//         icon: Image.asset("lib/assets/Pending.png"),
//         onPressed: () {
//           // Implement onPressed action
//         });
//   }

//   @override
//   void initState() {
//     super.initState();
//     // displayPending();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         title: const Text(
//           'Pending Order',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: IconButton(
//           icon: Image.asset(
//             "lib/assets/Artboard 40.png",
//             height: 30,
//             width: 20,
//           ),
//           onPressed: () => Navigator.pop(context, orders),
//           iconSize: 24,
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               color: Colors.grey[200],
//             ),
//             Column(
//               children: [inPending()],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget inPending() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             height: 95,
//             width: double.infinity,
//             color: Colors.grey[200]?.withOpacity(0.0),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => const AddMember()),
//                             );
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //       builder: (context) => const intro()),
//                             // );
//                           },
//                           child: Container(
//                             height: 35,
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'lib/assets/3.png',
//                                   height: 19,
//                                   width: 22,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   'New',
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.white),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () async {
//                             createOrder();

//                             /////////////////////////////////////////////////////////////
//                             //   var headers = {'token': token};
//                             //   var request = http.Request(
//                             //       'GET',
//                             //       Uri.parse(
//                             //           'https://member.tunai.io/cashregister/member/walkin'));

//                             //   request.headers.addAll(headers);

//                             //   http.StreamedResponse response =
//                             //       await request.send();

//                             //   if (response.statusCode == 200) {
//                             //     final responsebody =
//                             //         await response.stream.bytesToString();
//                             //     var body = json.decode(responsebody);
//                             //     Map<String, dynamic> _walkin = body;

//                             //     walkin = _walkin['members'];

//                             //     if (walkin != null && walkin.isNotEmpty) {
//                             //       for (var i = 0; i < walkin.length; i++) {
//                             //         walkInMemberID = walkin[i]['memberID'];
//                             //       }
//                             //     }
//                             //   } else {
//                             //     print(response.reasonPhrase);
//                             //   }
//                             //   print(walkin);

//                             //   print(walkInMemberID);
//                           },
//                           child: Container(
//                             height: 35,
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'lib/assets/1.png',
//                                   height: 19,
//                                   width: 22,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   'Walk-in',
//                                   style: TextStyle(
//                                       fontSize: 16, color: Colors.white),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => CarMemberPage()),
//                         );
//                       },
//                       child: Container(
//                         height: 35,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.blue,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'lib/assets/2.png',
//                               height: 19,
//                               width: 22,
//                             ),
//                             SizedBox(width: 10),
//                             Text(
//                               'Search member',
//                               style:
//                                   TextStyle(fontSize: 16, color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(left: 15.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'Order list',
//                 style: TextStyle(fontSize: 16, color: Colors.black),
//               ),
//             ],
//           ),
//         ),
//         displayPending(),
//         // testingDisplay(),
//         Padding(
//           padding: const EdgeInsets.only(left: 15.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text(
//                 'System will automatically delete orders older than 2 days.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

  // Widget testingDisplay() {
  //   return FutureBuilder(
  //     future: getOrder(),
  //     builder: (context, snapshot) {
  //       if (!snapshot.hasData) {
  //         return Text('Loading');
  //       } else {
  //         return Expanded(
  //           child: Container(
  //             child: ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: simpan.length,
  //               itemBuilder: (context, index) {
  //                 final data = simpan[index];
  //                 return Card(
  //                   child: Container(
  //                     child: GestureDetector(
  //                       onTap: () {},
  //                       child: Column(
  //                         children: [
  //                           Container(
  //                             width: 350,
  //                             child: Text(
  //                               "ORDER ID: ${data['orderID']}",
  //                               textAlign: TextAlign.left,
  //                             ),
  //                           ),
  //                           ElevatedButton(
  //                             onPressed: () {},
  //                             child: Text('Delete'),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }
  // Widget displayPending() {
  //   return FutureBuilder(
  //     future: fetchPendingAndMembers(),
  //     builder:
  //         (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasError) {
  //         return Center(
  //           child: Text('Error: ${snapshot.error}'),
  //         );
  //       } else {
  //         Map<String, dynamic>? data = snapshot.data;
  //         if (data == null) {
  //           return const Center(
  //             child: Text('No data available.'),
  //           );
  //         }

  //         orders = data['pending'] ?? [];
  //         members = data['members'] ?? [];

  //         return ListView.builder(
  //           shrinkWrap: true,
  //           physics: const ScrollPhysics(),
  //           itemCount: orders.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             var order = orders[index];
  //             var memberID = order['memberID'].toString();
  //             final orderId = order['orderID'];

  //             // Find the member with matching memberID
  //             var memberData = members.firstWhere(
  //                 (member) => member['memberID'].toString() == memberID,
  //                 orElse: () => null);

  //             var memberName = memberData != null ? memberData['name'] : 'N/A';
  //             var memberMobile =
  //                 memberData != null ? memberData['mobile'] : 'N/A';

  //             String formattedNumber =
  //                 '(${memberMobile.substring(0, 4)}) ${memberMobile.substring(4, 7)}-${memberMobile.substring(7)}';

  //             return GestureDetector(
  //               onTap: () {
  //                 showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return CupertinoTheme(
  //                       data: CupertinoThemeData(
  //                         primaryContrastingColor: Colors.white,
  //                       ),
  //                       child: CupertinoAlertDialog(
  //                         title: Text('Switch customer'),
  //                         content: Text('Switch to $memberName\'s order?'),
  //                         actions: [
  //                           CupertinoDialogAction(
  //                             child: Text('No'),
  //                             onPressed: () {
  //                               Navigator.of(context).pop();
  //                             },
  //                           ),
  //                           CupertinoDialogAction(
  //                             child: Text('Yes'),
  //                             onPressed: () {
  //                               Navigator.of(context)
  //                                   .pop(); // Dismiss the dialog
  //                               Navigator.of(context).pop();
  //                             },
  //                           ),
  //                         ],
  //                       ),
  //                     );
  //                   },
  //                 );
  //               },
  //               child: Padding(
  //                 padding:
  //                     const EdgeInsets.only(top: 5.0, left: 8.0, right: 8.0),
  //                 child: Dismissible(
  //                   key: Key(orderId.toString()),
  //                   direction: DismissDirection.endToStart,
  //                   background: Container(
  //                     color: Colors.red,
  //                     child: const Icon(Icons.delete, color: Colors.white),
  //                   ),
  //                   onDismissed: (direction) {
  //                     deleteOrder(orderId);
  //                     setState(() {
  //                       widget.getLatest;
  //                     });
  //                     print(orderId);
  //                   },
  //                   child: Card(
  //                     child: Column(children: [
  //                       Row(
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.only(left: 8.0),
  //                             child: Image.asset(
  //                               "lib/assets/Artboard 40 copy 2.png",
  //                               width: 30,
  //                               height: 30,
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.only(
  //                               left: 16,
  //                             ), // Add padding to the left
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(
  //                                   memberName,
  //                                   style: const TextStyle(
  //                                     fontSize: 18,
  //                                     color: Colors.black,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                 ),
  //                                 SizedBox(height: 8),
  //                                 Text(
  //                                   formattedNumber,
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     color: Colors.grey,
  //                                     overflow: TextOverflow.ellipsis,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Divider(),
  //                           Padding(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.access_time,
  //                                   size: 18,
  //                                   color: Colors.grey,
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(left: 8.0),
  //                                   child: Text(
  //                                     DateFormat('dd-MM-yyyy').format(
  //                                         DateTime.fromMillisecondsSinceEpoch(
  //                                             order['createDate'] * 1000)),
  //                                     style: TextStyle(
  //                                       color: Colors.grey,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 Spacer(),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(left: 8.0),
  //                                   child: Text(
  //                                     order['amount'].toStringAsFixed(2),
  //                                     style: TextStyle(
  //                                       color: Colors.black,
  //                                       fontWeight: FontWeight.bold,
  //                                       fontSize: 18,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       )
  //                     ]),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       }
  //     },
  //   );
  // }

  // Future deleteOrder(int orderId) async {
  //   var headers = {'token': token};
  //   var request = http.Request('POST',
  //       Uri.parse('https://order.tunai.io/loyalty/order/$orderId/delete'));

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       widget.getLatest;
  //     });
  //     print(await response.stream.bytesToString());
  //     print("delete order");
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  // Future<Map<String, dynamic>> fetchPendingAndMembers() async {
  //   var headers = {
  //     'token': token,
  //   };

  //   var pendingRequest = http.Request(
  //     'GET',
  //     Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
  //   );
  //   pendingRequest.headers.addAll(headers);

  //   var membersRequest = http.Request(
  //     'GET',
  //     Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
  //   );
  //   membersRequest.headers.addAll(headers);

  //   var pendingResponse = await http.Client().send(pendingRequest);
  //   var membersResponse = await http.Client().send(membersRequest);

  //   if (pendingResponse.statusCode == 200 &&
  //       membersResponse.statusCode == 200) {
  //     final pendingResponseBody = await pendingResponse.stream.bytesToString();
  //     final membersResponseBody = await membersResponse.stream.bytesToString();
  //     final pendingBody = json.decode(pendingResponseBody);
  //     final membersBody = json.decode(membersResponseBody);

  //     orders = pendingBody['orders'];
  //     members = membersBody['members'];

  //     Map<String, dynamic> result = {
  //       'pending': orders,
  //       'members': members,
  //     };

  //     // print('In the result: $result');
  //     return result;
  //   } else {
  //     print(pendingResponse.reasonPhrase);
  //     print(membersResponse.reasonPhrase);
  //     return {};
  //   }
  // }

  // Future getOrder() async {
  //   var headers = {
  //     'token': token,
  //   };

  //   var request = http.Request(
  //       'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     final responsebody = await response.stream.bytesToString();
  //     final body = json.decode(responsebody);
  //     //message untuk save data dalam
  //     Map<String, dynamic> orderz = body;
  //     simpan = [];
  //     testorders = orderz['orders'];

  //     for (int i = 0; i < testorders.length; i++) {
  //       simpan.add(testorders[i]);
  //     }
  //     print(testorders);
  //     return testorders;
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

//   Future createOrder() async {
//     var headers = {
//       'token': token,
//       'Content-Type': 'application/x-www-form-urlencoded'
//     };

//     var request =
//         http.Request('POST', Uri.parse('https://order.tunai.io/loyalty/order'));

//     var memberID = '21887957';
//     request.bodyFields = {'memberID': memberID};
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       final responsebody = await response.stream.bytesToString();
//       final body = json.decode(responsebody);

//       walkinOrder = body['orders'];
//       var orderID = walkinOrder[0]['orderID'];

//       setState(() {});

//       // dynamic wOrder = walkinOrder.firstWhere(
//       //                           (wOrder) => "21887957" == wOrder['memberID']);
//       //                       final walkOrder = wOrder;
//       //                       final walkOrderId = walkOrder[0]['orderID'];

//       print("walkinOrder: $walkinOrder orderID: $orderID ");

//       // ignore: use_build_context_synchronously
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => trialMenuPage(
//                   memberMobile: mobile,
//                   memberName: memberName,
//                   orderId: orderID.toString(),
//                 )),
//       );
//     } else {
//       print(response.reasonPhrase);
//     }
//   }
// }

// CupertinoDialogAction(
//                               child: Text('Yes'),
//                               onPressed: () {
//                                 Navigator.of(context)
//                                     .pop(); // Dismiss the dialog
//                                 Navigator.of(context)
//                                     .push(
//                                       PageRouteBuilder(
//                                         pageBuilder: (context, animation,
//                                                 secondaryAnimation) =>
//                                             //sini pakai testMenuPage
//                                             trialMenuPage(
//                                           orderId: orderId.toString(),
//                                           // memberId: (orders[index] as Map<
//                                           //         String, dynamic>)['memberID']
//                                           //     .toString(),
//                                           memberName: memberName,
//                                           memberMobile: formattedNumber,
//                                         ),
//                                         transitionsBuilder: (context, animation,
//                                             secondaryAnimation, child) {
//                                           return SlideTransition(
//                                             position: Tween<Offset>(
//                                               begin: Offset(0,
//                                                   1), // Start the transition from bottom
//                                               end: Offset.zero,
//                                             ).animate(animation),
//                                             child: child,
//                                           );
//                                         },
//                                       ),
//                                     )
//                                     .then((value) => setState(() {}));
//                               },
//                             ),
//TrialEditItemPunyaBarang
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:minimal/testingSelectStaff.dart';
// import '../api.dart';
// import '../cart.dart';
// import '../function.dart';
// import 'login.dart';

// //showModalBottom for edit item in each service & product
// class TrialEditItem extends StatefulWidget {
//   const TrialEditItem(
//       {required this.cartOrderId,
//       required this.otemOtemID,
//       required this.otemSkuID,
//       // required this.staff,
//       required this.otem,
//       required this.itemData,
//       required this.updateQuantity,
//       required this.updateRemarks,
//       required this.updateDiscount,
//       required this.updateCart,
//       Key? key});

//   final String cartOrderId;
//   final String otemOtemID;
//   final String otemSkuID;
//   final List<dynamic> otem;
//   // final List<dynamic> staff;
//   final Map<String, dynamic> itemData;
//   final Function updateQuantity;
//   final Function updateRemarks;
//   final Function updateDiscount;
//   final Function updateCart;

//   @override
//   State<TrialEditItem> createState() => _TrialEditItemState();
// }

// class _TrialEditItemState extends State<TrialEditItem> {
//   var detail = {};

//   late TextEditingController remarksController =
//       TextEditingController(text: widget.itemData['remarks']);
//   late TextEditingController discController =
//       TextEditingController(text: widget.itemData['discount'].toString());
//   TextEditingController discPercentageController = TextEditingController();

//   List<TextEditingController> effortControllers = [];
//   List<TextEditingController> handsOnControllers = [];

//   String paid = '';

//   int? selectedStaffIndex;
//   Map<String, Map<String, String>> otemOrderMap = {};
//   List<Map<String, dynamic>> updatedStaffDetails = [];

//   Map<String, dynamic> mapEdit = {};

//   //untuksimpanselectedDetails
//   List<dynamic> selectedStaffDetails = [];
//   double latestDiscount = 0;

//   @override
//   void initState() {
//     super.initState();
//     getStaffs();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         centerTitle: true,
//         title: const Text(
//           'Edit Item',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: IconButton(
//           icon: Image.asset(
//             "lib/assets/Artboard 40.png",
//             height: 30,
//             width: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//           iconSize: 24,
//         ),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.grey[200],
//           ),
//           Column(
//             children: [hi()],
//           ),
//         ],
//       ),
//     );
//   }

//   void getStaffs() {
//     //pass itemData untuk pass specific otemID
//     dynamic otem = widget.otem.firstWhere(
//       (otem) => otem['otemID'] == widget.itemData['otemID'],
//     );
//     List<int> staffIDs =
//         otem['staffs'].map<int>((staff) => staff['staffID'] as int).toList();
//     setState(() {
//       selectedStaffDetails = otem['staffs']
//           .where((staff) => staffIDs.contains(staff['staffID']))
//           .toList();
//     });
//   }

//   Widget hi() {
//     print("masuk balik: $selectedStaffDetails"); //staffID,effort,handson
//     print(widget.otem);
//     // print(widget.staff); //staffID,name,mobile

//     final totalSub = calSub(widget.itemData);

//     double totalPrice = widget.itemData['price'].toDouble() *
//         double.parse(widget.itemData['quantity']);
//     double discountPercentage =
//         (widget.itemData['discount'] / totalPrice) * 100;
//     double afterDisc = discountPercentage.toDouble();

//     // discController.text = widget.itemData['discount'].toString();
//     discController.selection = TextSelection.fromPosition(
//         TextPosition(offset: discController.text.length));
//     discPercentageController.text = afterDisc.toString();
//     // remarksController.text = widget.itemData['remarks'];
//     // remarksController.selection = TextSelection.fromPosition(TextPosition(offset: remarksController.text.length));

//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             Expanded(
//                 child: Padding(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   widget.itemData['itemName'].toString(),
//                                   style: const TextStyle(
//                                       fontSize: 16, color: Colors.black),
//                                 ),
//                                 const SizedBox(width: 30),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       width: 30,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius:
//                                             BorderRadius.circular(15.0),
//                                       ),
//                                       child: IconButton(
//                                         icon: Image.asset(
//                                           "lib/assets/Minus.png",
//                                           height: 20,
//                                           width: 20,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             int quantity = int.parse(widget
//                                                     .itemData[
//                                                 'quantity']); // Parse the quantity as an int
//                                             quantity--; // Increment the quantity by 1
//                                             widget.itemData['quantity'] = quantity
//                                                 .toString(); // Convert the quantity back to a string
//                                             print(widget.itemData['quantity']);
//                                           });
//                                         },
//                                         iconSize: 24,
//                                       ),
//                                     ),
//                                     Text(
//                                       widget.itemData['quantity'].toString(),
//                                       style: const TextStyle(
//                                           fontSize: 16, color: Colors.black),
//                                     ),
//                                     Container(
//                                       width: 30,
//                                       height: 30,
//                                       decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius:
//                                             BorderRadius.circular(15.0),
//                                       ),
//                                       child: IconButton(
//                                         icon: Image.asset(
//                                           "lib/assets/Plus.png",
//                                           height: 20,
//                                           width: 20,
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             int quantity = int.parse(widget
//                                                     .itemData[
//                                                 'quantity']); // Parse the quantity as an int
//                                             quantity++; // Increment the quantity by 1
//                                             widget.itemData['quantity'] = quantity
//                                                 .toString(); // Convert the quantity back to a string
//                                             print(widget.itemData['quantity']);
//                                           });
//                                         },
//                                         iconSize: 24,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     Padding(
//                                       padding:
//                                           const EdgeInsets.only(right: 12.0),
//                                       child: Container(
//                                         width: 80,
//                                         height: 30,
//                                         decoration: BoxDecoration(
//                                           color: Colors.blue,
//                                           borderRadius:
//                                               BorderRadius.circular(5.0),
//                                         ),
//                                         child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             SizedBox(width: 10),
//                                             Text(
//                                               widget.itemData['price']
//                                                   .toStringAsFixed(2),
//                                               style: const TextStyle(
//                                                   fontSize: 16,
//                                                   color: Colors.white),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(8.0),
//                       alignment: Alignment.centerLeft,
//                       child: const Text(
//                         "Others",
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                     //bahagian staff

//                     Container(
//                       height: 165,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       child: SingleChildScrollView(
//                         physics: const ScrollPhysics(),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text(
//                                         "Staff",
//                                         style: TextStyle(
//                                             fontSize: 14, color: Colors.grey),
//                                       ),
//                                       const SizedBox(width: 30),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Container(
//                                             width: 30,
//                                             height: 30,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius:
//                                                   BorderRadius.circular(15.0),
//                                             ),
//                                             child: IconButton(
//                                               icon: Image.asset(
//                                                 "lib/assets/Plus.png",
//                                                 height: 30,
//                                                 width: 30,
//                                               ),
//                                               onPressed: () async {
//                                                 final selectedDetails =
//                                                     await showModalBottomSheet(
//                                                         context: context,
//                                                         isScrollControlled:
//                                                             true,
//                                                         shape: const RoundedRectangleBorder(
//                                                             borderRadius:
//                                                                 BorderRadius.vertical(
//                                                                     top: Radius
//                                                                         .circular(
//                                                                             20))),
//                                                         builder: (BuildContext
//                                                             context) {
//                                                           return SizedBox(
//                                                               height: 750,
//                                                               child:
//                                                                   TestSelectStaff(
//                                                                 cartOrderId: widget
//                                                                     .cartOrderId,
//                                                                 otems:
//                                                                     widget.otem,
//                                                                 // staff: widget
//                                                                 //     .staff,
//                                                               ));
//                                                         });
//                                                 if (selectedDetails != null) {
//                                                   setState(() {
//                                                     // Add the selected details to the selectedStaffDetails list
//                                                     selectedStaffDetails.addAll(
//                                                         selectedDetails);
//                                                     // Initialize the controllers for the newly added details
//                                                     // for (int i = 0;
//                                                     //     i <
//                                                     //         selectedDetails
//                                                     //             .length;
//                                                     //     i++) {
//                                                     //   effortControllers.add(
//                                                     //       TextEditingController());
//                                                     //   handsOnControllers.add(
//                                                     //       TextEditingController());
//                                                     // }
//                                                     print(
//                                                         "Map baru: $selectedStaffDetails");
//                                                   });
//                                                 }
//                                               },
//                                               iconSize: 24,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                   const Divider(),
//                                   ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: const ScrollPhysics(),
//                                     itemCount: selectedStaffDetails.length,
//                                     itemBuilder: (context, index) {
//                                       detail = selectedStaffDetails[index];
//                                       print("Detail: $detail");
//                                       int destaff = detail['staffID'];
//                                       dynamic theStaff = staff.firstWhere(
//                                         (theStaff) =>
//                                             theStaff['staffID'] == destaff,
//                                         orElse: () =>
//                                             null, // Provide a default value if no matching element is found
//                                       );

//                                       final displayStaffName = theStaff;
//                                       final theName = displayStaffName['name'];
//                                       // var effortText = effortControllers[index];
//                                       // var handsOnText =
//                                       //     handsOnControllers[index];

//                                       // late TextEditingController effortText =
//                                       //     TextEditingController(
//                                       //   text: detail['effort'].toString(),
//                                       // );

//                                       // effortText.selection =
//                                       //     TextSelection.fromPosition(
//                                       //         TextPosition(
//                                       //             offset:
//                                       //                 effortText.text.length));
//                                       // var handsOnText = TextEditingController(
//                                       //   text: detail['handon'] != null
//                                       //       ? detail['handon'].toString()
//                                       //       : '0',
//                                       // );

//                                       return Column(
//                                         children: [
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Row(
//                                               children: [
//                                                 Image.asset(
//                                                   "lib/assets/Artboard 40 copy 2.png",
//                                                   width: 30,
//                                                   height: 30,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   theName.toString(),
//                                                   style: const TextStyle(
//                                                       fontSize: 12),
//                                                 ),
//                                                 Spacer(),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       selectedStaffDetails
//                                                           .removeAt(index);
//                                                       print(
//                                                           'Latest: ${selectedStaffDetails}');
//                                                     });
//                                                   },
//                                                   child: const Icon(
//                                                     Icons.delete,
//                                                     size: 15,
//                                                     color: Colors.red,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Row(
//                                               children: [
//                                                 const SizedBox(width: 20),
//                                                 Expanded(
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       setState(() {
//                                                         selectedStaffIndex =
//                                                             index;
//                                                         // effortText =
//                                                         //     TextEditingController(
//                                                         //   text: detail[
//                                                         //               'effort'] !=
//                                                         //           null
//                                                         //       ? detail['effort']
//                                                         //           .toString()
//                                                         //       : '0',
//                                                         // );
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       width: 106,
//                                                       height: 57,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.grey[200],
//                                                         borderRadius:
//                                                             const BorderRadius
//                                                                     .all(
//                                                                 Radius.circular(
//                                                                     8)),
//                                                       ),
//                                                       child: Column(
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Row(
//                                                               children: [
//                                                                 const Text(
//                                                                   'Effort ',
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         12,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                   width: 18,
//                                                                   height: 18,
//                                                                   decoration:
//                                                                       const BoxDecoration(
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                     color: Colors
//                                                                         .blue,
//                                                                   ),
//                                                                   child:
//                                                                       const Icon(
//                                                                     Icons.edit,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     size: 15,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .only(
//                                                                     left: 8,
//                                                                     bottom: 3),
//                                                             child: Row(
//                                                               children: [
//                                                                 Expanded(child: StatefulBuilder(builder:
//                                                                     (BuildContext
//                                                                             context,
//                                                                         StateSetter
//                                                                             setState) {
//                                                                   return TextFormField(
//                                                                     enabled:
//                                                                         selectedStaffIndex ==
//                                                                             index,
//                                                                     // controller:
//                                                                     //     effortText,
//                                                                     style:
//                                                                         const TextStyle(
//                                                                       fontSize:
//                                                                           14,
//                                                                       color: Colors
//                                                                           .black,
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                     ),
//                                                                     keyboardType:
//                                                                         TextInputType
//                                                                             .text,
//                                                                     inputFormatters: [
//                                                                       FilteringTextInputFormatter
//                                                                           .digitsOnly,
//                                                                     ],
//                                                                     onChanged:
//                                                                         (value) {
//                                                                       setState(
//                                                                           () {
//                                                                         // Update the 'efforts' value in the 'detail' map
//                                                                         detail['effort'] =
//                                                                             int.parse(value);
//                                                                             selectedStaffDetails[index] = detail;
//                                                                       });
//                                                                     },
//                                                                     // onChanged:
//                                                                     //     (value) {
//                                                                     //   // Handle changes in Effort value
//                                                                     //   setState(
//                                                                     //       () {
//                                                                     //     try {
//                                                                     //       detail['efforts'] =
//                                                                     //           int.parse(value); // Update the 'handon' value
//                                                                     //     } catch (e) {
//                                                                     //       // Handle parsing error (e.g., display an error message)
//                                                                     //       print(
//                                                                     //           'Error: $e');
//                                                                     //       // You can set a fallback value or display an error message to the user
//                                                                     //       detail['efforts'] =
//                                                                     //           0; // Fallback value
//                                                                     //     }
//                                                                     //   });
//                                                                     // },
//                                                                     decoration:
//                                                                         const InputDecoration(
//                                                                       isDense:
//                                                                           true,
//                                                                       contentPadding:
//                                                                           EdgeInsets
//                                                                               .zero,
//                                                                       border: InputBorder
//                                                                           .none,
//                                                                     ),
//                                                                   );
//                                                                 })),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 10),
//                                                 Expanded(
//                                                   child: GestureDetector(
//                                                     onTap: () {
//                                                       setState(() {
//                                                         selectedStaffIndex =
//                                                             index;
//                                                       });
//                                                     },
//                                                     child: Container(
//                                                       width: 106,
//                                                       height: 57,
//                                                       decoration: BoxDecoration(
//                                                         color: Colors.grey[200],
//                                                         borderRadius:
//                                                             const BorderRadius
//                                                                     .all(
//                                                                 Radius.circular(
//                                                                     8)),
//                                                       ),
//                                                       child: Column(
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Row(
//                                                               children: [
//                                                                 const Text(
//                                                                   'Hands on ',
//                                                                   style:
//                                                                       TextStyle(
//                                                                     fontSize:
//                                                                         12,
//                                                                     color: Colors
//                                                                         .grey,
//                                                                     overflow:
//                                                                         TextOverflow
//                                                                             .ellipsis,
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                   width: 18,
//                                                                   height: 18,
//                                                                   decoration:
//                                                                       BoxDecoration(
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                     color: Colors
//                                                                         .blue,
//                                                                   ),
//                                                                   child: Icon(
//                                                                     Icons.edit,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     size: 15,
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .only(
//                                                                     left: 8,
//                                                                     bottom: 3),
//                                                             child: Row(
//                                                               children: [
//                                                                 Expanded(
//                                                                   child: StatefulBuilder(builder: (BuildContext
//                                                                           context,
//                                                                       StateSetter
//                                                                           setState) {
//                                                                     return TextFormField(
//                                                                       // initialValue:
//                                                                       //     detail['handon']
//                                                                       //         .toString(),
//                                                                       // controller:
//                                                                       //     handsOnText,
//                                                                       // controller:
//                                                                       //     handsOnText,
//                                                                       style:
//                                                                           TextStyle(
//                                                                         fontSize:
//                                                                             14,
//                                                                         color: Colors
//                                                                             .black,
//                                                                         overflow:
//                                                                             TextOverflow.ellipsis,
//                                                                       ),
//                                                                       keyboardType:
//                                                                           TextInputType
//                                                                               .text,
//                                                                       inputFormatters: [
//                                                                         FilteringTextInputFormatter
//                                                                             .digitsOnly,
//                                                                       ],
//                                                                       onChanged:
//                                                                           (value) {
//                                                                         setState(
//                                                                             () {
//                                                                           // Update the 'efforts' value in the 'detail' map
//                                                                           detail['handon'] =
//                                                                               int.parse(value);
//                                                                         });
//                                                                       },
//                                                                       // onChanged:
//                                                                       //     (value) {
//                                                                       //   // Handle changes in Hands on value
//                                                                       //   setState(
//                                                                       //       () {
//                                                                       //     try {
//                                                                       //       detail['handson'] =
//                                                                       //           int.parse(value); // Update the 'handon' value
//                                                                       //     } catch (e) {
//                                                                       //       // Handle parsing error (e.g., display an error message)
//                                                                       //       print('Error: $e');
//                                                                       //       // You can set a fallback value or display an error message to the user
//                                                                       //       detail['handson'] =
//                                                                       //           0; // Fallback value
//                                                                       //     }
//                                                                       //   });
//                                                                       // },
//                                                                       decoration:
//                                                                           InputDecoration(
//                                                                         isDense:
//                                                                             true,
//                                                                         contentPadding:
//                                                                             EdgeInsets.zero,
//                                                                         border:
//                                                                             InputBorder.none,
//                                                                       ),
//                                                                     );
//                                                                   }),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                   Visibility(
//                                     visible: selectedStaffDetails.isEmpty,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Text(
//                                         "No staff selected",
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Container remarks
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Container(
//                         width: double.infinity,
//                         height: 65,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Remarks",
//                                     style: TextStyle(
//                                         fontSize: 14, color: Colors.grey),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 29,
//                                           child: TextField(
//                                             controller: remarksController,
//                                             decoration: InputDecoration(
//                                               // labelText:
//                                               //     widget.itemData['remarks'] != null
//                                               //         ? remarksController.text
//                                               //         : 'Type here',
//                                               floatingLabelBehavior:
//                                                   FloatingLabelBehavior.never,
//                                               border: InputBorder.none,
//                                             ),
//                                             keyboardType: TextInputType.text,
//                                             // onSubmitted: (text){
//                                             //   setState(() {
//                                             //     remarksController.text = text;
//                                             //   });
//                                             // },
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ),

//                     Row(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             "Adjustment",
//                             style: TextStyle(fontSize: 16, color: Colors.black),
//                           ),
//                         ),
//                       ],
//                     ),
//                     //container discount
//                     Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 width: double.infinity,
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             "Discount",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: SizedBox(
//                                                   height: 29,
//                                                   child: TextField(
//                                                     controller: discController,
//                                                     decoration: InputDecoration(
//                                                       // labelText: widget.itemData['discount'] != null
//                                                       //     ? widget.itemData['discount'].toString()
//                                                       //     : 'Type here',
//                                                       floatingLabelBehavior:
//                                                           FloatingLabelBehavior
//                                                               .never,
//                                                       border: InputBorder.none,
//                                                     ),
//                                                     keyboardType: TextInputType
//                                                         .text, // Use text input type
//                                                     inputFormatters: [
//                                                       FilteringTextInputFormatter
//                                                           .digitsOnly, // Restrict input to digits only
//                                                     ],
//                                                     // onChanged: inDiscount,
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: Container(
//                                 width: double.infinity,
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(10.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Text(
//                                             "Discount%",
//                                             style: TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.grey),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Expanded(
//                                                 child: SizedBox(
//                                                   height: 29,
//                                                   child: TextField(
//                                                     controller:
//                                                         discPercentageController,
//                                                     decoration: InputDecoration(
//                                                       labelText: '0.00',
//                                                       floatingLabelBehavior:
//                                                           FloatingLabelBehavior
//                                                               .never,
//                                                       border: InputBorder.none,
//                                                     ),
//                                                     keyboardType:
//                                                         TextInputType.number,
//                                                     enabled:
//                                                         false, // Disable editing
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Container(
//                         width: double.infinity,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(10.0),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Total",
//                                     style: TextStyle(
//                                         fontSize: 14, color: Colors.grey),
//                                   ),
//                                   Text(
//                                     totalSub.toStringAsFixed(2),
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: ElevatedButton(
//                                 onPressed: () async {
//                                   int newquantity =
//                                       int.parse(widget.itemData['quantity']);

//                                   await changeQty(widget.otemOtemID.toString(),
//                                       newquantity);

//                                   widget.updateCart();

//                                   String remarks = remarksController.text;
//                                   changeRemark(
//                                       widget.otemOtemID.toString(), remarks);

//                                   String discountText = discController.text;
//                                   double discount =
//                                       0.0; // Default value if the input is empty

//                                   if (discountText.isNotEmpty) {
//                                     discount =
//                                         double.tryParse(discountText) ?? 0.0;
//                                   }
//                                   changeDiscount(discount);

//                                   updateDetails();
//                                   await otemsStaff(updatedStaffDetails);
//                                   widget.updateCart();

//                                   Navigator.pop(context);
//                                 },
//                                 child: const Text("Save Changes"),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ))
//           ],
//         ),
//       ),
//     );
//   }

//   void inDiscount(String value) {
//     setState(() {
//       widget.itemData['discount'] = int.tryParse(value) ?? 0;
//     });
//   }

//   void updateDetails() {
//     // Create a new list to store the updated staff details
//     updatedStaffDetails = [];
//     print("dalam update: $selectedStaffDetails");
//     // Iterate over the existing staff details and update the effort and hands-on values
//     for (int i = 0; i < selectedStaffDetails.length; i++) {
//       var staffDetail = selectedStaffDetails[i];
//       // var effortText = effortControllers[i];
//       // var handsOnText = handsOnControllers[i];
//       var updatedStaffDetail = {
//         'staffID': staffDetail['staffID'],
//         'name': staffDetail['name'],
//         'image': staffDetail['image'],
//         'effort': staffDetail['effort'], 
//         // 'effort': effortText.text,
//         // 'handson': handsOnText.text,
//       };
//       updatedStaffDetails.add(updatedStaffDetail);
//     }

//     print("Updated Staff Details: $updatedStaffDetails");
//     print('selectedStaffDetails length: ${selectedStaffDetails}');
  
//   }

//   Future<void> otemsStaff(
//       List<Map<String, dynamic>> updatedStaffDetails) async {
//     var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

//     print("dalam otem: $updatedStaffDetails");

//     // Check if the widget is still mounted before proceeding
//     if (!mounted) {
//       return;
//     }
//     if (updatedStaffDetails == null) {
//       print("No staff selected");
//       return;
//     }
//     var request = http.Request(
//       'POST',
//       Uri.parse(
//           'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/servant/set'),
//     );

//     request.body = json.encode({
//       "staffs": updatedStaffDetails.map((staff) {
//         return {
//           "staffID": staff['staffID'],
//           "image": staff['image'],
//           "effort": staff['effort'],
//           "handon": staff['handson'],
//         };
//       }).toList(),
//     });
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     print("dalam api: $updatedStaffDetails");

//     if (response.statusCode == 200) {
//       print(await response.stream.bytesToString());
//     } else {
//       print(response.reasonPhrase);
//       print("GoodLuck");
//     }
//   }

//   double calSub(Map<String, dynamic> itemData) {
//     final int quantity = int.parse(itemData['quantity'].toString());
//     final double price = double.parse(itemData['price'].toString());
//     final double disc = double.parse(itemData['discount'].toString());
//     return (quantity * price) - disc;
//   }

//   Future changeQty(String otemID, int quantity) async {
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var url =
//         'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/quantity';

//     var response = await http.post(Uri.parse(url), headers: headers, body: {
//       'quantity': quantity.toString(),
//     });

//     if (response.statusCode == 200) {
//       print(response.body);
//       if (mounted) {
//         setState(() {
//           // Find the index of the map with the corresponding otemID
//           final index =
//               widget.otem.indexWhere((element) => element['otemID'] == otemID);
//           if (index != -1) {
//             // Update the quantity value in the map
//             widget.otem[index]['quantity'] = quantity.toString();
//           }
//         });
//       }
//     } else {
//       print(response.reasonPhrase);
//     }
//     widget.updateQuantity();
//   }

//   Future<void> changeRemark(String otemID, String remarks) async {
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var url =
//         'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/remarks';

//     var response = await http.post(Uri.parse(url), headers: headers, body: {
//       'remarks': remarks,
//     });

//     if (response.statusCode == 200) {
//       print(response.body);
//       if (mounted) {
//         setState(() {
//           widget.itemData['remarks'] = remarks;
//           widget.updateRemarks(otemID, widget.itemData['remarks']);
//         });
//       }
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

//   Future<void> changeDiscount(
//     double discount,
//   ) async {
//     // Check if the widget is still mounted before proceeding
//     if (!mounted) {
//       return;
//     }
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/discount'));

//     request.bodyFields = {'discount': discount.toString()};
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       print(await response.stream.bytesToString());
//       print("Dah masuk");
//     } else {
//       print(response.reasonPhrase);
//     }

//     // Call the updateDiscount method to update the discount value in the cart page
//     widget.updateDiscount();
//   }
// }

/////////sesat
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:minimal/test/login.dart';
// import 'package:minimal/test/staffItem.dart';
// import 'package:minimal/testingSelectStaff.dart';
// import '../api.dart';
// import '../cart.dart';
// import '../function.dart';
// import 'discount.dart';

// //showModalBottom for edit item in each service & product
// class EditItem extends StatefulWidget {
//   const EditItem(
//       {required this.cartOrderId,
//       required this.otemOtemID,
//       required this.otemSkuID,
//       required this.staff,
//       required this.otem,
//       required this.updateRemarks,
//       required this.itemData,
//       required this.updateQuantity,
//       required this.updateDiscount,
//       required this.updateStaffValues,
//       required this.refresh,
//       Key? key});

//   final String cartOrderId;
//   final String otemOtemID;
//   final String otemSkuID;
//   final List<dynamic> otem;
//   final List<dynamic> staff;
//   final Map<String, dynamic> itemData;
//   final Function(String, String) updateRemarks;
//   final Function updateQuantity;
//   final Function updateDiscount;
//   final Function updateStaffValues;
//   final Function refresh;

//   @override
//   State<EditItem> createState() => _EditItemState();
// }

// class _EditItemState extends State<EditItem> {
//   TextEditingController remarksController = TextEditingController();

//   TextEditingController discController = TextEditingController();
//   List<TextEditingController> effortControllers = [];
//   List<TextEditingController> handsOnControllers = [];

//   String paid = '';

//   int? selectedStaffIndex;
//   Map<String, Map<String, String>> otemOrderMap = {};
//   List<Map<String, dynamic>> updatedStaffDetails = [];

//   //untuksimpanselectedDetails
//   List<dynamic> selectedStaffDetails = [];

//   @override
//   void initState() {
//     super.initState();
//     getStaffs();
//     // Future staffData = APIFunctions.getStaff();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         centerTitle: true,
//         title: const Text(
//           'Edit Item',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: xIcon(),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.grey[200],
//           ),
//           Column(
//             children: [hi()],
//           ),
//         ],
//       ),
//     );
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

//   void getStaffs() {
//     //pass itemData untuk pass specific otemID
//     dynamic otem = widget.otem.firstWhere(
//       (otem) => otem['otemID'] == widget.itemData['otemID'],
//     );
//     List<int> staffIDs =
//         otem['staffs'].map<int>((staff) => staff['staffID'] as int).toList();
//     setState(() {
//       selectedStaffDetails = otem['staffs']
//           .where((staff) => staffIDs.contains(staff['staffID']))
//           .toList();
//     });
//   }

//   Widget hi() {
//     print("masuk balik: $selectedStaffDetails");

//     print(widget.otem);
//     print(widget.staff);

//     final totalSub = calSub(widget.itemData);
//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         mainAxisSize: MainAxisSize.max,
//         children: <Widget>[
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.0),
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
//                               widget.itemData['itemName'].toString(),
//                               style: const TextStyle(
//                                   fontSize: 16, color: Colors.black),
//                             ),
//                             const SizedBox(width: 30),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Container(
//                                   width: 30,
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(15.0),
//                                   ),
//                                   child: IconButton(
//                                     icon: Image.asset(
//                                       "lib/assets/Minus.png",
//                                       height: 20,
//                                       width: 20,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         int quantity = int.parse(widget
//                                                 .itemData[
//                                             'quantity']); // Parse the quantity as an int
//                                         quantity--; // Increment the quantity by 1
//                                         widget.itemData['quantity'] = quantity
//                                             .toString(); // Convert the quantity back to a string
//                                         print(widget.itemData['quantity']);
//                                       });
//                                     },
//                                     iconSize: 24,
//                                   ),
//                                 ),
//                                 Text(
//                                   widget.itemData['quantity'].toString(),
//                                   style: const TextStyle(
//                                       fontSize: 16, color: Colors.black),
//                                 ),
//                                 Container(
//                                   width: 30,
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(15.0),
//                                   ),
//                                   child: IconButton(
//                                     icon: Image.asset(
//                                       "lib/assets/Plus.png",
//                                       height: 20,
//                                       width: 20,
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         int quantity = int.parse(widget
//                                                 .itemData[
//                                             'quantity']); // Parse the quantity as an int
//                                         quantity++; // Increment the quantity by 1
//                                         widget.itemData['quantity'] = quantity
//                                             .toString(); // Convert the quantity back to a string
//                                         print(widget.itemData['quantity']);
//                                       });
//                                     },
//                                     iconSize: 24,
//                                   ),
//                                 ),
//                               ],
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
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(right: 12.0),
//                                   child: Container(
//                                     width: 80,
//                                     height: 30,
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue,
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(width: 10),
//                                         Text(
//                                           widget.itemData['price']
//                                               .toStringAsFixed(2),
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white),
//                                         ),
//                                       ],
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
//                 Container(
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.centerLeft,
//                   child: const Text(
//                     "Others",
//                     style: TextStyle(fontSize: 16, color: Colors.black),
//                   ),
//                 ),

//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: SingleChildScrollView(
//                       physics: const ScrollPhysics(),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       "Staff",
//                                       style: TextStyle(
//                                           fontSize: 14, color: Colors.grey),
//                                     ),
//                                     const SizedBox(width: 30),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Container(
//                                           width: 25,
//                                           height: 25,
//                                           decoration: BoxDecoration(
//                                             color: Colors.white,
//                                             borderRadius:
//                                                 BorderRadius.circular(15.0),
//                                           ),
//                                           child: IconButton(
//                                             icon: Image.asset(
//                                               "lib/assets/Plus.png",
//                                               height: 20,
//                                               width: 20,
//                                             ),
//                                             onPressed: () async {
//                                               final selectedDetails =
//                                                   await showModalBottomSheet(
//                                                       context: context,
//                                                       isScrollControlled: true,
//                                                       shape: const RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.vertical(
//                                                                   top: Radius
//                                                                       .circular(
//                                                                           20))),
//                                                       builder: (BuildContext
//                                                           context) {
//                                                         return SizedBox(
//                                                             height: 750,
//                                                             child:
//                                                                 TestSelectStaff(
//                                                               cartOrderId: widget
//                                                                   .cartOrderId,
//                                                               otems:
//                                                                   widget.otem,
//                                                               // staff:
//                                                               //     widget.staff,
//                                                             ));
//                                                       });
//                                               if (selectedDetails != null) {
//                                                 setState(() {
//                                                   // Add the selected details to the selectedStaffDetails list
//                                                   selectedStaffDetails
//                                                       .addAll(selectedDetails);
//                                                   // Initialize the controllers for the newly added details
//                                                   for (int i = 0;
//                                                       i <
//                                                           selectedDetails
//                                                               .length;
//                                                       i++) {
//                                                     effortControllers.add(
//                                                         TextEditingController());
//                                                     handsOnControllers.add(
//                                                         TextEditingController());
//                                                   }
//                                                   print(
//                                                       "Map baru: $selectedStaffDetails");
//                                                 });
//                                               }
//                                             },
//                                             iconSize: 24,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                                 const Divider(),
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   physics: const ScrollPhysics(),
//                                   itemCount: selectedStaffDetails.length,
//                                   itemBuilder: (context, index) {
//                                     final detail = selectedStaffDetails[index];
//                                     // var effortText = effortControllers[index];
//                                     // var handsOnText =
//                                     //     handsOnControllers[index];

//                                     return Column(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Row(
//                                             children: [
//                                               Image.asset(
//                                                 "lib/assets/Artboard 40 copy 2.png",
//                                                 width: 30,
//                                                 height: 30,
//                                               ),
//                                               const SizedBox(width: 8),
//                                               Text(
//                                                 detail['staffID'].toString(),
//                                                 style: const TextStyle(
//                                                     fontSize: 12),
//                                               ),
//                                               Spacer(),
//                                               GestureDetector(
//                                                 onTap: () {
//                                                   setState(() {
//                                                     selectedStaffDetails
//                                                         .removeAt(index);
//                                                     print(
//                                                         'Latest: ${selectedStaffDetails}');
//                                                   });
//                                                 },
//                                                 child: const Icon(
//                                                   Icons.delete,
//                                                   size: 15,
//                                                   color: Colors.red,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Row(
//                                             children: [
//                                               const SizedBox(width: 20),
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       selectedStaffIndex =
//                                                           index;
//                                                     });
//                                                   },
//                                                   child: Container(
//                                                     width: 106,
//                                                     height: 57,
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.grey[200],
//                                                       borderRadius:
//                                                           const BorderRadius
//                                                                   .all(
//                                                               Radius.circular(
//                                                                   8)),
//                                                     ),
//                                                     child: Column(
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Row(
//                                                             children: [
//                                                               const Text(
//                                                                 'Effort ',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 12,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                               ),
//                                                               Container(
//                                                                 width: 18,
//                                                                 height: 18,
//                                                                 decoration:
//                                                                     const BoxDecoration(
//                                                                   shape: BoxShape
//                                                                       .circle,
//                                                                   color: Colors
//                                                                       .blue,
//                                                                 ),
//                                                                 child:
//                                                                     const Icon(
//                                                                   Icons.edit,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   size: 15,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                       .only(
//                                                                   left: 8,
//                                                                   bottom: 3),
//                                                           child: Row(
//                                                             children: [
//                                                               Expanded(
//                                                                 child:
//                                                                     GestureDetector(
//                                                                   onTap: () {
//                                                                     // Handle tap on Effort text
//                                                                   },
//                                                                   child:
//                                                                       TextFormField(
//                                                                     // controller:
//                                                                     //     effortText,
//                                                                     style:
//                                                                         const TextStyle(
//                                                                       fontSize:
//                                                                           14,
//                                                                       color: Colors
//                                                                           .black,
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                     ),
//                                                                     keyboardType:
//                                                                         TextInputType
//                                                                             .number,
//                                                                     onChanged:
//                                                                         (value) {
//                                                                       // Handle changes in Effort value
//                                                                     },
//                                                                     decoration:
//                                                                         const InputDecoration(
//                                                                       isDense:
//                                                                           true,
//                                                                       contentPadding:
//                                                                           EdgeInsets
//                                                                               .zero,
//                                                                       border: InputBorder
//                                                                           .none,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 10),
//                                               Expanded(
//                                                 child: GestureDetector(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       selectedStaffIndex =
//                                                           index;
//                                                     });
//                                                   },
//                                                   child: Container(
//                                                     width: 106,
//                                                     height: 57,
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.grey[200],
//                                                       borderRadius:
//                                                           BorderRadius.all(
//                                                               Radius.circular(
//                                                                   8)),
//                                                     ),
//                                                     child: Column(
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Row(
//                                                             children: [
//                                                               Text(
//                                                                 'Hands on ',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize: 12,
//                                                                   color: Colors
//                                                                       .grey,
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .ellipsis,
//                                                                 ),
//                                                               ),
//                                                               Container(
//                                                                 width: 18,
//                                                                 height: 18,
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   shape: BoxShape
//                                                                       .circle,
//                                                                   color: Colors
//                                                                       .blue,
//                                                                 ),
//                                                                 child: Icon(
//                                                                   Icons.edit,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   size: 15,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                       .only(
//                                                                   left: 8,
//                                                                   bottom: 3),
//                                                           child: Row(
//                                                             children: [
//                                                               Expanded(
//                                                                 child:
//                                                                     GestureDetector(
//                                                                   onTap: () {
//                                                                     // Handle tap on Hands on text
//                                                                   },
//                                                                   child:
//                                                                       TextFormField(
//                                                                     // controller:
//                                                                     //     handsOnText,
//                                                                     style:
//                                                                         TextStyle(
//                                                                       fontSize:
//                                                                           14,
//                                                                       color: Colors
//                                                                           .black,
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .ellipsis,
//                                                                     ),
//                                                                     keyboardType:
//                                                                         TextInputType
//                                                                             .number,
//                                                                     onChanged:
//                                                                         (value) {
//                                                                       // Handle changes in Hands on value
//                                                                     },
//                                                                     decoration:
//                                                                         InputDecoration(
//                                                                       isDense:
//                                                                           true,
//                                                                       contentPadding:
//                                                                           EdgeInsets
//                                                                               .zero,
//                                                                       border: InputBorder
//                                                                           .none,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 ),
//                                 Visibility(
//                                   visible: selectedStaffDetails.isEmpty,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       "No staff selected",
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Container remarks
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Container(
//                     width: double.infinity,
//                     height: 65,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Remarks",
//                                 style:
//                                     TextStyle(fontSize: 14, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: SizedBox(
//                                       height: 29,
//                                       child: TextField(
//                                         controller: remarksController,
//                                         decoration: InputDecoration(
//                                           labelText:
//                                               widget.itemData['remarks'] != null
//                                                   ? remarksController.text
//                                                   : 'Type here',
//                                           floatingLabelBehavior:
//                                               FloatingLabelBehavior.never,
//                                           border: InputBorder.none,
//                                         ),
//                                         keyboardType: TextInputType.text,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),

//                 Row(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         "Adjustment",
//                         style: TextStyle(fontSize: 16, color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//                 //container discount
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Container(
//                             width: double.infinity,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Discount",
//                                         style: TextStyle(
//                                             fontSize: 14, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: SizedBox(
//                                               height: 29,
//                                               child: TextField(
//                                                 controller: discController,
//                                                 decoration: InputDecoration(
//                                                   labelText: widget.itemData[
//                                                                   'discount']
//                                                               .toString() !=
//                                                           null
//                                                       ? widget
//                                                           .itemData['discount']
//                                                           .toString()
//                                                       : 'Type here',
//                                                   floatingLabelBehavior:
//                                                       FloatingLabelBehavior
//                                                           .never,
//                                                   border: InputBorder.none,
//                                                 ),
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Container(
//                             width: double.infinity,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10.0),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         "Discount%",
//                                         style: TextStyle(
//                                             fontSize: 14, color: Colors.grey),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: SizedBox(
//                                               height: 29,
//                                               child: TextField(
//                                                 controller: discController,
//                                                 decoration: InputDecoration(
//                                                   labelText: 'Type here',
//                                                   floatingLabelBehavior:
//                                                       FloatingLabelBehavior
//                                                           .never,
//                                                   border: InputBorder.none,
//                                                 ),
//                                                 keyboardType:
//                                                     TextInputType.text,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8.0),
//                   child: Container(
//                     width: double.infinity,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 "Total",
//                                 style:
//                                     TextStyle(fontSize: 14, color: Colors.grey),
//                               ),
//                               Text(
//                                 totalSub.toStringAsFixed(2),
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: ElevatedButton(
//                             onPressed: () {
//                               int newquantity =
//                                   int.parse(widget.itemData['quantity']);

//                               changeQty(
//                                   widget.otemOtemID.toString(), newquantity);
//                               String remarks = remarksController.text;
//                               changeRemark(
//                                   widget.otemOtemID.toString(), remarks);
//                               String discountText = discController.text;
//                               double discount =
//                                   0.0; // Default value if the input is empty

//                               if (discountText.isNotEmpty) {
//                                 discount = double.tryParse(discountText) ?? 0.0;
//                               }
//                               changeDiscount(discount);
//                               updateDetails();
//                               otemsStaff(updatedStaffDetails);
//                               widget.refresh();
//                             },
//                             child: const Text("Save Changes"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ))
//         ],
//       ),
//     );
//   }

//   void updateDetails() {
//     // Create a new list to store the updated staff details
//     updatedStaffDetails = [];
//     // Iterate over the existing staff details and update the effort and hands-on values
//     for (int i = 0; i < selectedStaffDetails.length; i++) {
//       var staffDetail = selectedStaffDetails[i];
//       // var effortText = effortControllers[i];
//       // var handsOnText = handsOnControllers[i];
//       var updatedStaffDetail = {
//         'staffID': staffDetail['staffID'],
//         'name': staffDetail['name'],
//         'image': staffDetail['image'],
//         // 'effort': effortText.text,
//         // 'handson': handsOnText.text,
//       };
//       updatedStaffDetails.add(updatedStaffDetail);
//     }

//     print("Updated Staff Details: $updatedStaffDetails");
//   }

//   Future<void> otemsStaff(
//       List<Map<String, dynamic>> updatedStaffDetails) async {
//     var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

//     // Check if the widget is still mounted before proceeding
//     if (!mounted) {
//       return;
//     }
//     if (updatedStaffDetails == null) {
//       print("No staff selected");
//       return;
//     }
//     var request = http.Request(
//       'POST',
//       Uri.parse(
//           'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/servant/set'),
//     );

//     request.body = json.encode({
//       "staffs": selectedStaffDetails.map((staff) {
//         return {
//           "staffID": staff['staffID'],
//           "image": staff['image'],
//           "efforts": staff['efforts'],
//           "handson": staff['handson'],
//         };
//       }).toList(),
//     });
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     print("dalam api: $selectedStaffDetails");

//     if (response.statusCode == 200) {
//       print(await response.stream.bytesToString());
//     } else {
//       print(response.reasonPhrase);
//       print("GoodLuck");
//     }
//   }

//   double calSub(Map<String, dynamic> itemData) {
//     final int quantity = int.parse(itemData['quantity'].toString());
//     final double price = double.parse(itemData['price'].toString());
//     return quantity * price;
//   }

//   Future<void> changeRemark(String otemID, String remarks) async {
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var url =
//         'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/remarks';

//     var response = await http.post(Uri.parse(url), headers: headers, body: {
//       'remarks': remarks,
//     });

//     if (response.statusCode == 200) {
//       print(response.body);
//       setState(() {
//         widget.itemData['remarks'] = remarks;
//         widget.updateRemarks(otemID, widget.itemData['remarks']);
//         Navigator.pop(context);
//       });
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

//   Future changeQty(String otemID, int quantity) async {
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var url =
//         'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/$otemID/quantity';

//     var response = await http.post(Uri.parse(url), headers: headers, body: {
//       'quantity': quantity.toString(),
//     });

//     if (response.statusCode == 200) {
//       print(response.body);
//       if (mounted) {
//         setState(() {
//           // Find the index of the map with the corresponding otemID
//           final index =
//               widget.otem.indexWhere((element) => element['otemID'] == otemID);
//           if (index != -1) {
//             // Update the quantity value in the map
//             widget.otem[index]['quantity'] = quantity.toString();
//           }
//         });
//       }
//     } else {
//       print(response.reasonPhrase);
//     }
//     widget.updateQuantity();
//     widget.refresh();
//   }

//   Future<void> changeDiscount(
//     double discount,
//   ) async {
//     // Check if the widget is still mounted before proceeding
//     if (!mounted) {
//       return;
//     }
//     var headers = {
//       'token': tokenGlobal,
//     };
//     var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${widget.otemOtemID}/discount'));

//     request.bodyFields = {'discount': discount.toString()};
//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       print(await response.stream.bytesToString());
//       print("Dah masuk");
//     } else {
//       print(response.reasonPhrase);
//     }

//     // Call the updateDiscount method to update the discount value in the cart page
//     widget.updateDiscount();
//   }
// }

// //showModalBottom for staff in editItem
// class StaffInEditItem extends StatefulWidget {
//   const StaffInEditItem(
//       {Key? key,
//       required this.cartOrderId,
//       required this.staff,
//       required this.otems});

//   final String cartOrderId;

//   final List<dynamic> otems;
//   final List<dynamic> staff;

//   @override
//   State<StaffInEditItem> createState() => _StaffInEditItemState();
// }

// class _StaffInEditItemState extends State<StaffInEditItem> {
//   Set<int> _selectedIndices = Set<int>();

//   bool isCustomTapped = false;
//   bool okTapped = false;
//   bool showRefresh = false;

//   int? selectedStaffIndex;

//   Map<String, dynamic>? selectedStaffDetails;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//           title: const Text(
//             'Select Staff',
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
//               children: [hi()],
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

//   Widget hi() {
//     Future staffData = APIFunctions.getStaff();
//     return Expanded(
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   'Staff list',
//                   style: TextStyle(fontSize: 18, color: Colors.black),
//                 ),
//               ],
//             ),
//           ),
//           FutureBuilder(
//             future: staffData,
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//               } else {
//                 return StatefulBuilder(
//                   builder: (context, setState) {
//                     return GridView.builder(
//                       shrinkWrap: true,
//                       itemCount: staff.length,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 10,
//                         crossAxisSpacing: 10,
//                         childAspectRatio: 2.5,
//                       ),
//                       itemBuilder: (context, index) {
//                         var staffDetails = staff[index];
//                         var name = staffDetails['name'];
//                         String mobileNumber = staffDetails['mobile'].toString();
//                         String formattedNumber =
//                             '(${mobileNumber.substring(0, 4)}) ${mobileNumber.substring(4, 7)}-${mobileNumber.substring(7)}';

//                         return GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               if (_selectedIndices.contains(index)) {
//                                 _selectedIndices.remove(index);
//                               } else {
//                                 _selectedIndices.add(index);
//                               }
//                               selectedStaffDetails = getStaffDetails();
//                               printSelectedStaffDetails();
//                             });
//                           },
//                           child: Card(
//                             shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                 color: _selectedIndices.contains(index)
//                                     ? Colors.blue
//                                     : Colors.transparent,
//                                 width: 2.0,
//                               ),
//                               borderRadius: BorderRadius.circular(4.0),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Image(
//                                     image: NetworkImage(staff[index]['icon']),
//                                     width: 25,
//                                     height: 25,
//                                   ),
//                                   SizedBox(width: 8),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           name,
//                                           style: TextStyle(
//                                             fontSize: 18,
//                                             color: Colors.black,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           formattedNumber,
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.black,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Map<String, dynamic>? getStaffDetails() {
//     if (_selectedIndices.isEmpty) {
//       return null;
//     }
//     List<Map<String, dynamic>> selectedDetails = [];
//     for (int index in _selectedIndices) {
//       var staffDetails = staff[index];
//       var name = staffDetails['name'];
//       var image = staffDetails['icon'];
//       var staffID = staffDetails['staffID'];
//       selectedDetails.add({
//         'name': name,
//         'image': image,
//         'staffID': staffID,
//       });
//     }
//     return {
//       'selectedStaff': selectedDetails,
//     };
//   }

//   void printSelectedStaffDetails() {
//     if (_selectedIndices.isEmpty) {
//       print('No containers selected.');
//     } else {
//       print('Selected staff details:');
//       for (int index in _selectedIndices) {
//         var staffDetails = staff[index];
//         var name = staffDetails['name'];
//         var image = staffDetails['icon'];
//         var staffID = staffDetails['staffID'];

//         print('Name: $name staffID: $staffID Image: $image ');
//       }
//     }
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
//             if (_selectedIndices.isNotEmpty) {
//               List<Map<String, dynamic>> selectedDetails = [];
//               for (int index in _selectedIndices) {
//                 var staffDetails = staff[index];
//                 var staffID = staffDetails['staffID'];
//                 var name = staffDetails['name'];
//                 var image = staffDetails['icon'];
//                 selectedDetails.add({
//                   'staffID': staffID,
//                   'name': name,
//                   'image': image,
//                 });
//               }
//               Navigator.pop(context,
//                   selectedDetails); // Pass the selectedDetails as the result
//             } else {
//               Navigator.pop(context); // If no selection, simply pop the page
//             }
//           },
//           child: Text('Add'),
//         ),
//       ),
//     );
//   }
// }
// //showModalBottom for staff button in cart

// class StaffPart extends StatefulWidget {
//   const StaffPart(
//       {Key? key,
//       required this.cartOrderId,
//       required this.otems,
//       required this.skus,
//       required this.updateCart});

//   final String cartOrderId;

//   final List<dynamic> otems;
//   final List<dynamic> skus;
//   final Function updateCart;

//   @override
//   State<StaffPart> createState() => _StaffPartState();
// }

// class _StaffPartState extends State<StaffPart> {
//   Set<int> _selectedIndices = Set<int>();

//   bool isCustomTapped = false;
//   bool okTapped = false;
//   bool showRefresh = false;

//   int? selectedStaffIndex;

//   Map<String, dynamic>? selectedStaffDetails;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//         title: const Text(
//           'Select Staff',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: xIcon(),
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.grey[200],
//           ),
//           Column(
//             children: [
//               hi(), // Call hi() method here to display the staff list
//             ],
//           ),
//         ],
//       ),
//       bottomNavigationBar: addButton(),
//     );
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

//   Widget hi() {
//     Future staffData = APIFunctions.getStaff();

//     print("otem dalam staff : ${otems}");

//     return Expanded(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Staff list',
//                     style: TextStyle(fontSize: 18, color: Colors.black),
//                   ),
//                 ],
//               ),
//             ),
//             FutureBuilder(
//               future: staffData,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 } else {
//                   return StatefulBuilder(
//                     builder: (context, setState) {
//                       return GridView.builder(
//                         shrinkWrap: true,
//                         itemCount: staff.length,
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           mainAxisSpacing: 10,
//                           crossAxisSpacing: 10,
//                           childAspectRatio: 2.5,
//                         ),
//                         itemBuilder: (context, index) {
//                           var staffDetails = staff[index];
//                           var name = staffDetails['name'];
//                           String mobileNumber = staffDetails['mobile'].toString();
//                           String formattedNumber =
//                               '(${mobileNumber.substring(0, 4)}) ${mobileNumber.substring(4, 7)}-${mobileNumber.substring(7)}';
      
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 if (_selectedIndices.contains(index)) {
//                                   _selectedIndices.remove(index);
//                                 } else {
//                                   _selectedIndices.add(index);
//                                 }
//                                 selectedStaffDetails = getSelectedStaffDetails();
//                                 printSelectedStaffDetails();
//                               });
//                             },
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: _selectedIndices.contains(index)
//                                       ? Colors.blue
//                                       : Colors.transparent,
//                                   width: 2.0,
//                                 ),
//                                 borderRadius: BorderRadius.circular(4.0),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Image(
//                                       image: NetworkImage(staff[index]['icon']),
//                                       width: 25,
//                                       height: 25,
//                                     ),
//                                     SizedBox(width: 8),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             name,
//                                             style: TextStyle(
//                                               fontSize: 18,
//                                               color: Colors.black,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           SizedBox(height: 8),
//                                           Text(
//                                             formattedNumber,
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.black,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic>? getSelectedStaffDetails() {
//     if (_selectedIndices.isEmpty) {
//       return null;
//     }

//     List<Map<String, dynamic>> selectedDetails = [];
//     for (int index in _selectedIndices) {
//       var staffDetails = staff[index];
//       var name = staffDetails['name'];
//       var image = staffDetails['icon'];
//       var staffID = staffDetails['staffID'];
//       selectedDetails.add({
//         'name': name,
//         'image': image,
//         'staffID': staffID,
//       });
//     }

//     return {
//       'selectedStaff': selectedDetails,
//     };
//   }

//   void printSelectedStaffDetails() {
//     if (_selectedIndices.isEmpty) {
//       print('No containers selected.');
//     } else {
//       print('Selected staff details:');
//       for (int index in _selectedIndices) {
//         var staffDetails = staff[index];
//         var name = staffDetails['name'];
//         var image = staffDetails['icon'];
//         var staffID = staffDetails['staffID'];

//         print('Name: $name staffID: $staffID Image: $image ');
//       }
//     }
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
//             Navigator.pop(context);
//             if (_selectedIndices.isNotEmpty) {
//               List<Map<String, dynamic>> selectedDetails = [];
//               for (int index in _selectedIndices) {
//                 var staffDetails = staff[index];
//                 var staffID = staffDetails['staffID'];
//                 var name = staffDetails['name'];
//                 var image = staffDetails['icon'];
//                 selectedDetails.add({
//                   'staffID': staffID,
//                   'name': name,
//                   'image': image,
//                 });
//               }

//               showModalBottomSheet<void>(
//                 context: context,
//                 isScrollControlled: true,
//                 shape: const RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.vertical(top: Radius.circular(20))),
//                 builder: (BuildContext context) {
//                   return SizedBox(
//                     height: 750,
//                     child: SpecificStaff(
//                       staffID: selectedstaffID,
//                       staffDetails:
//                           selectedDetails.isNotEmpty ? selectedDetails : null,
//                       otems: widget.otems,
//                       cartOrderId: widget.cartOrderId,
//                       skus: widget.skus,
//                       updateCart: widget.updateCart,
//                     ),
//                   );
//                 },
//               );
//             }
//           },
//           child: Text('Add'),
//         ),
//       ),
//     );
//   }
// }
// //showModalBottom for 'Add' button to show specific staff added from StaffPart

// class SpecificStaff extends StatefulWidget {
//   const SpecificStaff(
//       {required this.staffID,
//       required this.staffDetails,
//       required this.otems,
//       required this.skus,
//       required this.cartOrderId,
//       required this.updateCart,
//       Key? key});

//   final String staffID;
//   final List<Map<String, dynamic>>? staffDetails;
//   final List<dynamic> otems;
//   final List<dynamic> skus;
//   final String cartOrderId;
//   final Function updateCart;

//   @override
//   State<SpecificStaff> createState() => _SpecificStaffState();
// }

// class _SpecificStaffState extends State<SpecificStaff> {
//   Map<String, Map<String, String>> otemOrderMap = {};
//   // List<Map<String, dynamic>> updatedStaffDetails = [];
//   int? selectedItemCount;
//   int? selectedStaffIndex;
//   Map<String, String> selectedSkus = {};

//   bool isCustomTapped = false;
//   bool okTapped = false;
//   bool showRefresh = false;

//   List<TextEditingController> effortControllers = [];
//   List<TextEditingController> handsOnControllers = [];

//   // TextEditingController effortText = TextEditingController();
//   // TextEditingController handsOnText = TextEditingController();

//   void handleSkusSelected(Map<String, String> skus) {
//     setState(() {
//       selectedSkus = skus;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Initialize the effort and hands-on controllers for each staff detail
//     for (int i = 0; i < widget.staffDetails!.length; i++) {
//       effortControllers.add(TextEditingController());
//       handsOnControllers.add(TextEditingController());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//           title: const Text(
//             "Staff Added",
//             style: TextStyle(color: Colors.black),
//           ),
//           leading: IconButton(
//             icon: Image.asset(
//               "lib/assets/Artboard 40.png",
//               height: 30,
//               width: 20,
//             ),
//             onPressed: () => Navigator.pop(context),
//             iconSize: 24,
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Stack(
//             children: [
//               Container(
//                 color: Colors.grey[200],
//               ),
//               Column(
//                 children: [hi()],
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: addButton());
//   }

//   Widget hi() {
//     print("Dalam specific staff: ${widget.otems}");
//     return Column(
//       children: [
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount:
//               widget.staffDetails != null ? widget.staffDetails!.length : 0,
//           itemBuilder: (context, index) {
//             var staffDetail = widget.staffDetails![index];

//             TextEditingController effortTextController =
//                 effortControllers[index];
//             TextEditingController handsOnTextController =
//                 handsOnControllers[index];

//             effortControllers.add(effortTextController);
//             handsOnControllers.add(handsOnTextController);

//             // var effortText = effortControllers[index];
//             // var handsOnText = handsOnControllers[index];
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 height: 155,
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Text(
//                             'Staff',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Image.network(
//                             staffDetail['image'],
//                             width: 20,
//                             height: 20,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             staffDetail['name'],
//                             style: TextStyle(fontSize: 12),
//                           ),
//                           Spacer(),
//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 widget.staffDetails!.removeAt(index);
//                                 print('Latest: ${widget.staffDetails}');
//                               });
//                             },
//                             child: const Icon(
//                               Icons.delete,
//                               size: 15,
//                               color: Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           SizedBox(width: 20),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedStaffIndex = index;
//                                 });
//                               },
//                               child: Container(
//                                 width: 106,
//                                 height: 57,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(8)),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         children: [
//                                           const Text(
//                                             'Effort ',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 18,
//                                             height: 18,
//                                             decoration: const BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: Colors.blue,
//                                             ),
//                                             child: const Icon(
//                                               Icons.edit,
//                                               color: Colors.white,
//                                               size: 15,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 8, bottom: 3),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: GestureDetector(
//                                               onTap: () {
//                                                 // Handle tap on Effort text
//                                               },
//                                               child: TextFormField(
//                                                 controller:
//                                                     effortTextController,
//                                                 style: const TextStyle(
//                                                   fontSize: 14,
//                                                   color: Colors.black,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                 ),
//                                                 keyboardType: TextInputType
//                                                     .text, // Use text input type
//                                                 inputFormatters: [
//                                                   FilteringTextInputFormatter
//                                                       .digitsOnly, // Restrict input to digits only
//                                                 ],
//                                                 onChanged: (value) {
//                                                   // Handle changes in Effort value
//                                                 },
//                                                 decoration:
//                                                     const InputDecoration(
//                                                   isDense: true,
//                                                   contentPadding:
//                                                       EdgeInsets.zero,
//                                                   border: InputBorder.none,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   selectedStaffIndex = index;
//                                 });
//                               },
//                               child: Container(
//                                 width: 106,
//                                 height: 57,
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[200],
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(8)),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         children: [
//                                           const Text(
//                                             'Hands on ',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: Colors.grey,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 18,
//                                             height: 18,
//                                             decoration: const BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: Colors.blue,
//                                             ),
//                                             child: const Icon(
//                                               Icons.edit,
//                                               color: Colors.white,
//                                               size: 15,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 8, bottom: 3),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: TextFormField(
//                                               controller: handsOnTextController,
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 color: Colors.black,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               keyboardType: TextInputType
//                                                   .text, // Use text input type
//                                               inputFormatters: [
//                                                 FilteringTextInputFormatter
//                                                     .digitsOnly, // Restrict input to digits only
//                                               ],
//                                               onChanged: (value) {
//                                                 // Handle changes in Hands on value
//                                               },
//                                               decoration: const InputDecoration(
//                                                 isDense: true,
//                                                 contentPadding: EdgeInsets.zero,
//                                                 border: InputBorder.none,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             height: 70,
//             width: double.infinity,
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(Radius.circular(8)),
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     children: [
//                       Text(
//                         'Apply to ',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       Spacer(),
//                       GestureDetector(
//                         onTap: () {
//                           showModalBottomSheet<int>(
//                             context: context,
//                             isScrollControlled: true,
//                             shape: const RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(20))),
//                             builder: (BuildContext context) {
//                               return SizedBox(
//                                 height: 750,
//                                 child: TrialSelectItem(
//                                   otems: widget.otems,
//                                   onSkusSelected: handleSkusSelected,
//                                   skus: widget.skus,
//                                 ),
//                               );
//                             },
//                           ).then((selectedCount) {
//                             if (selectedCount != null) {
//                               setState(() {
//                                 selectedItemCount = selectedCount;
//                               });
//                             }
//                           });
//                         },
//                         child: Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.blue,
//                           ),
//                           child: Icon(
//                             Icons.edit,
//                             color: Colors.white,
//                             size: 15,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         '${selectedItemCount ?? 0} item',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.blue,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
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
//         otemOrderMap[otemID] = orderMap;
//       }
//     }

//     // Perform actions with the otemOrderMap
//     print('Otem Order Map: $otemOrderMap');
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
//           onPressed: () async {
//             List<Map<String, dynamic>> updatedStaffDetails = [];
//             for (int i = 0; i < widget.staffDetails!.length; i++) {
//               var staffDetail = widget.staffDetails![i];
//               var effortText = effortControllers[i];
//               var handsOnText = handsOnControllers[i];
//               var updatedStaffDetail = {
//                 'staffID': staffDetail['staffID'],
//                 'name': staffDetail['name'],
//                 'image': staffDetail['image'],
//                 'effort': effortText.text,
//                 'handson': handsOnText.text,
//               };
//               updatedStaffDetails.add(updatedStaffDetail);
//               print("testtttttt");
//               print(updatedStaffDetails);
//             }

//             matchingValue();
//             await trialotemsStaff(selectedSkus, updatedStaffDetails);

//             setState(() {});
//           },
//           child: const Text('Apply'),
//         ),
//       ),
//     );
//   }

//   // void updateDetails() {
//   //   // Create a new list to store the updated staff details
//   //   // updatedStaffDetails = [];

//   //   // Iterate over the existing staff details and update the effort and hands-on values
//   //   for (int i = 0; i < widget.staffDetails!.length; i++) {
//   //     var staffDetail = widget.staffDetails![i];
//   //     var effortText = effortControllers[i];
//   //     var handsOnText = handsOnControllers[i];
//   //     var updatedStaffDetail = {
//   //       'staffID': staffDetail['staffID'],
//   //       'name': staffDetail['name'],
//   //       'image': staffDetail['image'],
//   //       'effort': effortText.text,
//   //       'handson': handsOnText.text,
//   //     };
//   //     updatedStaffDetails.add(updatedStaffDetail);
//   //     print("testtttttt");
//   //     print(updatedStaffDetails);
//   //   }
//   // }

//   Future<void> otemsStaff(Map<String, Map<String, String>> otemOrderMap,
//       List<Map<String, dynamic>> updatedStaffDetails) async {
//     var orderID = otemOrderMap.values.map((map) => map['orderID']).toList();
//     var otemIDs = otemOrderMap.values.map((map) => map['otemID']).toList();

//     print("Dalam otemStaff: $otemOrderMap $orderID $otemIDs");
//     print("Dalam otemStaff: $updatedStaffDetails");
//     print("Dalam otemStaff: ${widget.cartOrderId}");

//     var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

//     for (var i = 0; i < otemIDs.length; i++) {
//       // Check if the widget is still mounted before proceeding
//       // if (!mounted) {
//       //   return;
//       // }
//       var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://order.tunai.io/loyalty/order/${orderID[i]}/otems/${otemIDs[i]}/servant/set'),
//       );

//       request.body = json.encode({
//         "staffs": updatedStaffDetails.map((staff) {
//           return {
//             "staffID": staff['staffID'],
//             "efforts": staff['efforts'],
//             "handson": staff['handson'],
//           };
//         }).toList(),
//       });
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         print(otemIDs);
//         print(await response.stream.bytesToString());
//         if (mounted) {
//           Navigator.pop(context);
//         }
//       } else {
//         print(response.reasonPhrase);
//         print("GoodLuck");
//       }
//     }
//   }

//   Future<void> trialotemsStaff(Map<String, String> selectedSkus,
//       List<Map<String, dynamic>> updatedStaffDetails) async {
//     List<String> itemIDs = selectedSkus.values.map((value) {
//       return value.split(':').last;
//     }).toList();

//     print("itemIDs: $itemIDs");

//     var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

//     for (var i = 0; i < itemIDs.length; i++) {
//       // Check if the widget is still mounted before proceeding
//       // if (!mounted) {
//       //   return;
//       // }
//       var request = http.Request(
//         'POST',
//         Uri.parse(
//             'https://order.tunai.io/loyalty/order/${widget.cartOrderId}/otems/${itemIDs[i]}/servant/set'),
//       );

//       request.body = json.encode({
//         "staffs": updatedStaffDetails.map((staff) {
//           return {
//             "staffID": staff['staffID'],
//             "efforts": staff['effort'],
//             "handson": staff['handson'],
//           };
//         }).toList(),
//       });
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         print(await response.stream.bytesToString());
//         if (mounted) {
//           widget.updateCart();
//           Navigator.pop(context);
//         }
//       } else {
//         print(response.reasonPhrase);
//         print("GoodLuck");
//       }
//     }
//   }
// }
