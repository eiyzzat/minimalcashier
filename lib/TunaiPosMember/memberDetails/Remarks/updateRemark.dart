// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class UpdateRemark extends StatefulWidget {
  final int remarkID;
  final String remark;
  const UpdateRemark({super.key, required this.remarkID, required this.remark});

  @override
  State<UpdateRemark> createState() => _UpdateRemarkState();
}

class _UpdateRemarkState extends State<UpdateRemark> {
  List<dynamic> remark = [];
  FocusNode _remarkFocusNode = FocusNode();
  String remarks = '';

  TextEditingController inputRemark = TextEditingController();

  bool _formEdited = false;

  @override
  void initState() {
    remarks = widget.remark;
    inputRemark = TextEditingController(text: remarks);
    super.initState();
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
                            title: const Text(
                                'This remark will be deleted are you sure?'),
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
                    icon: Image.asset(
                      'icons/TrashRed.png',
                      scale: 40,
                    )))
          ],
        ),
        body: Container(
          color: const Color(0xFFf3f2f8),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Column(
              children: [
                Container(
                    width: double.infinity,
                    height: 150,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Colors.white,
                    ),
                    child: Scrollbar(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          controller: inputRemark,
                          focusNode: _remarkFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Type remark here',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 10),
                          ),
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          onTap: () {
                            setState(() {
                              _formEdited = true;
                            });
                            _remarkFocusNode.requestFocus();
                            inputRemark.selection = TextSelection.fromPosition(
                              TextPosition(offset: inputRemark.text.length),
                            );
                          },
                        ),
                      ),
                    )),
                const SizedBox(
                  height: 10,
                ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async {
                          var headers = {
                            'token': token,
                            'Content-Type': 'application/x-www-form-urlencoded'
                          };
                          var request = http.Request(
                              'POST',
                              Uri.parse(
                                  'https://member.tunai.io/cashregister/member/$memberIDglobal/remark/${widget.remarkID}/update'));
                          request.bodyFields = {'remarks': inputRemark.text};
                          request.headers.addAll(headers);

                          http.StreamedResponse response = await request.send();

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
                                borderRadius: BorderRadius.circular(8))),
                        child: const Text('Save')),
                  ),
              ],
            ),
          ),
        ));
  }
}
