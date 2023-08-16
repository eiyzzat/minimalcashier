import 'package:flutter/material.dart';
import 'mobile_scaffold.dart';

class TabletScaffold extends StatefulWidget {
  const TabletScaffold({super.key});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: const Text(
            'Tablet',
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MemberMobileScaffold()));
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.purple.shade300,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              child: const Center(child: Text('Member')),
            ),
          ),
        ));
  }
}
