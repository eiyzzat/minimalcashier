import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:minimal/orderPage.dart';
import 'package:minimal/test/firstPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String tokenGlobal = '';

class _LoginPageState extends State<LoginPage> {
  var usernameController = TextEditingController();
  var passWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 45),
                TextFormField(
                  obscureText: true,
                  controller: passWordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.password),
                  ),
                ),
                SizedBox(height: 45),
                OutlinedButton.icon(
                  onPressed: () {
                    login();
                  },
                  icon: Icon(
                    Icons.login,
                    size: 18,
                  ),
                  label: Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (usernameController.text.isNotEmpty &&
        passWordController.text.isNotEmpty) {
      var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      var request = http.Request(
          'POST', Uri.parse('https://m5.tunai.io/loyalty/authen/login'));
      request.bodyFields = {
        'username': usernameController.text,
        'password': passWordController.text
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBytes = await response.stream.toBytes();
        final responseBody = utf8.decode(responseBytes);
        final body = json.decode(responseBody);
        print(responseBody);
        await saveTokenToSharedPreferences(body['token']);
        setState(() {
          tokenGlobal = body['token'];
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FirstPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid user credential")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Blank Field Not Allowed")),
      );
    }
  }

  Future<void> saveTokenToSharedPreferences(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("loginToken", token);
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString("loginToken");

    if (savedToken != null) {
      setState(() {
        tokenGlobal = savedToken;
      });
      // Token found, navigate to the desired page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FirstPage()),
      );
    }
  }
}
