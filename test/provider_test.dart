import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_Image_platform_channel.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image/src/common/power_image_request.dart';
import 'package:power_image/src/external/power_external_image_provider.dart';
import 'package:power_image/src/texture/power_texture_image_provider.dart';
import 'package:power_image_ext/power_image_ext.dart';

import 'test_utils.dart';

void main() {
  PowerImagePlatformChannel? platformChannel =
      PowerImageLoader.instance.channel.impl as PowerImagePlatformChannel?;
  final Map<String, List<MethodCall>> calls = <String, List<MethodCall>>{};
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    platformChannel!.methodChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      calls.putIfAbsent(methodCall.method, () {
        return <MethodCall>[];
      });

      calls[methodCall.method]!.add(methodCall);
      return [{}];
    });

    MethodChannel(platformChannel.eventChannel.name)
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'listen':
        case 'cancel':
        default:
          return null;
      }
    });

    PowerImageLoader.instance
        .setup(PowerImageSetupOptions(renderingTypeTexture));
  });

  group('options_test', () {
    setUp(() {});

    test('factory', () {
      // texture
      final PowerImageRequestOptions textureOptions = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider =
          PowerImageProvider.options(textureOptions);
      expect(textureProvider.runtimeType == PowerTextureImageProvider, true);

      // external
      final PowerImageRequestOptions externalOptions = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeExternal);
      PowerImageProvider externalProvider =
          PowerImageProvider.options(externalOptions);
      expect(externalProvider.runtimeType == PowerExternalImageProvider, true);

      // renderingType null
      final PowerImageRequestOptions renderingTypeNullOptions =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: null);
      PowerImageProvider renderingTypeNullProvider =
          PowerImageProvider.options(renderingTypeNullOptions);
      expect(renderingTypeNullProvider.runtimeType == PowerTextureImageProvider,
          true);

      // renderingType unknown
      final PowerImageRequestOptions testRenderingTypeOptions =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: 'testRenderingType');
      expect(() {
        PowerImageProvider.options(testRenderingTypeOptions);
      }, throwsA(isA<AssertionError>()));
    });

    test('==', () {
      // texture
      final PowerImageRequestOptions textureOptions1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider1 =
          PowerImageProvider.options(textureOptions1);

      final PowerImageRequestOptions textureOptions2 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider2 =
          PowerImageProvider.options(textureOptions2);

      expect(textureProvider2 == textureProvider1, true);

      // external
      final PowerImageRequestOptions externalOptions1 =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: renderingTypeExternal);
      PowerImageProvider externalProvider1 =
          PowerImageProvider.options(externalOptions1);

      final PowerImageRequestOptions externalOptions2 =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: renderingTypeExternal);
      PowerImageProvider externalProvider2 =
          PowerImageProvider.options(externalOptions2);

      expect(externalProvider1 == externalProvider2, true);
    });

    test('!=', () {
      // texture
      final PowerImageRequestOptions textureOptions1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider1 =
          PowerImageProvider.options(textureOptions1);

      //same src different image size
      final PowerImageRequestOptions textureOptions2 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 101.0,
          imageHeight: 100.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider2 =
          PowerImageProvider.options(textureOptions2);

      expect(textureProvider2 == textureProvider1, false);

      // external
      final PowerImageRequestOptions externalOptions1 =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: renderingTypeExternal);
      PowerImageProvider externalProvider1 =
          PowerImageProvider.options(externalOptions1);

      final PowerImageRequestOptions externalOptions2 =
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 101.0,
              imageHeight: 101.0,
              renderingType: renderingTypeExternal);
      PowerImageProvider externalProvider2 =
          PowerImageProvider.options(externalOptions2);

      expect(externalProvider1 == externalProvider2, false);

      expect(externalProvider1 == textureProvider1, false);
    });

    test('load_success', () async {
      final PowerImageRequestOptions textureOptions1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider1 =
          PowerImageProvider.options(textureOptions1);

      final ImageStreamCompleter completer =
          textureProvider1.load(textureProvider1, null);
      expect(completer.runtimeType == OneFrameImageStreamCompleter, true);

      final int textureId = 233;
      final int width = 1;
      final int height = 2;
      completer.addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) {
            expect(image.runtimeType == PowerTextureImageInfo, true);
            PowerTextureImageInfo textureImageInfo = image as PowerTextureImageInfo;
            expect(textureImageInfo.image.width == 1, true);
            expect(textureImageInfo.image.height == 1, true);
            expect(textureImageInfo.textureId == textureId, true);
            expect(textureImageInfo.width == width, true);
            expect(textureImageInfo.height == height, true);
      }));

      Map mockCompleteMap = {
        'eventName': 'onReceiveImageEvent',
        'uniqueKey': PowerImageLoader.completers.keys.toList()[0],
        'success': true,
        'textureId': textureId,
        'width': width,
        'height': height
      };

      ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
        platformChannel!.eventChannel.name,
        platformChannel.eventChannel.codec
            .encodeSuccessEnvelope(mockCompleteMap),
        (_) {},
      );
      await Future.delayed(const Duration(milliseconds: 500), (){});
    });

    test('load_multiFrame_success', () async {
      final PowerImageRequestOptions textureOptions1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      PowerImageProvider textureProvider1 =
      PowerImageProvider.options(textureOptions1);

      final ImageStreamCompleter? completer = imageCache!.putIfAbsent(textureProvider1, ()  {
        return textureProvider1.load(textureProvider1, null);
      });
      // final ImageStreamCompleter completer =
      // textureProvider1.load(textureProvider1, null);
      expect(completer.runtimeType == OneFrameImageStreamCompleter, true);
      final int textureId = 233;
      final int width = 1;
      final int height = 2;

      ImageStreamListener listener = ImageStreamListener((ImageInfo image, bool synchronousCall) {
        expect(image.runtimeType == PowerTextureImageInfo, true);
        PowerTextureImageInfo textureImageInfo = image as PowerTextureImageInfo;
        expect(textureImageInfo.image.width == 1, true);
        expect(textureImageInfo.image.height == 1, true);
        expect(textureImageInfo.textureId == textureId, true);
        expect(textureImageInfo.width == width, true);
        expect(textureImageInfo.height == height, true);
      });

      completer?.addListener(listener);

      Map mockCompleteMap = {
        'eventName': 'onReceiveImageEvent',
        'uniqueKey': PowerImageLoader.completers.keys.toList()[0],
        'success': true,
        'textureId': textureId,
        '_multiFrame': true,
        'width': width,
        'height': height
      };

      ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
        platformChannel!.eventChannel.name,
        platformChannel.eventChannel.codec
            .encodeSuccessEnvelope(mockCompleteMap),
            (_) {},
      );

      await Future.delayed(const Duration(milliseconds: 500), (){
        completer?.removeListener(listener);
        expect(imageCache!.containsKey(textureProvider1) == true, true);
        Future.microtask(() {
          expect(imageCache!.containsKey(textureProvider1) == false, true);
        });
      });
    });

    test('load_error', () {
      final PowerImageRequestOptions textureOptions1 = PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: renderingTypeTexture);

      FlutterError.onError = (FlutterErrorDetails details) {
        throw Error();
      };

      PowerImageProvider textureProvider1 =
          PowerImageProvider.options(textureOptions1);

      final ImageStreamCompleter completer =
          textureProvider1.load(textureProvider1, null);
      expect(completer.runtimeType == OneFrameImageStreamCompleter, true);

      final Map mockCompleteMap = {
        'eventName': 'onReceiveImageEvent',
        'uniqueKey': PowerImageLoader.completers.keys.toList()[0],
        'success': false,
        'textureId': 0
      };

      completer.addListener(
          ImageStreamListener((ImageInfo image, bool synchronousCall) {},
              onError: (dynamic exception, StackTrace? stackTrace) {
        expect(exception.runtimeType == PowerImageLoadException, true);
        PowerImageLoadException powerImageLoadException = exception;
        expect(mapEquals(powerImageLoadException.nativeResult, mockCompleteMap),
            true);
      }));

      ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
        platformChannel!.eventChannel.name,
        platformChannel.eventChannel.codec
            .encodeSuccessEnvelope(mockCompleteMap),
        (_) {},
      );
    });
  });

  test('PowerExternalImageProvider', () {
    PowerExternalImageProvider provider =
        PowerExternalImageProvider(testRequestOptions());

    expect(
        () => provider.createImageInfo({
              'handle': 0,
              'length': -1,
              'width': 0,
              'height': 0,
              'rowBytes': 0
            }),
        throwsA(isA<ArgumentError>()));
  });

  test('PowerTextureImageProvider', () {
    PowerTextureImageProvider provider =
        PowerTextureImageProvider(testRequestOptions());
    PowerImageRequest request = PowerImageRequest.create(testRequestOptions());
    provider.dispose();

    expect(
      calls['releaseImageRequests'],
      <Matcher>[
        isMethodCall('releaseImageRequests', arguments: [request.encode()])
      ],
    );
  });
}
