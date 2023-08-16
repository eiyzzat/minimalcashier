// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_function_literals_in_foreach_calls, prefer_is_empty, sized_box_for_whitespace, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Function/generalFunction.dart';
import 'voucherDetails.dart';

class AvailableRedemeedExpired extends StatefulWidget {
  final String serviceName;
  final List<dynamic> serviceItems;
  const AvailableRedemeedExpired(
      {super.key, required this.serviceName, required this.serviceItems});

  @override
  State<AvailableRedemeedExpired> createState() =>
      _AvailableRedemeedExpiredState();
}

class _AvailableRedemeedExpiredState extends State<AvailableRedemeedExpired> {
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
            widget.serviceName,
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
        ),
        body: DefaultTabController(
          length: 3,
          child: Container(
              color: const Color(0xFFf3f2f8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 10),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(235, 235, 235, 1.0),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TabBar(
                            indicator: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0)),
                            labelColor: const Color(0xFF1276ff),
                            unselectedLabelColor:
                                const Color.fromRGBO(170, 170, 170, 1.0),
                            tabs: [
                              const Tab(
                                text: 'Available',
                              ),
                              const Tab(
                                text: 'Redeemed',
                              ),
                              const Tab(
                                text: 'Expired',
                              )
                            ]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [getAvailable(), getRedemmed(), getExpired()],
                    ),
                  )
                ],
              )),
        ));
  }

  getAvailable() {
    List<dynamic> availableExpiry = [];
    List<dynamic> availableNoExpiry = [];
    if (widget.serviceItems.isNotEmpty) {
      widget.serviceItems.sort(
          (a, b) => (a['expiryDate'] as int).compareTo(b['expiryDate'] as int));
      if (widget.serviceItems.isNotEmpty) {
        for (var i = 0; i < widget.serviceItems.length; i++) {
          if (widget.serviceItems[i]['redeemDate'] == 0 &&
              widget.serviceItems[i]['expiredDate'] == 0) {
            if (widget.serviceItems[i]['expiryDate'] != 0) {
              availableExpiry.add(widget.serviceItems[i]);
            } else {
              availableNoExpiry.add(widget.serviceItems[i]);
            }
          }
        }
      }
    }
    Map<String, List<dynamic>> availableExpiryCreateDateGroup = {};
    Map<String, List<dynamic>> availableNoExpiryCreateDateGroup = {};

    ////////////////////////////////////////////////////////////////////////////

    availableExpiry.forEach((item) {
      int createDate = item['createDate'];
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(createDate * 1000);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      String date = '';
      String unitPrice = '';

      if (item['expiryDate'] != 0) {
        date = DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(item['expiryDate'] * 1000));
      } else {
        date = '0';
      }

      unitPrice = item['price'].toString();

      String key = '${formattedDate}_${date}_$unitPrice'; // Combine formattedDate and expiryDate as the key

      if (!availableExpiryCreateDateGroup.containsKey(key)) {
        availableExpiryCreateDateGroup[key] =
            []; // Initialize with an empty list
      }

      // Use a null check before accessing the value and adding the item
      availableExpiryCreateDateGroup[key]?.add(item);
    });

    ////////////////////////////////////////////////////////////////////////////

    availableNoExpiry.forEach((item) {
      int createDate = item['createDate'];
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(createDate * 1000);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      String unitPrice = '';

      unitPrice = item['price'].toString();

      String key = '${formattedDate}_$unitPrice'; // Combine formattedDate and expiryDate as the key

      if (!availableNoExpiryCreateDateGroup.containsKey(key)) {
        availableNoExpiryCreateDateGroup[key] =
            []; // Initialize with an empty list
      }

      // Use a null check before accessing the value and adding the item
      availableNoExpiryCreateDateGroup[key]?.add(item);
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (availableExpiryCreateDateGroup.length != 0)
               Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      'Limited time vouchers',
                      style: TextStyle(color: Color(0xFF8a8a8a)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            Column(
              children: availableExpiryCreateDateGroup.entries.map((entry) {
                final String createDate = entry.key.split('_')[0];
                final List<dynamic> availableserviceItems = entry.value;

                return Column(
                  children: [
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
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height * 2.65 / 3,
                              child: VoucherDetails(
                                  name: widget.serviceName,
                                  items: availableserviceItems),
                            );
                          },
                        );
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      availableserviceItems.length.toString() +
                                          (availableserviceItems.length < 2
                                              ? ' unit'
                                              : ' units'), // Add a comma after the first part
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    ),
                                    Text(
                                      'Unit price: ${formatAmount(availableserviceItems
                                                  .last['price'])}',
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Purchase Date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(createDate)
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 80,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expiry date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      availableserviceItems
                                                                  .last[
                                                              'expiryDate'] *
                                                          1000)),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }).toList(),
            ),
            if (availableExpiryCreateDateGroup.length != 0)
              const SizedBox(
                height: 20,
              ),
            if (availableNoExpiryCreateDateGroup != 0)
               Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      'No expiry vouchers',
                      style: TextStyle(color: Color(0xFF8a8a8a)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            Column(
              children: availableNoExpiryCreateDateGroup.entries.map((entry) {
                final String createDate = entry.key.split('_')[0];
                final List<dynamic> availableserviceItemsNo = entry.value;

                return Column(
                  children: [
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
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height * 2.65 / 3,
                              child: VoucherDetails(
                                  name: widget.serviceName,
                                  items: availableserviceItemsNo),
                            );
                          },
                        );
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      availableserviceItemsNo.length
                                              .toString() +
                                          (availableserviceItemsNo.length < 2
                                              ? ' unit'
                                              : ' units'), // Add a comma after the first part
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    ),
                                    Text(
                                      'Unit price: ${formatAmount(availableserviceItemsNo
                                                  .last['price'])}',
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Purchase Date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(createDate)
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 80,
                                    ),
                                     Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Expiry date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        SizedBox(height: 5),
                                        Text('No expiry')
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  getRedemmed() {
    Map<String, List<dynamic>> redeemedCreateDateGroup = {};
    List<dynamic> redeemed = [];

    if (widget.serviceItems.isNotEmpty) {
      widget.serviceItems.sort(
          (a, b) => (a['expiryDate'] as int).compareTo(b['expiryDate'] as int));
      if (widget.serviceItems.isNotEmpty) {
        for (var i = 0; i < widget.serviceItems.length; i++) {
          if (widget.serviceItems[i]['redeemDate'] != 0) {
            redeemed.add(widget.serviceItems[i]);
          }
        }
      }
    }

    redeemed.forEach((item) {
      int createDate = item['createDate'];
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(createDate * 1000);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      String date = '';
      String unitPrice = '';

      if (item['expiryDate'] != 0) {
        date = DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(item['expiryDate'] * 1000));
      } else {
        date = '0';
      }

      unitPrice = item['price'].toString();

      String key = '${formattedDate}_${date}_$unitPrice'; // Combine formattedDate and expiryDate as the key

      if (!redeemedCreateDateGroup.containsKey(key)) {
        redeemedCreateDateGroup[key] = []; // Initialize with an empty list
      }

      // Use a null check before accessing the value and adding the item
      redeemedCreateDateGroup[key]?.add(item);
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'Redeemed vouchers',
                style: TextStyle(color: Color(0xFF8a8a8a)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: redeemedCreateDateGroup.entries.map((entry) {
                final String createDate = entry.key.split('_')[0];
                final List<dynamic> redeemedItems = entry.value;

                return Column(
                  children: [
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
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height * 2.65 / 3,
                              child: VoucherDetails(
                                  name: widget.serviceName,
                                  items: redeemedItems),
                            );
                          },
                        );
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      redeemedItems.length.toString() +
                                          (redeemedItems.length < 2
                                              ? ' unit'
                                              : ' units'), // Add a comma after the first part
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    ),
                                    Text(
                                      'Unit price: ${formatAmount(
                                                  redeemedItems.last['price'])}',
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Purchase Date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(createDate)
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 80,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expiry date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            redeemedItems.last['expiryDate'] !=
                                                    0
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            redeemedItems.last[
                                                                    'expiryDate'] *
                                                                1000))
                                                : 'No expiry',
                                            style: redeemedItems
                                                        .last['expiryDate'] !=
                                                    0
                                                ? const TextStyle(
                                                    color: Color(0xFFff9502))
                                                : const TextStyle(
                                                    color: Color(0xFF333333)))
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  getExpired() {
    Map<String, List<dynamic>> expiredCreateDateGroup = {};
    List<dynamic> expired = [];

    if (widget.serviceItems.isNotEmpty) {
      widget.serviceItems.sort(
          (a, b) => (a['expiryDate'] as int).compareTo(b['expiryDate'] as int));
      if (widget.serviceItems.isNotEmpty) {
        for (var i = 0; i < widget.serviceItems.length; i++) {
          if (widget.serviceItems[i]['expiredDate'] != 0) {
            expired.add(widget.serviceItems[i]);
          }
        }
      }
    }

    expired.forEach((item) {
      int createDate = item['createDate'];
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(createDate * 1000);
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

      String date = '';
      String unitPrice = '';

      if (item['expiryDate'] != 0) {
        date = DateFormat('dd/MM/yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(item['expiryDate'] * 1000));
      } else {
        date = '0';
      }

      unitPrice = item['price'].toString();

      String key = '${formattedDate}_${date}_$unitPrice'; // Combine formattedDate and expiryDate as the key

      if (!expiredCreateDateGroup.containsKey(key)) {
        expiredCreateDateGroup[key] = []; // Initialize with an empty list
      }

      // Use a null check before accessing the value and adding the item
      expiredCreateDateGroup[key]?.add(item);
    });
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Text(
                'Expired vouchers',
                style: TextStyle(color: Color(0xFF8a8a8a)),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              children: expiredCreateDateGroup.entries.map((entry) {
                final String createDate = entry.key.split('_')[0];
                final List<dynamic> expiredItems = entry.value;

                return Column(
                  children: [
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
                            return Container(
                              height:
                                  MediaQuery.of(context).size.height * 2.65 / 3,
                              child: VoucherDetails(
                                  name: widget.serviceName,
                                  items: expiredItems),
                            );
                          },
                        );
                      },
                      child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      expiredItems.length.toString() +
                                          (expiredItems.length < 2
                                              ? ' unit'
                                              : ' units'), // Add a comma after the first part
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    ),
                                    Text(
                                      'Unit price: ${formatAmount(
                                                  expiredItems.last['price'])}',
                                      style:
                                          const TextStyle(color: Color(0xFF878787)),
                                    )
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Purchase Date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(createDate)
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 80,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expiry date',
                                          style: TextStyle(
                                              color: Color(0xFF878787)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                            expiredItems.last['expiryDate'] != 0
                                                ? DateFormat('dd/MM/yyyy')
                                                    .format(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            expiredItems.last[
                                                                    'expiryDate'] *
                                                                1000))
                                                : 'No expiry',
                                            style: expiredItems
                                                        .last['expiryDate'] !=
                                                    0
                                                ? const TextStyle(
                                                    color: Color(0xFFbe2f19))
                                                : const TextStyle(
                                                    color: Color(0xFF333333)))
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
