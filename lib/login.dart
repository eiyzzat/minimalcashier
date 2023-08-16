import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constant/token.dart';
import 'new.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


// bool rememberPassword = false;

class _LoginPageState extends State<LoginPage> {
  var usernameController = TextEditingController();
  var passWordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SafeArea(
            child: Center(
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "TunaiBiz",
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      autofillHints: [AutofillHints.username],
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 45),
                    TextFormField(
                      autofillHints: const [AutofillHints.password],
                      obscureText: _obscureText,
                      controller: passWordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: _obscureText
                              ? Icon(Icons.visibility)
                              : Icon(Icons.visibility_off),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: rememberPassword,
                    //       onChanged: (newValue) {
                    //         setState(() {
                    //           rememberPassword = newValue ?? false;
                    //         });
                    //       },
                    //     ),
                    //     Text('Remember Password'),
                    //   ],
                    // ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          await login();
    
                         
                        },
                        child: const Text(
                          "Login ",
                        ),
                      ),
                    )
                  ],
                ),
              ),
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
      await saveTokenAndCredentialsToSharedPreferences(
        body['token'],
        usernameController.text,
        passWordController.text,
      );
      setState(() {
        token = body['token'];
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => New()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid user credentials")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Blank Fields Not Allowed")),
    );
  }
}


  Future<void> saveTokenAndCredentialsToSharedPreferences(
    String token, String username, String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("loginToken", token);
  await prefs.setString("rememberedUsername", username);
  await prefs.setString("rememberedPassword", password);
}


  void checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? savedToken = prefs.getString("loginToken");
  String? savedUsername = prefs.getString("rememberedUsername");
  String? savedPassword = prefs.getString("rememberedPassword");

  print('Saved Token: $savedToken');
  print('Saved Username: $savedUsername');
  print('Saved Password: $savedPassword');

  if (savedToken != null) {
    setState(() {
      token = savedToken;
    });
    // Token found, navigate to the desired page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => New()),
    );
  } else {
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        usernameController.text = savedUsername;
        passWordController.text = savedPassword;
      });
    }
  }
}


  @override
  void dispose() {
    usernameController.dispose();
    passWordController.dispose();
    super.dispose();
  }
}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:minimal/firstPage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// String token = '';

// class _LoginPageState extends State<LoginPage> {
//   var usernameController = TextEditingController();
//   var passWordController = TextEditingController();
//   bool rememberMe = false;
//   String savedUsername = '';
//   String savedPassword = '';

//   @override
//   void initState() {
//     super.initState();
//     checkLoginStatus();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "TunaiBiz",
//                   style: TextStyle(
//                       color: Colors.blue, // Change the color here
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold // Change the font size here
//                       ),
//                 ),
//                 const SizedBox(height: 15),
//                 TextFormField(
//                   controller: usernameController,
//                   decoration: const InputDecoration(
//                     labelText: "Username",
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.email),
//                   ),
//                 ),
//                 const SizedBox(height: 45),
//                 TextFormField(
//                   obscureText: true,
//                   controller: passWordController,
//                   decoration: const InputDecoration(
//                     labelText: "Password",
//                     border: OutlineInputBorder(),
//                     suffixIcon: Icon(Icons.password),
//                   ),
//                 ),

//                 CheckboxListTile(
//                   title: Text("Remember Me"),
//                   value: rememberMe,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       rememberMe = value ?? false;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 25),
                
//                 SizedBox(
//                   width: double.infinity,
//                   height: 40,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       login();
//                     },
//                     child: const Text(
//                       "Login ",
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> login() async {
//     if (usernameController.text.isNotEmpty &&
//         passWordController.text.isNotEmpty) {
//       var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
//       var request = http.Request(
//           'POST', Uri.parse('https://m5.tunai.io/loyalty/authen/login'));
//       request.bodyFields = {
//         'username': usernameController.text,
//         'password': passWordController.text
//       };
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         if (rememberMe) {
//           // Save the username and password to SharedPreferences
//           await saveCredentialsToSharedPreferences(
//             usernameController.text,
//             passWordController.text,
//           );
          
//         }
//         final responseBytes = await response.stream.toBytes();
//         final responseBody = utf8.decode(responseBytes);
//         final body = json.decode(responseBody);
//         print(responseBody);
//         await saveTokenToSharedPreferences(body['token']);
//         setState(() {
//           token = body['token'];
//         });
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => FirstPage()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Invalid user credential")),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Blank Field Not Allowed")),
//       );
//     }
//   }

//   Future<void> saveCredentialsToSharedPreferences(
//     String username,
//     String password,
//   ) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("savedUsername", username);
//     await prefs.setString("savedPassword", password);
//   }

//   Future<void> saveTokenToSharedPreferences(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("loginToken", token);
//   }

//   void checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? savedToken = prefs.getString("loginToken");
//     String? savedUsername = prefs.getString("savedUsername");
//     String? savedPassword = prefs.getString("savedPassword");

//     if (savedToken != null) {
//       setState(() {
//         token = savedToken;
//       });
//       // Token found, navigate to the desired page
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => FirstPage()),
//       );
//     } else if (rememberMe && savedUsername != null && savedPassword != null) {
//       setState(() {
//         usernameController.text = savedUsername;
//         passWordController.text = savedPassword;
//       });
//     }
//   }
// }
