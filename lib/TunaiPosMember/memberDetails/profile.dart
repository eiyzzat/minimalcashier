// ignore_for_file: prefer_final_fields, avoid_print
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../responsiveMember/mobile_scaffold.dart';

class Profile extends StatefulWidget {
  final VoidCallback updateData;
  const Profile({super.key, required this.updateData});

  @override
  State<Profile> createState() => _ProfileState();
}

enum Marital { single, married }

/* can only declare otside the class */
enum Gender { male, female }
/* can only declare otside the class */

class _ProfileState extends State<Profile> {
  String memberName = '';
  String memberIC = '';
  String info1 = '';
  String info2 = '';
  String icon = '';
  String dob = '';
  String dob2 = '';
  String mobile = '';
  String _selectedEthnic = 'Malay';

  int marital = 0;
  int newmarital = 0;
  int gender = 0;
  int newgender = 0;
  int ethnics = 0;
  int ethnicID = 0;
  int vip = 0;
  int newvip = 0;
  int vvip = 0;
  int newvvip = 0;
  int vvvip = 0;
  int newvvvip = 0;

  bool maritalClick = false;
  bool genderClick = false;
  bool vipClick = false;
  bool _vipChecked = false;
  bool _vvipChecked = false;
  bool _vvvipChecked = false;
  bool doneUpdate = false;

  final _dateController = TextEditingController();
  final inputName = TextEditingController();
  final inputIC = TextEditingController();
  final _info1 = TextEditingController();
  final _info2 = TextEditingController();

  List<dynamic> member = [];
  List<dynamic> ethnic = [];

  final _dateFocusNode = FocusNode();

  List<String> _ethnicList = [
    'African',
    'Caucasian',
    'Chinese',
    'Indian',
    'Malay',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _dateController.clear();
  }

  Future getMemberDetails() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/detail'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      //var decode = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> member1 = body;

      //final name = body['members']['name'];

      member = member1['members'];

      if (member.isNotEmpty) {
        for (var i = 0; i < member.length; i++) {
          memberName = member[i]['name'];
          icon = member[i]['icon'];
          dob = member[i]['dob'];
          mobile = member[i]['mobile'];
          vip = member[i]['vip'];
          vvip = member[i]['vvip'];
          vvvip = member[i]['vvvip'];
          memberIC = member[i]['nationalID'];
          marital = member[i]['marital'];
          gender = member[i]['gender'];
          info1 = member[i]['nick1'];
          info2 = member[i]['nick2'];
          // index = i;
        }
      }

      ethnic = member1['ethnics'];
      if (ethnic.isNotEmpty) {
        for (var i = 0; i < ethnic.length; i++) {
          ethnics = ethnic[i]['ethnicID'];
        }
      }

      return member;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          elevation: 1,
          backgroundColor: const Color(0xFFffffff),
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
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.black),
          ),
          actions: doneUpdate
              ? [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        doneUpdate =
                            false; // Set doneUpdate to false to hide the button
                      });
                      FocusScope.of(context).unfocus();
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1175fc),
                      ),
                    ),
                  ),
                ]
              : [],
        ),
        body: FutureBuilder(
            future: getMemberDetails(),
            builder: (context, snapshot) {
              //if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                //ReadApiName
                inputName.text = memberName;
                inputName.selection = TextSelection.fromPosition(
                    TextPosition(offset: inputName.text.length));
                //ReadApiNationalID
                inputIC.text = memberIC;
                inputIC.selection = TextSelection.fromPosition(
                    TextPosition(offset: inputIC.text.length));
                //ReadApiDate
                _dateController.text = dob;
                _dateController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _dateController.text.length));
                //ReadApiVIP
                _info1.text = info1;
                _info1.selection = TextSelection.fromPosition(
                    TextPosition(offset: _info1.text.length));
                _info2.text = info2;
                _info2.selection = TextSelection.fromPosition(
                    TextPosition(offset: _info2.text.length));

                if (vip == 0) {
                  _vipChecked = false;
                } else if (vip == 1) {
                  _vipChecked = true;
                }
                //ReadApiVVIP
                if (vvip == 0) {
                  _vvipChecked = false;
                } else if (vvip == 1) {
                  _vvipChecked = true;
                }
                //ReadApiVVVIP
                if (vvvip == 0) {
                  _vvvipChecked = false;
                } else if (vvvip == 1) {
                  _vvvipChecked = true;
                }
                //ReadApiEthnic
                if (ethnics == 0) {
                  _selectedEthnic == 'Others';
                } else if (ethnics == 1) {
                  _selectedEthnic == 'Malay';
                } else if (ethnics == 2) {
                  _selectedEthnic == 'Chinese';
                } else if (ethnics == 3) {
                  _selectedEthnic == 'Indian';
                } else if (ethnics == 4) {
                  _selectedEthnic == 'Caucasian';
                } else if (ethnics == 5) {
                  _selectedEthnic == 'African';
                }

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    color: const Color(0xFFf3f2f8),
                    width: double.infinity,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return SingleChildScrollView(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 10, right: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Colors.white,
                                        ),
                                        height: 85,
                                        child: Stack(children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              //crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                //ReadApiIcon
                                                icon != ''
                                                    ? CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(icon),
                                                        backgroundColor:
                                                            const Color(
                                                                0xFFf3f2f8),
                                                        radius: 30,
                                                      )
                                                    : const CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        radius: 30,
                                                      ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    //if user dob is not 0, it will display dob, if dob is 0 it display '0000-00-00'
                                                    child: dob != '0000-00-00'
                                                        ? memberName != ''
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  //ReadApiName
                                                                  Text(
                                                                      memberName),
                                                                  //ReadApiDOB
                                                                  Text(dob),
                                                                ],
                                                              )
                                                            : Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  //ReadApiMobile
                                                                  Text(mobile),
                                                                  //ReadApiDOB
                                                                  Text(dob),
                                                                ],
                                                              )
                                                        : memberName != ''
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      memberName),
                                                                ],
                                                              )
                                                            : Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(mobile),
                                                                ],
                                                              )),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Row(
                                              children: [
                                                Container(
                                                  child: vip == 1
                                                      ? const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.blue,
                                                            radius: 6,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                Container(
                                                  child: vvip == 1
                                                      ? const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.orange,
                                                            radius: 6,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                Container(
                                                  child: vvvip == 1
                                                      ? const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            radius: 6,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text('Customer info'),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Colors.white,
                                        ),
                                        height: 285,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10, right: 10),
                                          child: Stack(children: [
                                            const Positioned(
                                              top: 0,
                                              left: 1,
                                              child: Text(
                                                'Name',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 73,
                                              left: 1,
                                              child: Text(
                                                'IC/Passport',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 146,
                                              left: 1,
                                              child: Text(
                                                'Birthday',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 219,
                                              left: 1,
                                              child: Text(
                                                'Ethnic',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  controller: inputName,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Type here',
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10),
                                                  ),
                                                  onChanged: (value) {
                                                    memberName = inputName.text;
                                                    updateName();
                                                  },
                                                ),
                                                const Divider(),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: inputIC,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Type here',
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10),
                                                  ),
                                                  onChanged: (value) {
                                                    memberIC = inputIC.text;
                                                    updateIC();
                                                  },
                                                  onTap: () {
                                                    setState(() {
                                                      doneUpdate = true;
                                                    });
                                                  },
                                                ),
                                                const Divider(),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  focusNode: _dateFocusNode,
                                                  readOnly: true,
                                                  controller: _dateController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'No date set',
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10),
                                                  ),
                                                  onTap: () async {
                                                    _dateFocusNode.unfocus();
                                                    final currentDate =
                                                        DateTime.now();
                                                    await showModalBottomSheet(
                                                        context: context,
                                                        builder:
                                                            (BuildContext
                                                                    context) =>
                                                                Material(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: Stack(
                                                                    children: [
                                                                      Container(
                                                                        height:
                                                                            300,
                                                                        child: CupertinoDatePicker(
                                                                            mode: CupertinoDatePickerMode.date,
                                                                            minimumDate: DateTime(1900),
                                                                            maximumDate: DateTime(currentDate.year + 1), // Add 1 year to the current year
                                                                            maximumYear: currentDate.year, // Restrict years after the current year
                                                                            onDateTimeChanged: (DateTime dateTime) {
                                                                              setState(() {
                                                                                _dateController.text = DateFormat('yyyy-MM-dd').format(dateTime);
                                                                                print(_dateController.text);
                                                                                dob2 = _dateController.text;
                                                                                updateDOB();
                                                                                // dob =
                                                                                //     dob2;
                                                                              });
                                                                            }),
                                                                      ),
                                                                      Positioned(
                                                                        top: 0,
                                                                        right:
                                                                            10,
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(8),
                                                                            child:
                                                                                Text(
                                                                              'Done',
                                                                              style: TextStyle(fontSize: 20, color: Color(0xFF1276ff)),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ));
                                                    print(dob2);
                                                  },
                                                ),
                                                const Divider(),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 15,
                                                  ),
                                                  child:
                                                      DropdownButtonFormField<
                                                          String>(
                                                    decoration:
                                                        const InputDecoration
                                                                .collapsed(
                                                            hintText: ''),
                                                    value: _selectedEthnic,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedEthnic =
                                                            value!;
                                                        if (_selectedEthnic ==
                                                            'Others') {
                                                          ethnicID = 0;
                                                        } else if (_selectedEthnic ==
                                                            'Malay') {
                                                          ethnicID = 1;
                                                        } else if (_selectedEthnic ==
                                                            'Chinese') {
                                                          ethnicID = 2;
                                                        } else if (_selectedEthnic ==
                                                            'Indian') {
                                                          ethnicID = 3;
                                                        } else if (_selectedEthnic ==
                                                            'Caucasian') {
                                                          ethnicID = 4;
                                                        } else if (_selectedEthnic ==
                                                            'African') {
                                                          ethnicID = 5;
                                                        }
                                                        updateEthnic();
                                                      });
                                                    },
                                                    items: _ethnicList
                                                        .map((ethnicity) {
                                                      return DropdownMenuItem(
                                                        value: ethnicity,
                                                        child: Text(ethnicity),
                                                      );
                                                    }).toList(),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ]),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              color: Colors.white,
                                            ),
                                            height: 65,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      title: const Text(
                                                        'Single',
                                                      ),
                                                      leading: Radio<Marital>(
                                                        value: Marital.single,
                                                        groupValue:
                                                            checkMarital(),
                                                        onChanged:
                                                            (Marital? value) {
                                                          setState(() {
                                                            maritalClick = true;
                                                            newmarital = 1;
                                                            updateMaritalStatus();
                                                          });
                                                        },
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 0),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      title: const Text(
                                                        'Married',
                                                      ),
                                                      leading: Radio<Marital>(
                                                        value: Marital.married,
                                                        groupValue:
                                                            checkMarital(),
                                                        onChanged:
                                                            (Marital? value) {
                                                          setState(() {
                                                            maritalClick = true;
                                                            newmarital = 0;
                                                            updateMaritalStatus();
                                                          });
                                                        },
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 0),
                                                    ),
                                                  ),
                                                ),
                                                const Expanded(
                                                    child: SizedBox())
                                              ],
                                            ),
                                          ),
                                          const Positioned(
                                            top: 10,
                                            left: 1,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                'Marital',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              color: Colors.white,
                                            ),
                                            height: 65,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      top: 15,
                                                    ),
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      title: const Text(
                                                        'Male',
                                                      ),
                                                      leading: Radio<Gender>(
                                                        value: Gender.male,
                                                        groupValue:
                                                            checkGender(),
                                                        onChanged:
                                                            (Gender? value) {
                                                          setState(() {
                                                            genderClick = true;
                                                            newgender = 1;
                                                            updateGenderStatus();
                                                          });
                                                        },
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 0),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      title: const Text(
                                                        'Female',
                                                      ),
                                                      leading: Radio<Gender>(
                                                        value: Gender.female,
                                                        groupValue:
                                                            checkGender(),
                                                        onChanged:
                                                            (Gender? value) {
                                                          setState(() {
                                                            genderClick = true;
                                                            newgender = 0;
                                                            updateGenderStatus();
                                                          });
                                                        }, // Set the fill color
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 0),
                                                    ),
                                                  ),
                                                ),
                                                const Expanded(
                                                    child: SizedBox())
                                              ],
                                            ),
                                          ),
                                          const Positioned(
                                            top: 10,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                'Gender',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Stack(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              color: Colors.white,
                                            ),
                                            height: 65,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      leading: Checkbox(
                                                        value: _vipChecked,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _vipChecked =
                                                                newValue ??
                                                                    false;
                                                            if (_vipChecked ==
                                                                true) {
                                                              newvip = 1;
                                                            }
                                                            //
                                                            else if (_vipChecked ==
                                                                false) {
                                                              newvip = 0;
                                                            }
                                                            updateVIP();
                                                          });
                                                        },
                                                        activeColor:
                                                            Colors.blue,
                                                        checkColor:
                                                            Colors.white,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                      title: const Text('VIP'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      leading: Checkbox(
                                                        value: _vvipChecked,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _vvipChecked =
                                                                newValue ??
                                                                    false;
                                                            if (_vvipChecked ==
                                                                true) {
                                                              newvvip = 1;
                                                            }
                                                            if (_vvipChecked ==
                                                                false) {
                                                              newvvip = 0;
                                                            }
                                                            updateVVIP();
                                                          });
                                                        },
                                                        activeColor:
                                                            Colors.orange,
                                                        checkColor:
                                                            Colors.white,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                      title: const Text('VVIP'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListTile(
                                                      horizontalTitleGap: -5,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      leading: Checkbox(
                                                        value: _vvvipChecked,
                                                        onChanged: (newValue) {
                                                          setState(() {
                                                            _vvvipChecked =
                                                                newValue ??
                                                                    false;
                                                            if (_vvvipChecked ==
                                                                true) {
                                                              newvvvip = 1;
                                                            }
                                                            if (_vvvipChecked ==
                                                                false) {
                                                              newvvvip = 0;
                                                            }
                                                            updateVVVIP();
                                                          });
                                                        },
                                                        activeColor: Colors.red,
                                                        checkColor:
                                                            Colors.white,
                                                        shape:
                                                            const CircleBorder(),
                                                      ),
                                                      title:
                                                          const Text('VVVIP'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Positioned(
                                            top: 10,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 10),
                                              child: Text(
                                                'Member Tier',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text('Additional info'),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Colors.white,
                                        ),
                                        height: 140,
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 10),
                                          child: Stack(children: [
                                            const Positioned(
                                              top: 0,
                                              left: 1,
                                              child: Text(
                                                'Info 1',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 73,
                                              left: 1,
                                              child: Text(
                                                ' Info 2',
                                                style: TextStyle(
                                                    color: Color(0xFF1276ff)),
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  controller: _info1,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Type here',
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10),
                                                  ),
                                                  onChanged: (value) {
                                                    info1 = _info1.text;
                                                    updateInfo1();
                                                  },
                                                ),
                                                const Divider(),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  controller: _info2,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText: 'Type here',
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            top: 10),
                                                  ),
                                                  onChanged: (value) {
                                                    info2 = _info2.text;
                                                    updateInfo2();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ]),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              widget.updateData();
                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8))),
                                            child: const Text('Save')),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                    ],
                                  ),
                                )));
                      },
                    ),
                  ),
                );
              } else {
                return const Text('');
                //}
              }
            }));
  }

  Future updateName() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateName = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/name'));

    requestUpdateName.bodyFields = {'name': memberName};

    requestUpdateName.headers.addAll(headers);

    http.StreamedResponse responseName = await requestUpdateName.send();

    if (responseName.statusCode == 200) {
    } else {}
  }

  Future updateIC() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateIC = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/nationalID'));

    requestUpdateIC.bodyFields = {'nationalID': memberIC};

    requestUpdateIC.headers.addAll(headers);

    http.StreamedResponse responseIC = await requestUpdateIC.send();

    if (responseIC.statusCode == 200) {
    } else {}
  }

  Future updateMaritalStatus() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateMarital = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/marital'));

    requestUpdateMarital.bodyFields = {'marital': newmarital.toString()};

    requestUpdateMarital.headers.addAll(headers);

    http.StreamedResponse responseMarital = await requestUpdateMarital.send();

    if (responseMarital.statusCode == 200) {
    } else {}
  }

  Future updateGenderStatus() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateGender = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/gender'));

    requestUpdateGender.bodyFields = {'gender': newgender.toString()};

    requestUpdateGender.headers.addAll(headers);

    http.StreamedResponse responseGender = await requestUpdateGender.send();

    if (responseGender.statusCode == 200) {
    } else {}
  }

  Future updateDOB() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateDOB = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/dob'));

    print('DOB:$_dateController.text');

    requestUpdateDOB.bodyFields = {'dob': _dateController.text.toString()};

    requestUpdateDOB.headers.addAll(headers);

    http.StreamedResponse responseDOB = await requestUpdateDOB.send();

    if (responseDOB.statusCode == 200) {
      setState(() {
        dob = _dateController.text;
      });
    } else {}
  }

  Future updateVIP() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateVIP = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/vip'));

    requestUpdateVIP.bodyFields = {'vip': newvip.toString()};

    requestUpdateVIP.headers.addAll(headers);

    http.StreamedResponse responseVIP = await requestUpdateVIP.send();

    if (responseVIP.statusCode == 200) {
    } else {}
  }

  Future updateVVIP() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateVVIP = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/vvip'));

    requestUpdateVVIP.bodyFields = {'vvip': newvvip.toString()};

    requestUpdateVVIP.headers.addAll(headers);

    http.StreamedResponse responseVVIP = await requestUpdateVVIP.send();

    if (responseVVIP.statusCode == 200) {
    } else {}
  }

  Future updateVVVIP() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateVVVIP = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/vvvip'));

    requestUpdateVVVIP.bodyFields = {'vvvip': newvvvip.toString()};

    requestUpdateVVVIP.headers.addAll(headers);

    http.StreamedResponse responseVVVIP = await requestUpdateVVVIP.send();

    if (responseVVVIP.statusCode == 200) {
    } else {}
  }

  Future updateEthnic() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateEthnic = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/ethnicID'));

    requestUpdateEthnic.bodyFields = {'ethnicID': ethnicID.toString()};

    requestUpdateEthnic.headers.addAll(headers);

    http.StreamedResponse responseEthnic = await requestUpdateEthnic.send();

    if (responseEthnic.statusCode == 200) {
    } else {}
  }

  Future updateInfo1() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateInfo1 = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/nick1'));

    requestUpdateInfo1.bodyFields = {'nick1': info1};

    requestUpdateInfo1.headers.addAll(headers);

    http.StreamedResponse responseInfo1 = await requestUpdateInfo1.send();

    if (responseInfo1.statusCode == 200) {
    } else {}
  }

  Future updateInfo2() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestUpdateInfo2 = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/member/$memberIDglobal/nick2'));

    requestUpdateInfo2.bodyFields = {'nick2': info2};

    requestUpdateInfo2.headers.addAll(headers);

    http.StreamedResponse responseInfo2 = await requestUpdateInfo2.send();

    if (responseInfo2.statusCode == 200) {
    } else {}
  }

  checkMarital() {
    if (maritalClick == false) {
      if (marital == 0) {
        return Marital.married;
      } else if (marital == 1) {
        return Marital.single;
      }
    } else {
      if (newmarital == 0) {
        return Marital.married;
      } else if (newmarital == 1) {
        return Marital.single;
      }
    }
  }

  checkGender() {
    if (genderClick == false) {
      if (gender == 0) {
        return Gender.female;
      } else if (gender == 1) {
        return Gender.male;
      }
    } else {
      if (newgender == 0) {
        return Gender.female;
      } else if (newgender == 1) {
        return Gender.male;
      }
    }
  }
}
