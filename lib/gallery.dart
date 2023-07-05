import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assignment1/gallery_picture.dart' as gallery_picture;

import './components/floatingbutton.dart';
import './style.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
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
        backgroundColor: lightColor,
        floatingActionButton: TwoButtons(
          _pickImg, _initImg, 
          Icon(Icons.add, color: lightColor),
          Icon(Icons.remove, color: lightColor),
          "사진 추가하기", "사진 전부 지우기")
        ,
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(2),
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          crossAxisCount: 3,
          children: _pickedImgs.asMap().map((i, xf) => MapEntry(i,
              Container(
                child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(child: ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => gallery_picture.GalleryPicture(
                                        imgList: _pickedImgs,
                                      ),
                                    ));
                              },
                              child: Image.file(
                                File(xf.path),
                                fit: BoxFit.cover,
                              )))),
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
              ))).values.toList(),
          // _pickedImgs.map((xf) =>

        ),
      ),
    );
  }

  void _updatePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final imglist = _pickedImgs.map((xf) => xf.path).toList();
    await prefs.remove('paths');
    prefs.setStringList('paths', imglist);
  }

  Future<void> getImgList() async {
    final prefs = await SharedPreferences.getInstance();
    try{
      var imglist = prefs.getStringList('paths') ?? [];
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
