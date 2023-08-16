// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../textFormating.dart';
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import 'staff.dart';

class ItemDetails extends StatefulWidget {
  final int saleID;
  final int completedID;
  final String skuName;
  final double priceAmt;
  final double outstandAmt;
  final double discountAmt;
  final List<dynamic> staff;
  final VoidCallback updateData;
  const ItemDetails(
      {super.key,
      required this.saleID,
      required this.completedID,
      required this.skuName,
      required this.priceAmt,
      required this.outstandAmt,
      required this.discountAmt,
      required this.staff,
      required this.updateData});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  double subTotal = 0;
  double total = 0;
  double newEffort = 0;
  double newHof = 0;

  int quantity = 0;

  List<TextEditingController> effortControllers = [];
  List<TextEditingController> hofControllers = [];

  List<dynamic> staff = [];

  bool doneUpdate = false;
  bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    subTotal = widget.priceAmt - widget.outstandAmt - widget.discountAmt;
    quantity = 1;
    total = subTotal * quantity;

    staff = widget.staff;

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
          'Item details',
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
                if (isEdit == true) {
                  widget.updateData();
                }
                Navigator.pop(context);
              },
            ),
          ),
        ),
        actions: doneUpdate
            ? [
                TextButton(
                  onPressed: () {
                    upDateStaff();
                    setState(() {
                      doneUpdate =
                          false; // Set doneUpdate to false to hide the button
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF1175fc),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xFFf3f2f8),
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.skuName,
                          style: const TextStyle(color: Color(0xFF878787)),
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Unit Price'),
                                  Text(
                                    formatAmount(widget.priceAmt),
                                    style: const TextStyle(
                                        color: Color(0xFF333333)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (widget.outstandAmt != 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Outstanding'),
                                    Text(
                                      widget.outstandAmt.toString(),
                                      style: const TextStyle(
                                          color: Color(0xFFff2c55)),
                                    ),
                                  ],
                                ),
                              if (widget.outstandAmt != 0)
                                const SizedBox(
                                  height: 10,
                                ),
                              if (widget.discountAmt != 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Discount'),
                                    Text(
                                      formatAmount(widget.discountAmt),
                                      style: const TextStyle(
                                          color: Color(0xFF28cd41)),
                                    ),
                                  ],
                                ),
                              if (widget.discountAmt != 0)
                                const SizedBox(
                                  height: 10,
                                ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal'),
                                  Text(
                                    formatAmount(subTotal),
                                    style: const TextStyle(
                                        color: Color(0xFF1276ff)),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quantity'),
                                  Text('X $quantity',
                                      style: const TextStyle(
                                          color: Color(0xFF333333)))
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                            Text(
                              formatAmount(total),
                              style: const TextStyle(color: Color(0xFF000000)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Staff'),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet<dynamic>(
                                  enableDrag: false,
                                  barrierColor: Colors.transparent,
                                  isScrollControlled: true,
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  )),
                                  builder: (BuildContext context) {
                                    return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2.65 /
                                                3,
                                        child: Staff(saleStaff: staff));
                                  },
                                ).then((updatedSaleStaff) {
                                  if (updatedSaleStaff != null) {
                                    setState(() {
                                      isEdit = true;
                                      staff = updatedSaleStaff;
                                      upDateStaff();
                                    });
                                  }
                                });
                              },
                              child: Image.asset(
                                'icons/Plus (Blue).png',
                                scale: 50,
                              ),
                            )
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: staff.length,
                            itemBuilder: (context, index) {
                              if (index >= effortControllers.length) {
                                effortControllers.add(TextEditingController(
                                    text: formatDoubleText(
                                        staff[index]['effort'].toDouble())));
                                hofControllers.add(TextEditingController(
                                    text: formatDoubleText(
                                        staff[index]['hof'].toDouble())));
                              }

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      const Color(0xFFf3f2f8),
                                                  backgroundImage: NetworkImage(
                                                      staff[index]['emoji']),
                                                  radius: 25,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(staff[index]['name']),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                isEdit = true;
                                                deleteStaff(index);
                                              },
                                              child: Image.asset(
                                                'icons/Person (Red).png',
                                                scale: 50,
                                              ),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text('Effort'),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Image.asset(
                                                          'icons/Edit (Blue).png',
                                                          scale: 60,
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              10), // Limit input to 5 characters
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'^\d+\.?\d{0,2}')),
                                                        ],
                                                      textAlign:
                                                          TextAlign.center,
                                                      controller:
                                                          effortControllers[
                                                              index],
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: '0.00',
                                                        isDense:
                                                            true, // Added this
                                                        contentPadding:
                                                            EdgeInsets.all(7),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                        ), // Added this
                                                      ),
                                                      onChanged: (newValue) {
                                                        String numericPart =
                                                            newValue.replaceAll(
                                                                RegExp(
                                                                    r'[^\d.]'),
                                                                '');
                                                        newEffort =
                                                            double.tryParse(
                                                                    numericPart) ??
                                                                0.0;
                                                        newHof = double.parse(
                                                            hofControllers[
                                                                    index]
                                                                .text);
                                                        updateStaffInfo(index,
                                                            newEffort, newHof);
                                                      },
                                                      onTap: () {
                                                        setState(() {
                                                          isEdit = true;
                                                          doneUpdate = true;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                              'Hands on'),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Image.asset(
                                                            'icons/Edit (Blue).png',
                                                            scale: 60,
                                                          )
                                                        ],
                                                      ),
                                                      TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          LengthLimitingTextInputFormatter(
                                                              10), // Limit input to 5 characters
                                                          FilteringTextInputFormatter
                                                              .allow(RegExp(
                                                                  r'^\d+\.?\d{0,2}')),
                                                        ],
                                                        textAlign:
                                                            TextAlign.center,
                                                        controller:
                                                            hofControllers[
                                                                index],
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText: '0.00',
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.all(7),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                        ),
                                                        onChanged: (newValue) {
                                                          String numericPart =
                                                              newValue.replaceAll(
                                                                  RegExp(
                                                                      r'[^\d.]'),
                                                                  '');
                                                          newHof = double.tryParse(
                                                                  numericPart) ??
                                                              0.0;
                                                          newEffort = double.parse(
                                                              effortControllers[
                                                                      index]
                                                                  .text);
                                                          updateStaffInfo(
                                                              index,
                                                              newEffort,
                                                              newHof);
                                                        },
                                                        onTap: () {
                                                          setState(() {
                                                            isEdit = true;
                                                            doneUpdate = true;
                                                          });
                                                        },
                                                      ),
                                                    ]),
                                              ),
                                              Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    color: Colors.white,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index < staff.length - 1)
                                    const Divider(
                                      thickness: 1,
                                    )
                                ],
                              );
                            })
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateStaffInfo(int index, double newEffort, double newHof) {
    setState(() {
      staff[index]['effort'] = newEffort;
      staff[index]['hof'] = newHof;
    });
  }

  void deleteStaff(int index) {
    setState(() {
      staff.removeAt(index);
      effortControllers = [];
      hofControllers = [];
    });
    upDateStaff();
  }

  upDateStaff() async {
    var headers = {'token': token, 'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/cashregister/sale/${widget.saleID}/completed/${widget.completedID}/update'));
    request.body = json.encode({"staffs": staff});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    } else {
      print(response.reasonPhrase);
    }
  }
}
