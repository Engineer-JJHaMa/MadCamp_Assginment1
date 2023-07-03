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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(),
          body: TabBarView(
            children: [
              phone_nums.PhoneNums(),
              gallery.Gallery(),
              calendar.Calendar(),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.blue,
            child: TabBar(tabs: const [
              Tab(icon: Icon(Icons.phone)),
              Tab(icon: Icon(Icons.perm_media)),
              Tab(icon: Icon(Icons.contact_page)),
            ])
          ),
        ),
      )
    );
  }
}
