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
  void initState() {
    super.initState();
    getImgList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment(
              Alignment.bottomRight.x, Alignment.bottomRight.y - 0.3),
                child: FloatingActionButton(
                  onPressed: (){_pickImg();},
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                ),
              ),
          Align(
            alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                onPressed: (){
                   _initImg();
                },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete),
            ),
          ),
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
                          debugPrint('gfdgdhgfd');
                          _dltImg(xf);
                        });
                      },
                      child: const Icon(Icons.cancel, color: Colors.red),
                    )
                  )
                ]
              ),
            )).toList(),


      ),
    );
  }



  // initial state
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
    if(images != null) {
      setState(() {
        _pickedImgs.addAll(images);
      });
      var prefs = await SharedPreferences.getInstance();
      var imglist = _pickedImgs.map((xf) => xf.path).toList();
      await prefs.remove('paths');
      prefs.setStringList('paths', imglist);
    }
  }

  void _dltImg(data) async {
    _pickedImgs.remove(data);
    var prefs = await SharedPreferences.getInstance();
    var imglist = _pickedImgs.map((xf) => xf.path).toList();
    await prefs.remove('paths');
    prefs.setStringList('paths', imglist);
  }

  void _initImg() async {
    setState(() {
      debugPrint('init is executed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      _pickedImgs.clear();
    });
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('paths');
  }
}

