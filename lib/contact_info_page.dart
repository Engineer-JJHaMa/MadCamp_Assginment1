import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactInfo extends StatefulWidget {
  String phoneNum = '';
  String personName = '';
  ContactInfo({Key? key, required this.phoneNum, required this.personName})
      : super(key: key);

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {
  static const mainColor = Color.fromARGB(255, 149, 150, 208);
  static const subColor = Color.fromARGB(255, 203, 144, 191);
  static const lightColor = Color(0xFFF8FAFF);
  static const darkColor = Color(0xFF353866);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: AppBar(
                backgroundColor: lightColor,
                elevation: 0.0,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: subColor,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )),
          body: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        widget.personName,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 2.0),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 60),
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
                          child: Icon(
                            Icons.phone,
                            size: 20,
                          ),
                          color: subColor,
                          textColor: Colors.white,
                        ),
                        MaterialButton(
                          elevation: 0,
                          onPressed: () {
                            makeSms((widget.phoneNum).toString());
                          },
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.message,
                            size: 20,
                          ),
                          color: subColor,
                          textColor: Colors.white,
                        ),
                        MaterialButton(
                          elevation: 0,
                          onPressed: () {},
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.videocam,
                            size: 20,
                          ),
                          color: subColor,
                          textColor: Colors.white,
                        ),
                      ],
                    )
                  ]))),
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
