import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  static const mainColor = Color.fromARGB(255, 149, 150, 208);
  static const subColor = Color.fromARGB(255, 203, 144, 191);
  static const lightColor = Color(0xFFF8FAFF);
  static const darkColor = Color(0xFF353866);
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImgs = [];

  @override
  void initState() {
    super.initState();
    getImgList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          visible: true,
          curve: Curves.bounceIn,
          backgroundColor: darkColor,
          // childMargin: const EdgeInsets.all(0),
          gradient: LinearGradient(
            colors: [mainColor, subColor],
            stops: [0, 0.75],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          gradientBoxShape: BoxShape.circle,
          childrenButtonSize: Size(56, 56),
          children: [
            SpeedDialChild(
              child: Container(
                width: 56,
                height: 56,
                child: const Icon(Icons.add, color: lightColor),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [mainColor, subColor],
                    stops: [0, 0.75],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              label: "사진 추가하기",
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: lightColor,
                  fontSize: 13.0),
              backgroundColor: mainColor,
              labelBackgroundColor: mainColor,
              onTap: () {
                _pickImg();
              }),
            SpeedDialChild(
              child: Container(
                  width: 56,
                  height: 56,
                  // padding: EdgeInsets.all(0),
                  child: const Icon(Icons.remove, color: lightColor),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [mainColor, subColor],
                      stops: [0, 0.75],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              label: "사진 전부 지우기",
              backgroundColor: mainColor,
              labelBackgroundColor: mainColor,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, color: lightColor, fontSize: 13.0),
              onTap: () {
                _initImg();
              },
            )
          ],
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(2),
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 3,
          children: _pickedImgs.map((xf) => Container(
            child: Stack(
              fit: StackFit.expand,
              children: [Image.file(
                File(xf.path),
                fit: BoxFit.cover,
                ),
                Positioned(
                  right: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _dltImg(xf);
                      });
                    },
                    child: const Icon(Icons.cancel, color: mainColor),
                  )
                )
              ]
            ),
          )).toList(),
        ),
      ),
    );
  }


  void _updatePreference() async {
    var prefs = await SharedPreferences.getInstance();
    var imglist = _pickedImgs.map((xf) => xf.path).toList();
    await prefs.remove('paths');
    prefs.setStringList('paths', imglist);
  }



  Future<void> getImgList() async {
    var prefs = await SharedPreferences.getInstance();
    try{
      var imglist = prefs.getStringList('paths') ?? [];
      for(final line in imglist){
      }
      var images = imglist.map((path) => XFile(path)).toList();
      setState(() {
        _pickedImgs = images;
      });
    }catch(e){debugPrint('error: $e');}
  }

  Future<void> _pickImg() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if(images != null) {
      setState(() {
        _pickedImgs.addAll(images);
      });
      _updatePreference();
    }
  }

  void _dltImg(data) async {
    _pickedImgs.remove(data);
    _updatePreference();
  }

  void _initImg() async {
    setState(() {
      _pickedImgs.clear();
    });
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('paths');
  }
}

