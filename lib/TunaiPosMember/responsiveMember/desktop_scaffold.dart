import "package:flutter/material.dart";

class DesktopScaffold extends StatefulWidget {
  const DesktopScaffold({super.key});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold>  {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: 
          AppBar(
            elevation: 1,
            toolbarHeight: 85,
            backgroundColor: Colors.white,
            title:  Padding(
              padding: EdgeInsets.only(top: 40, bottom: 50, right: 250),
              child: Column(
                children: [
                  Icon(Icons.person,
                  size: 45,
                   color: Colors.grey,),
                  Text('Member',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey
                  ),)
                ],
              ),
            ),
           bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: SizedBox.shrink(),
          // )
            //bottom: Text("member"),
          ),
        ),
        body: Row(
          children: [
            // Expanded(
            //   flex: 1,
            //   child: AllMember()
            // ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

}