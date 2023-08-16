// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constant/token.dart';

class CreditDate extends StatefulWidget {
  final DateTime date;
  final int saleID;
  final VoidCallback updateData;
  const CreditDate(
      {super.key,
      required this.date,
      required this.saleID,
      required this.updateData});

  @override
  State<CreditDate> createState() => _CreditDateState();
}

class _CreditDateState extends State<CreditDate> {
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
        title: const Text(
          'Date',
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
                  })),
        ),
      ),
      body: Center(
        child: Container(
          height: double.infinity,
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.001),
          child: CalendarDatePicker(
            initialDate: widget.date,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            onDateChanged: (DateTime newDate) async {
              DateTime newDateTime = DateTime(
                  newDate.year,
                  newDate.month,
                  newDate.day,
                  widget.date.hour,
                  widget.date.minute,
                  widget.date.second);
              int unixTimestamp = newDateTime.millisecondsSinceEpoch ~/ 1000;

              var headers = {
                'token': token,
                'Content-Type': 'application/x-www-form-urlencoded'
              };
              var request = http.Request(
                  'POST',
                  Uri.parse('https://order.tunai.io/cashregister/sale/${widget.saleID}/backdate'));
              request.bodyFields = {'salesDate': unixTimestamp.toString()};
              request.headers.addAll(headers);

              http.StreamedResponse response = await request.send();

              if (response.statusCode == 200) {
                widget.updateData();
                Navigator.pop(context);
              } else {
                print(response.reasonPhrase);
              }
            },
          ),
        ),
      ),
    );
  }
}
