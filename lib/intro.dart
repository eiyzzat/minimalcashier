import 'package:flutter/material.dart';

import 'addOrder.dart';
import 'home.dart';


class intro extends StatelessWidget {
  const intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      
      body: ListView(
        physics: const BouncingScrollPhysics(),
       padding: const EdgeInsets.only(top: 20),

        children: [

          GestureDetector(
              onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addOrder(title: 'Create Order')),
                    );
                  },
          
          
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200, color: Colors.blue[200],
                child: 
                Center(child: Text('Create Order'))
                
                ),
            ),
          ),
          
          GestureDetector(
              onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Order')),
                    );
                  }, 
            
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200, color: Colors.blue[200],
                child: 
                Center(child: Text('Order'))
                
                ),
            ),
          
      
          ),
          
        ],
      ),
      
    );
  }
}
