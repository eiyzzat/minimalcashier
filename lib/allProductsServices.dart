import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/login.dart';
import 'dart:convert';

import 'constant/token.dart';

//untuk store skuID,selling,quantity
Map<int, Map<String, dynamic>> selectedProductServices = {};

ValueNotifier<int> pStotalQuantityNotifier = ValueNotifier<int>(0);
ValueNotifier<double> pStotalSellingPriceNotifier = ValueNotifier<double>(0.0);

class AllProductServices extends StatefulWidget {
  final String searchText;
  const AllProductServices({
    Key? key,
    required this.searchText, 
  }) : super(key: key);

  @override
  State<AllProductServices> createState() => _AllProductServicesState();
}

int getProductServicesTotalQuantity() {
  int totalQuantity = 0;
  for (var sku in selectedProductServices.values) {
    int quantity = sku['quantity'] ?? 0;
    totalQuantity += quantity;
  }
  pStotalQuantityNotifier.value = totalQuantity;
  return pStotalQuantityNotifier.value;
}

double getProductServicesTotalPrice() {
  double totalPrice = 0;
  for (var sku in selectedProductServices.values) {
    double price = sku['selling']?.toDouble() ?? 0.0;
    totalPrice += price;
  }
  pStotalSellingPriceNotifier.value = totalPrice;
  return pStotalSellingPriceNotifier.value;
}

class _AllProductServicesState extends State<AllProductServices> {
  List<dynamic> allItem = [];

  @override
  void initState() {
    super.initState();
    fetchProductServices();
  }

  List<dynamic> _getFilteredItems() {
    if (widget.searchText.isEmpty) {
      return allItem;
    } else {
      final searchTextLowercase = widget.searchText.toLowerCase();
      return allItem.where((item) {
        final itemName = item['name']?.toString().toLowerCase() ?? '';
        print("itemname: $itemName");
        return itemName.contains(searchTextLowercase);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final skus = _getFilteredItems();
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //display product
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
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
                                Flexible(
                                  child: Text(
                                    sku['name'],
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
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
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${sku['selling'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                      const SizedBox(width: 10),
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
                                            thedecrement(sku['skuID']);
                                          },
                                          iconSize: 24,
                                        ),
                                      ),
                                      Text(
                                        '${selectedProductServices.containsKey(sku['skuID']) ? selectedProductServices[sku['skuID']]!['quantity'] : 0} ',
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
                      ),
                    ],
                  ),

                  //stop sini
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void increase(int skuID) {
    var sku = allItem.firstWhere((sku) => sku['skuID'] == skuID);
    int quantity = (selectedProductServices[skuID]?['quantity'] ?? 0);
    double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

    setState(() {
      if (selectedProductServices.containsKey(skuID)) {
        quantity++;
        selectedProductServices[skuID]!['quantity'] = quantity;
        print("quantity:$quantity");
        selectedProductServices[skuID]!['selling'] =
            (selectedProductServices[skuID]!['quantity']! * sellingPrice)
                .toInt();
      } else {
        var sku = allItem.firstWhere((sku) => sku['skuID'] == skuID);

        quantity++;
        selectedProductServices[skuID] = {
          'selling': sku['selling'],
          'quantity': quantity,
          'skuID': skuID,
        };
        print("else:$quantity");
      }
      int totalQuantity =
          getProductServicesTotalQuantity(); // Calculate the total quantity
      // print("Total Quantity: $totalQuantity");
      // print(selectedProductServices);
      getProductServicesTotalPrice();
    });
  }

  int calculateTotalQuantity(
      Map<int, Map<String, dynamic>> selectedProductServices) {
    int totalQuantity = 0;
    for (var service in selectedProductServices.values) {
      setState(() {
        int quantity = service['quantity'] ?? 0;
        totalQuantity += quantity;
      });
    }
    pStotalQuantityNotifier.value = totalQuantity;
    return pStotalQuantityNotifier.value;
  }

  thedecrement(int skuID) {
    setState(() {
      if (selectedProductServices.containsKey(skuID)) {
        int quantity = (selectedProductServices[skuID]?['quantity'] ?? 0);
        quantity--;

        if (quantity == 0) {
          // Remove the service if the quantity becomes zero or negative
          selectedProductServices.remove(skuID);
        } else {
          var sku = allItem.firstWhere((sku) => sku['skuID'] == skuID);
          double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

          selectedProductServices[skuID]!['quantity'] = quantity;
          selectedProductServices[skuID]!['selling'] =
              (quantity * sellingPrice).toInt();
        }
      }
      int totalQuantity = calculateTotalQuantity(selectedProductServices);
      // print("Total Quantity: $totalQuantity");
      getProductServicesTotalPrice();
      // print(selectedProductServices);
    });
  }

  void decrement(int skuID) {
    setState(() {
      if (selectedProductServices.containsKey(skuID)) {
        selectedProductServices[skuID]!['quantity'] =
            (selectedProductServices[skuID]!['quantity'] ?? 0) - 1;

        if (selectedProductServices[skuID]!['quantity']! <= 0) {
          // Remove the service if the quantity becomes zero or negative
          selectedProductServices.remove(skuID);
        } else {
          var sku = allItem.firstWhere((sku) => sku['skuID'] == skuID);
          double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

          selectedProductServices[skuID]!['selling'] =
              (selectedProductServices[skuID]!['quantity']! * sellingPrice)
                  .toInt();
        }
      }

      // Calculate the total service quantity
      int totalProductQuantity = selectedProductServices.isEmpty
          ? 0
          : selectedProductServices.values
              .map((product) => product['quantity'] ?? 0)
              .reduce((a, b) => a + b);

      // Update the value of totalServiceQuantityNotifier
      // ptotalQuantityNotifier.value = totalProductQuantity;
      getProductServicesTotalPrice();
      print(selectedProductServices);
    });
  }

  Future<void> fetchProductServices() async {
    var headers = {'token': token};
    var request =
        http.Request('GET', Uri.parse('https://menu.tunai.io/loyalty/sku'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      setState(() {
        allItem = body['skus'];
       
      });
      // print(responsebody); 
    } else {
      print(response.reasonPhrase);
    }
  }
}
