// ignore_for_file: use_build_context_synchronously, duplicate_ignore, avoid_print, unnecessary_string_escapes, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'car.dart';

class UpdateCar extends StatefulWidget {
  final VoidCallback updateData;
  const UpdateCar({super.key, required this.updateData});

  @override
  State<UpdateCar> createState() => _UpdateCarState();
}

final _model = TextEditingController();

class _UpdateCarState extends State<UpdateCar> {
  final _colorname = TextEditingController();
  final _brand = TextEditingController();

  // ignore: prefer_final_fields
  late TextEditingController _registration =
      TextEditingController.fromValue(TextEditingValue(text: registration));
  // ignore: prefer_final_fields
  late TextEditingController _manufacturedYear =
      TextEditingController.fromValue(TextEditingValue(text: year));
  // ignore: prefer_final_fields
  late TextEditingController _mileage =
      TextEditingController.fromValue(TextEditingValue(text: mileage));
  // ignore: prefer_final_fields
  late TextEditingController _chasisNumber =
      TextEditingController.fromValue(TextEditingValue(text: chassis));

  List<dynamic> car = [];
  List<dynamic> makers = [];
  List<dynamic> models = [];

  String registration = '';
  String color = '';
  String chassis = '';
  String makersname = '';
  String modelsname = '';
  String year = '';
  String mileage = '';

  bool doneUpdate = false;

  Future getCarDetails() async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/detail'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();
      var body = json.decode(responsebody);
      Map<String, dynamic> member1 = body;

      car = member1['cars'];

      if (car.isNotEmpty) {
        for (var i = 0; i < car.length; i++) {
          registration = car[i]['registration'];
          year = car[i]['year'].toString();
          _colorname.text = car[i]['color'];
          mileage = car[i]['mileage'].toString();
          chassis = car[i]['chassis'];
        }
      }

      makers = member1['makers'];
      if (makers.isNotEmpty) {
        for (var i = 0; i < makers.length; i++) {
          _brand.text = makers[i]['name'];
          brandID = makers[i]['makerID'];
        }
      }

      models = member1['models'];
      if (models.isNotEmpty) {
        for (var i = 0; i < models.length; i++) {
          _model.text = models[i]['name'];
        }
      }

      return car;
    } else {
      print(response.reasonPhrase);
    }
  }

  void _updateData() {
    setState(() {});
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Transform.scale(
              scale: 1.2,
              child: CloseButton(
                  color: const Color(0xFF1276ff),
                  onPressed: () {
                    Navigator.pop(context);
                  })),
        ),
        title:  Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Edit car',
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
      body: FutureBuilder(
          future: getCarDetails(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFf3f2f8),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 10, right: 10),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
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
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    const Positioned(
                                      top: 73,
                                      left: 1,
                                      child: Text(
                                        'Model',
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    const Positioned(
                                      top: 146,
                                      left: 1,
                                      child: Text(
                                        'License plate',
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    const Positioned(
                                      top: 219,
                                      left: 1,
                                      child: Text(
                                        'Manufactured year',
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _brand,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            hintText: 'No brand selected',
                                            hintStyle: TextStyle(
                                              color: Colors
                                                  .black, // Change the hint text color here
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                          onTap: () {
                                            showModalBottomSheet<dynamic>(
                                              enableDrag: false,
                                              barrierColor: Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              )),
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      2.65 /
                                                      3,
                                                  child: CarBrandExpand(
                                                      brandname: _brand),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const Divider(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          controller: _model,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                          onTap: () {
                                            showModalBottomSheet<dynamic>(
                                              enableDrag: false,
                                              barrierColor: Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              )),
                                              builder: (BuildContext context) {
                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      2.65 /
                                                      3,
                                                  child: CarModel(
                                                    updateData: _updateData,
                                                  ),
                                                );
                                              },
                                            );
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
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                        ),
                                        const Divider(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: _manufacturedYear,
                                                decoration:
                                                    const InputDecoration(
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
                                                  LengthLimitingTextInputFormatter(
                                                      4),
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9]')),
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
                                            if (_manufacturedYear
                                                    .text.isNotEmpty &&
                                                ((int.tryParse(_manufacturedYear
                                                                .text) ??
                                                            0) <
                                                        1901 ||
                                                    (int.tryParse(
                                                                _manufacturedYear
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
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
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    const Positioned(
                                      top: 73,
                                      left: 1,
                                      child: Text(
                                        'Mileage',
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    const Positioned(
                                      top: 146,
                                      left: 1,
                                      child: Text(
                                        'Chassis number',
                                        style:
                                            TextStyle(color: Color(0xFF878787)),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _colorname,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            hintText: 'No color selected',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
                                          onTap: () {
                                            showModalBottomSheet<dynamic>(
                                              enableDrag: false,
                                              barrierColor: Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              )),
                                              builder: (BuildContext context) {
                                                return SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      2.65 /
                                                      3,
                                                  child: ColorSelectionPage(
                                                      colorname: _colorname),
                                                );
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
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
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
                                            contentPadding:
                                                EdgeInsets.only(top: 10),
                                          ),
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff)),
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
                                  onPressed: (int.tryParse(
                                                  _manufacturedYear.text) !=
                                              null &&
                                          int.parse(_manufacturedYear.text) >=
                                              1901 &&
                                          int.parse(_manufacturedYear.text) <=
                                              DateTime.now().year)
                                      ? () {
                                          updateApi();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8))),
                                  child: const Text('Save')),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('');
              //}
            }
          }),
    );
  }

  updateApi() async {
    var headers = {
      'token': token,
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    // Registration
    var requestRegistration = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/registration'));

    requestRegistration.bodyFields = {'registration': _registration.text};
    requestRegistration.headers.addAll(headers);

    http.StreamedResponse responseRegistration =
        await requestRegistration.send();

    // Manufactured Year
    var requestManufacturedYear = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/year'));

    requestManufacturedYear.bodyFields = {'year': _manufacturedYear.text};
    requestManufacturedYear.headers.addAll(headers);

    http.StreamedResponse responseManufacturedYear =
        await requestManufacturedYear.send();

    // Mileage
    var requestMileage = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/mileage'));
    requestMileage.bodyFields = {'mileage': _mileage.text};
    requestMileage.headers.addAll(headers);

    http.StreamedResponse responseMileage = await requestMileage.send();

    // Chasis Number
    var requestChasis = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/chassis'));
    requestChasis.bodyFields = {'chassis': _chasisNumber.text};
    requestChasis.headers.addAll(headers);

    http.StreamedResponse responseChasis = await requestChasis.send();

    if (responseManufacturedYear.statusCode == 200 ||
        responseRegistration.statusCode == 200 ||
        responseMileage.statusCode == 200 ||
        responseChasis.statusCode == 200) {
      widget.updateData();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      print(responseManufacturedYear.reasonPhrase);
    }
  }
}

class ColorSelectionPage extends StatefulWidget {
  final TextEditingController colorname;
  const ColorSelectionPage({super.key, required this.colorname});
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
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => UpdateCar()));
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                  () async {
                                widget.colorname.text = colorName;
                                int colorID = carColor[index]['colorID'];

                                var headers = {
                                  'token': token,
                                  'Content-Type':
                                      'application/x-www-form-urlencoded'
                                };
                                // Color
                                var requestColor = http.Request(
                                    'POST',
                                    Uri.parse(
                                        'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/colorID'));
                                requestColor.bodyFields = {
                                  'colorID': colorID.toString()
                                };
                                requestColor.headers.addAll(headers);

                                http.StreamedResponse responseColor =
                                    await requestColor.send();

                                if (responseColor.statusCode == 200) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                } else {
                                  print(responseColor.reasonPhrase);
                                }
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
  final TextEditingController brandname;
  const CarBrandExpand({super.key, required this.brandname});

  @override
  State<CarBrandExpand> createState() => _CarBrandExpandState();
}

int brandID = 0;

class _CarBrandExpandState extends State<CarBrandExpand> {
  final searchController = TextEditingController();
  List<dynamic> carBrand = [];
  List<dynamic> queriedList = [];
  bool isGridView = true;
  bool change = false;
  //int brandID = 0;
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
                  change = true;
                  brandID = queriedList[index]['makerID'];
                  widget.brandname.text = queriedList[index]['name'];
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
                          height: MediaQuery.of(context).size.height * 2.65 / 3,
                          child:
                              CarModel(updateData: () {}, brandchange: change));
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
                      change = true;
                      brandID = queriedList[index]['makerID'];
                      widget.brandname.text = queriedList[index]['name'];
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
                            child: CarModel(
                                updateData: () {}, brandchange: change),
                          );
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
  final VoidCallback updateData;
  final bool brandchange;
  const CarModel(
      {super.key, required this.updateData, this.brandchange = false});

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
      //var decode = await response.stream.bytesToString();

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
                    return Container();
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
                                      onTap: () async {
                                        int modelID =
                                            queriedList[index]['model_id'];
                                        _model.text =
                                            queriedList[index]['model_name'];

                                        var headers = {
                                          'token': token,
                                          'Content-Type':
                                              'application/x-www-form-urlencoded'
                                        };

                                        // Model
                                        var request = http.Request(
                                            'POST',
                                            Uri.parse(
                                                'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carIDglobal/model'));
                                        request.bodyFields = {
                                          'modelID': modelID.toString()
                                        };
                                        request.headers.addAll(headers);

                                        http.StreamedResponse response =
                                            await request.send();

                                        if (response.statusCode == 200) {
                                          widget.updateData();
                                          if (widget.brandchange == false) {
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          print(response.reasonPhrase);
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
