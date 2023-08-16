// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../constant/token.dart';

class Cashier extends StatefulWidget {
  final int staffID;
  final int saleID;
  final VoidCallback updateData;
  const Cashier(
      {super.key,
      required this.staffID,
      required this.saleID,
      required this.updateData});

  @override
  State<Cashier> createState() => _CashierState();
}

class _CashierState extends State<Cashier> {
  List<dynamic> cashier = [];
  List<dynamic> cashierTrue = [];

  int selectedStaffID = 0;

  bool loadAPI = true;

  Future getCashier() async {
    var headers = {'token': token};
    var request =
        http.Request('GET', Uri.parse('https://staff.tunai.io/loyalty/staff'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> cashiers = body;
      cashier = cashiers['staffs'];

      for(int i = 0; i < cashier.length; i++){
        if(cashier[i]['cashier']['isCashier'] == 1 && cashier[i]['deleteDate'] == 0){
          cashierTrue.add(cashier[i]);
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 200.0;

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          centerTitle: true,
          title: const Text(
            'Cashier',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Transform.scale(
              scale: 1.4,
              child: CloseButton(
                color: const Color(0xFF1276ff),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: FutureBuilder(
            future: loadAPI ? getCashier() : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Container(
                    width: double.infinity,
                    color: const Color(0xFFf3f2f8),
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Select cashier'),
                                const SizedBox(height: 10),
                                GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          2, // Number of colors per row
                                      childAspectRatio: aspectRatio,
                                      crossAxisSpacing:
                                          10, // Gap between the columns
                                      mainAxisSpacing:
                                          10, // Gap between the rows
                                    ),
                                    itemCount: cashierTrue.length,
                                    itemBuilder: (context, index) {

                                      final bool isSelected = selectedStaffID ==
                                          cashierTrue[index]['staffID'];

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              loadAPI = false;
                                              selectedStaffID = isSelected
                                                  ? null
                                                  : cashierTrue[index]['staffID'];
                                            });
                                            updateCashier(
                                                cashierTrue[index]['staffID']);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              color: widget.staffID !=
                                                      cashierTrue[index]['staffID']
                                                  ? Colors.white
                                                  : Colors.blue.shade100,
                                              border: isSelected
                                                  ? Border.all(
                                                      color: Colors.blue,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  cashierTrue[index]['image'] != ''
                                                      ? CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  cashierTrue[index]
                                                                      [
                                                                      'image']),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFf3f2f8),
                                                          radius: 30,
                                                        )
                                                      : CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  cashierTrue[index]
                                                                      ['icon']),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFf3f2f8),
                                                          radius: 30,
                                                        ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                            child: Text(
                                                                cashierTrue[index]
                                                                    ['name'])),
                                                        Text(
                                                          '${'(' + cashierTrue[index]['mobile'].substring(0, 4) + ')' + cashierTrue[index]['mobile'].substring(4, 7)}-' +
                                                              cashierTrue[index]
                                                                      ['mobile']
                                                                  .substring(7),
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF878787)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      
                                    })
                              ],
                            ),
                          ),
                        ),
                      );
                    }));
              }
            }));
  }

  updateCashier(int staffID) async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/cashregister/sale/${widget.saleID}/cashier'));
    request.bodyFields = {'staffID': staffID.toString()};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      widget.updateData();
      Navigator.pop(context);
    } else {
      print(response.reasonPhrase);
    }
  }
}
