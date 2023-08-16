// ignore_for_file: prefer_typing_uninitialized_variables, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_declarations, prefer_interpolation_to_compose_strings, avoid_print, prefer_const_constructors

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../Function/generalFunction.dart';
import '../../../constant/token.dart';
import '../memberDetails/Broadcast/newBroadcast.dart';
import '../memberDetails/Message/message.dart';
import '../memberDetails/member_details.dart';
import 'add_member.dart';

class MemberMobileScaffold extends StatefulWidget {
  const MemberMobileScaffold({super.key});

  @override
  State<MemberMobileScaffold> createState() => _MemberMobileScaffoldState();
}

String memberNameDetails = '';
/* Used to display the name for specific member when we click on that member */
// MemberDetails
String memberMobile = '';
/* Used to display the mobile for specific member if they got no name, when we click on that member */
// MemberDetails
String memberIDglobal = '';
/* Used for the http line in api when needed memberID */
// AddCar // AddRemarks // Car // CheckList // Credit // MemberDetails // Notes
// Outstanding // Point // Profile // Remark // UpdateCar // UpdateRemark // Voucher

class _MemberMobileScaffoldState extends State<MemberMobileScaffold>
    with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  final now = DateTime.now(); // Get the current month
  var size, height, width;
  var member;
  TabController? tabController; // Declare tabController variable
  List<dynamic> queriedList = [];
  List memberList = [];
  int currentIndex = 0;
  int recentTot = 0;
  int newTot = 0;
  int birthdayTot = 0;
  int outstandingTot = 0;
  bool loadAPI = true;
  bool isMenuVisible = false; // Track the visibility of the menu
  bool isDisposed = false; // Flag to track widget disposal

  loadApi() async {
    await getInformation(); // akan pegi dkt getInformation dlk baru akan baca next line kat dibah
    if (!isDisposed) {
      setState(() {
        queriedList = memberList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // Locks the app to portrait mode
    ]);
    tabController = TabController(length: 5, vsync: this);
    tabController?.addListener(() {
      setState(() {
        currentIndex =
            tabController?.index ?? 0; // Update the currentIndex variable
      });
    });
    if (loadAPI) {
      loadApi();
    }
  }

  @override
  void dispose() {
    tabController?.dispose(); // Dispose of the tabController
    isDisposed = true;
    super.dispose();
  }

  Future<void> getInformation() async {
    if (isDisposed) {
      // Return early if the widget is disposed
      return;
    }

    var headers = {'token': token};
    var request = http.Request(
        'GET', Uri.parse('https://member.tunai.io/cashregister/member'));
    request.bodyFields = {};
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      memberList = [];

      member = text["members"];

      for (int i = 0; i < member.length; i++) {
        if (member[i]['deleteDate'] == 0) {
          memberList.add(member[i]);
        }
      }

      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['task'] == 'New Member' &&
            DateTime.fromMillisecondsSinceEpoch(
                        memberList[i]['createDate'] * 1000)
                    .month ==
                now.month) {
          newTot++;
        }
      }
      List<Future<void>> futures = [];
      for (int i = 0; i < memberList.length; i++) {
        if (isDisposed) {
          // Return if the widget was disposed during the API call
          return;
        }
        //     getVoucherTotal(memberList[i]['memberID'], i);
        futures.add(getVoucherTotal(memberList[i]['memberID'], i));
      }
      await Future.wait(futures);
      final currentMonth = DateFormat('MM').format(now);
      for (int i = 0; i < memberList.length; i++) {
        if (DateFormat('MM').format(DateTime.parse(memberList[i]['dob'])) ==
            currentMonth) {
          birthdayTot++;
        }
      }

      for (int i = 0; i < memberList.length; i++) {
        if (memberList[i]['outstandings'] > 0) {
          outstandingTot++;
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: const Color(0xFFffffff),
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
        title: const Center(
          child: Text(
            'All Members',
            style: TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                showModalBottomSheet<dynamic>(
                  enableDrag: false,
                  isScrollControlled: true,
                  context: context,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  )),
                  builder: (BuildContext context) {
                    return AddMember(loadData: loadData);
                  },
                );
              },
              icon: Image.asset(
                'icons/Add-member-icon.png',
                height: 30,
              ),
            ),
          )
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            Container(
              height: 5,
              width: width,
              color: Colors.white,
            ),
            Flexible(
              child: Container(
                color: Colors.white,
                width: width,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 0, bottom: 0),
                          child: Center(
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFebebeb),
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: 'Search',
                                  contentPadding: const EdgeInsets.all(15.0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              onChanged: searchMember,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: TabBar(
                          controller: tabController,
                          isScrollable: true,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 13),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 4,
                          indicatorColor: Colors.blue,
                          labelColor: Colors.black,
                          tabs: [
                            const Tab(
                              text: 'Recent',
                            ),
                            const Tab(
                              text: 'New',
                            ),
                            const Tab(
                              text: 'Birthday',
                            ),
                            const Tab(
                              text: 'Outstanding',
                            ),
                            const Tab(
                              text: 'Walk-In',
                            ),
                          ]),
                    ),
                    //),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: FutureBuilder(
                    future: loadAPI ? getInformation() : null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Container(
                          width: double.infinity,
                          color: const Color(0xFFf3f2f8),
                          child: TabBarView(
                            controller: tabController,
                            children: [
                              listRecent(),
                              listNew(),
                              listBirthday(),
                              listOutstanding(),
                              listWalkIn(),
                            ],
                          ),
                        );
                      }
                    })),
            Container(
              child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: [
                    const BottomNavigationBarItem(
                        icon: Padding(
                          padding: EdgeInsets.only(left: 20),
                        ),
                        label: 'account_group'),
                    BottomNavigationBarItem(
                        icon: Column(
                          children: [
                            const Text(
                              'Total',
                            ),
                            getTotalList()
                          ],
                        ),
                        label: 'total_member'),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        // child: Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () {
                        //         setState(
                        //           () {
                        //             loadAPI = false;
                        //             if (isMenuVisible = true) {
                        //               showPopupMenu();
                        //             }
                        //             isMenuVisible = true;
                        //           },
                        //         );
                        //       },
                        //       child: isMenuVisible
                        //           ? Image.asset(
                        //               'icons/Message.png',
                        //               height: 30,
                        //               color: Colors.blueAccent.shade100,
                        //               // Set the appropriate color
                        //             )
                        //           : Image.asset(
                        //               'icons/Message.png',
                        //               height: 30,
                        //               // Set the appropriate color
                        //             ),
                        //     ),
                        //   ],
                        // ),
                      ),
                      label: 'Message',
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  /* Message pop menu */
  void showPopupMenu() {
    final iconBox = context.findRenderObject() as RenderBox;
    final iconPosition = iconBox.localToGlobal(Offset.zero);

    final menuWidth = 120.0; // Adjust the width of the menu as needed
    final menuHeight = 160.0; // Adjust the height of the menu as needed

    showMenu(
      context: context,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      position: RelativeRect.fromLTRB(
        iconPosition.dx + iconBox.size.width - menuWidth,
        iconPosition.dy + iconBox.size.height - menuHeight,
        iconPosition.dx + iconBox.size.width - menuWidth,
        iconPosition.dy + iconBox.size.height - menuHeight,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet<dynamic>(
                      enableDrag: false,
                      isScrollControlled: true,
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      )),
                      builder: (BuildContext context) {
                        return const NewBroadcast();
                      },
                    );
                  },
                  child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'icons/Speaker.png',
                              scale: 50,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text('Broadcast'),
                          ],
                        ),
                      ))),
              const Divider(
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet<dynamic>(
                        enableDrag: false,
                        isScrollControlled: true,
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        )),
                        builder: (BuildContext context) {
                          return const Message();
                        },
                      );
                    },
                    child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'icons/Textbox.png',
                                scale: 50,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Message'),
                            ],
                          ),
                        ))),
              ),
            ],
          ),
        )
      ],
    ).then((value) {
      // Handle the dismissal of the popup menu
      setState(() {
        isMenuVisible = false;
        // Change the icon color back to the original color
      });
    });
  }

/* Recent */
  listRecent() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        int timestamp = queriedList[index]['todayDate'];
        DateTime dateTime =
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
        if ((index == 0 ||
            (index > 0 &&
                DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            queriedList[index - 1]['todayDate'] * 1000)) !=
                    DateFormat('yyyy-MM-dd').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            queriedList[index]['todayDate'] * 1000))))) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 15),
                child: Text(
                  formattedDate,
                  style: const TextStyle(color: Color(0xFF8a8a8a)),
                ),
              ),
              getMemberBox(index)
            ],
          );
        } else {
          return getMemberBox(index);
        }
      },
    );
  }

/* New */
  listNew() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        if (queriedList[index]['task'] == 'New Member') {
          DateTime createDate = DateTime.fromMillisecondsSinceEpoch(
              queriedList[index]['createDate'] * 1000);
          if (DateFormat('MM').format(createDate) ==
              DateFormat('MM').format(now)) {
            return getMemberBox(index);
          }
        }
        return Container();
      },
    );
  }

/* Birthday */
  listBirthday() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        final currentMonth = DateFormat('MM').format(now);
        if (DateFormat('MM')
                .format(DateTime.parse(queriedList[index]['dob'])) ==
            currentMonth) {
          return getMemberBox(index);
        } else {
          return Container();
        }
      },
    );
  }

/* Outstanding */
  listOutstanding() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        if (queriedList[index]['outstandings'] != 0) {
          return getMemberBox(index);
        } else {
          return Container();
        }
      },
    );
  }

  /* Walk-In */
  listWalkIn() {
    return ListView.builder(
      itemCount: queriedList.length,
      itemBuilder: (context, index) {
        if (queriedList[index]['mobile'] == '000000000000') {
          return getMemberBox(index);
        } else {
          return Container();
        }
      },
    );
  }

  getMemberBox(int index) {
    int timestamp = queriedList[index]['todayDate'];
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String suffix = (hour >= 12) ? 'PM' : 'AM';
    hour = (hour > 12) ? hour - 12 : hour;
    String minuteString = minute.toString().padLeft(2, '0');

    loadAPI = false;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MemberDetails(updateData: updateData)));
          memberNameDetails = queriedList[index]['name'];
          memberIDglobal = queriedList[index]['memberID'].toString();
          memberMobile = queriedList[index]['mobile'];
        },
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.white),
                child: Column(
                  children: [
                    Row(children: [
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 5, top: 20, bottom: 0),
                          child: queriedList[index]['icon'] == ''
                              ? const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 30,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(queriedList[index]['icon']),
                                  backgroundColor: const Color(0xFFf3f2f8),
                                  radius: 30,
                                )),
                      Expanded(
                        flex: 3,
                        child: queriedList[index]['dob'] == '0000-00-00'
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, top: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                          child: queriedList[index]['outstandings'] == 0
                                              ? Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 10),
                                                  child: queriedList[index]['name'] != ''
                                                      ? Text(queriedList[index]['name'].toString(),
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight
                                                                  .w500))
                                                      : Text('${'(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7)}-' + queriedList[index]['mobile'].substring(7),
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight.w500)))
                                              : Padding(padding: const EdgeInsets.only(top: 10), child: queriedList[index]['name'] != '' ? Text(queriedList[index]['name'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)) : Text('${'(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7)}-' + queriedList[index]['mobile'].substring(7), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                            child: queriedList[index]['vip'] ==
                                                    1
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, bottom: 50),
                                                    child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.blue,
                                                        radius: 7),
                                                  )
                                                : null),
                                        Container(
                                            child: queriedList[index]['vvip'] ==
                                                    1
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5, bottom: 50),
                                                    child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.orange,
                                                        radius: 7),
                                                  )
                                                : null),
                                        Container(
                                            child:
                                                queriedList[index]['vvvip'] == 1
                                                    ? const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 5,
                                                                bottom: 50),
                                                        child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.red,
                                                            radius: 7),
                                                      )
                                                    : null),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  bottom: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: queriedList[index]['outstandings'] == 0
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                top: 5),
                                                        child: queriedList[index]['name'] !=
                                                                ''
                                                            ? Text(queriedList[index]['name'].toString(),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500))
                                                            : Text('${'(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7)}-' + queriedList[index]['mobile'].substring(7),
                                                                style: const TextStyle(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.w500)))
                                                    : Padding(padding: const EdgeInsets.only(top: 10), child: queriedList[index]['name'] != '' ? Text(queriedList[index]['name'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red)) : Text('${'(' + queriedList[index]['mobile'].substring(0, 4) + ') ' + queriedList[index]['mobile'].substring(4, 7)}-' + queriedList[index]['mobile'].substring(7), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)))),
                                            Text(queriedList[index]['dob'])
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              child:
                                                  queriedList[index]['vip'] == 1
                                                      ? const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  bottom: 50),
                                                          child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              radius: 7),
                                                        )
                                                      : null),
                                          Container(
                                              child: queriedList[index]
                                                          ['vvip'] ==
                                                      1
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, bottom: 50),
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.orange,
                                                          radius: 7),
                                                    )
                                                  : null),
                                          Container(
                                              child: queriedList[index]
                                                          ['vvvip'] ==
                                                      1
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 5, bottom: 50),
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.red,
                                                          radius: 7),
                                                    )
                                                  : null),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ]),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            child: queriedList[index]['credits'] != 0
                                ? Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: Color(0xFFf3f2f8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 9,
                                                right: 9,
                                                top: 6,
                                                bottom: 6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                    child: Image.asset(
                                                  'icons/Dollar.png',
                                                  height: 15,
                                                )),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(formatAmount(
                                                        queriedList[index]
                                                            ['credits'])
                                                    .toString()),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )
                                : null),
                        Container(
                            child: queriedList[index]['points'] != 0
                                ? Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(5),
                                            ),
                                            color: Color(0xFFf3f2f8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 9,
                                                right: 9,
                                                top: 6,
                                                bottom: 6),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                    child: Image.asset(
                                                  'icons/Star.png',
                                                  height: 15,
                                                )),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(queriedList[index]
                                                        ['points']
                                                    .toString()),
                                              ],
                                            ),
                                          )),
                                    ),
                                  )
                                : const SizedBox(
                                    width: 10,
                                  )),
                        queriedList[index]['voucherTotal'] != 0
                            ? Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Color(0xFFf3f2f8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 9, right: 9, top: 6, bottom: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Image.asset(
                                              'icons/Voucher.png',
                                              height: 15,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(queriedList[index]
                                                  ['voucherTotal']
                                              .toString()),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container()
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 10),
                          child: Text(
                            queriedList[index]['task'].toString(),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, top: 10),
                          child: Text(
                            '$hour:$minuteString $suffix',
                            // + formattedDate,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  getVoucherTotal(int memberID, int i) async {
    var headers = {'token': token};
    var request = http.Request(
        'GET',
        Uri.parse('https://member.tunai.io/cashregister/member/' +
            memberID.toString() +
            '/summary/total/vouchers'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var decode = await response.stream.bytesToString();

      var text = json.decode(decode);

      memberList[i]['voucherTotal'] = text["total"];
    } else {
      print(response.reasonPhrase);
    }
  }

  /* Total for each tab bar list */
  getTotalList() {
    if (currentIndex == 0) {
      return Text('${memberList.length}/${memberList.length}');
    } else if (currentIndex == 1) {
      return Text('$newTot/${memberList.length}');
    } else if (currentIndex == 2) {
      return Text('$birthdayTot/${memberList.length}');
    } else if (currentIndex == 3) {
      return Text('$outstandingTot/${memberList.length}');
    } else if (currentIndex == 4) {
      return Text('$outstandingTot/${memberList.length}');
    }
  }

/* Seraching */
  void searchMember(String query) {
    List<dynamic> suggestion;

    loadAPI = false;

    if (query.isEmpty) {
      suggestion = memberList;
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
        bool mobileMatch =
            element['mobile'].toString().toLowerCase().contains(query) ||
                element['mobile'].toString().toLowerCase().endsWith(query);
        return nameMatch || mobileMatch;
      }).toList();
    }

    setState(() {
      queriedList = suggestion;
    });
  }

  loadData() {
    loadApi();
  }

  updateData() {
    setState(() {
      loadApi();
    });
  }
}
