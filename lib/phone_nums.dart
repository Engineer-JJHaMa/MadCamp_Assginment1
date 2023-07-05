import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/foundation.dart';

import './components/contact_info_page.dart' as contact_info_page;
import './style.dart';

class PhoneNums extends StatefulWidget {
  PhoneNums({Key? key}) : super(key: key);

  @override
  _PhoneNums createState() => _PhoneNums(); // State 생성.
}

class _PhoneNums extends State<PhoneNums> {
  @override
  void initState() {
    super.initState();
    getPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: getPermission(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: SizedBox(height: 50, child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: contactErrMsgPadding,
              child: Text(
                'Error: ${snapshot.error}',
                style: contactErrMsgFontSize,
              ),
            );
          } else {
            return Scaffold(
              backgroundColor: lightColor,
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: contactAppBarDecoration,
                ),
                leading: IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {},
                ),
                title: Text('Contact'),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: !snapshot.hasData ? null : () =>
                      showSearch(
                        context: context,
                        delegate: Search(snapshot.data)
                      ),
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
              body: Container(
                height: contactListHeight,
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    Contact contact = snapshot.data[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: mainColor,
                            radius: 20,
                            child: Icon(
                              Icons.person,
                              color: lightColor,
                            ),
                          ),
                          title: Text(contact.displayName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((contact.phones).toString()),
                            ],
                          ),
                          onTap: () => showContactInfo(context, contact),
                        ),
                      const Divider(color: darkColor,),
                      ],
                    );
                  }
                ),
              ),
            );
          }
        }
      ),
    );
  }

  Future<List<Contact>> getPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.contacts, Permission.phone, Permission.sms].request();
    if (statuses[Permission.contacts]!.isGranted) {
      return await FastContacts.allContacts;
    } else {
      openAppSettings();
      return [];
    }
  }
}

Future<void> showContactInfo(BuildContext context, Contact contact) {
  return showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: contact_info_page.ContactInfo(
          phoneNum: contact.phones.toString(),
          personName: contact.displayName.toString()
        ),
      );
    }
  );
}

class Search extends SearchDelegate<Contact> {
  // x 버튼 : 검색 query 초기화
  @override
  List<Widget> buildActions(BuildContext context) {
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
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // 검색 결과 띄우기(함수 호출 시 전체 덮는 창)
  @override
  Contact? selectedResult;
  // 최근 query 저장
  List<String> recentList = ["tmp1", "tmp2"];
  // 전화번호부 전체 리스트
  List<Contact> contact = [];
  List<Contact> p = [];
  Search(this.p) {
    contact = p;
  }
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult.toString()),
      ),
    );
  }

  // contact 리스트에서 검색해서 반환
  @override
  Widget buildSuggestions(BuildContext context) {
    List<Contact> suggestionList = [];
    query.isEmpty
        ? suggestionList = contact
        : suggestionList.addAll(contact.where(
            (element) => element.displayName.toString().contains(query),
          ));

    @override
    void showResults(BuildContext context, int index) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => contact_info_page.ContactInfo(
              personName: suggestionList[index].displayName.toString(),
              phoneNum: suggestionList[index].phones.toString(),
            ),
          ));
    }

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList[index].displayName.toString(),
          ),
          onTap: () {
            selectedResult = suggestionList[index];
            showContactInfo(context, suggestionList[index]);
            // showResults(context, index);
          },
        );
      },
    );
  }
}
