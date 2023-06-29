import 'package:assignment1/phone_nums.dart' as phone_nums;
import 'package:assignment1/gallery.dart' as gallery;
import 'package:assignment1/tmp_tab.dart' as tmp_tab;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(),
        body: TabBarView(
          children: const [
            phone_nums.PhoneNums(),
            gallery.Gallery(),
            tmp_tab.TmpTab(),
          ],
        ),
        bottomNavigationBar: Container(
            color: Colors.blue,
            child: TabBar(tabs: const [
              Tab(icon: Icon(Icons.phone)),
              Tab(icon: Icon(Icons.perm_media)),
              Tab(icon: Icon(Icons.contact_page)),
            ])),
      ),
    ));
  }
}
