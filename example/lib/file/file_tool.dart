import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class ExampleFileManager {

  static String? imgFilePath;

  static Future<File> writeImage() async {
    final file = await _localFile;
    imgFilePath = file.path;
    final byteData = await rootBundle.load('assets/images/flutter_asset_lena_jpg.jpg');
    return file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/flutter_asset_lena_jpg.jpg');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}