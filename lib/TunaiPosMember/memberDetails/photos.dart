import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Photos extends StatefulWidget {
  const Photos({super.key});

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  List<File> imageFile = [];

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
            'Photos',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 1,
          backgroundColor: Colors.white,
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
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _getFromCamera();
                  },
                  icon: const Icon(Icons.camera_enhance),
                  color: const Color(0xFF1276ff),
                  iconSize: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: IconButton(
                    onPressed: () {
                      _getFromGallery();
                    },
                    icon: const Icon(Icons.add),
                    color: const Color(0xFF1276ff),
                    iconSize: 35,
                  ),
                ),
              ],
            )
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
                child: imageFile.isEmpty
                    ?  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No photos yet!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'You can take photos using the camera icon',
                            style: TextStyle(color: Color(0xFF878787)),
                          ),
                          Text('or upload photos from your gallery.',
                              style: TextStyle(color: Color(0xFF878787)))
                        ],
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.only(top: 10, right: 10, left: 10),
                        child: SizedBox(
                          height: 30,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: imageFile.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Image.file(
                                imageFile[index],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
              ));
            })));
  }

  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile.add(File(pickedFile.path));
      });
    }
  }

  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile.add(File(pickedFile.path));
      });
    }
  }
}
