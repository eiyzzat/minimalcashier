import 'package:flutter/material.dart';
import 'package:minimal/test/firstPage.dart';
import 'package:minimal/test/login.dart';
import 'package:minimal/textFormating.dart';
import 'orderPage.dart';
import 'textFormating.dart';


void main() {
  // print(formatDoubleText(100));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // print(formatStartEndTimeText(unixTime, duration));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage()
    );
  }
}