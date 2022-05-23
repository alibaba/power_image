import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_Image_platform_channel.dart';
import 'package:power_image/src/common/power_image_request.dart';

void main() {
  //test initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  group('options_test', () {
    setUp(() {});

    test('constructors', () {
      PowerImageRequestOptions options_network = PowerImageRequestOptions.network(
          'network',
          renderingType: renderingTypeExternal,
          imageWidth: 100,
          imageHeight: 101);
      expect(options_network.src == PowerImageRequestOptionsSrcNormal(src: 'network'),
          true);
      expect(options_network.imageWidth == 100, true);
      expect(options_network.imageHeight == 101, true);
      expect(options_network.renderingType == renderingTypeExternal, true);
      expect(options_network.imageType == imageTypeNetwork, true);

      PowerImageRequestOptions options_nativeAsset = PowerImageRequestOptions.nativeAsset(
          'nativeAsset',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(options_nativeAsset.src == PowerImageRequestOptionsSrcNormal(src: 'nativeAsset'),
          true);
      expect(options_nativeAsset.imageWidth == 100, true);
      expect(options_nativeAsset.imageHeight == 101, true);
      expect(options_nativeAsset.renderingType == renderingTypeTexture, true);
      expect(options_nativeAsset.imageType == imageTypeNativeAssert, true);

      PowerImageRequestOptions options_asset = PowerImageRequestOptions.asset(
          'asset', package: 'package',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(options_asset.src == PowerImageRequestOptionsSrcAsset(src: 'asset', package: 'package'),
          true);
      expect(options_asset.imageWidth == 100, true);
      expect(options_asset.imageHeight == 101, true);
      expect(options_asset.renderingType == renderingTypeTexture, true);
      expect(options_asset.imageType == imageTypeAssert, true);

      PowerImageRequestOptions options_file = PowerImageRequestOptions.file(
          'file',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(options_file.src == PowerImageRequestOptionsSrcNormal(src: 'file'),
          true);
      expect(options_file.imageWidth == 100, true);
      expect(options_file.imageHeight == 101, true);
      expect(options_file.renderingType == renderingTypeTexture, true);
      expect(options_file.imageType == imageTypeFile, true);
    });

    test('equal_hashCode', () {
      PowerImageRequestOptions options_1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');

      PowerImageRequestOptions options_2 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');

      Map<PowerImageRequestOptions, dynamic> testMap =
          <PowerImageRequestOptions, dynamic>{};
      testMap[options_1] = 'options_1';
      testMap[options_2] = 'options_2';
      expect(testMap.length == 1, true);
      expect(testMap[options_1] == 'options_2', true);

      PowerImageRequestOptions options_3 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue_2"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType');
      testMap[options_3] = 'options_3';
      expect(testMap.length == 2, true);
      expect(testMap[options_3] == 'options_3', true);
      expect(testMap[options_2] == 'options_2', true);
    });
  });
}
