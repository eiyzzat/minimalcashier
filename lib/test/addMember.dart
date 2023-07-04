import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api.dart';
import '../main.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  String _errorPhoneLength = '';

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

//const List<String> _countryCodes = ['+60', '+70'];

  static const List<Map<String, String>> _countryCodes = [
    {'code': '60', 'name': 'MY'},
    {'code': '65', 'name': 'SG'},
    // Add more country codes and names as needed
  ];

  Map<String, String> _selectedCountryCode = _countryCodes.first;

//String phoneText = _selectedCountryCode.substring(1) + _phoneController.text;

  String dob = '';

//String name = _nameController.text;

  final _dateFocusNode = FocusNode();

  bool _isSearchingCountryCode = false;
  bool _isPhoneEntered = false;

  final _formKey = GlobalKey<FormState>();
  bool _formEdited = false;

  @override
  void initState() {
    super.initState();
    //_phoneController.addListener(validateNumber);

    // clear text controllers
    _dateController.clear();
    _phoneController.clear();
    _nameController.clear();
  }

  void validateNumber() {
    if (_phoneController.text.length != 9) {
      setState(() {
        _errorPhoneLength = 'Number must be 9 digits';
      });
    } else {
      setState(() {
        _errorPhoneLength = '';
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 2.67 / 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Transform.scale(
              scale: 1.3,
              child: CloseButton(
                color: Color(0xFF1276ff),
                onPressed: () {
                  if (_formEdited) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          title: Text(
                              'Are you sure you want to discard this new member?'),
                          //message: Text('Are you sure you want to discard changes?'),
                          actions: <Widget>[
                            Container(
                              color: Colors.white,
                              child: CupertinoActionSheetAction(
                                child: Text('Discard Changes'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                isDestructiveAction: true,
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: Text('Keep Editing'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'Add Member',
              style: TextStyle(color: Colors.black),
            ),
          ]),
        ),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {
                    _formEdited = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  color: Color(0xFFf3f2f8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Required info\*',
                              style: TextStyle(color: Color(0xFF878787)),
                            )),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          height: 48,
                          child: Row(children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Map<String, String>>(
                                    value: _selectedCountryCode,
                                    items: _countryCodes
                                        .map((Map<String, String> country) {
                                      return DropdownMenuItem<
                                          Map<String, String>>(
                                        value: country,
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '+(${country['code']})',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                              TextSpan(
                                                text: ' ${country['name']}',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (Map<String, String>? value) {
                                      setState(() {
                                        _phoneController.clear();
                                        _selectedCountryCode = value!;
                                      });
                                    },
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            VerticalDivider(),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9]')),
                                    if (_selectedCountryCode['name'] == 'MY')
                                      FilteringTextInputFormatter.deny(
                                        RegExp(
                                            r'^0+'), //users can't type 0 at 1st position
                                      ),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter phone number',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    print(_selectedCountryCode);
                                    if (_selectedCountryCode['name'] == 'MY') {
                                      // Code to execute if the selected country code is 'MY' (Malaysia)
                                      if (value.startsWith('11')) {
                                        setState(() {
                                          _isPhoneEntered = value.isNotEmpty;
                                          _errorPhoneLength = (value.isEmpty ||
                                                  (value.length != 10))
                                              ? 'Number must be 10 digits long'
                                              : '';
                                        });
                                      } else {
                                        setState(() {
                                          _isPhoneEntered = value.isNotEmpty;
                                          _errorPhoneLength = (value.isEmpty ||
                                                  (value.length != 9))
                                              ? 'Number must be 9 digits long'
                                              : '';
                                        });
                                      }
                                    } else if (_selectedCountryCode['name'] ==
                                        'SG') {
                                      // Code to execute if the selected country code is 'SG' (Singapore)
                                      setState(() {
                                        _isPhoneEntered = value.isNotEmpty;
                                        _errorPhoneLength = (value.isEmpty ||
                                                (value.length != 8))
                                            ? 'Number must be 8 digits long'
                                            : '';
                                      });
                                    }
                                  },
                                  style: _isPhoneEntered
                                      ? TextStyle(color: Color(0xFF1276ff))
                                      : null,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _phoneController.text.isNotEmpty &&
                                  _errorPhoneLength.isEmpty,
                              child:
                                  Icon(Icons.check_circle, color: Colors.green),
                            ),
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Optional Info',
                              style: TextStyle(color: Color(0xFF878787)),
                            )),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 13),
                                      child: Image.asset(
                                        'lib/assets/Persons.png',
                                        height: 5,
                                      ),
                                    ),
                                    prefixIconColor: Colors.blue,
                                    hintText: 'Add member name',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: Divider(
                                  height: 0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: TextFormField(
                                  focusNode: _dateFocusNode,
                                  controller: _dateController,
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 13),
                                      child: Image.asset(
                                        'lib/assets/Birthday.png',
                                        height: 5,
                                      ),
                                    ),
                                    prefixIconColor: Colors.blue,
                                    hintText: 'Add birthday',
                                    border: InputBorder.none,
                                  ),
                                  onTap: () async {
                                    _dateFocusNode.unfocus();
                                    final currentDate = DateTime.now();
                                    final pickedDate =
                                        await showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          Material(
                                        color: Colors.transparent,
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 300,
                                              child: CupertinoDatePicker(
                                                mode: CupertinoDatePickerMode
                                                    .date,
                                                minimumDate: DateTime(1900),
                                                maximumDate: DateTime(currentDate
                                                        .year +
                                                    1), // Add 1 year to the current year
                                                maximumYear: currentDate
                                                    .year, // Restrict years after the current year
                                                onDateTimeChanged:
                                                    (DateTime dateTime) {
                                                  setState(() {
                                                    _dateController.text =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(dateTime);
                                                    dob = _dateController.text;
                                                  });
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 10,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  child: Text(
                                                    'Done',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color:
                                                            Color(0xFF1276ff)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: (_phoneController.text.isEmpty ||
                                      _errorPhoneLength.isNotEmpty)
                                  ? null
                                  : () {
                                      addMember(context);
                                    },
                              child: Text('Save'),
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  addMember(context) async {
    String phoneText = _selectedCountryCode['code']! + _phoneController.text;
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var request = http.Request(
        'POST', Uri.parse('https://member.tunai.io/cashregister/member'));
    request.bodyFields = {
      'mobile': phoneText,
      'dob': dob,
      'name': _nameController.text
    };

    print(phoneText);
    print(dob);
    print(_nameController.text);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      phoneText = _selectedCountryCode['code']! + _phoneController.text;
      dob = '';

    } else {
      print(response.reasonPhrase);
    }
  }
}