// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class Reset extends StatefulWidget {
  const Reset({super.key});

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  late DateTime currentDate;
  late DateTime nextThreeYears;
  late List<Map<String, dynamic>> dates;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    currentDate = DateTime.now();
    nextThreeYears = currentDate.add(const Duration(days: 365 * 3));
    dates = generateDates();
  }

  List<Map<String, dynamic>> generateDates() {
    dates = [];

    final noExpiry = {'month': 'No expiry', 'date': null};
    dates.add(noExpiry);

    // Add 1 month from the current date
    final oneMonthDate = currentDate.add(const Duration(days: 30));
    dates.add({'month': '1 month', 'date': oneMonthDate});

    // Add 2 months from the current date
    final twoMonthsDate = currentDate.add(const Duration(days: 30 * 2));
    dates.add({'month': '2 months', 'date': twoMonthsDate});

    // Add 3 months from the current date
    final threeMonthsDate = currentDate.add(const Duration(days: 30 * 3));
    dates.add({'month': '3 months', 'date': threeMonthsDate});

    // Add 6 months from the current date
    final sixMonthsDate = currentDate.add(const Duration(days: 30 * 6));
    dates.add({'month': '6 months', 'date': sixMonthsDate});

    // Add 9 months from the current date
    final nineMonthsDate = currentDate.add(const Duration(days: 30 * 9));
    dates.add({'month': '9 months', 'date': nineMonthsDate});

    // Add 1 year from the current date
    final oneYearDate = currentDate.add(const Duration(days: 365));
    dates.add({'month': '1 year', 'date': oneYearDate});

    // Add 2 years from the current date
    final twoYearsDate = currentDate.add(const Duration(days: 365 * 2));
    dates.add({'month': '2 years', 'date': twoYearsDate});

    return dates;
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
            'Reset',
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
            width: double.infinity,
            color: const Color(0xFFf3f2f8),
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                  child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 10, right: 10, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Unit price',
                                    style: TextStyle(color: Color(0xFF878787)),
                                  ),
                                  const Spacer(),
                                  Image.asset(
                                    'icons/Edit (Blue).png',
                                    scale: 60,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text('0.00')
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text('Preset'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          height:
                              320, // Provide a specific height for the GridView
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 3,
                            ),
                            itemCount: dates.length,
                            itemBuilder: (context, index) {
                              final date = dates[index];
                              final String month = date['month'];
                              final DateTime? dateTime = date['date'];

                              final bool isSelected = index == selectedIndex;

                              if (dateTime == null) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.transparent,
                                        width: isSelected ? 2.0 : 0.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        month,
                                        style:
                                            const TextStyle(color: Color(0xFF000000)),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final String formattedDate =
                                  '${dateTime.day.toString().padLeft(2, '0')}-'
                                  '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: isSelected ? 2.0 : 0.0,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        month,
                                        style:
                                            const TextStyle(color: Color(0xFF000000)),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        formattedDate,
                                        style:
                                            const TextStyle(color: Color(0xFF1175fc)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text('Calendar'),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        height: 300,
                        padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.001),
                        child: CalendarDatePicker(
                          initialDate: currentDate,
                          firstDate: currentDate,
                          lastDate: nextThreeYears,
                          //.subtract(Duration(days: 1)), // Set the last selectable date
                          onDateChanged: (DateTime newDate) async {
                            // // Handle date selection here
                            // // Convert the date to a Unix timestamp format
                            // DateTime newDateTime = DateTime(
                            //     newDate.year,
                            //     newDate.month,
                            //     newDate.day,
                            //     // widget.date.hour,
                            //     // widget.date.minute,
                            //     // widget.date.second);
                            // int unixTimestamp = newDateTime.millisecondsSinceEpoch ~/ 1000;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ));
            })));
  }
}
