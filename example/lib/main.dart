import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:power_image_example/examples/example_gallery_preview.dart';
import 'examples/drag_overlay.dart';
import 'examples/example_decoration_image_page.dart';
import 'examples/example_page.dart';
import 'package:power_image/power_image.dart';
import 'examples/example_prefetch_page.dart';
import 'examples/image_cache_status.dart';
import 'file/file_tool.dart';

void main() {
  runZonedGuarded(() async {
    print('PowerImageDemo_start');

    FlutterError.onError = (FlutterErrorDetails details) {
      print('PowerImageDemo_FlutterError.onError' + details.toString());
    };

    PowerImageBinding();
    PowerImageLoader.instance.setup(PowerImageSetupOptions(renderingTypeTexture,
        errorCallbackSamplingRate: null,
        errorCallback: (PowerImageLoadException exception) {}));
    runApp(MyApp());
  }, (error, stackTrace) async {
    print('PowerImageDemo_runZonedGuarded.onError' + error.toString());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerScrollView',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      DragOverlay.show(
          context: context,
          view: ImageCacheStatusWidget());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('power_image example app'),
      ),
      body: ListView(children: <Widget>[
        ListTile(
          title: Text('prefech_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExamplePrefetchPage();
            }));
          },
        ),
        ListTile(
          title: Text('external_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExamplePage(renderingTypeExternal);
            }));
          },
        ),
        ListTile(
          title: Text('texture_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExamplePage(renderingTypeTexture);
            }));
          },
        ),
        ListTile(
          title: Text('decoration_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ExampleDecorationImagePage();
            }));
          },
        ),
        ListTile(
          title: Text('gallery'),
          onTap: () async {
            ImagePicker picker = ImagePicker();
            var image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ExampleGalleryPrev(path: image.path,);
              }));
            }
          }
        )
      ]),
    );
  }
}
