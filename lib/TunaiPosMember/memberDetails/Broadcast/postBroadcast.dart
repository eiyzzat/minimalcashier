import 'package:flutter/material.dart';

class PostBroadcast extends StatefulWidget {
  final String firstImage;
  final String broadcastTitle;
  const PostBroadcast(
      {super.key, required this.firstImage, required this.broadcastTitle});

  @override
  State<PostBroadcast> createState() => _PostBroadcastState();
}

class _PostBroadcastState extends State<PostBroadcast> {
  List<String> list = <String>[
    'All Member',
    'Custom group 1',
  ];

  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  TextEditingController inputMessage = TextEditingController();
  
  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    title.text = widget.broadcastTitle;
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: const Text(
            'Post Broadcast',
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
          actions: [
            TextButton(
                onPressed: () {},
                child: const Text(
                  'Send',
                  style: TextStyle(
                    color: Color(0xFF1276ff),
                    fontSize: 20,
                  ),
                ))
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 15, left: 10, right: 10, bottom: 20),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(widget.firstImage)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 20),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                const Positioned(
                                  top: 0,
                                  left: 1,
                                  child: Text(
                                    'Title',
                                    style: TextStyle(color: Color(0xFF878787)),
                                  ),
                                ),
                                const Positioned(
                                  top: 73,
                                  left: 1,
                                  child: Text(
                                    'Caption [Option]',
                                    style: TextStyle(color: Color(0xFF878787)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: title,
                                      decoration: const InputDecoration(
                                        hintStyle: TextStyle(
                                          color: Colors
                                              .black, // Change the hint text color here
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(top: 10),
                                      ),
                                      style:
                                          const TextStyle(color: Color(0xFF1276ff)),
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TextFormField(
                                      controller: caption,
                                      decoration: const InputDecoration(
                                        hintStyle: TextStyle(
                                          color: Color(
                                              0xFFc6c6c6), // Change the hint text color here
                                        ),
                                        hintText: 'Write a caption',
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(top: 10),
                                      ),
                                      style:
                                          const TextStyle(color: Color(0xFF1276ff)),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Text(
                                'Send to',
                                style: TextStyle(color: Color(0xFF333333)),
                              ),
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
                                      Container(), // Add this line to remove the underline
                                  isExpanded: true,
                                  onChanged: (String? value) {
                                    // This is called when the user selects an item.
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
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              );
            })));
  }
}
