import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/test/trialCart.dart';
import 'package:minimal/updatedCart.dart';
import 'dart:convert';

import '../allProducts.dart';
import '../allServices.dart';
import '../api.dart';

Map<String, Map<int, dynamic>> storeServiceAndProduct = {
  "services": selectedService,
  "products": selectedProduct,
};

class trialMenuPage extends StatefulWidget {
  const trialMenuPage({
    Key? key,
    required this.orderId,
    required this.memberName,
    required this.memberMobile,
  }) : super(key: key);

  final String orderId;
  final String memberName;
  final String memberMobile;

  @override
  State<trialMenuPage> createState() => _trialMenuPage();
}

class _trialMenuPage extends State<trialMenuPage> {
  //both store data from api
  List<dynamic> otems = [];
  List<dynamic> skus = [];
  List<dynamic> selectedItems = [];

  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;

  @override
  void initState() {
    super.initState();
  }

  void reset (){
    selectedService.clear();
    selectedProduct.clear();
    selectedItems.clear();
  }

  Future<void> apicreateOtemsByService(
    Map<String, Map<int, dynamic>> storeServiceAndProduct,
    BuildContext context,
    int combinedTotalItems,
    double combineTotalPrice,
  ) async {
    print('otemsssssssssssssss\n $otems');
    var existingSkus = Set<int>();

    for (var entry in storeServiceAndProduct.entries) {
      var serviceData = entry.value;

      for (var itemData in serviceData.values) {
        var skuID = itemData['skuID'];

        // Check if skuID already exists in existingSkus
        if (existingSkus.contains(skuID)) {
          continue;
        }

        var price = itemData['selling'];
        var quantity = itemData['quantity'];

        var headers = {
          'token': token,
          'Content-Type': 'application/x-www-form-urlencoded',
        };
        var request = http.Request(
          'POST',
          Uri.parse('https://order.tunai.io/loyalty/order/' +
              '${widget.orderId}' +
              '/otems/sku'),
        );
        request.bodyFields = {
          'skuID': skuID.toString(),
          'price': price.toDouble().toStringAsFixed(2),
          'quantity': quantity.toString(),
        };
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode != 200) {
          print(response.reasonPhrase);
        } else {
          final responsebody = await response.stream.bytesToString();
          final body = json.decode(responsebody);
          otems =
              body['otems'].where((item) => item['deleteDate'] == 0).toList();
          skus = body['skus'];

          // Add skuID to existingSkus
          existingSkus.add(skuID);
        }
      }
      //print('Dalam store: $storeServiceAndProduct');
    }
    // print('combine');
    // print(combinedTotalItems);
    // Move the Navigator.push code here
    setState(() {
      storeServiceAndProduct = {};
    });
    // print("setstate");
    // print(storeServiceAndProduct);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrialCart(
          cartName: widget.memberName,
          cartOrderId: widget.orderId,
          totalItems: combinedTotalItems,
          totalPrice: combineTotalPrice,
          otems: otems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.black),
        ),
        leading: xIcon(),
        actions: [pendingIcon()],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            children: [
              containerOrder(),
              folder(),
            ],
          ),
          // bottomContainer()
          bottomContainertest()
        ],
      ),
    );
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

  Widget pendingIcon() {
    return IconButton(
        icon: Image.asset("lib/assets/Pending.png"),
        onPressed: () {
          // Implement onPressed action
        });
  }

  Widget containerOrder() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(
                  "lib/assets/Artboard 40 copy 2.png",
                  width: 30,
                  height: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.memberName,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.memberMobile,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        overflow: TextOverflow.ellipsis,
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
  }

  Widget folder() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      isExpanded1 = !isExpanded1;
                      isExpanded2 = false;
                      isExpanded3 = false;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: isExpanded1 ? 262 : 162,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 5),
                            const Icon(Icons.search,
                                size: 24, color: Colors.blue),
                            if (isExpanded1) const SizedBox(width: 3),
                            if (isExpanded1)
                              const Text(
                                'Test',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
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
            const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isExpanded1 ? 35 : 100,
              height: 35,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    isExpanded1 = false;
                    isExpanded2 = !isExpanded2;
                    isExpanded3 = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isExpanded2 ? Colors.blue : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder,
                          size: 24,
                          color: isExpanded2 ? Colors.white : Colors.blue),
                      if (!isExpanded1 || isExpanded2) const SizedBox(width: 3),
                      if (!isExpanded1 || isExpanded2)
                        Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 16,
                            color: isExpanded2 ? Colors.white : Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isExpanded1 ? 35 : 100,
              height: 35,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    isExpanded1 = false;
                    isExpanded2 = false;
                    isExpanded3 = !isExpanded3;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isExpanded3 ? Colors.blue : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder,
                          size: 24,
                          color: isExpanded3 ? Colors.white : Colors.blue),
                      if (!isExpanded1 || isExpanded3) const SizedBox(width: 3),
                      if (!isExpanded1 || isExpanded3)
                        Text(
                          'Product',
                          style: TextStyle(
                            fontSize: 16,
                            color: isExpanded3 ? Colors.white : Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 4),
          ],
        ),
        GestureDetector(
          child: Container(
            width: 500,
            height: 558,
            color: Colors.grey[200],
            child: isExpanded1
                ? AllProducts()
                : isExpanded2
                    ? AllServices()
                    : isExpanded3
                        ? AllProducts()
                        : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  String updateTotalItems() {
    int totalItem = getServiceTotalQuantity() + getProductTotalQuantity();
    totalQuantityNotifier.value = totalItem;
    return totalItem.toString();
  }

  String updateTotalPrice() {
    double totalPrice = getServiceTotalPrice() + getProductTotalPrice();
    totalSellingPriceNotifier.value = totalPrice;
    return totalPrice.toString();
  }

  Widget bottomContainertest() {
    return Positioned(
      bottom: 0,
      child: Container(
        height: 76,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
              iconSize: 24.0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: totalQuantityNotifier,
                  builder:
                      (BuildContext context, int totalItems, Widget? child) {
                    return ValueListenableBuilder<double>(
                      valueListenable: totalSellingPriceNotifier,
                      builder: (BuildContext context, double totalPrice,
                          Widget? child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: ptotalQuantityNotifier,
                          builder: (BuildContext context, int pItems,
                              Widget? child) {
                            return ValueListenableBuilder<double>(
                              valueListenable: ptotalSellingPriceNotifier,
                              builder: (BuildContext context,
                                  double ptotalPrice, Widget? child) {
                                int combinedTotalItems = totalItems + pItems;
                                double combineTotalPrice =
                                    totalPrice + ptotalPrice;
                                return ElevatedButton(
                                  onPressed: () async {
                                   
                                      await apicreateOtemsByService(
                                        storeServiceAndProduct,
                                        context,
                                        combinedTotalItems,
                                        combineTotalPrice,
                                      );
                                      reset();
                                      print(
                                          'Dalam store: $storeServiceAndProduct');
                                    
                                  },
                                  child: Text(
                                    "$combinedTotalItems item | ${combineTotalPrice.toStringAsFixed(2)} ",
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
