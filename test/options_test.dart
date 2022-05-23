import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';

void main() {
  //test initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  group('options_test', () {
    setUp(() {});

    test('constructors', () {
      PowerImageRequestOptions optionsNetwork = PowerImageRequestOptions.network(
          'network',
          renderingType: renderingTypeExternal,
          imageWidth: 100,
          imageHeight: 101);
      expect(optionsNetwork.src == PowerImageRequestOptionsSrcNormal(src: 'network'),
          true);
      expect(optionsNetwork.imageWidth == 100, true);
      expect(optionsNetwork.imageHeight == 101, true);
      expect(optionsNetwork.renderingType == renderingTypeExternal, true);
      expect(optionsNetwork.imageType == imageTypeNetwork, true);

      PowerImageRequestOptions optionsNativeAsset = PowerImageRequestOptions.nativeAsset(
          'nativeAsset',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(optionsNativeAsset.src == PowerImageRequestOptionsSrcNormal(src: 'nativeAsset'),
          true);
      expect(optionsNativeAsset.imageWidth == 100, true);
      expect(optionsNativeAsset.imageHeight == 101, true);
      expect(optionsNativeAsset.renderingType == renderingTypeTexture, true);
      expect(optionsNativeAsset.imageType == imageTypeNativeAssert, true);

      PowerImageRequestOptions optionsAsset = PowerImageRequestOptions.asset(
          'asset', package: 'package',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(optionsAsset.src == PowerImageRequestOptionsSrcAsset(src: 'asset', package: 'package'),
          true);
      expect(optionsAsset.imageWidth == 100, true);
      expect(optionsAsset.imageHeight == 101, true);
      expect(optionsAsset.renderingType == renderingTypeTexture, true);
      expect(optionsAsset.imageType == imageTypeAssert, true);

      PowerImageRequestOptions optionsFile = PowerImageRequestOptions.file(
          'file',
          renderingType: renderingTypeTexture,
          imageWidth: 100,
          imageHeight: 101);
      expect(optionsFile.src == PowerImageRequestOptionsSrcNormal(src: 'file'),
          true);
      expect(optionsFile.imageWidth == 100, true);
      expect(optionsFile.imageHeight == 101, true);
      expect(optionsFile.renderingType == renderingTypeTexture, true);
      expect(optionsFile.imageType == imageTypeFile, true);
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
