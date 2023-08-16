// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class UpdateAppointment extends StatefulWidget {
  final String memberName;
  final String memberMobile;
  final String date;
  final String itemName;
  final String formattedTime;
  final String formattedEndTime;
  final int duration;
  final String staffName;
  final String remarks;

  const UpdateAppointment(
      {super.key,
      required this.memberName,
      required this.memberMobile,
      required this.date,
      required this.itemName,
      required this.formattedTime,
      required this.formattedEndTime,
      required this.duration,
      required this.staffName,
      required this.remarks});

  @override
  State<UpdateAppointment> createState() => _UpdateAppointmentState();
}

class _UpdateAppointmentState extends State<UpdateAppointment> {
  late TextEditingController appointmentDate =
      TextEditingController.fromValue(TextEditingValue(text: widget.date));
  late TextEditingController service =
      TextEditingController.fromValue(TextEditingValue(text: widget.itemName));
  late TextEditingController staff =
      TextEditingController.fromValue(TextEditingValue(text: widget.staffName));
  late TextEditingController remarks =
      TextEditingController.fromValue(TextEditingValue(text: widget.remarks));

  bool menuVisible = false;

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
          'Update appointment',
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
          PopupMenuButton<String>(
            shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            elevation: 1,
            offset: const Offset(0, 45),
            padding: EdgeInsets.zero,
            child: Image.asset(
              'icons/More (Blue).png',
              color: menuVisible ? Colors.blueAccent.shade100 : null,
              scale: 40,
            ),
            onOpened: () {
              setState(() {
                menuVisible = !menuVisible;
              });
            },
            onCanceled: () {
              setState(() {
                menuVisible = !menuVisible;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    getDelayby30Minutes(),
                    const Divider(
                      thickness: 1,
                      color: Color(0xFFf3f2f8),
                    ),
                    getDelaybyanHour(),
                    const Divider(
                      thickness: 3,
                      color: Color(0xFFf3f2f8),
                    ),
                    getSetAsCompleted(),
                    const Divider(
                      thickness: 1,
                      color: Color(0xFFf3f2f8),
                    ),
                    getSetAsNoShow(),
                    const Divider(
                      thickness: 1,
                      color: Color(0xFFf3f2f8),
                    ),
                    getDeleteAppointment(),
                  ],
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
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.memberName),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '(${widget.memberMobile.substring(0, 4)})${widget.memberMobile.substring(4, 7)}-${widget.memberMobile.substring(7)}',
                              style: const TextStyle(color: Color(0xFF878787)),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Appointment details',
                        style: TextStyle(color: Color(0xFF4b556b)),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      height: 285,
                      width: double.infinity,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Stack(children: [
                          const Positioned(
                            top: 0,
                            left: 1,
                            child: Text(
                              'Appointment date',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ),
                          const Positioned(
                            top: 73,
                            left: 1,
                            child: Text(
                              'Service',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ),
                          const Positioned(
                            top: 146,
                            left: 1,
                            child: Text(
                              'Start time',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ),
                          const Positioned(
                            top: 219,
                            left: 1,
                            child: Text(
                              'Staff',
                              style: TextStyle(color: Color(0xFF878787)),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: appointmentDate,
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
                              const Divider(),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: service,
                                decoration: const InputDecoration(
                                  hintText: 'Type here',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 10),
                                ),
                                style:
                                    const TextStyle(color: Color(0xFF1276ff)),
                              ),
                              Divider(),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        widget.formattedTime,
                                        style: const TextStyle(
                                            color: Color(0xFF1276ff),
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.formattedEndTime,
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff),
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          '(${widget.duration.toString()} mins)',
                                          style: const TextStyle(
                                              color: Color(0xFF1276ff),
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const Divider(),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: staff,
                                decoration: const InputDecoration(
                                  hintText: 'Type here',
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top: 10),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF1276ff),
                                ),
                              )
                            ],
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Others',
                        style: TextStyle(color: Color(0xFF4b556b)),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: double.infinity,
                      height: 72,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 0,
                              left: 1,
                              child: Text(
                                'Remarks',
                                style: TextStyle(color: Color(0xFF878787)),
                              ),
                            ),
                            TextFormField(
                              controller: remarks,
                              decoration: const InputDecoration(
                                hintText: 'Type here',
                                hintStyle: TextStyle(
                                  color: Colors
                                      .black, // Change the hint text color here
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 10),
                              ),
                              style: const TextStyle(color: Color(0xFF1276ff)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        'Appointment color',
                        style: TextStyle(color: Color(0xFF4b556b)),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ));
          })),
    );
  }

  GestureDetector getDeleteAppointment() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 5,
            ),
            Image.asset(
              'icons/Trash.png',
              scale: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Delete appointment',
              style: TextStyle(fontSize: 14, color: Color(0xFFff3b2f)),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector getSetAsNoShow() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 5,
            ),
            Image.asset(
              'icons/Rect.X.png',
              scale: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Set as no show',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector getSetAsCompleted() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 5,
            ),
            Image.asset(
              'icons/Rect.Check.png',
              scale: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Set as completed',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector getDelaybyanHour() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 5,
            ),
            Image.asset(
              'icons/Delay.60.png',
              scale: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Delay by an hour',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector getDelayby30Minutes() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'icons/Delay.30.png',
              scale: 40,
              color: Colors.black,
            ),
            const SizedBox(
              width: 5,
            ),
            const Text(
              'Delay by 30 minutes',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
