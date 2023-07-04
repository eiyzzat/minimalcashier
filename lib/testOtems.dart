import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api.dart';

//import 'package:intl/intl.dart';

class testOtems extends StatefulWidget {
  final TestOtems;
  const testOtems({Key? key, required this.TestOtems}) : super(key: key);

  @override
  State<testOtems> createState() => _testOtems();
}

class _testOtems extends State<testOtems> {
  /**String formatDateTime(int unixTimeStamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimeStamp * 1000);
    var formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDateTime;
  }**/

  List<dynamic> _otems = [];
  //List simpanOtem = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Otems'),
      ),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                addOtems();
              },
              child: Text('create'),
            ),
            
            SizedBox(height: 15),
            Expanded(
              child: FutureBuilder(
                future: getOtems(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: _otems.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: Container(
                                child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => changePrice(
                            //                 TestPrice: _otems[index])))
                            //     .then((value) => setState(
                            //           () {},
                            //         ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("OTEM: " +
                                  _otems[index]['otemID'].toString()),
                              Text("ORDER ID: " +
                                  _otems[index]['orderID'].toString()),
                              Text("SKUID: " +
                                  _otems[index]['skuID'].toString()),
                              Text("PRICE: " +
                                  _otems[index]['price'].toString()),
                              Text("DISCOUNT: " +
                                  _otems[index]['discount'].toString()),
                              Text("OUTSTANDINGS: " +
                                  _otems[index]['outstandings'].toString()),
                              Text("TAX AMOUNT: " +
                                  _otems[index]['taxAmount'].toString()),
                              Text("TAX TYPE: " +
                                  _otems[index]['taxType'].toString()),
                              Text("SELECTION ID: " +
                                  _otems[index]['selectionID'].toString()),
                              Text("PAYMENT ID: " +
                                  _otems[index]['paymentID'].toString()),
                              Text("TRANSACTION ID: " +
                                  _otems[index]['trxnID'].toString()),
                              Text("REMARKS: " +
                                  _otems[index]['remarks'].toString()),
                              Text("QUANTITY: " +
                                  _otems[index]['quantity'].toString()),
                              Text("STAFFS: " +
                                  _otems[index]['staffs'].toString()),
                              Text("CREATE DATE: " +
                                  _otems[index]['createDate'].toString()),
                              Text("DELETE DATE: " +
                                  _otems[index]['deleteDate'].toString()),
                              Text("UPDATE DATE: " +
                                  _otems[index]['updateDate'].toString()),
                              ElevatedButton(
                                onPressed: () {
                                  resetData(_otems[index]['orderID'].toString(),
                                      _otems[index]['otemID'].toString());
                                },
                                child: Text('Reset Data'),
                              )
                            ],
                          ),
                        )));
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getOtems() async {
    var headers = {
      'token': token,
    };

    var request = http.Request(
      'GET',
      // ignore: prefer_interpolation_to_compose_strings
      Uri.parse('https://order.tunai.io/loyalty/order/' +
          '${widget.TestOtems['orderID']}' +
          '/otems'),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);

      Map<String, dynamic> otemz = body;
      //simpanOtem = [];
      _otems = otemz['otems'];

      //for (int i = 0; i < _otems.length; i++) {
      //simpanOtem.add(_otems[i]);
      //}

      return _otems;
    } else {
      print(response.reasonPhrase);
    }
  }

  void addOtems() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST',
        Uri.parse('https://order.tunai.io/loyalty/order/' +
            '${widget.TestOtems['orderID']}' +
            '/otems/sku'));

    request.bodyFields = {'skuID': '692529', 'price': '25'};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);

      Map<String, dynamic> newOtem = body;
      _otems.add(newOtem);

      setState(() {});
    } else {
      print(response.reasonPhrase);
    }
  }

  void addOtemsBulk() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.Request(
        'POST',
        Uri.parse('https://order.tunai.io/loyalty/order/' +
            '${widget.TestOtems['orderID']}' +
            '/otems/bulk/sku'));

    request.body = json.encode({
      "skus": [
        {"skuID": 680976, "price": 15},
        {"skuID": 680976, "price": 15}
      ]
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);

      Map<String, dynamic> newOtem = body;
      _otems.add(newOtem);

      setState(() {});
    } else {
      print(response.reasonPhrase);
    }
  }

  void resetData(String orderID, String otemID) async {
    var headers = {'token': token};
    var request = http.Request(
        'POST',
        Uri.parse('https://order.tunai.io/loyalty/order/' +
            '$orderID' +
            '/otems/' +
            '$otemID' +
            '/reset'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        _otems = [];
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}