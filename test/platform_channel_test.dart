import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_image_platform_channel.dart';
import 'package:power_image/src/common/power_image_request.dart';

void main() {
  //test initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  group('methodChannel_eventChannel', () {
    PowerImagePlatformChannel? platformChannel =
        PowerImageLoader.instance.channel.impl as PowerImagePlatformChannel?;

    final Map<String, List<MethodCall>> calls = <String, List<MethodCall>>{};
    PowerImageRequest? startedRequest;

    setUp(() {
      platformChannel!.methodChannel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        calls.putIfAbsent(methodCall.method, () {
          return <MethodCall>[];
        });

        calls[methodCall.method]!.add(methodCall);

        return [{}];
      });

      calls.clear();

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
          .setup(PowerImageSetupOptions(renderingTypeExternal));
    });

    test('startImageRequests', () async {
      startedRequest = PowerImageLoader.instance
          .loadImage(PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: 'renderingType'))
          .request;

      expect(
        calls['startImageRequests'],
        <Matcher>[
          isMethodCall('startImageRequests',
              arguments: [startedRequest!.encode()])
        ],
      );
    });

    test('releaseImageRequests', () async {
      PowerImageLoader.instance.releaseImageRequest(PowerImageRequestOptions(
          src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
          imageType: 'imageType',
          imageWidth: 100.0,
          imageHeight: 101.0,
          renderingType: 'renderingType'));

      expect(
        calls['releaseImageRequests'],
        <Matcher>[
          isMethodCall('releaseImageRequests',
              arguments: [startedRequest!.encode()])
        ],
      );
    });

    test('onReceiveImageEvent', () async {
      PowerImageCompleter imageCompleter = PowerImageLoader.instance.loadImage(
          PowerImageRequestOptions(
              src: PowerImageRequestOptionsSrcNormal(src: "srcValue"),
              imageType: 'imageType',
              imageWidth: 100.0,
              imageHeight: 101.0,
              renderingType: 'renderingType'));

      Map mockCompleteMap = {
        'eventName': 'onReceiveImageEvent',
        'uniqueKey': imageCompleter.request!.uniqueKey()
      };

      ServicesBinding.instance!.defaultBinaryMessenger.handlePlatformMessage(
        platformChannel!.eventChannel.name,
        platformChannel.eventChannel.codec
            .encodeSuccessEnvelope(mockCompleteMap),
        (_) {},
      );

      Map value = await (imageCompleter.completer!.future);

      expect(value, equals(mockCompleteMap));
    });

    test('PowerImagePlatformChannel', () {
      PowerImagePlatformChannel channel = PowerImagePlatformChannel();
      channel.registerEventHandler('testHandlerName', (event) {});
      expect(channel.eventHandlers['testHandlerName'] != null, true);
      channel.unregisterEventHandler('testHandlerName');
      expect(channel.eventHandlers['testHandlerName'] == null, true);
    });
  });
}
