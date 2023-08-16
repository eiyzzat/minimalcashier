import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class AddRemarks extends StatefulWidget {
  const AddRemarks({super.key});

  @override
  State<AddRemarks> createState() => _AddRemarksState();
}

class _AddRemarksState extends State<AddRemarks> {
  final inputRemark = TextEditingController();
  bool _formEdited = false;
  bool done = false;

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Transform.scale(
            scale: 1.3,
            child: CloseButton(
              color: const Color(0xFF1276ff),
              onPressed: () {
                if (_formEdited) {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoActionSheet(
                        title: const Text(
                            'Are you sure you want to discard this new remark?'),
                        //message: Text('Are you sure you want to discard changes?'),
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
            ),
          ),
        ),
        title:  Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Add remark',
            style: TextStyle(color: Colors.black),
          ),
        ]),
        actions: [
          if (inputRemark.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: TextButton(
                onPressed: () async {
                  //if (inputRemark.text.isNotEmpty) {
                  var headers = {
                    'token': token,
                    'Content-Type': 'application/x-www-form-urlencoded'
                  };
                  /* PostNotes */
                  var requestAddRemark = http.Request(
                      'POST',
                      Uri.parse('https://member.tunai.io/cashregister/member/$memberIDglobal/remark'));
                  requestAddRemark.bodyFields = {'remarks': inputRemark.text};

                  requestAddRemark.headers.addAll(headers);

                  http.StreamedResponse responseAddRemark =
                      await requestAddRemark.send();

                  if (responseAddRemark.statusCode == 200) {
                    inputRemark.clear();
                    // ignore: use_build_context_synchronously
                    Navigator.pop(context, 'refresh');
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
            )
        ],
      ),
      body: Container(
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
                  Form(
                    onChanged: () {
                      setState(() {
                        _formEdited = true;
                      });
                    },
                    child: Container(
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
                            decoration: const InputDecoration(
                              hintText: 'Type remark here',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(top: 10),
                              alignLabelWithHint: true,
                            ),
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.top,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
        }),
      ),
    );
  }
}
