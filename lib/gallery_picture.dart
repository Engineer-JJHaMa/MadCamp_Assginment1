import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'style.dart';
import 'package:carousel_slider/carousel_slider.dart';




class GalleryPicture extends StatefulWidget {
  GalleryPicture({Key? key, required this.imgList})
      : super(key: key);
  final List<XFile> imgList;
  @override
  State<GalleryPicture> createState() => _GalleryPictureState();
}

class _GalleryPictureState extends State<GalleryPicture>{

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: AppBar(
              backgroundColor: lightColor,
              elevation: 0.0,
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: subColor,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            )
        ),
        body: Column(
          children: [
            SizedBox(
            child: Stack(
              children: [
                sliderWidget(),
              ],
            )
            )
          ],
        )
      )
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
        carouselController: _controller,
        items: (widget.imgList.map((imgLink) {
          return Builder(
            builder: (context) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  File(imgLink.path),
                  fit: BoxFit.fitWidth,
                ),
              );
            },
          );
        } )).toList(), options: CarouselOptions(
      height: 300,
      viewportFraction: 1.0,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 4),
      onPageChanged: (index, reason) {
        setState(() {
          _current = index;
        });
      },
    ));
  }
}