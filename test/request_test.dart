import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_image_request.dart';

void main() {
  //test initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  group('request_test', () {
    setUp(() {});

    test('constructor', () {
      PowerImageRequestOptions options_1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');

      PowerImageRequest request_1 = PowerImageRequest.create(options_1);
      expect(request_1.src == options_1.src, true);
      expect(request_1.imageType == options_1.imageType, true);
      expect(request_1.renderingType == options_1.renderingType, true);
      expect(request_1.imageWidth == options_1.imageWidth, true);
      expect(request_1.imageHeight == options_1.imageHeight, true);
    });

    test('uniqueKey()', () {
      PowerImageRequestOptions options_1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');

      PowerImageRequest request_1 = PowerImageRequest.create(options_1);

      //same request has same uniqueKey
      dynamic uniqueKey_1_1 = request_1.uniqueKey();
      dynamic uniqueKey_1_2 = request_1.uniqueKey();
      expect(uniqueKey_1_1 == uniqueKey_1_2, true);

      //same option has different request
      PowerImageRequest request_2 = PowerImageRequest.create(options_1);
      dynamic uniqueKey_2 = request_2.uniqueKey();
      expect(uniqueKey_2 == uniqueKey_1_1, true);
    });

    test('encode()', () {
      PowerImageRequestOptions options_1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');

      PowerImageRequest request_1 = PowerImageRequest.create(options_1);

      Map<String, dynamic> encode = request_1.encode()!;
      //create once
      expect(encode == request_1.encode(), true);

      expect(mapEquals(encode['src'], options_1.src.encode()), true);
      expect(encode['width'] == request_1.imageWidth, true);
      expect(encode['height'] == request_1.imageHeight, true);
      expect(encode['imageType'] == request_1.imageType, true);
      expect(encode['renderingType'] == request_1.renderingType, true);
      expect(encode['uniqueKey'] == request_1.uniqueKey(), true);
    });
  });
}
