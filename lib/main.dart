import 'package:assignment1/phone_nums.dart' as phone_nums;
import 'package:assignment1/gallery.dart' as gallery;
import 'package:assignment1/calendar.dart' as calendar;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:fast_contacts/fast_contacts.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  static const mainColor = Color(0xFF20BF55);
  static const subColor = Color(0xFF01BAEF);
  List<Tab> tabs = [
    Tab(icon: Icon(Icons.phone, color: Colors.white)),
    Tab(
        icon: Icon(
      Icons.perm_media,
      color: subColor,
    )),
    Tab(
        icon: Icon(
      Icons.contact_page,
      color: subColor,
    )),
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController.addListener(
      () {
        if (!_tabController.indexIsChanging) {
          setState(() {
            if (_tabController.index == 0) {
              tabs = [
                Tab(icon: Icon(Icons.phone, color: Colors.white)),
                Tab(
                    icon: Icon(
                  Icons.perm_media,
                  color: subColor,
                )),
                Tab(
                    icon: Icon(
                  Icons.contact_page,
                  color: subColor,
                )),
              ];
            } else if (_tabController.index == 1) {
              tabs = [
                Tab(icon: Icon(Icons.phone, color: mainColor)),
                Tab(
                    icon: Icon(
                  Icons.perm_media,
                  color: Colors.white,
                )),
                Tab(
                    icon: Icon(
                  Icons.contact_page,
                  color: subColor,
                )),
              ];
            } else {
              tabs = [
                Tab(icon: Icon(Icons.phone, color: mainColor)),
                Tab(
                    icon: Icon(
                  Icons.perm_media,
                  color: mainColor,
                )),
                Tab(
                    icon: Icon(
                  Icons.contact_page,
                  color: Colors.white,
                )),
              ];
            }
          });
        }
      },
    );
    return MaterialApp(
        home: Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: [
          phone_nums.PhoneNums(),
          gallery.Gallery(),
          calendar.Calendar(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: tabs,
          unselectedLabelColor: Color(0xFF01BAEF),
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF20BF55), Color(0xFF01BAEF)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              color: Colors.redAccent),
        ),
      ),
    ));
  }
}
