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