import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';


class ContactInfo extends StatefulWidget {

  String phoneNum = '';
  String personName = '';
  ContactInfo ({ Key? key, required this.phoneNum, required this.personName }) : super(key: key);

  @override
  State<ContactInfo> createState() => _ContactInfoState();

}

class _ContactInfoState extends State<ContactInfo> {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                    }
                ),
              )
          ),
          body: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 20, top: 20),
                  child: Text(widget.personName, style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),),
                ),
                Text(widget.phoneNum),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        makePhoneCall(widget.phoneNum);
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
                        makeSms((widget.phoneNum).toString());
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
                  ],
                )
              ])),
    );
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