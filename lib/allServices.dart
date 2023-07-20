import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/test/login.dart';
import 'api.dart';
import 'dart:convert';

//untuk store skuID,selling,quantity
Map<int, Map<String, int>> selectedService = {};

ValueNotifier<int> totalQuantityNotifier = ValueNotifier<int>(0);
ValueNotifier<double> totalSellingPriceNotifier = ValueNotifier<double>(0.0);

class AllServices extends StatefulWidget {
  const AllServices({
    Key? key,
  }) : super(key: key);

  static int totalQuantity = 0;

  @override
  State<AllServices> createState() => _AllServicesState();
}

int getServiceTotalQuantity() {
  int totalQuantity = 0;
  for (var sku in selectedService.values) {
    int quantity = sku['quantity'] ?? 0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getServiceTotalPrice() {
  double totalPrice = 0;
  for (var sku in selectedService.values) {
    double price = sku['selling']?.toDouble() ?? 0.0;
    totalPrice += price;
  }
  totalSellingPriceNotifier.value = totalPrice;
  print("totalsell: ${totalSellingPriceNotifier.value}");
  return totalSellingPriceNotifier.value;
}

class _AllServicesState extends State<AllServices> {
  List<dynamic> services = [];
  List<dynamic> sections = [];

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  void _setExpandedIndex(int? index) {
    setState(() {
      if (_expandedIndex == index) {
        // If the same section is being expanded, collapse it
        _expandedIndex = null;
      } else {
        // Otherwise, expand the new section
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            height: 80,
            //section
            child: ListView.builder(
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final sectionID = section['sectionID'];
                final sectionName = section['name'];

                final skus = services
                    .where((sku) => sku['sectionID'] == sectionID)
                    .toList();

                if (sectionName == null || sectionName.isEmpty) {
                  return Container();
                }
                return ExpansionTile(
                  title: Text(
                    sectionName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  maintainState: true,
                  onExpansionChanged: (isExpanded) {
                    _setExpandedIndex(isExpanded ? index : null);
                  },
                  initiallyExpanded: _expandedIndex == index,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      //display service
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: skus.length,
                        itemBuilder: (context, index) {
                          //service
                          final sku = skus[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            sku['name'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black),
                                             maxLines: 2,   
                                             overflow: TextOverflow.ellipsis,
                                          ),
                                          
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                '${sku['selling'].toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(width: 40),
                                              Expanded(
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: IconButton(
                                                    icon: Image.asset(
                                                      "lib/assets/Minus.png",
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                    onPressed: () {
                                                      thedecrement(
                                                          sku['skuID']);
                                                    },
                                                    iconSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${selectedService[sku?['skuID']]?['quantity'] ?? 0}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: IconButton(
                                                  icon: Image.asset(
                                                    "lib/assets/Plus.png",
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                  onPressed: () {
                                                    //increment pakai sku[skuID]
                                                    // incrementQuantity(
                                                    //     sku['skuID']);
                                                    increase(sku['skuID']);
                                                  },
                                                  iconSize: 24,
                                                ),
                                              ),
                                            ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            //stop sini
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void incrementQuantity(int skuID) {
    setState(() {
      if (selectedService.containsKey(skuID)) {
        print(selectedService);
        selectedService[skuID]!['quantity'] =
            (selectedService[skuID]!['quantity'] ?? 0) + 1;

        var sku = services.firstWhere((sku) => sku['skuID'] == skuID);
        double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

        selectedService[skuID]!['selling'] =
            (selectedService[skuID]!['quantity']! * sellingPrice).toInt();
      } else {
        var sku = services.firstWhere((sku) => sku['skuID'] == skuID);
        selectedService[skuID] = {
          'selling': sku['selling'],
          'quantity': 1,
          'skuID': skuID,
        };
      }
      // Calculate the total service quantity
      int totalServiceQuantity = selectedService.values
          .map((service) => service['quantity'] ?? 0)
          .reduce((a, b) => a + b);

      // Update the value of totalServiceQuantityNotifier
      totalQuantityNotifier.value = totalServiceQuantity;
      getServiceTotalPrice();
      print(selectedService);
    });
  }

  void increase(int skuID) {
    var sku = services.firstWhere((sku) => sku['skuID'] == skuID);
    int quantity = (selectedService[skuID]?['quantity'] ?? 0);
    double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

    setState(() {
      if (selectedService.containsKey(skuID)) {
        quantity++;
        selectedService[skuID]!['quantity'] = quantity;
        print("quantity:$quantity");
        selectedService[skuID]!['selling'] =
            (selectedService[skuID]!['quantity']! * sellingPrice).toInt();
      } else {
        var sku = services.firstWhere((sku) => sku['skuID'] == skuID);

        quantity++;
        selectedService[skuID] = {
          'selling': sku['selling'],
          'quantity': quantity,
          'skuID': skuID,
        };
        print("else:$quantity");
      }
      int totalQuantity = calculateTotalQuantity(
          selectedService); // Calculate the total quantity
      print("Total Quantity: $totalQuantity");
      print(selectedService);
      getServiceTotalPrice();
    });
  }

  int calculateTotalQuantity(Map<int, Map<String, dynamic>> selectedService) {
    int totalQuantity = 0;
    for (var service in selectedService.values) {
      setState(() {
        int quantity = service['quantity'] ?? 0;
        totalQuantity += quantity;
      });
    }
    totalQuantityNotifier.value = totalQuantity;
    return totalQuantityNotifier.value;
  }

  void decrement(int skuID) {
    int quantity = (selectedService[skuID]?['quantity'] ?? 0);
    setState(() {
      if (selectedService.containsKey(skuID)) {
        quantity--;

        if (selectedService[skuID]!['quantity']! <= 0) {
          // Remove the service if the quantity becomes zero or negative
          selectedService.remove(skuID);
        } else {
          var sku = services.firstWhere((sku) => sku['skuID'] == skuID);
          double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

          selectedService[skuID]!['selling'] =
              (selectedService[skuID]!['quantity']! * sellingPrice).toInt();
        }
      }
      int totalQuantity = calculateTotalQuantity(
          selectedService); // Calculate the total quantity
      print("Total Quantity: $totalQuantity");

      // Calculate the total service quantity
      // int totalServiceQuantity = selectedService.isEmpty
      //     ? 0
      //     : selectedService.values
      //         .map((service) => service['quantity'] ?? 0)
      //         .reduce((a, b) => a + b);

      // Update the value of totalServiceQuantityNotifier
      // totalQuantityNotifier.value = totalServiceQuantity;
      getServiceTotalPrice();
      print(selectedService);
    });
  }

  thedecrement(int skuID) {
    setState(() {
      if (selectedService.containsKey(skuID)) {
        int quantity = (selectedService[skuID]?['quantity'] ?? 0);
        quantity--;

        if (quantity == 0) {
          // Remove the service if the quantity becomes zero or negative
          selectedService.remove(skuID);
        } else {
          var sku = services.firstWhere((sku) => sku['skuID'] == skuID);
          double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

          selectedService[skuID]!['quantity'] = quantity;
          selectedService[skuID]!['selling'] =
              (quantity * sellingPrice).toInt();
        }
      }
      int totalQuantity = calculateTotalQuantity(selectedService);
      print("Total Quantity: $totalQuantity");
      getServiceTotalPrice();
      print(selectedService);
    });
  }

  Future<void> fetchServices() async {
    var headers = {'token': tokenGlobal};
    var request = http.Request(
        'GET', Uri.parse('https://menu.tunai.io/loyalty/type/1/sku?active=1'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonData = await response.stream.bytesToString();
      final decodedData = json.decode(jsonData);
      setState(() {
        services = decodedData['skus'];
        sections = decodedData['sections'];
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}
