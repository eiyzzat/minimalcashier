import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/login.dart';
import 'package:minimal/cart_staff_item.dart';

class SpecificStaff extends StatefulWidget {
  const SpecificStaff(
      {required this.staffID,
      required this.staffDetails,
      required this.otems,
      required this.skus,
      required this.cartOrderId,
      required this.updateCart,
      Key? key});

  final String staffID;
  final List<Map<String, dynamic>>? staffDetails;
  final List<dynamic> otems;
  final List<dynamic> skus;
  final String cartOrderId;
  final Function updateCart;

  @override
  State<SpecificStaff> createState() => _SpecificStaffState();
}

class _SpecificStaffState extends State<SpecificStaff> {
  Map<String, Map<String, String>> otemOrderMap = {};
  // List<Map<String, dynamic>> updatedStaffDetails = [];
  String? selectedItemCount;
  int? selectedStaffIndex;
  Map<String, String> selectedSkus = {};

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> handsOnControllers = [];

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
                          const SizedBox(width: 8),
                          Text(
                            staffDetail['name'],
                            style: TextStyle(fontSize: 12),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.staffDetails!.removeAt(index);
                                print('Latest: ${widget.staffDetails}');
                              });
                            },
                            child: const Image(
                              image: AssetImage(
                                  'lib/assets/remove.jpg'), 
                              width: 22,
                              height:
                                  20, 
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
                                  color: Colors.white,
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
                                                    TextInputType.text,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
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
                              //kotak effort
                              child: Container(
                                width: 106,
                                height: 57,
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                                    TextInputType.text,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
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
                          showModalBottomSheet<String>(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20))),
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 750,
                                child: CartStaffSelectItem(
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
          onPressed: () async {
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
              // print("testtttttt");
              // print(updatedStaffDetails);
            }

            matchingValue();
            // print("selectedkusstaff: $selectedSkus");
            //  print("updatedStaffDetailsstaff: $updatedStaffDetails");
            await trialotemsStaff(selectedSkus, updatedStaffDetails);

            Navigator.pop(context);

            // setState(() {});
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

    var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

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

    var headers = {'token': tokenGlobal, 'Content-Type': 'application/json'};

    for (var i = 0; i < itemIDs.length; i++) {
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

        widget.updateCart();
      } else {
        print(response.reasonPhrase);
        print("GoodLuck");
      }
    }
  }
}
