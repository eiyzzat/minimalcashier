import 'package:flutter/material.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppointmentState createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  late Widget secondColumnWidget;

  @override
  void initState() {
    super.initState();
    secondColumnWidget = const Text(
      'Initial Text',
      style: TextStyle(fontSize: 18),
    );
  }

  void updateSecondColumnWidget(String option) {
    setState(() {
      switch (option) {
        case 'Button 1':
          secondColumnWidget = Container(
            color: Colors.blue,
            width: 100,
            height: 100,
          );
          break;
        case 'Button 2':
          secondColumnWidget = Container(
            color: Colors.green,
            width: 150,
            height: 150,
          );
          break;
        case 'Button 3':
          secondColumnWidget = Container(
            color: Colors.red,
            width: 200,
            height: 200,
          );
          break;
        default:
          secondColumnWidget = const Text(
            'Invalid Option',
            style: TextStyle(fontSize: 18),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two Column Screen'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => updateSecondColumnWidget('Button 1'),
                  child: const Text('Button 1'),
                ),
                ElevatedButton(
                  onPressed: () => updateSecondColumnWidget('Button 2'),
                  child: const Text('Button 2'),
                ),
                ElevatedButton(
                  onPressed: () => updateSecondColumnWidget('Button 3'),
                  child: const Text('Button 3'),
                ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1,),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Second Column',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                secondColumnWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

