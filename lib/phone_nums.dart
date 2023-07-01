import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:url_launcher/url_launcher_string.dart';


import 'package:flutter/foundation.dart';

class PhoneNums extends StatefulWidget {
  PhoneNums({Key? key}) : super(key: key);



  @override
  _PhoneNums createState() => _PhoneNums(); // State 생성.
}

class _PhoneNums extends State<PhoneNums> {
  @override
  void initState() {
    super.initState();
    getPhones();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: Scaffold(
        body: Container(
          height: double.infinity,
          child: FutureBuilder(
            future: getContacts(),

            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(
                  child:
                      SizedBox(height: 50, child: CircularProgressIndicator()),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Contact contact = snapshot.data[index];
                    return Column(children: [
                      ListTile(
                        leading: const CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((contact.phones).toString()),
                          ],
                        ),
                        onTap: () async {
                          await showDialog(
                              context: context,
                              builder: (context) {
                                return Center(
                                    child: SizedBox(
                                      height:240,
                                      child: Scaffold(
                                        appBar: AppBar(
                                          leading: const CircleAvatar(
                                            radius: 20,
                                            child: Icon(Icons.person),
                                          ),
                                          title: Text(contact.displayName),
                                        ),
                                        body: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                                MaterialButton(
                                                  onPressed: () {
                                                    makePhoneCall((contact.phones).toString());
                                                    },
                                                  shape: CircleBorder(),
                                                  child: Icon(
                                                    Icons.phone,
                                                    size: 20,
                                                  ),
                                                  color: Colors.greenAccent,
                                                  textColor: Colors.white,
                                                ),
                                                MaterialButton(
                                                  onPressed: () {},
                                                  shape: CircleBorder(),
                                                  child: Icon(
                                                    Icons.message,
                                                    size: 20,
                                                  ),
                                                  color: Colors.greenAccent,
                                                  textColor: Colors.white,
                                                ),
                                                MaterialButton(
                                                  onPressed: () {},
                                                  shape: CircleBorder(),
                                                  child: Icon(
                                                    Icons.videocam,
                                                    size: 20,
                                                  ),
                                                  color: Colors.greenAccent,
                                                  textColor: Colors.white,
                                                ),
                                                MaterialButton(
                                                  onPressed: () {},
                                                  shape: CircleBorder(),
                                                  child: Icon(
                                                    Icons.info,
                                                    size: 20,
                                                  ),
                                                  color: Colors.greenAccent,
                                                  textColor: Colors.white,
                                            ),
                                          ],
                                      ),
                                    ),
                                  ),
                                  );
                              });
                        },
                      ),
                      const Divider()
                    ]);
                  });
            },
          ),
        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;

    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      return await FastContacts.allContacts;
    }
    return [];
  }
  getPhones() async {
    bool isGranted = await Permission.phone.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.phone.request().isGranted;
    }
    return [];
  }

  void makePhoneCall(String url) async {
    String parsedUrl = url.substring(1, url.length - 1);
    if (await canLaunchUrlString('tel:$parsedUrl')) {
      await launchUrlString('tel:$parsedUrl');
    }
    else {
      throw 'cannot call';
    }
  }

}
