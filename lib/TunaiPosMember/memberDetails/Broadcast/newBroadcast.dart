// ignore_for_file: avoid_print, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';

import 'allBroadcastImage.dart';
import 'postBroadcast.dart';

class NewBroadcast extends StatefulWidget {
  const NewBroadcast({super.key});

  @override
  State<NewBroadcast> createState() => _NewBroadcastState();
}

class _NewBroadcastState extends State<NewBroadcast> {
  Map<String, List<dynamic>> groupedBroadcasts = {};
  Map<String, List<dynamic>> first12Images = {};
  Map<String, List<dynamic>> temp = {};

  List<dynamic> broadcast = [];

  String firstImage = '';
  String broadcastTitle = '';

  loadAPI() async {
    await getBroadcastImage();
    setState(() {
      if (first12Images.isNotEmpty) {
        String firstKey = first12Images.keys.elementAt(0);
        firstImage = first12Images[firstKey]![0]['path'];
        broadcastTitle = first12Images[firstKey]![0]['title'];
      }
      temp = groupedBroadcasts;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAPI();
  }

  Future getBroadcastImage() async {
    var headers = {'token': token};

    var request = http.Request(
        'GET', Uri.parse('https://loyalty.tunai.io/bimages?delta=0'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);

      Map<String, dynamic> broadcasts = body;
      broadcast = broadcasts['bimages'];

      if (broadcast.isNotEmpty) {
        for (var i = broadcast.length - 1; i >= 0; i--) {
          String titleValue = broadcast[i]['title'];

          if (groupedBroadcasts.containsKey(titleValue)) {
            groupedBroadcasts[titleValue]!.insert(0, broadcast[i]);
          } else {
            groupedBroadcasts[titleValue] = [broadcast[i]];
          }
        }
      }

      if (groupedBroadcasts.isNotEmpty) {
        String firstKey = groupedBroadcasts.keys.elementAt(0);
        List<dynamic> images = groupedBroadcasts[firstKey]!;

        if (images.length < 12) {
          first12Images[firstKey] = images;

          int count = images.length;
          int index = 1;

          while (count < 12 && index < groupedBroadcasts.length) {
            String nextKey = groupedBroadcasts.keys.elementAt(index);
            List<dynamic> nextImages = groupedBroadcasts[nextKey]!;
            int remaining = 12 - count;

            if (nextImages.length <= remaining) {
              first12Images[nextKey] = nextImages;
              count += nextImages.length;
            } else {
              first12Images[nextKey] = nextImages.sublist(0, remaining);
              count += remaining;
            }

            index++;
          }
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                'New broadcast',
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
                    onPressed: () {
                      showModalBottomSheet<dynamic>(
                        enableDrag: false,
                        barrierColor: Colors.transparent,
                        isScrollControlled: true,
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        )),
                        builder: (BuildContext context) {
                          return SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2.65 / 3,
                            child: PostBroadcast(
                                firstImage: firstImage,
                                broadcastTitle: broadcastTitle),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Next',
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
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return FutureBuilder(
                      //future: getBroadcastImage(),
                      builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return images();
                    }
                  });
                }))));
  }

  Widget images() {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 500.0;
    return ListView.builder(
      itemCount: first12Images.length,
      itemBuilder: (context, index) {
        String key = first12Images.keys.elementAt(index);
        List<dynamic> broadcasts = first12Images[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            index == 0
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 10, right: 10, bottom: 10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(firstImage)),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 20, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines:
                          2, // Set the maximum number of lines before truncating with ellipsis
                    ),
                  ),
                  index == 0
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: getViewAllBroadcastImage(context))
                      : Container()
                ],
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

                  return getChangeFirstImage(
                      broadcast, aspectRatio, screenWidth);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  GestureDetector getChangeFirstImage(
      broadcast, double aspectRatio, double screenWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          firstImage = broadcast['path'];
          broadcastTitle = broadcast['title'];
        });
      },
      child: SizedBox(
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

  GestureDetector getViewAllBroadcastImage(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result = await showModalBottomSheet<dynamic>(
          enableDrag: false,
          barrierColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          builder: (BuildContext context) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 2.65 / 3,
              child: AllBroadcastImage(
                  temp: temp,
                  firstImage: firstImage,
                  broadcastTitle: broadcastTitle),
            );
          },
        );
        setState(() {
          firstImage = result[0];
          broadcastTitle = result[1];
        });
      },
      child: Container(
        color: const Color(0xFFf3f2f8),
        child:  Row(
          children: [
            Text(
              'View More',
              style: TextStyle(color: Color(0xFF1276ff), fontSize: 16),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF1276ff),
            ),
          ],
        ),
      ),
    );
  }
}
