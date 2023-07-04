import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api.dart';
import 'dart:convert';

//untuk store skuID,selling,quantity
Map<int, Map<String, dynamic>> selectedProduct = {};

ValueNotifier<int> ptotalQuantityNotifier = ValueNotifier<int>(0);
ValueNotifier<double> ptotalSellingPriceNotifier = ValueNotifier<double>(0.0);

class AllProducts extends StatefulWidget {
  const AllProducts({
    Key? key,
  }) : super(key: key);

  @override
  State<AllProducts> createState() => _AllProductsState();
}

int getProductTotalQuantity() {
  int totalQuantity = 0;
  for (var sku in selectedProduct.values) {
    int quantity = sku['quantity'] ?? 0;
    totalQuantity += quantity;
  }
  return totalQuantity;
}

double getProductTotalPrice() {
  double totalPrice = 0;
  for (var sku in selectedProduct.values) {
    double price = sku['selling']?.toDouble() ?? 0.0;
    totalPrice += price;
    ptotalSellingPriceNotifier.value = totalPrice;
  }
  return ptotalSellingPriceNotifier.value;
}

class _AllProductsState extends State<AllProducts> {
  List<dynamic> products = [];
  List<dynamic> sections = [];

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  void _setExpandedIndex(int? index) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else {
        _expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              final sectionID = section['sectionID'];
              final sectionName = section['name'];

              final skus = products
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    //display product
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
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${sku['selling'].toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(width: 10),
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
                                              Text(
                                                '${selectedProduct.containsKey(sku['skuID']) ? selectedProduct[sku['skuID']]!['quantity'] : 0} ',
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
                                                    increment(sku['skuID']);
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
      ],
    );
  }

  void increment(int skuID) {
    setState(() {
      if (selectedProduct.containsKey(skuID)) {
        selectedProduct[skuID]!['quantity'] =
            (selectedProduct[skuID]!['quantity'] ?? 0) + 1;

        var sku = products.firstWhere((sku) => sku['skuID'] == skuID);
        double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

        selectedProduct[skuID]!['selling'] =
            (selectedProduct[skuID]!['quantity']! * sellingPrice).toInt();
      } else {
        var sku = products.firstWhere((sku) => sku['skuID'] == skuID);
        selectedProduct[skuID] = {
          'selling': sku['selling'],
          'quantity': 1,
          'skuID': skuID,
        };
      }
      // Calculate the total service quantity
      int totalProductQuantity = selectedProduct.values
          .map((product) => product['quantity'] ?? 0)
          .reduce((a, b) => a + b);

      // Update the value of totalServiceQuantityNotifier
      ptotalQuantityNotifier.value = totalProductQuantity;
      getProductTotalPrice();
      print(selectedProduct);
    });
  }

  // void testIncrement(String skuID) {
  //   setState(() {
  //     int quantity = selectedProduct[skuID]!['quantity'];
  //     if (selectedProduct.containsKey(skuID)) {
  //       quantity++;
        
  //     } else {
  //       var sku = products.firstWhere((sku) => sku['skuID'] == skuID);
  //       selectedProduct[skuID] = {
  //         'selling': sku['selling'],
  //         'quantity': quantity,
  //         'skuID': skuID,
  //       };
  //     }
  //   });
  // }

  void decrement(int skuID) {
    setState(() {
      if (selectedProduct.containsKey(skuID)) {
        selectedProduct[skuID]!['quantity'] =
            (selectedProduct[skuID]!['quantity'] ?? 0) - 1;

        if (selectedProduct[skuID]!['quantity']! <= 0) {
          // Remove the service if the quantity becomes zero or negative
          selectedProduct.remove(skuID);
        } else {
          var sku = products.firstWhere((sku) => sku['skuID'] == skuID);
          double sellingPrice = sku['selling']?.toDouble() ?? 0.0;

          selectedProduct[skuID]!['selling'] =
              (selectedProduct[skuID]!['quantity']! * sellingPrice).toInt();
        }
      }

      // Calculate the total service quantity
      int totalProductQuantity = selectedProduct.isEmpty
          ? 0
          : selectedProduct.values
              .map((product) => product['quantity'] ?? 0)
              .reduce((a, b) => a + b);

      // Update the value of totalServiceQuantityNotifier
      ptotalQuantityNotifier.value = totalProductQuantity;
      getProductTotalPrice();
      print(selectedProduct);
    });
  }

  Future<void> fetchProduct() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET', Uri.parse('https://menu.tunai.io/loyalty/type/2/sku?active=1'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final jsonData = await response.stream.bytesToString();
      final decodedData = json.decode(jsonData);
      setState(() {
        products = decodedData['skus'];
        sections = decodedData['sections'];
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}
