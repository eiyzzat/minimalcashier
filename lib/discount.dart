import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/pending.dart';
import 'package:minimal/testingSelectStaff.dart';
import '../api.dart';
import '../cart.dart';
import '../function.dart';
import 'discount.dart';

class Discount extends StatefulWidget {
  const Discount(
      {Key? key,
      required this.orderId,
      required this.otems,
      required this.skus,
      required this.updateDiscount});

  final String orderId;
  final List<dynamic> otems;
  final List<dynamic> skus;
  final Function updateDiscount;

  @override
  State<Discount> createState() => _DiscountState();
}

class _DiscountState extends State<Discount> {
 

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  int? selectedItemCount;

  Map<String, String> selectedSkus = {};
  Map<String, Map<String, String>> discItemMap = {};

  TextEditingController discController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          centerTitle: true,
          title: const Text(
            'Discount',
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
              children: [hi2()],
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

  void handleSkusSelected(Map<String, String> skus) {
    setState(() {
      selectedSkus = skus;
    });
  }

  Widget hi2() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Discount",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                      controller: discController,
                                      decoration: const InputDecoration(
                                        labelText: 'Type here',
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
            ),
            const SizedBox(width: 8),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discount%",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                                    controller: discController,
                                    decoration: InputDecoration(
                                      labelText: 'Type here',
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
          ],
        ),
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
                    const Text(
                      'Apply to ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet<int>(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return SizedBox(
                              height: 750,
                              child: SelectItemForDiscount(
                                otems: widget.otems,
                                onSkusSelected: handleSkusSelected, skus: widget.skus, 
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
    ]);
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
        discItemMap[otemID] = orderMap;
      }
    }

    // Perform actions with the otemOrderMap
    print('Otem Order Map: $discItemMap');
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
            setState(() {
              // Navigator.pop(context);
              matchingValue();
              print("disc text: ${discController.text}");
              String thediscount = discController.text;
              changeDiscount(discItemMap, thediscount);
              popWithData(discItemMap, thediscount, selectedSkus);
            });
          },
          child: Text('Apply'),
        ),
      ),
    );
  }

  void popWithData(Map<String, Map<String, String>> discItemMap,
      String discount, Map<String, String> selectedSkus) {
    Navigator.pop(context, {
      'discItemMap': discItemMap,
      'discount': discount,
      'selectedSkus': selectedSkus
    });
  }

  Future<void> changeDiscount(
    Map<String, Map<String, String>> discItemMap,
    String discount,
  ) async {
    for (var entry in discItemMap.entries) {
      String otemID = entry.key;
      print(otemID);
      
      var orderID = entry.value['orderID'];
      print(orderID);

      // Find the index of the corresponding otem in the otems list
      int index = widget.otems.indexWhere(
          (item) => item['otemID'] == otemID && item['orderID'] == orderID);
      if (index != -1) {
        // Set the new discount for the otem
        widget.otems[index]['discount'] = discount;
      }
    }

    // Call your existing API code to update the discounts
    var orderID = discItemMap.values.map((map) => map['orderID']).toList();
    var otemIDs = discItemMap.values.map((map) => map['otemID']).toList();

    for (var i = 0; i < otemIDs.length; i++) {
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
              'https://order.tunai.io/loyalty/order/${orderID[i]}/otems/${otemIDs[i]}/discount'));

      request.bodyFields = {'discount': discount};
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        print("Dah masuk");
      } else {
        print(response.reasonPhrase);
      }
    }

    // Call the updateDiscount method to update the discount value in the cart page
    widget.updateDiscount();
  }
}






// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../api.dart';
// import '../cart.dart';
// import '../function.dart';

// class TestItemForDiscount extends StatefulWidget {
//   const TestItemForDiscount({
//     Key? key,
//     required this.otems,
//     required this.onSkusSelected,
//   });
//   final List<dynamic> otems;
//   final Function(Map<String, String>) onSkusSelected;

//   @override
//   State<TestItemForDiscount> createState() => _TestItemForDiscountState();
// }

// class _TestItemForDiscountState extends State<TestItemForDiscount> {
//   Map<String, String> selectedSkus = {};

//   bool okTapped = false;
//   bool showRefresh = false;


//   Set<int> selectedItems = {};
//   int selectedItemCount = 0;
//   bool isAllItemsSelected = false;

//   void updateSelectedItems(Set<int> updatedSelectedItems) {
//     setState(() {
//       selectedItems = updatedSelectedItems;
//       selectedItemCount = selectedItems.length;

//       // Update selectedSkus map
//       selectedSkus.clear();
//       for (int index in selectedItems) {
//         final sku = skus[index];
//         selectedSkus[index.toString()] = sku['skuID'].toString();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           title: Text(
//             "Select Items ${selectedItems.length}",
//             style: TextStyle(color: Colors.black),
//           ),
//           leading: xIcon(),
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
//   return Column(
//     children: [
//       Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 1.9,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           itemCount: skus.length,
//           itemBuilder: (context, index) {
//             final sku = skus[index];
//             final isSelected = selectedItems.contains(index);

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   if (selectedItems.contains(index)) {
//                     selectedItems.remove(index);
//                     selectedSkus.remove(index.toString());
//                   } else {
//                     selectedItems.add(index);
//                     final sku = skus[index];
//                     selectedSkus[index.toString()] = sku['skuID'].toString();
//                   }
//                   print(selectedSkus);
//                 });
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: Stack(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     sku['name'],
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${sku['selling'].toStringAsFixed(2)}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.blue,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (isSelected)
//                       Positioned(
//                         bottom: 10,
//                         right: 10,
//                         child: Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.blue,
//                           ),
//                           child: Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }


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
//             setState(() {});
//             widget.onSkusSelected(selectedSkus);
//             Navigator.pop(context, [selectedItems.length, selectedSkus]);

//             print('Pass total selected container: $selectedItems');
//           },
//           child: Text('Ok'),
//         ),
//       ),
//     );
//   }
// }