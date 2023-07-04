import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    totalSellingPriceNotifier.value = totalPrice;
  }
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
                                                color: Colors.black),
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
                                                const SizedBox(width: 10),
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
                                                        decrement(sku['skuID']);
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
                                                      incrementQuantity(
                                                          sku['skuID']);
                                                    },
                                                    iconSize: 24,
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      ),
                                    ],
                                  ),
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

  void increase (int skuID) {
    setState(() {
      if (selectedService.containsKey(skuID)) {
        print(selectedService);
        int quantity =
            (selectedService[skuID]!['quantity'] ?? 0);

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
     
    });
  }

  void decrement(int skuID) {
    setState(() {
      if (selectedService.containsKey(skuID)) {
        selectedService[skuID]!['quantity'] =
            (selectedService[skuID]!['quantity'] ?? 0) - 1;

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

      // Calculate the total service quantity
      int totalServiceQuantity = selectedService.isEmpty ? 0 : selectedService.values
          .map((service) => service['quantity'] ?? 0)
          .reduce((a, b) => a + b);



      // Update the value of totalServiceQuantityNotifier
      totalQuantityNotifier.value = totalServiceQuantity;
      getServiceTotalPrice();
      print(selectedService);
    });
  }

  Future<void> fetchServices() async {
    var headers = {'token': token};
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
