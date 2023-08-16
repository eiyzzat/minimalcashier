import 'package:flutter/material.dart';

class Message extends StatefulWidget {
  const Message({super.key});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  List<String> list = <String>[
    'All member',
  ];

  final inputMessage = TextEditingController();
  
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 2.65 / 3,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              )),
              centerTitle: true,
              title: const Text(
                'Message',
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
            body: Container(
                width: double.infinity,
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
                            const EdgeInsets.only(left: 15, right: 15, top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send to',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 25),
                                child: DropdownButton<String>(
                                  elevation: 1,
                                  value: dropdownValue,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 30,
                                    color: Color(0xFF1276ff),
                                  ),
                                  underline:
                                      Container(),
                                  isExpanded: true,
                                  onChanged: (String? value) {
                                    setState(() {
                                      dropdownValue = value!;
                                    });
                                  },
                                  items: list.map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Message',
                              style: TextStyle(color: Color(0xFF333333)),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                              child: Scrollbar(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: TextFormField(
                                    controller: inputMessage,
                                    decoration: const InputDecoration(
                                      hintText: 'Type message here',
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(top: 10),
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
                          ],
                        ),
                      ),
                    ),
                  );
                }))));
  }
}
