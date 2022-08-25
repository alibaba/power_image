import 'dart:convert';

import 'package:power_image/power_image.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:power_image_example/file/file_tool.dart';

class ExampleTool {
  static PowerImageRequestOptions optionsFromExampleSrc(ExampleSrc exampleSrc) {
    return PowerImageRequestOptions(
        src: PowerImageRequestOptionsSrcNormal(src: exampleSrc.src!),
        renderingType: exampleSrc.renderingType,
        imageType: exampleSrc.imageType!,
        imageWidth: exampleSrc.imageWidth,
        imageHeight: exampleSrc.imageHeight);
  }

  static List<ExampleSrc> exampleOptionsWithRenderType(String renderingType) {
    return baseOptions.map((ExampleSrc element) {
      return ExampleSrc(
          src: element.src,
          imageType: element.imageType,
          renderingType: renderingType);
    }).toList();
  }

  static Future<List<ExampleSrc>> getWebpList(String renderingType) async {
    List<ExampleSrc> options = [];

    String gifStr = await rootBundle.loadString('assets/gif_list.json');
    List<dynamic> gifList = json.decode(gifStr);
    for (var e in gifList) {
      options.add(ExampleSrc(
          src: e,
          imageType: imageTypeNetwork,
          renderingType: renderingType,
          imageWidth: 100,
          imageHeight: 100));
    }

    String str = await rootBundle.loadString('assets/jpg_list.json');
    List<dynamic> jsonList = json.decode(str);
    for (var e in jsonList) {
      options.add(ExampleSrc(
          src: e,
          imageType: imageTypeNetwork,
          renderingType: renderingType,
          imageWidth: 100,
          imageHeight: 100));
    }


    return options;
  }

  static List<ExampleSrc> getFlutterAssets(String renderingType) {
    return [
      ExampleSrc(
          src: 'assets/images/flutter_asset_lena_png.png',
          imageType: imageTypeAsset,
          renderingType: renderingType,
          imageWidth: 100,
          imageHeight: 100),
      ExampleSrc(
          src: 'assets/images/flutter_asset_lena_jpg.jpg',
          imageType: imageTypeAsset,
          renderingType: renderingType,
          imageWidth: 100,
          imageHeight: 100)
    ];
  }

  static Future<List<ExampleSrc>> getLocalImages(String renderingType) async {
    //测试本地图前先存一张本地图
    await ExampleFileManager.writeImage();

    return [
      ExampleSrc(
          src: ExampleFileManager.imgFilePath,
          imageType: imageTypeFile,
          renderingType: renderingType,
          imageWidth: 100,
          imageHeight: 100)
    ];
  }

  static List<ExampleSrc> baseOptions = [
    ExampleSrc(
      src:
          'https://img.alicdn.com/imgextra/i3/O1CN01dI9bg11Oc5uEpLey2_!!6000000001725-2-tps-1200-1037.png', //TODO
      imageType: imageTypeNetwork,
    ),
    ExampleSrc(
      src:
          'https://img.alicdn.com/imgextra/i1/O1CN01cP35u123jmnydAhPy_!!6000000007292-49-tps-1200-1037.webp', //TODO
      imageType: imageTypeNetwork,
    ),
    ExampleSrc(
      src:
          'https://img.alicdn.com/imgextra/i4/O1CN01YgRvqU1SaxO12YlD2_!!6000000002264-0-tps-1200-1037.jpg', //TODO
      imageType: imageTypeNetwork,
    ),
    ExampleSrc(
      src:
          'https://gw.alicdn.com/imgextra/i1/O1CN01BO0RgX1Wjta3jJ6PC_!!6000000002825-49-tps-300-225.webp', //TODO
      imageType: imageTypeNetwork,
    ),
    ExampleSrc(
        src:
            'https://gw.alicdn.com/imgextra/i2/O1CN01brPoTe1uIv1hxvtY1_!!6000000006015-2-tps-2250-216.png', //TODO
        imageType: imageTypeNetwork,
        imageWidth: 225,
        imageHeight: 21),
    ExampleSrc(
        src:
            'https://gw.alicdn.com/imgextra/i4/O1CN01CAshbO1mHzIStgf9w_!!6000000004930-2-tps-318-108.png', //TODO
        imageType: imageTypeNetwork,
        imageWidth: 2318,
        imageHeight: 108),

    // ExampleSrc(
    //   src:
    //       'http://gw.alicdn.com/bao/uploaded/TB1ZLSwyhn1gK0jSZKPSutvUXXa.jpg_460x460q90_.heic', //TODO
    //   imageType: imageTypeNetwork,
    // ),
    ExampleSrc(
      src: 'lena_jpg',
      imageType: imageTypeNativeAsset,
    ),
    // ExampleSrc(
    //     src:
    //         'https://img.alicdn.com/imgextra/i4/O1CN012tn3IT1VxnzcPkMc7_!!6000000002720-1-tps-300-240.gif',
    //     imageType: imageTypeNetwork,
    //     imageWidth: 300,
    //     imageHeight: 240),
    ExampleSrc(
        src:
            'https://gw.alicdn.com/imgextra/i2/O1CN018TNbZw1gRi0uCr1nc_!!6000000004139-54-tps-300-240.apng',
        imageType: imageTypeNetwork,
        imageWidth: 300,
        imageHeight: 240),
    ExampleSrc(
        src:
            'https://img.alicdn.com/imgextra/i1/O1CN01BO0RgX1Wjta3jJ6PC_!!6000000002825-49-tps-300-225.webp',
        imageType: imageTypeNetwork,
        imageWidth: 300,
        imageHeight: 255),
  ];
}

class ExampleSrc {
  ExampleSrc({
    this.src,
    this.imageType,
    this.renderingType,
    this.imageWidth,
    this.imageHeight,
    this.package,
  });

  final String? src;
  final String? imageType;
  final String? renderingType;
  final double? imageWidth;
  final double? imageHeight;
  final String? package;

  @override
  String toString() {
    return 'src:$src\nimageType: $imageType\nrenderingType: $renderingType\nimageWidth:$imageWidth,imageHeight:$imageHeight,package:$package';
  }
}
