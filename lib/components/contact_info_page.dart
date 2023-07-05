import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../style.dart';

class ContactInfo extends StatefulWidget {
  late final String phoneNum;
  late final String personName;
  ContactInfo({Key? key, required this.phoneNum, required this.personName})
    : super(key: key);

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: AppBar(
            flexibleSpace: Container(
              decoration: contactAppBarDecoration,
            ),
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: subColor,
              onPressed: () => Navigator.pop(context),
            ),
          )
        ),
        body: Container(
          width: double.infinity,
          // height: double.infinity,
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20,bottom: 10),
                child: Text(
                  widget.personName,
                  style: DefaultTextStyle.of(context)
                    .style
                    .apply(fontSizeFactor: 2.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Text(widget.phoneNum),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    elevation: 0,
                    onPressed: () {
                      makePhoneCall(widget.phoneNum);
                    },
                    shape: CircleBorder(),
                    color: subColor,
                    textColor: lightColor,
                    child: Icon(Icons.phone, size: 20,),
                  ),
                  MaterialButton(
                    elevation: 0,
                    onPressed: () {
                      makeSms((widget.phoneNum).toString());
                    },
                    shape: CircleBorder(),
                    color: subColor,
                    textColor: lightColor,
                    child: Icon(Icons.message, size: 20,),
                  ),
                  MaterialButton(
                    elevation: 0,
                    onPressed: () {},
                    shape: CircleBorder(),
                    color: subColor,
                    textColor: lightColor,
                    child: Icon(Icons.videocam, size: 20,),
                  ),
                ],
              )
            ]
          )
        )
      ),
    );
  }

  void makePhoneCall(String url) async {
    String parsedUrl = url.substring(1, url.length - 1);
    if (await canLaunchUrlString('tel:$parsedUrl')) {
      await launchUrlString('tel:$parsedUrl');
    } else {
      throw 'cannot call';
    }
  }

  void makeSms(String url) async {
    String parsedUrl = url.substring(1, url.length - 1);
    if (await canLaunchUrlString('sms:$parsedUrl')) {
      await launchUrlString('sms:$parsedUrl');
    } else {
      throw 'cannot send message';
    }
  }
}
