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

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin{
  static const mainColor = Color.fromARGB(255, 149, 150, 208);
  static const subColor = Color.fromARGB(255, 203, 144, 191);
  static const lightColor = Color(0xFFF8FAFF);
  static const darkColor = Color(0xFF353866);
  List<Tab> tabs = [
    Tab(icon: Icon(Icons.phone, color: lightColor)),
    Tab(icon: Icon(Icons.perm_media, color: subColor,)),
    Tab(icon: Icon(Icons.contact_page, color: subColor,)),
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
    _tabController.addListener(() {
      if(!_tabController.indexIsChanging){
        setState(() {
          if(_tabController.index == 0){
            tabs = [
              Tab(icon: Icon(Icons.phone, color: lightColor)),
              Tab(icon: Icon(Icons.perm_media, color: subColor,)),
              Tab(icon: Icon(Icons.contact_page, color: subColor,)),
            ];
          } else if(_tabController.index == 1) {
            tabs = [
              Tab(icon: Icon(Icons.phone, color: mainColor)),
              Tab(icon: Icon(Icons.perm_media, color: lightColor,)),
              Tab(icon: Icon(Icons.contact_page, color: subColor,)),
            ];
          } else {
            tabs = [
              Tab(icon: Icon(Icons.phone, color: mainColor)),
              Tab(icon: Icon(Icons.perm_media, color: mainColor,)),
              Tab(icon: Icon(Icons.contact_page, color: lightColor,)),
            ];
          }
        });
      }
    },);
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
          color: lightColor,
          child: TabBar(
            controller: _tabController,
            tabs: tabs,
            unselectedLabelColor: Color(0xFF01BAEF),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                  colors: [mainColor, subColor]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              color: Colors.redAccent
            ),
          ),
        ),
      )
    );
  }
}
