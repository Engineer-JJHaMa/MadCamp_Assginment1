import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
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

  // getPermission() async{
  //   var status = await Permission.camera.status;
  //   if(status.isGranted){
  //     print('허락됨');
  //   } else if (status.isDenied){
  //     print('거절됨');
  //     Permission.contacts.request(); // 허락해달라고 팝업띄우는 코드
  //   }
  // }

  // @override
  // void initState(){
  //   super.initState();
  //   // getPermission();
  // }

  final ImagePicker _picker = ImagePicker();
  List<XFile> _pickedImgs = [];

  Future<void> _pickImg() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if(images != null) {
      setState(() {
        _pickedImgs = images;
      });
    }
  }
}

