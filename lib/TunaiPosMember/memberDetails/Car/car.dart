// ignore_for_file: avoid_print, sized_box_for_whitespace

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../constant/token.dart';
import '../../responsiveMember/mobile_scaffold.dart';
import 'addCar.dart';
import 'updateCar.dart';

class Car extends StatefulWidget {
  const Car({super.key});

  @override
  State<Car> createState() => _CarState();
}

String carIDglobal = '';

class _CarState extends State<Car> {
  int carModelID = 0;
  int makerID = 0;
  int carMakerID = 0;
  int mileage = 0;

  String carModelImage = '';
  String carModelName = '';
  String carMakerImage = '';
  String carMakerName = '';
  String registration = '';
  String carcolor = '';
  String carBrandImage = '';
  String year = '';

  List<dynamic> car = [];
  List<dynamic> makers = [];
  List<dynamic> models = [];
  List<dynamic> deleteDate = [];
  List<Map<String, dynamic>> carModels = [];
  List<Map<String, dynamic>> carMakers = [];

  Future getCarList() async {
    var headers = {'token': token};

    var request = http.Request(
        'GET',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car'));

    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responsebody = await response.stream.bytesToString();

      var body = json.decode(responsebody);

      Map<String, dynamic> member1 = body;

      car = member1['cars'];
      deleteDate = [];
      carModels = [];
      carMakers = [];
      if (car.isNotEmpty) {
        for (var i = 0; i < car.length; i++) {
          registration = car[i]['registration'];
          carcolor = car[i]['color'];
          mileage = car[i]['mileage'];
          year = car[i]['year'].toString();
          deleteDate.add(car[i]['deleteDate']);
        }
      }

      makers = member1['makers'];

      if (makers.isNotEmpty) {
        for (var i = 0; i < makers.length; i++) {
          String makerName = makers[i]['name'];
          String makerImage = makers[i]['image'];
          int makerID = makers[i]['makerID'];
          carMakers.add({
            'maker_name': makerName,
            'maker_id': makerID,
            'maker_image': makerImage,
          });
        }
      }

      models = member1['models'];

      if (models.isNotEmpty) {
        for (var i = 0; i < models.length; i++) {
          String modelName = models[i]['name'];
          String modelImage = models[i]['image'].toString();
          int modelID = models[i]['modelID'];
          int makerID = models[i]['makerID'];
          carModels.add({
            'model_name': modelName,
            'model_image': modelImage,
            'model_id': modelID,
            'maker_id': makerID,
          });
        }
      }
      return car;
    } else {
      print(response.reasonPhrase);
    }
  }

  void updateData() {
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
          title: const Text(
            'Car',
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
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: IconButton(
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
                      return Container(
                          height: MediaQuery.of(context).size.height * 2.65 / 3,
                          child: AddCar(updateData: updateData));
                    },
                  );
                },
                icon: const Icon(Icons.add),
                color: const Color(0xFF1276ff),
                iconSize: 35,
              ),
            ),
          ],
        ),
        body: FutureBuilder(
            future: getCarList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData && deleteDate.contains(0)) {
                return Container(
                    width: double.infinity,
                    color: const Color(0xFFf3f2f8),
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SingleChildScrollView(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: car.length,
                                  itemBuilder: (context, index) {
   
                                    car.sort((a, b) => b['createDate'].compareTo(a['createDate']));


                                    if (car[index]['deleteDate'] == 0) {
                                      var carModel1 = carModels
                                          .where((model) =>
                                              model['model_id'] ==
                                              car[index]['modelID'])
                                          .first;
                                      carModelName = carModel1['model_name'];
                                      carModelID = carModel1['model_id'];
                                      carModelImage = carModel1['model_image'];

                                      var modelmaker = carModel1['maker_id'];
                                      var carMaker = carMakers
                                          .where((maker) =>
                                              maker['maker_id'] == modelmaker)
                                          .first;
                                      carMakerName = carMaker['maker_name'];
                                      carMakerImage =
                                          carMaker['maker_image'].toString();
                                    }

                                    return SizedBox(
                                      height: car[index]['deleteDate'] == 0
                                          ? 200
                                          : 0,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 10, right: 10),
                                        child: car[index]['deleteDate'] == 0
                                            ? Dismissible(
                                                key: Key(car[index]['mcarID']
                                                    .toString()), // use a unique key for each item
                                                direction:
                                                    DismissDirection.endToStart,
                                                onDismissed: (direction) async {
                                                  final carID =
                                                      car[index]['mcarID'];
                                                  deleteCar(carID);
                                                },
                                                background: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
                                                    color: Colors.red,
                                                  ),
                                                  child:  Padding(
                                                    padding: EdgeInsets.all(16),
                                                    child: Row(children: [
                                                      Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )
                                                    ]),
                                                  ),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    carIDglobal = car[index]
                                                            ['mcarID']
                                                        .toString();

                                                    showModalBottomSheet<
                                                        dynamic>(
                                                      enableDrag: false,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                        top:
                                                            Radius.circular(20),
                                                      )),
                                                      builder: (BuildContext
                                                          context) {
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2.65 /
                                                              3,
                                                          child: UpdateCar(
                                                              updateData:
                                                                  updateData),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Image
                                                                          .network(
                                                                        carMakerImage,
                                                                        height:
                                                                            40,
                                                                        width:
                                                                            40,
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                          '$carMakerName $carModelName'),
                                                                      Text(
                                                                          '(${car[index]['year']})'),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                    flex: 2,
                                                                    child: carModelImage !=
                                                                            'null'
                                                                        ? Image
                                                                            .network(
                                                                            carModelImage,
                                                                            height:
                                                                                90,
                                                                            width:
                                                                                90,
                                                                          )
                                                                        : const Text(
                                                                            ''))
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  decoration: const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              12)),
                                                                      color: Color(
                                                                          0xFFf2f1f6)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        car[index]
                                                                            [
                                                                            'registration']),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                  decoration: const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              12)),
                                                                      color: Color(
                                                                          0xFFf2f1f6)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                        car[index]
                                                                            [
                                                                            'color']),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Container(
                                                                  decoration: const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(
                                                                              12)),
                                                                      color: Color(
                                                                          0xFFf2f1f6)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      '${NumberFormat('#,##0').format(int.parse(car[index]['mileage'].toString()))} km',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    );
                                  })));
                    }));
              } else {
                return  SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No cars yet!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'You can add member'
                        's'
                        ' car details using the + icon',
                        style: TextStyle(color: Color(0xFF878787)),
                      ),
                      Text('& the car details will display here when added',
                          style: TextStyle(color: Color(0xFF878787)))
                    ],
                  ),
                );
                //}
              }
            }));
  }

  deleteCar(int carID) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete Car'),
          content: const Text(
              'Are you sure you would like to delete the selected car?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                deleteCarFromAPI(carID);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteCarFromAPI(int carID) async {
    var headers = {'token': token};
    var request = http.Request(
        'POST',
        Uri.parse(
            'https://member.tunai.io/cashregister/members/$memberIDglobal/car/$carID/delete'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {});
    } else {
      print(response.reasonPhrase);
    }
  }
}
