import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImgs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){_pickImg();},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(2),
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 3,
        children: _pickedImgs.map((xf) => Container(
          child: Image.file(
            File(xf.path),
            fit: BoxFit.cover,
            ),
        )).toList(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getImgList();
  }

  Future<void> getImgList() async {
    var prefs = await SharedPreferences.getInstance();
    try{
      var imglist = prefs.getStringList('paths') ?? [];
      for(final line in imglist){
        debugPrint('call: ' + line);
      }
      var images = imglist.map((path) => XFile(path)).toList();
      setState(() {
        _pickedImgs = images;
      });
    }catch(e){debugPrint('error: $e');}
  }

  Future<void> _pickImg() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    debugPrint('finish pick');
    if(images != null) {
      setState(() {
        _pickedImgs.addAll(images);
      });
      var prefs = await SharedPreferences.getInstance();
      var imglist = _pickedImgs.map((xf) => xf.path).toList();
      for(final line in imglist){
        debugPrint('write: ' + line);
      }
      await prefs.remove('paths');
      prefs.setStringList('paths', imglist);
    }
  }
}

