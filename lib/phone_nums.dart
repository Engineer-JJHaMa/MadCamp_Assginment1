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
    getSms();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          title: Text('Contact'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Search());
              },
              icon: Icon(Icons.search),)
          ],
        ),
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
                                                  onPressed: () {
                                                    makeSms((contact.phones).toString());
                                                  },
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

  getSms() async {
    bool isGranted = await Permission.sms.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.sms.request().isGranted;
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
  void makeSms(String url) async {
    String parsedUrl = url.substring(1, url.length - 1);
    if (await canLaunchUrlString('sms:$parsedUrl')) {
      await launchUrlString('sms:$parsedUrl');
    }
    else {
      throw 'cannot send message';
    }
  }

}


class Search extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context){
    return <Widget>[
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close))
    ];
  }
  @override
  Widget buildLeading(BuildContext context){
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
    );
  }


  @override
  // initillize 핅요
  String selectedResult = '';
  // 최근 query 저장
  List<String> recentList = ["tmp1", "tmp2"];
  // 전화번호부
  List<String> listExample = ["elem1", "elem2"];

  Widget buildResults(BuildContext context){
    return Container(
      child: Center(
        child: Text(selectedResult)
,      ),
    );
  }
  @override
  Widget buildSuggestions(BuildContext context){
    List<String> suggestionList = [];
    query.isEmpty
        ? suggestionList = recentList
        : suggestionList.addAll(listExample.where(
        (element) => element.contains(query),
    ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index){
        return ListTile(
          title: Text(
            suggestionList[index],
          ),
          onTap: (){
            selectedResult = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}