import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/login.dart';
import 'package:minimal/cart.dart';
import 'package:minimal/textFormating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'allProducts.dart';
import 'allServices.dart';
import 'ordersPending.dart';
import 'allProductsServices.dart';

Map<String, Map<int, dynamic>> storeServiceAndProduct = {
  "services": selectedService,
  "products": selectedProduct,
  "all": selectedProductServices,
};

class FirstPage extends StatefulWidget {
  const FirstPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPage();
}

class _FirstPage extends State<FirstPage> {
  List<dynamic> orders = [];
  List<dynamic> members = [];
  List<dynamic> otem = [];
  List<dynamic> thelatestorder = [];

  Map<String, dynamic> baru = {};

  int count = 0;

  int nakDisplayQuantity = 0;
  double totalSubtotal = 0.0;
  String orderid = '';

  Map<String, dynamic> latestOrder = {};
  dynamic selectedOrder;

  List<dynamic> otems = [];
  List<dynamic> skus = [];
  List<dynamic> selectedItems = [];

  bool isExpanded1 = false;
  bool isExpanded2 = false;
  bool isExpanded3 = false;

  TextEditingController searchController = TextEditingController();
  String searchText = '';

  // double _searchWidth = 100.0;
  // double _serviceWidth = 100.0;
  // double _productWidth = 100.0;

  // void _toggleSearchExpanded() {
  //   setState(() {
  //     final temp = _searchWidth;
  //     _searchWidth = _serviceWidth;
  //     _serviceWidth = _productWidth;
  //     _productWidth = temp;
  //   });
  // }

  // void _toggleServiceExpanded() {
  //   setState(() {
  //     final temp = _serviceWidth;
  //     _serviceWidth = _searchWidth;
  //     _searchWidth = _productWidth;
  //     _productWidth = temp;
  //   });
  // }

  // void _toggleProductExpanded() {
  //   setState(() {
  //     final temp = _productWidth;
  //     _productWidth = _searchWidth;
  //     _searchWidth = _serviceWidth;
  //     _serviceWidth = temp;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    initializedData();
  }

  void reset() {
    selectedService.clear();
    selectedProduct.clear();
    selectedItems.clear();
    selectedProductServices.clear();
  }

  void initializedData() async {
    await fetchPendingAndMembers();
    // await getLatest();
    if(mounted){
       setState(() {
      fetchData();
    });
    }
   
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
        leading: IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.blue,
          ),
          onPressed: () async {
            // LoginUtils.logout(context, rememberPassword);
            showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text('Logout'),
                      onPressed: () async {
                        
                        Navigator.of(context).pop(); // Close the dialog
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        await pref.remove("loginToken");
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );

                     
                        // LoginUtils.logout(context,
                        //     rememberPassword); // Call the logout function from LoginUtils class.
                      },
                      isDestructiveAction: true,
                    ),
                  ],
                );
              },
            );
          },
          iconSize: 30,
        ),
        actions: [
          IconButton(
              icon: Image.asset("lib/assets/Pending.png"),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (BuildContext context) {
                    return SizedBox(
                        height: 750,
                        child: OrdersPending(
                          getLatest: getLatest,
                          updateFirst: updateFirst,
                          onOrderSelected: updateSelectedOrder,
                          fetchData: fetchData,
                        ));
                  },
                );
              })
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            children: [
              menuContainer(),
              Visibility(
                visible: latestOrder
                    .isNotEmpty, // Show the folder() widget if latestOrder is not empty
                child: folder(),
              ),
              Visibility(
                visible: !latestOrder
                    .isNotEmpty, // Show the text if latestOrder is empty
                child: Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No Orders yet!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Once you do, orders will",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "appear here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 70,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: latestOrder.isEmpty
                        ? null
                        : () {
                            _showDeleteConfirmationDialog(context);
                          },
                    child: Container(
                      // Set any desired properties for the container
                      width: 24,
                      height: 24,
                      color: Colors.white,
                      margin: const EdgeInsets.only(left: 30, bottom: 2),

                      child: Image.asset(
                        'lib/assets/Trash.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ValueListenableBuilder<int>(
                        //service quantity
                        valueListenable: totalQuantityNotifier,
                        builder: (BuildContext context, int totalItems,
                            Widget? child) {
                          return ValueListenableBuilder<double>(
                            //service price
                            valueListenable: totalSellingPriceNotifier,
                            builder: (BuildContext context, double totalPrice,
                                Widget? child) {
                              return ValueListenableBuilder<int>(
                                //product quantity
                                valueListenable: ptotalQuantityNotifier,
                                builder: (BuildContext context, int pItems,
                                    Widget? child) {
                                  return ValueListenableBuilder<double>(
                                    //product price
                                    valueListenable: ptotalSellingPriceNotifier,
                                    builder: (BuildContext context,
                                        double ptotalPrice, Widget? child) {
                                      return ValueListenableBuilder<int>(
                                        //allquantity
                                        valueListenable:
                                            pStotalQuantityNotifier,
                                        builder: (BuildContext context,
                                            int pSItems, Widget? child) {
                                          return ValueListenableBuilder<double>(
                                              //allprice
                                              valueListenable:
                                                  pStotalSellingPriceNotifier,
                                              builder: (BuildContext context,
                                                  double pStotalPrice,
                                                  Widget? child) {
                                                int combinedTotalItems =
                                                    totalItems +
                                                        pItems +
                                                        nakDisplayQuantity +
                                                        pSItems;
                                                double combineTotalPrice =
                                                    totalPrice +
                                                        ptotalPrice +
                                                        totalSubtotal +
                                                        pStotalPrice;
                                                return Visibility(
                                                  visible: !latestOrder
                                                      .isEmpty, // Show the button only when latestOrder is not empty
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      await newCreateOtem(
                                                        storeServiceAndProduct,
                                                        context,
                                                        combinedTotalItems,
                                                        combineTotalPrice,
                                                      );
                                                      reset();
                                                      totalSellingPriceNotifier
                                                          .value = 0;
                                                      totalQuantityNotifier
                                                          .value = 0;
                                                      ptotalSellingPriceNotifier
                                                          .value = 0;
                                                      ptotalQuantityNotifier
                                                          .value = 0;
                                                      pStotalSellingPriceNotifier
                                                          .value = 0;
                                                      pStotalQuantityNotifier
                                                          .value = 0;
                                                      // print('Dalam store: $storeServiceAndProduct');
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith<
                                                                      Color>(
                                                                  (states) {
                                                        if (states.contains(
                                                            MaterialState
                                                                .disabled)) {
                                                          return Colors
                                                              .grey; // Grey color for disabled state
                                                        } else {
                                                          return Colors
                                                              .blue; // Blue color for enabled state
                                                        }
                                                      }),
                                                    ),
                                                    child: Text(
                                                      "${latestOrder.isEmpty ? 0 : combinedTotalItems} item | ${latestOrder.isEmpty ? '0.00' : formatDoubleText(combineTotalPrice)}",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
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
          )
        ],
      ),
    );
  }

  updateFirst() async {
    await fetchPendingAndMembers();
    setState(() {
      fetchData();
    });
  }

  getLatest() {
    latestOrder = orders.last;
    orderid = latestOrder['orderID'].toString();
  }

  void updateSelectedOrder(dynamic order) {
    setState(() {
      latestOrder = order;

      orderid = latestOrder['orderID'].toString();
      fetchData();
    });
  }

  Widget menuContainer() {
    if (latestOrder.isNotEmpty) {
      int memberID = latestOrder['memberID'] ?? 0;

      dynamic dalamMem = members.firstWhere(
        (member) => memberID == member['memberID'],
        orElse: () => null,
      );

      String nameeee = dalamMem != null && dalamMem['mobile'] == "000000000000"
          ? "Walk-in"
          : dalamMem != null
              ? dalamMem['name']
              : "";

      String mobile = dalamMem != null ? dalamMem['mobile'] : "";
      String formattedNumber = mobile.isNotEmpty
          ? '(${mobile.substring(0, 4)}) ${mobile.substring(4, 7)}-${mobile.substring(7)}'
          : "";

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
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
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameeee,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedNumber,
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
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 1.0,
            ),
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
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "No member selected yet",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Selected member info will be display here",
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
      ); // Return an empty container if there are no orders
    }
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
                        curve: Curves.easeInOut,
                        width: isExpanded1
                            ? MediaQuery.of(context).size.width / 1.5
                            : MediaQuery.of(context).size.width / 2.3,
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
                            if (isExpanded1)
                              const SizedBox(
                                  width: 3), // Added SizedBox for spacing
                            if (isExpanded1)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (text) {
                                      setState(() {
                                        // Update the searchText variable whenever the TextField value changes
                                        searchText = text;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: InputBorder
                                          .none, // Remove the underline
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //serviceeeeee
            // const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: isExpanded1
                  ? MediaQuery.of(context).size.width / 8
                  : MediaQuery.of(context).size.width / 4,
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
                  child: ClipRect(
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Icon(Icons.folder,
                              size: 24,
                              color: isExpanded2 ? Colors.white : Colors.blue),
                        ),
                        if (!isExpanded1 || isExpanded2)
                          const SizedBox(width: 3),
                        if (!isExpanded1 || isExpanded2)
                          Flexible(
                            flex: 2,
                            child: Text(
                              'Service',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isExpanded2 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: isExpanded1
                  ? MediaQuery.of(context).size.width / 8
                  : MediaQuery.of(context).size.width / 4,
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
                  child: ClipRRect(
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Icon(Icons.folder,
                              size: 24,
                              color: isExpanded3 ? Colors.white : Colors.blue),
                        ),
                        if (!isExpanded1 || isExpanded3)
                          const SizedBox(width: 3),
                        if (!isExpanded1 || isExpanded3)
                          Flexible(
                            flex: 2,
                            child: Text(
                              'Product',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isExpanded3 ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
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
                ? AllProductServices(
                    searchText: searchText,
                  )
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
  // String updateTotalItems() {
  //   int totalItem = getServiceTotalQuantity() + getProductTotalQuantity();
  //   totalQuantityNotifier.value = totalItem;
  //   return totalItem.toString();
  // }

  // String updateTotalPrice() {
  //   double totalPrice = getServiceTotalPrice() + getProductTotalPrice();
  //   totalSellingPriceNotifier.value = totalPrice;
  //   return totalPrice.toString();
  // }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete All Items'),
          content: Text('Are you sure you want to delete all items?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  // Clear the selected items
                  selectedService.clear();
                  selectedProduct.clear();
                  selectedItems.clear();
                });

                totalSellingPriceNotifier.value = 0;
                totalQuantityNotifier.value = 0;
                ptotalSellingPriceNotifier.value = 0;
                ptotalQuantityNotifier.value = 0;

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> newCreateOtem(
    Map<String, Map<int, dynamic>> storeServiceAndProduct,
    BuildContext context,
    int combinedTotalItems,
    double combineTotalPrice,
  ) async {
    var existingSkus = Set<int>();
    String orderId = latestOrder['orderID'].toString();
    int memberID = int.parse(latestOrder['memberID'].toString());

    dynamic member = members.firstWhere(
      (member) => member['memberID'] == memberID,
      orElse: () => null,
    );

    var memberName = member['name'];

    for (var entry in storeServiceAndProduct.entries) {
      var serviceData = entry.value;

      for (var itemData in serviceData.values) {
        var skuID = itemData['skuID'];

        // Check if skuID already exists in existingSkus
        if (existingSkus.contains(skuID)) {
          continue;
        }

        var quantity = itemData['quantity'];
        var price = itemData['selling'] / quantity;
        var headers = {
          'token': tokenGlobal,
          'Content-Type': 'application/x-www-form-urlencoded',
        };
        var request = http.Request(
          'POST',
          Uri.parse('https://order.tunai.io/loyalty/order/$orderId/otems/sku'),
        );
        request.bodyFields = {
          'skuID': skuID.toString(),
          'price': price.toDouble().toStringAsFixed(2),
          'quantity': quantity.toString(),
        };
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode != 200) {
          // print(response.reasonPhrase);
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
    }

    setState(() {
      storeServiceAndProduct = {};
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Cart(
          cartName: memberName,
          cartOrderId: orderId,
          totalItems: combinedTotalItems,
          totalPrice: combineTotalPrice,
          otems: otems,
          fetchData: fetchData,
        ),
      ),
    );
  }

  fetchData() async {
    var headers = {'token': tokenGlobal};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/ ' + orderid + '/otems'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      setState(() {
        otem = body['otems'].where((item) => item['deleteDate'] == 0).toList();
        nakDisplayQuantity = otem.fold(
            0, (sum, otem) => sum + int.parse(otem['quantity'].toString()));

        totalSubtotal =
            otem.fold(0, (sum, otem) => sum + otem['price'] * otem['quantity']);
      });

      // print("otems firstPage: $otem");
      // print("qty firstPage: $nakDisplayQuantity");

      return otem;
    } else {
      // print(response.reasonPhrase);
    }
  }

  Future<void> fetchPendingAndMembers() async {
    var headers = {
      'token': tokenGlobal,
    };

    var pendingRequest = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );
    pendingRequest.headers.addAll(headers);

    var membersRequest = http.Request(
      'GET',
      Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
    );
    membersRequest.headers.addAll(headers);

    var pendingResponse = await http.Client().send(pendingRequest);
    var membersResponse = await http.Client().send(membersRequest);

    if (pendingResponse.statusCode == 200 &&
        membersResponse.statusCode == 200) {
      final pendingResponseBody = await pendingResponse.stream.bytesToString();
      final membersResponseBody = await membersResponse.stream.bytesToString();
      final pendingBody = json.decode(pendingResponseBody);
      final membersBody = json.decode(membersResponseBody);
if(mounted){
     setState(() {
        orders = pendingBody['orders'];
        latestOrder = orders.isNotEmpty ? orders.last : {};
        members = membersBody['members'];
        orderid = latestOrder['orderID'].toString();
      });
    } else {
      // print(pendingResponse.reasonPhrase);
      // print(membersResponse.reasonPhrase);
    }
  }
}
   
}

///////////////////backup/////////
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:minimal/test/login.dart';
// import 'package:minimal/test/trialCart.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../allProducts.dart';
// import '../allServices.dart';
// import '../ordersPending.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Map<String, Map<int, dynamic>> storeServiceAndProduct = {
//   "services": selectedService,
//   "products": selectedProduct,
// };

// class FirstPage extends StatefulWidget {
//   const FirstPage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<FirstPage> createState() => _FirstPage();
// }

// class _FirstPage extends State<FirstPage> {
//   //both store data from api
//   List<dynamic> menuOrder = [];
//   List<dynamic> menuMember = [];

//   List<dynamic> orders = [];
//   List<dynamic> members = [];
//   List<dynamic> thelatestorder = [];

//   Map<String, dynamic> baru = {};

//   int count = 0;

//   Map<String, dynamic> latestOrder = {};

//   List<dynamic> otems = [];
//   List<dynamic> skus = [];
//   List<dynamic> selectedItems = [];

//   bool isExpanded1 = false;
//   bool isExpanded2 = false;
//   bool isExpanded3 = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchPendingAndMembers();
//     theorder();
//     getMember();
//   }

//   void reset() {
//     selectedService.clear();
//     selectedProduct.clear();
//     selectedItems.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: const Text(
//           'Menu',
//           style: TextStyle(color: Colors.black),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.logout,
//             color: Colors.blue,
//           ),
//           // icon: Image.asset(
//           //   "lib/assets/Artboard 40.png",
//           //   height: 30,
//           //   width: 20,
//           // ),
//           // onPressed: () => Navigator.pop(context),
//           onPressed: () async {
//             SharedPreferences pref = await SharedPreferences.getInstance();
//             await pref.clear();
//             Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//                 (route) => false);
//           },
//           iconSize: 30,
//         ),
//         actions: [
//           IconButton(
//               icon: Image.asset("lib/assets/Pending.png"),
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   shape: const RoundedRectangleBorder(
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(20))),
//                   builder: (BuildContext context) {
//                     return SizedBox(
//                         height: 750,
//                         child: OrdersPending(
//                           getLatest: getLatest,
//                           updateFirst: updateFirst,
//                         ));
//                   },
//                 );
//                 // if (latestOrder  != null) {
//                 //   setState(() {
//                 //     // baru = menuawal;
//                 //     menuContainer(latestOrder);
//                 //   });

//                 //   // print("baru: $baru");
//                 //    print("latestOrder: $latestOrder");
//                 //   print("dalamapi: $menuMember");
//                 // }

//                 // print("dekat show: $latestOrder");
//               })
//         ],
//       ),
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.grey[200],
//           ),
//           Column(
//             children: [
//               // testContainer(),
//               menuContainer(latestOrder),
//               folder(),
//             ],
//           ),
//           bottomContainertest()
//         ],
//       ),
//     );
//   }

//   updateFirst() async {
//     await fetchPendingAndMembers();
//     setState(() {
//       getMember();
//     });
//   }

//   getLatest() {
//     latestOrder = menuOrder.last;
//   }

//   Widget menuContainer(Map<String, dynamic> latestOrder) {
//     var latestOrder = orders.isNotEmpty ? orders.last : null;

//     print("dalam menuContainer: $latestOrder");

//     if (latestOrder != null) {
//       int memberID = latestOrder['memberID'];

//       dynamic dalamMem = members.firstWhere(
//         (member) => memberID == member['memberID'],
//         orElse: () => null,
//       );

//       String nameeee = dalamMem != null && dalamMem['mobile'] == "000000000000"
//           ? "Walk-in"
//           : dalamMem != null
//               ? dalamMem['name']
//               : "";

//       String mobile = dalamMem['mobile'];
//       String formattedNumber =
//           '(${mobile.substring(0, 4)}) ${mobile.substring(4, 7)}-${mobile.substring(7)}';

//       return Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: Colors.white,
//             width: 1.0,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Image.asset(
//                   "lib/assets/Artboard 40 copy 2.png",
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(left: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       nameeee,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.black,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       formattedNumber,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     } else {
//       return Container(); // Return an empty container if there are no orders
//     }
//   }

//   Widget testContainer() {
//     if (baru.isNotEmpty) {
//       // Check if baru is not null and not empty
//       int memberID = baru['memberID'];

//       dynamic dalamMem = menuMember.firstWhere(
//         (member) => memberID == member['memberID'],
//         orElse: () => null,
//       );

//       if (dalamMem != null) {
//         // Check if dalamMem is not null
//         String nameeee =
//             dalamMem != null && dalamMem['mobile'] == "000000000000"
//                 ? "Walk-in"
//                 : dalamMem != null
//                     ? dalamMem['name']
//                     : ""; // Default empty string if dalamMem is null

//         String mobile = dalamMem['mobile'];
//         String formattedNumber =
//             '(${mobile.substring(0, 4)}) ${mobile.substring(4, 7)}-${mobile.substring(7)}';

//         return Padding(
//           padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: Colors.white,
//                 width: 1.0,
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 8.0),
//                     child: Image.asset(
//                       "lib/assets/Artboard 40 copy 2.png",
//                       width: 30,
//                       height: 30,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       left: 16,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           nameeee,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             color: Colors.black,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           formattedNumber,
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     }
//     if (menuOrder.isNotEmpty) {
//       getLatest();

//       int memberID = latestOrder['memberID'];

//       dynamic dalamMem = menuMember.firstWhere(
//         (member) => memberID == member['memberID'],
//         orElse: () => null,
//       );

//       String nameeee = dalamMem != null && dalamMem['mobile'] == "000000000000"
//           ? "Walk-in"
//           : dalamMem != null
//               ? dalamMem['name']
//               : ""; // Default empty string if dalamMem is null

//       String mobile = dalamMem != null ? dalamMem['mobile'] : "";
//       String formattedNumber = mobile.isNotEmpty
//           ? '(${mobile.substring(0, 4)}) ${mobile.substring(4, 7)}-${mobile.substring(7)}'
//           : "";

//       return Padding(
//         padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: Colors.white,
//               width: 1.0,
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8.0),
//                   child: Image.asset(
//                     "lib/assets/Artboard 40 copy 2.png",
//                     width: 30,
//                     height: 30,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                     left: 16,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         nameeee,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Colors.black,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         formattedNumber,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.only(top: 15.0, left: 5, right: 5),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: Colors.white,
//             width: 1.0,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Image.asset(
//                   "lib/assets/Artboard 40 copy 2.png",
//                   width: 30,
//                   height: 30,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(
//                   left: 16,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "No member selected yet",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Colors.blue,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Selected member will be display here",
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget folder() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.translucent,
//                   onTap: () {
//                     setState(() {
//                       isExpanded1 = !isExpanded1;
//                       isExpanded2 = false;
//                       isExpanded3 = false;
//                     });
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 500),
//                         width: isExpanded1 ? 262 : 162,
//                         height: 35,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(24),
//                           color: Colors.white,
//                         ),
//                         child: Row(
//                           children: [
//                             const SizedBox(width: 5),
//                             const Icon(Icons.search,
//                                 size: 24, color: Colors.blue),
//                             if (isExpanded1) const SizedBox(width: 3),
//                             if (isExpanded1)
//                               const Text(
//                                 'Test',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 4),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               width: isExpanded1 ? 35 : 100,
//               height: 35,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   setState(() {
//                     isExpanded1 = false;
//                     isExpanded2 = !isExpanded2;
//                     isExpanded3 = false;
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                     color: isExpanded2 ? Colors.blue : Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.folder,
//                           size: 24,
//                           color: isExpanded2 ? Colors.white : Colors.blue),
//                       if (!isExpanded1 || isExpanded2) const SizedBox(width: 3),
//                       if (!isExpanded1 || isExpanded2)
//                         Text(
//                           'Service',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: isExpanded2 ? Colors.white : Colors.black,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 3),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               width: isExpanded1 ? 35 : 100,
//               height: 35,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   setState(() {
//                     isExpanded1 = false;
//                     isExpanded2 = false;
//                     isExpanded3 = !isExpanded3;
//                   });
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                     color: isExpanded3 ? Colors.blue : Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.folder,
//                           size: 24,
//                           color: isExpanded3 ? Colors.white : Colors.blue),
//                       if (!isExpanded1 || isExpanded3) const SizedBox(width: 3),
//                       if (!isExpanded1 || isExpanded3)
//                         Text(
//                           'Product',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: isExpanded3 ? Colors.white : Colors.black,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 4),
//           ],
//         ),
//         GestureDetector(
//           child: Container(
//             width: 500,
//             height: 558,
//             color: Colors.grey[200],
//             child: isExpanded1
//                 ? AllProducts()
//                 : isExpanded2
//                     ? AllServices()
//                     : isExpanded3
//                         ? AllProducts()
//                         : const SizedBox.shrink(),
//           ),
//         ),
//       ],
//     );
//   }

//   String updateTotalItems() {
//     int totalItem = getServiceTotalQuantity() + getProductTotalQuantity();
//     totalQuantityNotifier.value = totalItem;
//     return totalItem.toString();
//   }

//   String updateTotalPrice() {
//     double totalPrice = getServiceTotalPrice() + getProductTotalPrice();
//     totalSellingPriceNotifier.value = totalPrice;
//     return totalPrice.toString();
//   }

//   Widget bottomContainertest() {
//     return Positioned(
//       bottom: 0,
//       child: Container(
//         height: 76,
//         width: MediaQuery.of(context).size.width,
//         color: Colors.white,
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {},
//               iconSize: 24.0,
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: ValueListenableBuilder<int>(
//                   valueListenable: totalQuantityNotifier,
//                   builder:
//                       (BuildContext context, int totalItems, Widget? child) {
//                     return ValueListenableBuilder<double>(
//                       valueListenable: totalSellingPriceNotifier,
//                       builder: (BuildContext context, double totalPrice,
//                           Widget? child) {
//                         return ValueListenableBuilder<int>(
//                           valueListenable: ptotalQuantityNotifier,
//                           builder: (BuildContext context, int pItems,
//                               Widget? child) {
//                             return ValueListenableBuilder<double>(
//                               valueListenable: ptotalSellingPriceNotifier,
//                               builder: (BuildContext context,
//                                   double ptotalPrice, Widget? child) {
//                                 int combinedTotalItems = totalItems + pItems;
//                                 double combineTotalPrice =
//                                     totalPrice + ptotalPrice;
//                                 return ElevatedButton(
//                                   onPressed: () async {
//                                     await newCreateOtem(
//                                       storeServiceAndProduct,
//                                       context,
//                                       combinedTotalItems,
//                                       combineTotalPrice,
//                                     );
//                                     reset();
//                                     totalSellingPriceNotifier.value = 0;
//                                     totalQuantityNotifier.value = 0;
//                                     print(
//                                         'Dalam store: $storeServiceAndProduct');
//                                   },
//                                   child: Text(
//                                     "$combinedTotalItems item | ${combineTotalPrice.toStringAsFixed(2)} ",
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> apicreateOtemsByService(
//     Map<String, Map<int, dynamic>> storeServiceAndProduct,
//     BuildContext context,
//     int combinedTotalItems,
//     double combineTotalPrice,
//   ) async {
//     var existingSkus = Set<int>();
//     var orderId = baru['orderID'].toString();
//     // String memberID = baru['memberID'].toString();

//     // dynamic dalamMem = menuMember.firstWhere(
//     //   (member) => memberID == member['memberID'],
//     //   orElse: () => null,
//     // );

//     // dynamic sku = menuMember.firstWhere((sku) =>
//     //                                 sku['memberID'] == memberID);

//     // String nameeee = dalamMem != null ? dalamMem['name']: '';

//     String memberID = baru['memberID'].toString();
//     int realMemberName = int.parse(memberID);

//     dynamic member = menuMember.firstWhere(
//       (member) => member['memberID'] == realMemberName,
//       orElse: () => null,
//     );

//     var memberName = member['name'];

//     print("dalamapi: $menuMember");
//     print("dalammem: $member");
//     // print("sku: $sku");
//     print('name: $memberName ');
//     for (var entry in storeServiceAndProduct.entries) {
//       var serviceData = entry.value;

//       for (var itemData in serviceData.values) {
//         var skuID = itemData['skuID'];

//         // Check if skuID already exists in existingSkus
//         if (existingSkus.contains(skuID)) {
//           continue;
//         }

//         var price = itemData['selling'];
//         var quantity = itemData['quantity'];

//         var headers = {
//           'token': tokenGlobal,
//           'Content-Type': 'application/x-www-form-urlencoded',
//         };
//         var request = http.Request(
//           'POST',
//           Uri.parse('https://order.tunai.io/loyalty/order/$orderId/otems/sku'),
//         );
//         request.bodyFields = {
//           'skuID': skuID.toString(),
//           'price': price.toDouble().toStringAsFixed(2),
//           'quantity': quantity.toString(),
//         };
//         request.headers.addAll(headers);

//         http.StreamedResponse response = await request.send();

//         if (response.statusCode != 200) {
//           print(response.reasonPhrase);
//         } else {
//           final responsebody = await response.stream.bytesToString();
//           final body = json.decode(responsebody);
//           otems =
//               body['otems'].where((item) => item['deleteDate'] == 0).toList();
//           skus = body['skus'];

//           // Add skuID to existingSkus
//           existingSkus.add(skuID);
//         }
//       }
//     }

//     setState(() {
//       storeServiceAndProduct = {};
//     });

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TrialCart(
//           cartName: memberName,
//           cartOrderId: orderId,
//           totalItems: combinedTotalItems,
//           totalPrice: combineTotalPrice,
//           otems: otems,
//         ),
//       ),
//     );
//   }

//   Future<void> newCreateOtem(
//     Map<String, Map<int, dynamic>> storeServiceAndProduct,
//     BuildContext context,
//     int combinedTotalItems,
//     double combineTotalPrice,
//   ) async {
//     var existingSkus = Set<int>();
//     String orderId = latestOrder['orderID'].toString();
//     int memberID = int.parse(latestOrder['memberID'].toString());

//     dynamic member = menuMember.firstWhere(
//       (member) => member['memberID'] == memberID,
//       orElse: () => null,
//     );

//     var memberName = member['name'];

//     print("dalamapi: $menuMember");
//     print("dalammem: $member");
//     // print("sku: $sku");
//     print('name: $memberName ');
//     for (var entry in storeServiceAndProduct.entries) {
//       var serviceData = entry.value;

//       for (var itemData in serviceData.values) {
//         var skuID = itemData['skuID'];

//         // Check if skuID already exists in existingSkus
//         if (existingSkus.contains(skuID)) {
//           continue;
//         }

//         var price = itemData['selling'];
//         var quantity = itemData['quantity'];

//         var headers = {
//           'token': tokenGlobal,
//           'Content-Type': 'application/x-www-form-urlencoded',
//         };
//         var request = http.Request(
//           'POST',
//           Uri.parse('https://order.tunai.io/loyalty/order/$orderId/otems/sku'),
//         );
//         request.bodyFields = {
//           'skuID': skuID.toString(),
//           'price': price.toDouble().toStringAsFixed(2),
//           'quantity': quantity.toString(),
//         };
//         request.headers.addAll(headers);

//         http.StreamedResponse response = await request.send();

//         if (response.statusCode != 200) {
//           print(response.reasonPhrase);
//         } else {
//           final responsebody = await response.stream.bytesToString();
//           final body = json.decode(responsebody);
//           otems =
//               body['otems'].where((item) => item['deleteDate'] == 0).toList();
//           skus = body['skus'];

//           // Add skuID to existingSkus
//           existingSkus.add(skuID);
//         }
//       }
//     }

//     setState(() {
//       storeServiceAndProduct = {};
//     });

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TrialCart(
//           cartName: memberName,
//           cartOrderId: orderId,
//           totalItems: combinedTotalItems,
//           totalPrice: combineTotalPrice,
//           otems: otems,
//         ),
//       ),
//     );
//   }

//   // void getCred()async {
//   //   SharedPreferences pref = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     token = pref.getString("login")!;
//   //   });

//   //   print("token: $token");

//   // }

//   theorder() async {
//     var headers = {'token': tokenGlobal};
//     var request = http.Request(
//         'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

//     request.headers.addAll(headers);

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       final responsebody = await response.stream.bytesToString();
//       final body = json.decode(responsebody);

//       setState(() {
//         menuOrder = body['orders'];
//         getLatest();
//       });

//       print(responsebody);
//     } else {
//       print(response.reasonPhrase);
//     }
//   }

//   getMember() {
//     var headers = {'token': tokenGlobal};
//     var request = http.Request(
//         'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

//     request.headers.addAll(headers);

//     request.send().then((response) {
//       if (response.statusCode == 200) {
//         response.stream.bytesToString().then((responsebody) {
//           final body = json.decode(responsebody);

//           setState(() {
//             menuMember = body['members'];
//           });
//           print(responsebody);
//           // print("menuMember: $menuMember");
//         });
//       } else {
//         print(response.reasonPhrase);
//       }
//     });
//   }

//   Future<Map<String, dynamic>> fetchPendingAndMembers() async {
//     var headers = {
//       'token': tokenGlobal,
//     };

//     var pendingRequest = http.Request(
//       'GET',
//       Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
//     );
//     pendingRequest.headers.addAll(headers);

//     var membersRequest = http.Request(
//       'GET',
//       Uri.parse('https://order.tunai.io/loyalty/order?active=1'),
//     );
//     membersRequest.headers.addAll(headers);

//     var pendingResponse = await http.Client().send(pendingRequest);
//     var membersResponse = await http.Client().send(membersRequest);

//     if (pendingResponse.statusCode == 200 &&
//         membersResponse.statusCode == 200) {
//       final pendingResponseBody = await pendingResponse.stream.bytesToString();
//       final membersResponseBody = await membersResponse.stream.bytesToString();
//       final pendingBody = json.decode(pendingResponseBody);
//       final membersBody = json.decode(membersResponseBody);

//       orders = pendingBody['orders'];
//       members = membersBody['members'];

//       Map<String, dynamic> result = {
//         'pending': orders,
//         'members': members,
//       };

//       setState(() {
//         orders = pendingBody['orders'];
//       });

//       return result;
//     } else {
//       print(pendingResponse.reasonPhrase);
//       print(membersResponse.reasonPhrase);
//       return {};
//     }
//   }
// }
//////////
 // Future<void> apicreateOtemsByService(
  //   Map<String, Map<int, dynamic>> storeServiceAndProduct,
  //   BuildContext context,
  //   int combinedTotalItems,
  //   double combineTotalPrice,
  // ) async {
  //   var existingSkus = Set<int>();
  //   var orderId = baru['orderID'].toString();
  //   // String memberID = baru['memberID'].toString();

  //   // dynamic dalamMem = menuMember.firstWhere(
  //   //   (member) => memberID == member['memberID'],
  //   //   orElse: () => null,
  //   // );

  //   // dynamic sku = menuMember.firstWhere((sku) =>
  //   //                                 sku['memberID'] == memberID);

  //   // String nameeee = dalamMem != null ? dalamMem['name']: '';

  //   String memberID = baru['memberID'].toString();
  //   int realMemberName = int.parse(memberID);

  //   dynamic member = menuMember.firstWhere(
  //     (member) => member['memberID'] == realMemberName,
  //     orElse: () => null,
  //   );

  //   var memberName = member['name'];

  //   print("dalamapi: $menuMember");
  //   print("dalammem: $member");
  //   // print("sku: $sku");
  //   print('name: $memberName ');
  //   for (var entry in storeServiceAndProduct.entries) {
  //     var serviceData = entry.value;

  //     for (var itemData in serviceData.values) {
  //       var skuID = itemData['skuID'];

  //       // Check if skuID already exists in existingSkus
  //       if (existingSkus.contains(skuID)) {
  //         continue;
  //       }

  //       var price = itemData['selling'];
  //       var quantity = itemData['quantity'];

  //       var headers = {
  //         'token': tokenGlobal,
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       };
  //       var request = http.Request(
  //         'POST',
  //         Uri.parse('https://order.tunai.io/loyalty/order/$orderId/otems/sku'),
  //       );
  //       request.bodyFields = {
  //         'skuID': skuID.toString(),
  //         'price': price.toDouble().toStringAsFixed(2),
  //         'quantity': quantity.toString(),
  //       };
  //       request.headers.addAll(headers);

  //       http.StreamedResponse response = await request.send();

  //       if (response.statusCode != 200) {
  //         print(response.reasonPhrase);
  //       } else {
  //         final responsebody = await response.stream.bytesToString();
  //         final body = json.decode(responsebody);
  //         otems =
  //             body['otems'].where((item) => item['deleteDate'] == 0).toList();
  //         skus = body['skus'];

  //         // Add skuID to existingSkus
  //         existingSkus.add(skuID);
  //       }
  //     }
  //   }

  //   setState(() {
  //     storeServiceAndProduct = {};
  //   });

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => TrialCart(
  //         cartName: memberName,
  //         cartOrderId: orderId,
  //         totalItems: combinedTotalItems,
  //         totalPrice: combineTotalPrice,
  //         otems: otems,
  //       ),
  //     ),
  //   );
  // }
  // void getCred()async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   setState(() {
  //     token = pref.getString("login")!;
  //   });

  //   print("token: $token");

  // }

  // theorder() async {
  //   var headers = {'token': tokenGlobal};
  //   var request = http.Request(
  //       'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

  //   request.headers.addAll(headers);

  //   http.StreamedResponse response = await request.send();

  //   if (response.statusCode == 200) {
  //     final responsebody = await response.stream.bytesToString();
  //     final body = json.decode(responsebody);

  //     setState(() {
  //       menuOrder = body['orders'];
        
  //     });

  //     print(responsebody);
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  // getMember() {
  //   var headers = {'token': tokenGlobal};
  //   var request = http.Request(
  //       'GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

  //   request.headers.addAll(headers);

  //   request.send().then((response) {
  //     if (response.statusCode == 200) {
  //       response.stream.bytesToString().then((responsebody) {
  //         final body = json.decode(responsebody);

  //         setState(() {
  //           menuMember = body['members'];
  //         });
  //         print(responsebody);
  //         // print("menuMember: $menuMember");
  //       });
  //     } else {
  //       print(response.reasonPhrase);
  //     }
  //   });
  // }
