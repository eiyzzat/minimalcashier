
import 'package:flutter/material.dart';
import 'package:minimal/cart.dart';
import '../function.dart';
import 'cart_specific_staff.dart';

class StaffPart extends StatefulWidget {
  const StaffPart(
      {Key? key,
      required this.cartOrderId,
      required this.otems,
      required this.skus,
      required this.updateCart});

  final String cartOrderId;

  final List<dynamic> otems;
  final List<dynamic> skus;
  final Function updateCart;

  @override
  State<StaffPart> createState() => _StaffPartState();
}

class _StaffPartState extends State<StaffPart> {
  Set<int> _selectedIndices = Set<int>();

  bool isCustomTapped = false;
  bool okTapped = false;
  bool showRefresh = false;

  int? selectedStaffIndex;

  Map<String, dynamic>? selectedStaffDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        title: const Text(
          'Select Staff',
          style: TextStyle(color: Colors.black),
        ),
        leading: xIcon(),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
          ),
          Column(
            children: [
              hi(), // Call hi() method here to display the staff list
            ],
          ),
        ],
      ),
      bottomNavigationBar: addButton(),
    );
  }

  Widget xIcon() {
    return IconButton(
      icon: Image.asset(
        "lib/assets/Artboard 40.png",
        height: 30,
        width: 20,
      ),
      onPressed: () => Navigator.pop(context),
      iconSize: 24,
    );
  }

  Widget hi() {
    Future staffData = APIFunctions.getStaff();

    // print("otem dalam staff : ${otems}");

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top:10.0,left:12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Staff list',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily:
                          'SFProDisplay', // Use the specified font family
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: staffData,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return GridView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: staff.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.5,
                          ),
                          itemBuilder: (context, index) {
                            var staffDetails = staff[index];
                            var name = staffDetails['name'];
                            String mobileNumber =
                                staffDetails['mobile'].toString();
                            String formattedNumber =
                                '(${mobileNumber.substring(0, 4)}) ${mobileNumber.substring(4, 7)}-${mobileNumber.substring(7)}';

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_selectedIndices.contains(index)) {
                                    _selectedIndices.remove(index);
                                  } else {
                                    _selectedIndices.add(index);
                                  }
                                  selectedStaffDetails =
                                      getSelectedStaffDetails();
                                  printSelectedStaffDetails();
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: _selectedIndices.contains(index)
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image(
                                        image:
                                            NetworkImage(staff[index]['icon']),
                                        width: 25,
                                        height: 25,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              formattedNumber,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? getSelectedStaffDetails() {
    if (_selectedIndices.isEmpty) {
      return null;
    }

    List<Map<String, dynamic>> selectedDetails = [];
    for (int index in _selectedIndices) {
      var staffDetails = staff[index];
      var name = staffDetails['name'];
      var image = staffDetails['icon'];
      var staffID = staffDetails['staffID'];
      selectedDetails.add({
        'name': name,
        'image': image,
        'staffID': staffID,
      });
    }

    return {
      'selectedStaff': selectedDetails,
    };
  }

  void printSelectedStaffDetails() {
    if (_selectedIndices.isEmpty) {
      print('No containers selected.');
    } else {
      print('Selected staff details:');
      for (int index in _selectedIndices) {
        var staffDetails = staff[index];
        var name = staffDetails['name'];
        var image = staffDetails['icon'];
        var staffID = staffDetails['staffID'];

        print('Name: $name staffID: $staffID Image: $image ');
      }
    }
  }

  Widget addButton() {
    return Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0,
          bottom: 25.0,
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (_selectedIndices.isNotEmpty) {
              List<Map<String, dynamic>> selectedDetails = [];
              for (int index in _selectedIndices) {
                var staffDetails = staff[index];
                var staffID = staffDetails['staffID'];
                var name = staffDetails['name'];
                var image = staffDetails['icon'];
                selectedDetails.add({
                  'staffID': staffID,
                  'name': name,
                  'image': image,
                });
              }

              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 750,
                    child: SpecificStaff(
                      staffID: selectedstaffID,
                      staffDetails:
                          selectedDetails.isNotEmpty ? selectedDetails : null,
                      otems: widget.otems,
                      cartOrderId: widget.cartOrderId,
                      skus: widget.skus,
                      updateCart: widget.updateCart,
                    ),
                  );
                },
              );
            }
          },
          child: Text('Add'),
        ),
      ),
    );
  }
}