// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../responsiveMember/mobile_scaffold.dart';
import '../../../constant/token.dart';

class UpdateRemark extends StatefulWidget {
  final int remarkID;
  const UpdateRemark({super.key, required this.remarkID, required remark});

  @override
  State<UpdateRemark> createState() => _UpdateRemarkState();
}

class _UpdateRemarkState extends State<UpdateRemark> {
  List<dynamic> remark = [];

  String _remark = '';

  final inputRemark = TextEditingController();
  
  bool _formEdited = false;

  Future getMemberRemarks() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/remark/${widget.remarkID}/details'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> member1 = body;

      remark = member1['remarks'];

      if (remark.isNotEmpty) {
        for (var i = 0; i < remark.length; i++) {
          _remark = remark[i]['remarks'];
        }
      }
      return remark;
    } else {
      print(response.reasonPhrase);
    }
  }

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
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            if (_formEdited) {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoActionSheet(
                    title: const Text(
                        'Are you sure you want to discard this new member?'),
                    actions: <Widget>[
                      Container(
                        color: Colors.white,
                        child: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          isDestructiveAction: true,
                          child: const Text('Discard Changes'),
                        ),
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text('Keep Editing'),
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
          child: const Icon(
            Icons.close,
            color: Color(0xFF1175fc),
            size: 35,
          ),
        ),
        title:  Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Edit remark',
            style: TextStyle(color: Colors.black),
          ),
        ]),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          title:
                              const Text('This remark will be deleted are you sure?'),
                          actions: <Widget>[
                            Container(
                              color: Colors.white,
                              child: CupertinoActionSheetAction(
                                onPressed: () async {
                                  var headers = {'token': token};
                                  var request = http.Request(
                                      'POST',
                                      Uri.parse(
                                          'https://member.tunai.io/cashregister/member/$memberIDglobal/remark/${widget.remarkID}/delete'));

                                  request.headers.addAll(headers);

                                  http.StreamedResponse response =
                                      await request.send();

                                  if (response.statusCode == 200) {
                                    Navigator.pop(context, 'refresh');
                                    Navigator.pop(context, 'refresh');
                                  } else {
                                    print(response.reasonPhrase);
                                  }
                                },
                                isDestructiveAction: true,
                                child: const Text('Delete Remark'),
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 30,
                  )))
        ],
      ),
      body: FutureBuilder(
          future: getMemberRemarks(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              inputRemark.text = _remark;
              return Container(
                color: const Color(0xFFf3f2f8),
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: Colors.white,
                            ),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: inputRemark,
                                    decoration: const InputDecoration(
                                      hintText: 'Type remark here',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(top: 10),
                                      alignLabelWithHint: true,
                                    ),
                                    maxLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    onChanged: (value) {
                                      _formEdited = true;
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  var headers = {
                                    'token': token,
                                    'Content-Type':
                                        'application/x-www-form-urlencoded'
                                  };
                                  var request = http.Request(
                                      'POST',
                                      Uri.parse(
                                          'https://member.tunai.io/cashregister/member/$memberIDglobal/remark/${widget.remarkID}/update'));
                                  request.bodyFields = {
                                    'remarks': inputRemark.text
                                  };
                                  request.headers.addAll(headers);

                                  http.StreamedResponse response =
                                      await request.send();

                                  if (response.statusCode == 200) {
                                    Navigator.pop(context, 'refresh');
                                  } else {
                                    print(response.reasonPhrase);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: const Text('Save')),
                          ),
                        ],
                      ),
                    ),
                  ));
                }),
              );
            } else {
              return const Text('');
              //}
            }
          }),
    );
  }
}
