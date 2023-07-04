import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:minimal/testOtems.dart';
import 'api.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _order = [];
  List simpan = [];

  Future getOrder() async {
    var headers = {
      'token': token,
    };

    var request =
        http.Request('GET', Uri.parse('https://order.tunai.io/loyalty/order?active=1'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      final body = json.decode(responsebody);
      //message untuk save data dalam
      Map<String, dynamic> orderz = body;
      simpan = [];
      _order = orderz['orders'];

      for (int i = 0; i < _order.length; i++) {
        simpan.add(_order[i]);
      }
      return _order;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: getOrder(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('Loading');
              } else {
                return Expanded(
                  child: Container(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: simpan.length,
                          itemBuilder: (context, index) {
                            return Card(
                                child: Container(
                                    child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => testOtems(
                                                TestOtems: _order[index])))
                                    .then((value) => setState(
                                          () {},
                                        ));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "ORDER ID: " +
                                          simpan[index]['orderID'].toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "MEMBER ID: " +
                                          simpan[index]['memberID'].toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "AMOUNT: " +
                                          simpan[index]['amount'].toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "STATUS: " +
                                          simpan[index]['status'].toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "CREATE DATE: " +
                                          DateFormat('dd-MM-yyyy')
                                              .format(DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      simpan[index]
                                                              ['createDate'] *
                                                          1000)),
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "COMPLETE DATE: " +
                                          simpan[index]['completeDate']
                                              .toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Container(
                                    width: 350,
                                    child: Text(
                                      "DELETE DATE: " +
                                          simpan[index]['deleteDate']
                                              .toString(),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        _deleteOrder(simpan[index]['orderID']);
                                      },
                                      child: Text('Delete'))
                                ],
                              ),
                            )));
                          })),
                );
              }
            },
          )
        ],
      ),
    );
  }

  void _deleteOrder(int orderId) async {
    var headers = {
      'token': token,
    };
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://order.tunai.io/loyalty/order/' + '$orderId' + '/delete'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order $orderId has been deleted')),
      );

      setState(() {
        // buang order
        _order.removeWhere((order) => order['orderID'] == orderId);
        simpan.removeWhere((order) => order['orderID'] == orderId);
      });
    } else {
      print(response.reasonPhrase);
    }
  }
}