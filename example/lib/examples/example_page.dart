import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_image/power_image.dart';

import 'example_tools.dart';

class ExamplePage extends StatefulWidget {
  final String renderingType;
  // final List<ExampleSrc> testOptions;
  const ExamplePage(this.renderingType, {Key? key}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  List<ExampleSrc> testOptions = [];

  @override
  void initState() {
    super.initState();
    imageCache!.maximumSizeBytes = 30 << 20;
    // //file
    // ExampleTool.getLocalImages(widget.renderingType).then((value){
    //     testOptions = value;
    //     setState(() {
    //
    //     });
    // });

    //jpgList > 300 个
    ExampleTool.getWebpList(widget.renderingType).then((value) {
      testOptions = value;
      setState(() {

      });
    });

    //flutter asset
    // testOptions = ExampleTool.getFlutterAssets(widget.renderingType);

    //混合场景
    // testOptions =
    //     ExampleTool.exampleOptionsWithRenderType(widget.renderingType);
  }

  Widget itemWithOptions(ExampleSrc options) {
    Widget image;
    //各种外观使用一下
    if (options.imageType == imageTypeNetwork) {
      image = PowerImage.network(options.src!,
          fit: BoxFit.contain,
          width: 250,
          height: 250,
          imageWidth: options.imageWidth,
          imageHeight: options.imageHeight,
          renderingType: options.renderingType, errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return Text(error.toString());
      });
    } else if (options.imageType == imageTypeNativeAssert) {
      image = PowerImage.nativeAsset(
        options.src!,
        fit: BoxFit.contain,
        width: 250,
        height: 250,
        imageWidth: options.imageWidth,
        imageHeight: options.imageHeight,
        renderingType: options.renderingType,
      );
    } else if (options.imageType == imageTypeAssert) {
      image = PowerImage.asset(
        options.src!,
        fit: BoxFit.contain,
        width: 250,
        height: 250,
        imageWidth: options.imageWidth,
        imageHeight: options.imageHeight,
        renderingType: options.renderingType,
      );
    } else if (options.imageType == imageTypeFile) {
      image = PowerImage.file(
        options.src!,
        fit: BoxFit.contain,
        width: 250,
        height: 250,
        imageWidth: options.imageWidth,
        imageHeight: options.imageHeight,
        renderingType: options.renderingType,
      );
    } else {
      image = Container();
    }

    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ExamplePage(widget.renderingType);
        }));
      },
      child: Stack(
        children: [
          Container(
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.black],
              )),
              child: image),
          // options.imageType == imageTypeNetwork
          //     ? Positioned(
          //         child: Image.network(
          //           options.src,
          //           width: 100,
          //           height: 100,
          //         ),
          //         top: 0,
          //         right: 0,
          //       )
          //     : Container(),
          // Positioned(
          //   child: Text(
          //     options.toString(),
          //     style: TextStyle(fontSize: 12),
          //     softWrap: true,
          //   ),
          //   left: 0,
          //   top: 0,
          //   right: 0,
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.renderingType),
      ),
      body: GridView.builder(
        cacheExtent: 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return itemWithOptions(testOptions[index]);
        },
        itemCount: testOptions.length,
      ),
    );
  }
}
