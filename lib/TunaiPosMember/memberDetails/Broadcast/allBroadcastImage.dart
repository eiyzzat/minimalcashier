// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class AllBroadcastImage extends StatefulWidget {
  final Map<String, List<dynamic>> temp;
  final String firstImage;
  final String broadcastTitle;
  const AllBroadcastImage(
      {super.key,
      required this.temp,
      required this.firstImage,
      required this.broadcastTitle});

  @override
  State<AllBroadcastImage> createState() => _AllBroadcastImageState();
}

class _AllBroadcastImageState extends State<AllBroadcastImage> {
  String firstImage = '';
  String broadcastTitle = '';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 500.0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        )),
        centerTitle: true,
        title: const Text(
          'Select Image',
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
                    Navigator.pop(
                        context, [widget.firstImage, widget.broadcastTitle]);
                  })),
        ),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFf3f2f8),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
            itemCount: widget.temp.length,
            itemBuilder: (context, index) {
              String key = widget.temp.keys.elementAt(index);
              List<dynamic> broadcasts = widget.temp[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10, top: 20, bottom: 5),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: broadcasts.length,
                      itemBuilder: (context, index) {
                        var broadcast = broadcasts[index];

                        return getPopBroadcastImage(
                            broadcast, context, aspectRatio, screenWidth);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  GestureDetector getPopBroadcastImage(
      broadcast, BuildContext context, double aspectRatio, double screenWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          firstImage = broadcast['path'];
          broadcastTitle = broadcast['title'];
        }); // ... logic to get the selected image names
        Navigator.pop(context, [firstImage, broadcastTitle]);
      },
      child: Container(
        height: aspectRatio *
            screenWidth, // Set the height to maintain a square shape
        width: double.infinity, // Make the container width fill the entire row
        child: Image.network(
          broadcast['path'],
          fit: BoxFit.cover, // Adjust the image fit as per your requirement
        ),
      ),
    );
  }
}
