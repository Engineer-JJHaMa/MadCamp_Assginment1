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
      home:
      FutureBuilder(
        future: getContacts(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child:
              SizedBox(height: 50, child: CircularProgressIndicator()),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {},
              ),
              title: Text('Contact'),
              centerTitle: true,
              actions: [
                IconButton(
                  onPressed: !snapshot.hasData ? null : () {
                    showSearch(context: context, delegate: Search(snapshot.data));
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
          );
        }
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


class Search extends SearchDelegate<Contact> {

  // x 버튼 : 검색 query 초기화
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

  // <- 버튼: 창 닫기
  @override
  Widget buildLeading(BuildContext context){
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
    );
  }

  // 검색 결과 띄우기(함수 호출 시 전체 덮는 창)
  @override
  String selectedResult = '';
  // 최근 query 저장
  List<String> recentList = ["tmp1", "tmp2"];
  // 전화번호부 전체 리스트
  List<Contact> contact = [];
  List<Contact> p = [];
  Search(this.p){
    contact = p;
  }
  Widget buildResults(BuildContext context){
    return Container(
      child: Center(
        child: Text(selectedResult)
,      ),
    );
  }

  // contact 리스트에서 검색해서 반환
  @override
  Widget buildSuggestions(BuildContext context){
    List<Contact> suggestionList = [];
    query.isEmpty
        ? suggestionList = contact
        : suggestionList.addAll(
          contact.where(
            (element) => element.displayName.toString().contains(query),
    ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index){
        return ListTile(
          title: Text(
            suggestionList[index].displayName.toString(),
          ),
          onTap: (){
            selectedResult = suggestionList[index].toString();
            showResults(context);
          },
        );
      },
    );
  }
}