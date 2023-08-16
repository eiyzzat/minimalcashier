// ignore_for_file: unnecessary_string_escapes, prefer_const_constructors, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';

class AddCar extends StatefulWidget {
  final VoidCallback updateData;
  const AddCar({super.key, required this.updateData});

  @override
  State<AddCar> createState() => _AddCarState();
}

final _colornameadd = TextEditingController();
/* When the color is selected, the empty textfield will now have the value for the selected color */
// ColorSelectionPage
final _brandadd = TextEditingController();
/* When the brand is selected, the empty textfield will now have the value for the selected brand */
// CarBrandExpand
final _modeladd = TextEditingController();
/* When the model is selected, the empty textfield will now have the value for the selected model */
// CarModel
String colorID = '';
/* Send the updated for color selection to api */
// ColorSelectionPage
String modelID = '';
/* Send the updated for model selection to api */
// CarModel

class _AddCarState extends State<AddCar> {
  final _registration = TextEditingController();
  final _manufacturedYear = TextEditingController();
  final _mileage = TextEditingController();
  final _chasisNumber = TextEditingController();

  bool registration = false;
  bool year = false;
  bool doneUpdate = false;

  String carID = '';

  List<dynamic> car = [];

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
              scale: 1.2,
              child: CloseButton(
                  color: const Color(0xFF1276ff),
                  onPressed: () {
                    _modeladd.clear();
                    _brandadd.clear();
                    _colornameadd.clear();
                    brandID = 0;
                    Navigator.pop(context);
                  })),
        ),
        title:  Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Add car',
            style: TextStyle(color: Colors.black),
          ),
        ]),
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                  child: Column(children: [
                    const SizedBox(
                      height: 5,
                    ),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Required info\*',
                          style: TextStyle(color: Color(0xFF000000)),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
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
                                'Brand',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            const Positioned(
                              top: 73,
                              left: 1,
                              child: Text(
                                'Model',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            const Positioned(
                              top: 146,
                              left: 1,
                              child: Text(
                                'License plate',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            const Positioned(
                              top: 219,
                              left: 1,
                              child: Text(
                                'Manufactured year',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _brandadd,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: 'No brand selected',
                                    hintStyle: TextStyle(
                                      color: Colors
                                          .black, // Change the hint text color here
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
                                  onTap: () {
                                    showModalBottomSheet<dynamic>(
                                      enableDrag: false,
                                      barrierColor: Colors.transparent,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      )),
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2.65 /
                                                3,
                                            child: const CarBrandExpand());
                                      },
                                    );
                                  },
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _modeladd,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
                                  onTap: () {
                                    if (brandID != 0) {
                                      showModalBottomSheet<dynamic>(
                                        enableDrag: false,
                                        barrierColor: Colors.transparent,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        )),
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  2.65 /
                                                  3,
                                              child: const CarModel());
                                        },
                                      );
                                    }
                                  },
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _registration,
                                  decoration: const InputDecoration(
                                    hintText: 'Type here',
                                    hintStyle: TextStyle(
                                      color: Colors
                                          .black, // Change the hint text color here
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
                                  onChanged: (value) {
                                    setState(() {
                                      registration = value.isNotEmpty;
                                    });
                                  },
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _manufacturedYear,
                                        decoration: const InputDecoration(
                                          hintText: 'Type here',
                                          hintStyle: TextStyle(
                                            color: Colors.black,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.only(top: 10),
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF1276ff),
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(4),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        onTap: () {
                                          setState(() {
                                            doneUpdate = true;
                                          });
                                        },
                                      ),
                                    ),
                                    if (_manufacturedYear.text.isNotEmpty &&
                                        ((int.tryParse(_manufacturedYear
                                                        .text) ??
                                                    0) <
                                                1901 ||
                                            (int.tryParse(_manufacturedYear
                                                        .text) ??
                                                    0) >
                                                DateTime.now().year))
                                      const Icon(
                                        Icons.warning,
                                        color: Colors.red,
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ]),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Optional info',
                          style: TextStyle(color: Color(0xFF000000)),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                        height: 220,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 10, right: 10),
                          child: Stack(children: [
                            const Positioned(
                              top: 0,
                              left: 1,
                              child: Text(
                                'Color',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            const Positioned(
                              top: 73,
                              left: 1,
                              child: Text(
                                'Mileage',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            const Positioned(
                              top: 146,
                              left: 1,
                              child: Text(
                                'Chassis number',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _colornameadd,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: 'No color selected',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
                                  onChanged: (value) {},
                                  onTap: () {
                                    showModalBottomSheet<dynamic>(
                                      enableDrag: false,
                                      barrierColor: Colors.transparent,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      )),
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2.65 /
                                                3,
                                            child: ColorSelectionPage());
                                      },
                                    );
                                  },
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(
                                        10), // Limit input to 5 characters
                                  ],
                                  controller: _mileage,
                                  decoration: const InputDecoration(
                                    hintText: 'Type here',
                                    hintStyle: TextStyle(
                                      color: Colors
                                          .black, // Change the hint text color here
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
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
                                  controller: _chasisNumber,
                                  decoration: const InputDecoration(
                                    hintText: 'Type here',
                                    hintStyle: TextStyle(
                                      color: Colors
                                          .black, // Change the hint text color here
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(top: 10),
                                  ),
                                  style:
                                      const TextStyle(color: Color(0xFF1276ff)),
                                ),
                              ],
                            ),
                          ]),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_registration.text.isNotEmpty &&
                                _manufacturedYear.text.isNotEmpty &&
                                int.tryParse(_manufacturedYear.text) != null &&
                                int.parse(_manufacturedYear.text) >= 1901 &&
                                int.parse(_manufacturedYear.text) <=
                                    DateTime.now().year)
                            ? () {
                                addNewCar();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  addNewCar() async {
    /*Car Required Info*/
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    var requestRequiredInfo = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car'));

    requestRequiredInfo.bodyFields = {
      'registration': _registration.text,
      'year': _manufacturedYear.text,
      'modelID': modelID,
    };
    requestRequiredInfo.headers.addAll(headers);

    http.StreamedResponse responseRequiredInfo =
        await requestRequiredInfo.send();

    var header = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car'));
    request.bodyFields = {};
    request.headers.addAll(header);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> member1 = body;

      car = member1['cars'];

      if (car.isNotEmpty) {
        for (var i = 0; i < car.length; i++) {
          if (car[i]['deleteDate'] == 0) {
            if (car[i]['registration'] == _registration.text) {
              carID = car[i]['mcarID'].toString();
            }
          }
        }
      }
    } else {
      print(response.reasonPhrase);
    }

    /*Car Mileage Info*/
    if (_mileage.text.isNotEmpty) {
      var requestCarMileage = http.Request(
          'POST',
          Uri.parse(
              'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carID/mileage'));

      requestCarMileage.bodyFields = {'mileage': _mileage.text};
      requestCarMileage.headers.addAll(headers);

      http.StreamedResponse responseCarMileage = await requestCarMileage.send();
      if (responseCarMileage.statusCode == 200) {
        // Do something if update was successful
        _chasisNumber.clear();
      } else {
        // Handle the error if the update was unsuccessful
      }
    }

    /*Car Chassis Number Info*/
    if (_chasisNumber.text.isNotEmpty) {
      var requestCarChassis = http.Request(
          'POST',
          Uri.parse(
              'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carID/chassis'));

      requestCarChassis.bodyFields = {'chassis': _chasisNumber.text};
      requestCarChassis.headers.addAll(headers);

      http.StreamedResponse responseCarChassis = await requestCarChassis.send();

      if (responseCarChassis.statusCode == 200) {
        // Do something if update was successful
        _chasisNumber.clear();
      } else {
        // Handle the error if the update was unsuccessful
      }
    }

    /*Car Car Color Info*/
    if (_colornameadd.text.isNotEmpty) {
      var requestCarColor = http.Request(
          'POST',
          Uri.parse(
              'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carID/colorID'));

      requestCarColor.bodyFields = {'colorID': colorID};
      requestCarColor.headers.addAll(headers);

      http.StreamedResponse responseCarColor = await requestCarColor.send();
      if (responseCarColor.statusCode == 200) {
        // Do something if update was successful
        _chasisNumber.clear();
      } else {
        // Handle the error if the update was unsuccessful
      }
    }

    if (responseRequiredInfo.statusCode == 200) {
      _modeladd.clear();
      _brandadd.clear();
      _colornameadd.clear();
      widget.updateData();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } else {
      print(responseRequiredInfo.reasonPhrase);
    }
  }
}

class ColorSelectionPage extends StatefulWidget {
  const ColorSelectionPage({super.key});

  @override
  State<ColorSelectionPage> createState() => _ColorSelectionPageState();
}

class _ColorSelectionPageState extends State<ColorSelectionPage> {
  List<dynamic> carColor = [];

  Future getCarColor() async {
    var headers = {'token': token};

    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/carcolor'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      //var decode = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> car = body;

      carColor = car['colors'];
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
            'Select color',
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
        ),
        body: Container(
          height: double.infinity,
          color: const Color(0xFFf3f2f8),
          child: Center(
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: getCarColor(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // Number of colors per row
                          childAspectRatio: 0.80,
                        ),
                        itemCount: carColor.length,
                        itemBuilder: (context, index) {
                          final colorName = carColor[index]['color'];
                          String colorHex = carColor[index]['hex']
                              .toString()
                              .replaceAll('#', '');
                          String formattedColorHex = '0xFF$colorHex';
                          // Remove "#" symbol

                          return GestureDetector(
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 0),
                                  () {
                                setState(() {
                                  _colornameadd.text = colorName;
                                  colorID =
                                      carColor[index]['colorID'].toString();
                                  Navigator.pop(context);
                                });
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color:
                                            Color(int.parse(formattedColorHex)),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    colorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }),
            ),
          ),
        ));
  }
}

class CarBrandExpand extends StatefulWidget {
  const CarBrandExpand({super.key});

  @override
  State<CarBrandExpand> createState() => _CarBrandExpandState();
}

String brandImageGlobal = '';
/* When i want to display the brand image */
// CarModel
int brandID = 0; //brand is maker in api
/* When o do the comparison of the ID in maker and model */
// CarModel

class _CarBrandExpandState extends State<CarBrandExpand> {
  final searchController = TextEditingController();
  List<dynamic> carBrand = [];
  List<dynamic> queriedList = [];
  bool isGridView = true;

  ValueNotifier refreshLayout = ValueNotifier(0);

  Future getCarBrand() async {
    var headers = {'token': token};

    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/car'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      //var decode = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> car = body;

      carBrand = car['makers'];
    }
  }

  loadApi() async {
    await getCarBrand(); // akan pegi dkt getInformation dlk baru akan baca next line kat dibah
    setState(() {
      queriedList = carBrand;
    });
  }

  @override
  void initState() {
    super.initState();
    loadApi();
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
          'Brand',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0.5,
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
                }),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: StatefulBuilder(
              builder: (BuildContext context, refresh) {
                return IconButton(
                  icon: Icon(
                    isGridView ? Icons.list : Icons.grid_view,
                    color: const Color(0xFF1276ff),
                    size: 30,
                  ),
                  onPressed: () {
                    refresh(
                      () {
                        isGridView = !isGridView;
                        refreshLayout.value++;
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xFFf3f2f8),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: TextFormField(
                  //onChanged: filterCarBrands, // Call the filter method on text change
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: const Color(0xFFebebeb),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onChanged: searchBrand,
                ),
              ),
            ),
            FutureBuilder(builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('');
              } else {
                return ValueListenableBuilder(
                  valueListenable: refreshLayout,
                  builder:
                      (BuildContext context, dynamic value, Widget? child) {
                    return isGridView ? buildGridView() : buildListView();
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget buildGridView() {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 400.0;
    return Expanded(
      child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of colors per row
            childAspectRatio: aspectRatio,
          ),
          itemCount: queriedList.length,
          itemBuilder: (context, index) {
            String brandImage = queriedList[index]['image'];
            String brandName = queriedList[index]['name'];
            return Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: GestureDetector(
                onTap: () {
                  brandID = queriedList[index]['makerID'];
                  _brandadd.text = queriedList[index]['name'];
                  brandImageGlobal = queriedList[index]['image'];
                  showModalBottomSheet<dynamic>(
                    enableDrag: false,
                    barrierColor: Colors.transparent,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    context: context,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    )),
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height * 2.65 / 3,
                          child: const CarModel());
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.network(
                          brandImage,
                          height: 130,
                          width: 130,
                        ),
                      ),
                      Text(
                        brandName,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget buildListView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: Colors.white,
          ),
          child: ListView.builder(
              itemCount: queriedList.length,
              itemBuilder: (context, index) {
                String brandImage = queriedList[index]['image'];
                String brandName = queriedList[index]['name'];

                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: GestureDetector(
                    onTap: () {
                      brandID = queriedList[index]['makerID'];
                      _brandadd.text = queriedList[index]['name'];
                      brandImageGlobal = queriedList[index]['image'];
                      showModalBottomSheet<dynamic>(
                        enableDrag: false,
                        barrierColor: Colors.transparent,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        )),
                        builder: (BuildContext context) {
                          return SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2.65 / 3,
                              child: const CarModel());
                        },
                      );
                    },
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.network(
                                  brandImage,
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                              Text(
                                brandName,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Divider(
                              thickness: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }

  void searchBrand(String query) {
    List<dynamic> suggestion;

    if (query.isEmpty) {
      suggestion = carBrand;
    } else {
      suggestion = queriedList.where((element) {
        List<String> nameParts = element['name'].toString().split(' ');
        bool nameMatch = false;
        for (int i = 0; i < nameParts.length; i++) {
          String namePart = nameParts[i].toLowerCase();
          if (namePart.startsWith(query) || namePart.endsWith(query)) {
            nameMatch = true;
            break;
          }
        }
        return nameMatch;
      }).toList();
    }
    setState(() {
      queriedList = suggestion;
    });
  }
}

class CarModel extends StatefulWidget {
  const CarModel({super.key});

  @override
  State<CarModel> createState() => _CarModelState();
}

class _CarModelState extends State<CarModel> {
  final searchController = TextEditingController();
  List<dynamic> carModel = [];
  List<Map<String, dynamic>> queriedList = [];
  List<Map<String, dynamic>> specificCarModel = [];

  Future getCarModel() async {
    var headers = {'token': token};

    var request =
        http.Request('GET', Uri.parse('https://loyalty.tunai.io/car'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> car = body;

      carModel = car['models'];
      int tot = 0;
      //loop untuk condition ambil specific car
      if (carModel.isNotEmpty) {
        for (var i = 0; i < carModel.length; i++) {
          if (carModel[i]['makerID'] == brandID) {
            specificCarModel.add({
              'model_id': carModel[i]['modelID'],
              'model_name': carModel[i]['name'],
              'model_image': carModel[i]['image'],
            });
            tot = tot + 1;
          }
        }
      }
    }
  }

  loadApi() {
    // akan pegi dkt getInformation dlk baru akan baca next line kat dibah
    queriedList = specificCarModel;
  }

  @override
  void initState() {
    super.initState();
    specificCarModel = [];
    loadApi();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = screenWidth / 440.0;

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          )),
          centerTitle: true,
          title: const Text(
            'Model',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0.5,
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
        ),
        body: Container(
          color: const Color(0xFFf3f2f8),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 100,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Center(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      filled: true,
                      fillColor: const Color(0xFFebebeb),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onChanged: searchModel,
                  ),
                ),
              ),
              FutureBuilder(
                future: getCarModel(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Expanded(
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Number of colors per row
                              childAspectRatio: aspectRatio,
                            ),
                            itemCount: queriedList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, left: 10, right: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        if (_modeladd.text.isEmpty) {
                                          modelID = queriedList[index]
                                                  ['model_id']
                                              .toString();
                                          _modeladd.text =
                                              queriedList[index]['model_name'];
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } else {
                                          modelID = queriedList[index]
                                                  ['model_id']
                                              .toString();
                                          _modeladd.text =
                                              queriedList[index]['model_name'];
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10, left: 10),
                                                child: Image.network(
                                                  brandImageGlobal.toString(),
                                                  height: 35,
                                                  width: 35,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: queriedList[index]
                                                            ['model_image'] !=
                                                        null
                                                    ? Image.network(
                                                        queriedList[index]
                                                                ['model_image']
                                                            .toString(),
                                                        height: 120,
                                                        width: 120,
                                                      )
                                                    : const SizedBox(
                                                        height: 120,
                                                        width: 120,
                                                        child: Center(
                                                          child: Text(
                                                              'No model image'),
                                                        ))),
                                            Text(
                                              queriedList[index]['model_name'],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )));
                            }));
                  }
                },
              ),
            ],
          ),
        ));
  }

  void searchModel(String query) {
    List<Map<String, dynamic>> suggestion;

    if (query.isEmpty) {
      suggestion = specificCarModel;
    } else {
      suggestion = queriedList.where((element) {
        List<String> nameParts = element['model_name'].toString().split(' ');
        bool nameMatch = false;
        for (int i = 0; i < nameParts.length; i++) {
          String namePart = nameParts[i].toLowerCase();
          if (namePart.startsWith(query) || namePart.endsWith(query)) {
            nameMatch = true;
            break;
          }
        }
        return nameMatch;
      }).toList();
    }
    setState(() {
      queriedList = suggestion;
      specificCarModel = [];
    });
  }
}
