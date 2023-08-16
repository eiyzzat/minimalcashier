// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../responsiveMember/mobile_scaffold.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  final inputNote = TextEditingController();
  List<dynamic> member = [];
  bool _formEdited = false;
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    getMemberNotes();
  }

  Future<void> getMemberNotes() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/loyalty/member/$memberIDglobal/notes'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> member1 = body;
      member = member1['members'];

      if (member.isNotEmpty) {
        for (var i = 0; i < member.length; i++) {
          inputNote.text = member[i]['notes'];
          setState(() {
            _isLoading = false; // Set loading state to false
          });
        }
      } else {
        setState(() {
          _isLoading = false; // Set loading state to false
        });
      }
    } else {
      print(response.reasonPhrase);
      setState(() {
        _isLoading = false; // Set loading state to false
      });
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
        title: const Text(
          'Notes',
          style: TextStyle(color: Colors.black),
        ),
        leading: GestureDetector(
          onTap: () {
            if (_formEdited) {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoActionSheet(
                    title: const Text(
                        'Are you sure you want to discard this new note?'),
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
              Navigator.pop(context);
            }
          },
          child: const Icon(
            Icons.close,
            color: Color(0xFF1175fc),
            size: 35,
          ),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          if (_formEdited)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: TextButton(
                onPressed: () async {
                  var headers = {
                    'token': token,
                    'Content-Type': 'application/x-www-form-urlencoded'
                  };

                  var requestUpdateNote = http.Request(
                    'POST',
                    Uri.parse(
                      'https://member.tunai.io/cashregister/member/$memberIDglobal/notes',
                    ),
                  );

                  requestUpdateNote.bodyFields = {'notes': inputNote.text};
                  requestUpdateNote.headers.addAll(headers);

                  http.StreamedResponse responseNote =
                      await requestUpdateNote.send();

                  if (responseNote.statusCode == 200) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF1175fc),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFf3f2f8),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
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
                          child: _isLoading
                              ? const Center(
                                  child:
                                      CircularProgressIndicator()) // Show loading indicator
                              : TextFormField(
                                  controller: inputNote,
                                  decoration: const InputDecoration(
                                    hintText: 'Type notes here',
                                    border: InputBorder.none,
                                    contentPadding:
                                        EdgeInsets.only(top: 10),
                                  ),
                                  maxLines: null,
                                  textAlignVertical: TextAlignVertical.top,
                                  onChanged: (value) {
                                    setState(() {
                                      _formEdited = true;
                                    });
                                  },
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
