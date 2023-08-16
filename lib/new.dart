import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TunaiPosMember/responsiveMember/mobile_scaffold.dart';
import 'firstPage.dart';
import 'login.dart';

class New extends StatefulWidget {
  const New({
    Key? key,
  }) : super(key: key);

  @override
  State<New> createState() => _FirstPage();
}

class _FirstPage extends State<New> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Minimal',
          style: TextStyle(color: Colors.black),
        ),
        
        actions: [
          IconButton(
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
                      child: const Text('Logout'),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the dialog
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        await pref.remove("loginToken");
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
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
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  buildmemberbutton(context),
                  const SizedBox(height: 20),
                  buildorderbutton(context),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(22.0),
              child: Text(
                "Version 0.0.0",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector buildorderbutton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            10), // Adjust the value to control the curvature
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset("lib/assets/order.png",
                      width: 100, height: 100),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Orders',
                      style: TextStyle(fontSize: 23),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector buildmemberbutton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemberMobileScaffold()),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            10), // Adjust the value to control the curvature
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Image.asset("lib/assets/members.png",
                      width: 100, height: 100),
                ]),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Members',
                      style: TextStyle(fontSize: 23),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
