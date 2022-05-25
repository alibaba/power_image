import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_image_platform_channel.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image_ext/image_info_ext.dart';

import 'test_utils.dart';

void main() {
  PowerImagePlatformChannel? platformChannel =
      PowerImageLoader.instance.channel.impl as PowerImagePlatformChannel?;
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();

    platformChannel!.methodChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
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
    PowerImagePlatformChannel? platformChannel =
        PowerImageLoader.instance.channel.impl as PowerImagePlatformChannel?;

    setUp(() {
      platformChannel!.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
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

    test('default_renderingType', () {
      expect(PowerImageLoader.instance.globalRenderType == renderingTypeTexture,
          true);
    });

    test('setting_renderType', () {
      PowerImageLoader.instance
          .setup(PowerImageSetupOptions(renderingTypeExternal));
      expect(
          PowerImageLoader.instance.globalRenderType == renderingTypeExternal,
          true);
    });

    test('errorCallback', () {
      PowerImageLoadException? e;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,
              errorCallback: (PowerImageLoadException exception) {
        e = exception;
      }, errorCallbackSamplingRate: 1));
      PowerImageLoadException e1 =
          PowerImageLoadException(nativeResult: {'testKey_e1': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e1);
      expect(e == e1, true);
    });

    test('errorCallbackSamplingRate', () {
      /// default
      PowerImageLoadException? e;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,
              errorCallback: (PowerImageLoadException exception) {
                e = exception;
              }));
      PowerImageLoadException e2 =
      PowerImageLoadException(nativeResult: {'testKey_e2': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e2);
      expect(e == e2, true);

      /// 0
      e = null;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,errorCallbackSamplingRate: 0,
              errorCallback: (PowerImageLoadException exception) {
                e = exception;
              }));
      PowerImageLoadException e3 =
      PowerImageLoadException(nativeResult: {'testKey_e3': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e3);
      expect(e == null, true);

      /// >1
      e = null;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,errorCallbackSamplingRate: 2,
              errorCallback: (PowerImageLoadException exception) {
                e = exception;
              }));
      PowerImageLoadException e4 =
      PowerImageLoadException(nativeResult: {'testKey_e4': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e4);
      expect(e == e4, true);

      /// 0~1
      e = null;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,errorCallbackSamplingRate: 0.001,
              errorCallback: (PowerImageLoadException exception) {
                e = exception;
              }));
      PowerImageLoadException e5 =
      PowerImageLoadException(nativeResult: {'testKey_e5': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e5);
      if (PowerImageMonitor.instance().needCallError == true) {
        expect(e == e5, true);
      }else {
        expect(e == null, true);
      }

      /// 0~1
      e = null;
      PowerImageLoader.instance.setup(
          PowerImageSetupOptions(renderingTypeExternal,errorCallbackSamplingRate: 0.999,
              errorCallback: (PowerImageLoadException exception) {
                e = exception;
              }));
      PowerImageLoadException e6 =
      PowerImageLoadException(nativeResult: {'testKey_e6': 'testValue'});
      PowerImageMonitor.instance().anErrorOccurred(e6);
      if (PowerImageMonitor.instance().needCallError == true) {
        expect(e == e6, true);
      }else {
        expect(e == null, true);
      }

    });

    group('Precache API', () {
      testWidgets('prefetchNetworkImage', (WidgetTester tester) async {
        Future<ImageInfo?>? imageInfo;
        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          imageInfo = PowerImageLoader.instance
              .prefetchNetworkImage('precache_url', context);
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);

        //test success
        ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
          platformChannel!.eventChannel.name,
          platformChannel.eventChannel.codec.encodeSuccessEnvelope(
              testCompleteMap(
                  success: true, width: 11, height: 22, textureId: 33)),
          (_) {},
        );

        imageInfo!.then((value) {
          expect(value != null, true);
          expect(value is PowerTextureImageInfo, true);
          PowerTextureImageInfo textureImageInfo = value as PowerTextureImageInfo;
          // expect(value.image is TextureImage, true);
          expect(textureImageInfo.width == 11, true);
          expect(textureImageInfo.height == 22, true);
          expect(textureImageInfo.textureId == 33, true);
        });
      });

      testWidgets('prefetchAssetImage', (WidgetTester tester) async {
        Map? mockCompleteMap;

        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          PowerImageLoader.instance.prefetchAssetImage('precache_url', context,
              onError: (dynamic exception, StackTrace? stackTrace) {
            PowerImageLoadException powerImageLoadException = exception;
            expect(
                mapEquals(
                    powerImageLoadException.nativeResult, mockCompleteMap),
                true);
          });
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);

        mockCompleteMap = testCompleteMap(
            success: false, width: 11, height: 22, textureId: 33);

        //test fail with onError
        ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
          platformChannel!.eventChannel.name,
          platformChannel.eventChannel.codec
              .encodeSuccessEnvelope(mockCompleteMap),
          (_) {},
        );
      });

      testWidgets('prefetchFileImage', (WidgetTester tester) async {
        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          PowerImageLoader.instance.prefetchFileImage('precache_url', context);
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);
        PowerImageLoader.completers.clear();
      });

      testWidgets('prefetchNativeAssetImage', (WidgetTester tester) async {
        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          PowerImageLoader.instance
              .prefetchNativeAssetImage('precache_url', context);
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);
        PowerImageLoader.completers.clear();
      });

      testWidgets('prefetchTypeImage', (WidgetTester tester) async {
        PowerImageRequestOptionsSrcNormal normalSrc =
            PowerImageRequestOptionsSrcNormal(src: 'src');
        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          PowerImageLoader.instance
              .prefetchTypeImage('type', normalSrc, context);
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);
        PowerImageLoader.completers.clear();
      });

      testWidgets('prefetch', (WidgetTester tester) async {
        await tester.pumpWidget(Builder(builder: (BuildContext context) {
          PowerImageRequestOptions options = PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: 'src'),
              renderingType: renderingTypeExternal,
              imageType: 'test_custom',
              imageWidth: 11,
              imageHeight: 22);

          PowerImageLoader.instance.prefetch(options, context);
          return Container();
        }));
        expect(PowerImageLoader.completers.length == 1, true);
        PowerImageLoader.completers.clear();
      });
    });
  });
}
