// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import '../Sales/orderDetails.dart';

class VoucherDetails extends StatefulWidget {
  final String name;
  final List<dynamic> items;
  const VoucherDetails({super.key, required this.name, required this.items});

  @override
  State<VoucherDetails> createState() => _VoucherDetailsState();
}

class _VoucherDetailsState extends State<VoucherDetails> {
  bool menuVisible = false;
  bool menuVisible1 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: Text(
            widget.name,
            style: const TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
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
          // actions: [
          //   PopupMenuButton<String>(
          //     shape: const ContinuousRectangleBorder(
          //         borderRadius: BorderRadius.all(Radius.circular(15.0))),
          //     elevation: 1,
          //     offset: const Offset(0, 45),
          //     padding: EdgeInsets.zero,
          //     child: Image.asset(
          //       'icons/More (Blue).png',
          //       color: menuVisible ? Colors.blueAccent.shade100 : null,
          //       scale: 40,
          //     ),
          //     onOpened: () {
          //       setState(() {
          //         menuVisible = !menuVisible;
          //       });
          //     },
          //     onCanceled: () {
          //       setState(() {
          //         menuVisible = !menuVisible;
          //       });
          //     },
          //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //       PopupMenuItem<String>(
          //         padding: EdgeInsets.zero,
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             GestureDetector(
          //               onTap: () {
          //                 Navigator.pop(context);
          //                 // showModalBottomSheet<dynamic>(
          //                 //   enableDrag: false,
          //                 //   barrierColor: Colors.transparent,
          //                 //   isScrollControlled: true,
          //                 //   context: context,
          //                 //   shape: const RoundedRectangleBorder(
          //                 //       borderRadius: BorderRadius.vertical(
          //                 //     top: Radius.circular(20),
          //                 //   )),
          //                 //   builder: (BuildContext context) {
          //                 //     return Container(
          //                 //         height: MediaQuery.of(context).size.height *
          //                 //             2.65 /
          //                 //             3,
          //                 //         child: Reset());
          //                 //   },
          //                 // );
          //               },
          //               child: Container(
          //                 color: Colors.white,
          //                 width: double.infinity,
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Image.asset(
          //                       'icons/Voucher 3.png',
          //                       scale: 40,
          //                       color: Colors.black,
          //                     ),
          //                     const SizedBox(
          //                       width: 5,
          //                     ),
          //                     const Text(
          //                       'Reset all voucher',
          //                       style: TextStyle(fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //             const Divider(
          //               thickness: 3,
          //               color: Color(0xFFf3f2f8),
          //             ),
          //             GestureDetector(
          //               onTap: () {
          //                 expireAllVoucher();
          //               },
          //               child: Container(
          //                 color: Colors.white,
          //                 width: double.infinity,
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Image.asset(
          //                       'icons/Expire.png',
          //                       scale: 50,
          //                     ),
          //                     const SizedBox(
          //                       width: 5,
          //                     ),
          //                     const Text(
          //                       'Expire all voucher',
          //                       style: TextStyle(
          //                           color: Color(0xFFff3b2f), fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //             const Divider(
          //               thickness: 1,
          //             ),
          //             GestureDetector(
          //               onTap: () {
          //                 deleteAllVoucher();
          //               },
          //               child: Container(
          //                 color: Colors.white,
          //                 width: double.infinity,
          //                 child: Row(
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     Image.asset(
          //                       'icons/Trash.png',
          //                       scale: 50,
          //                     ),
          //                     const SizedBox(
          //                       width: 5,
          //                     ),
          //                     const Text(
          //                       'Delete all voucher',
          //                       style: TextStyle(
          //                           color: Color(0xFFff3b2f), fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   )
          // ],
        ),
        body: Container(
            width: double.infinity,
            color: const Color(0xFFf3f2f8),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'Total voucher: ${widget.items.length}',
                            style: const TextStyle(color: Color(0xFF8a8a8a)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        for (var i = 0; i < widget.items.length; i++)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  int saleID = 0;
                                  if (widget.items[i]['consumedsaleID'] == 0) {
                                    saleID = widget.items[i]['purchasedsaleID'];
                                  } else {
                                    saleID = widget.items[i]['consumedsaleID'];
                                  }

                                  List<dynamic> credit = [];
                                  int amount = 0;

                                  var headers = {'token': token};
                                  var request = http.Request(
                                      'GET',
                                      Uri.parse(
                                          'https://member.tunai.io/cashregister/member/$memberIDglobal/credits'));

                                  request.headers.addAll(headers);

                                  http.StreamedResponse response =
                                      await request.send();

                                  if (response.statusCode == 200) {
                                    final responsebody =
                                        await response.stream.bytesToString();
                                    var body = json.decode(responsebody);

                                    Map<String, dynamic> creditss = body;

                                    credit = creditss['credits'];
                                    for (int i = 0; i < credit.length; i++) {
                                      if (credit[i]['consumed']['saleID'] ==
                                          saleID) {
                                        amount = credit[i]['amount'];
                                      }
                                    }
                                  } else {
                                    print(response.reasonPhrase);
                                  }

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
                                      return OrderDetails(
                                          amount: amount.toDouble(),
                                          saleID: saleID);
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            widget.items[i]['consumedsaleID'] ==
                                                    0
                                                ? Text(
                                                    'Order #${widget.items[i][
                                                                'purchasedsaleID']}',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF878787)),
                                                  )
                                                : Text(
                                                    'Order #${widget.items[i][
                                                                'consumedsaleID']}',
                                                    style: const TextStyle(
                                                        color:
                                                            Color(0xFF878787)),
                                                  ),
                                            // PopupMenuButton<String>(
                                            //   shape: const ContinuousRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.all(
                                            //               Radius.circular(
                                            //                   15.0))),
                                            //   elevation: 1,
                                            //   offset: const Offset(0, 30),
                                            //   padding: EdgeInsets.zero,
                                            //   child: Icon(
                                            //     Icons.more_horiz_rounded,
                                            //     color: menuVisible1
                                            //         ? Colors.blueAccent.shade100
                                            //         : const Color(0xFF1276ff),
                                            //   ),
                                            //   onOpened: () {
                                            //     setState(() {
                                            //       menuVisible1 = !menuVisible1;
                                            //     });
                                            //   },
                                            //   onCanceled: () {
                                            //     setState(() {
                                            //       menuVisible1 = !menuVisible1;
                                            //     });
                                            //   },
                                            //   itemBuilder:
                                            //       (BuildContext context) =>
                                            //           <PopupMenuEntry<String>>[
                                            //     PopupMenuItem<String>(
                                            //       padding: EdgeInsets.zero,
                                            //       child: Column(
                                            //         children: [
                                            //           GestureDetector(
                                            //             onTap: () {},
                                            //             child: Container(
                                            //               color: Colors.white,
                                            //               width:
                                            //                   double.infinity,
                                            //               child: Row(
                                            //                 children: [
                                            //                   const SizedBox(
                                            //                     width: 15,
                                            //                   ),
                                            //                   Image.asset(
                                            //                     'icons/Voucher 3.png',
                                            //                     scale: 40,
                                            //                     color: Colors
                                            //                         .black,
                                            //                   ),
                                            //                   const SizedBox(
                                            //                     width: 5,
                                            //                   ),
                                            //                   const Text(
                                            //                     'Redeem voucher',
                                            //                     style: TextStyle(
                                            //                         fontSize:
                                            //                             14),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           const Divider(
                                            //             thickness: 3,
                                            //             color:
                                            //                 Color(0xFFf3f2f8),
                                            //           ),
                                            //           GestureDetector(
                                            //             onTap: () {
                                            //               expireVoucher();
                                            //             },
                                            //             child: Container(
                                            //               color: Colors.white,
                                            //               width:
                                            //                   double.infinity,
                                            //               child: Row(
                                            //                 children: [
                                            //                   const SizedBox(
                                            //                     width: 15,
                                            //                   ),
                                            //                   Image.asset(
                                            //                     'icons/Expire.png',
                                            //                     scale: 50,
                                            //                   ),
                                            //                   const SizedBox(
                                            //                     width: 10,
                                            //                   ),
                                            //                   const Text(
                                            //                     'Expire voucher',
                                            //                     style: TextStyle(
                                            //                         color: Color(
                                            //                             0xFFff3b2f),
                                            //                         fontSize:
                                            //                             14),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           const Divider(
                                            //             thickness: 1,
                                            //           ),
                                            //           GestureDetector(
                                            //             onTap: () {
                                            //               deleteVoucher();
                                            //             },
                                            //             child: Container(
                                            //               color: Colors.white,
                                            //               width:
                                            //                   double.infinity,
                                            //               child: Row(
                                            //                 children: [
                                            //                   const SizedBox(
                                            //                     width: 15,
                                            //                   ),
                                            //                   Image.asset(
                                            //                     'icons/Trash.png',
                                            //                     scale: 50,
                                            //                   ),
                                            //                   const SizedBox(
                                            //                     width: 10,
                                            //                   ),
                                            //                   const Text(
                                            //                     'Delete voucher',
                                            //                     style: TextStyle(
                                            //                         color: Color(
                                            //                             0xFFff3b2f),
                                            //                         fontSize:
                                            //                             14),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ],
                                            // )
                                          ],
                                        ),
                                        const Divider(),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Purchase date',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              widget.items[i][
                                                                      'createDate'] *
                                                                  1000)),
                                                )
                                              ],
                                            )),
                                            Expanded(
                                                child: Center(
                                                    child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Expiry date',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    widget.items[i]['expiryDate'] != 0
                                                        ? DateFormat('dd/MM/yyyy').format(
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                widget.items[i]['expiryDate'] *
                                                                    1000))
                                                        : 'No expiry',
                                                    style: widget.items[i][
                                                                'expiryDate'] !=
                                                            0
                                                        ? const TextStyle(
                                                            color: Color(
                                                                0xFF1276ff))
                                                        : const TextStyle(
                                                            color: Color(0xFF333333)))
                                              ],
                                            ))),
                                            Expanded(
                                                child: Center(
                                                    child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Unit price',
                                                  style: TextStyle(
                                                      color: Color(0xFF878787)),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  formatAmount(widget.items[i]
                                                          ['price'])
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Color(0xFF1276ff)),
                                                )
                                              ],
                                            )))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            })));
  }

  expireAllVoucher() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Expire all Voucher?'),
          content:
              const Text('All voucher will be expire. This action cannot be undone'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {},
              child: const Text(
                'Expire',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteAllVoucher() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete all voucher'),
          content:
              const Text('All voucher will be delete. This action cannot be undone'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {},
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  expireVoucher() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Expire Voucher?'),
          content: const Text(
              'Selected voucher will be expire. This action cannot be undone'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {},
              child: const Text(
                'Expire',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteVoucher() {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete voucher'),
          content: const Text(
              'Selected voucher will be delete. This action cannot be undone'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {},
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
