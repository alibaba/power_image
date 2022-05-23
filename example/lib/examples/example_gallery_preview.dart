import 'dart:io';

import 'package:power_image/power_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExampleGalleryPrev extends StatefulWidget {
  const ExampleGalleryPrev({Key? key, this.path}) : super(key: key);

  final String? path;

  @override
  _ExampleGalleryPrevState createState() => _ExampleGalleryPrevState();
}

class _ExampleGalleryPrevState extends State<ExampleGalleryPrev> {
  @override
  Widget build(BuildContext context) {
    String path = widget.path!;
    Widget image = PowerImage.file(
      path,
      fit: BoxFit.contain,
      renderingType: renderingTypeExternal,
    );
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('preview'),
      ),
      body: Stack(
        children: [
          Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.black],
              )),
              child: image),
          Positioned(
            child: Image.file(
              File(path),
              width: 100,
              height: 100,
            ),
            top: 0,
            right: 0,
          ),
          Positioned(
            child: Text(
              path,
              style: TextStyle(fontSize: 12),
              softWrap: true,
            ),
            left: 0,
            top: 0,
            right: 0,
          ),
        ],
      ),
    );
  }
}
