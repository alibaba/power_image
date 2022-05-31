import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:power_image_example_kotlin_swift/examples/example_gallery_preview.dart';
import 'examples/drag_overlay.dart';
import 'examples/example_decoration_image_page.dart';
import 'examples/example_page.dart';
import 'package:power_image/power_image.dart';
import 'examples/example_prefetch_page.dart';
import 'examples/image_cache_status.dart';

void main() {
  runZonedGuarded(() async {

    FlutterError.onError = (FlutterErrorDetails details) {

    };

    PowerImageBinding();
    PowerImageLoader.instance.setup(PowerImageSetupOptions(renderingTypeTexture,
        errorCallbackSamplingRate: null,
        errorCallback: (PowerImageLoadException exception) {}));
    runApp(const MyApp());
  }, (error, stackTrace) async {

  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      DragOverlay.show(
          context: context,
          view: const ImageCacheStatusWidget());
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
          title: const Text('prefetch_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ExamplePrefetchPage();
            }));
          },
        ),
        ListTile(
          title: const Text('external_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ExamplePage(renderingTypeExternal);
            }));
          },
        ),
        ListTile(
          title: const Text('texture_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ExamplePage(renderingTypeTexture);
            }));
          },
        ),
        ListTile(
          title: const Text('decoration_image'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ExampleDecorationImagePage();
            }));
          },
        ),
        ListTile(
          title: const Text('gallery'),
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
