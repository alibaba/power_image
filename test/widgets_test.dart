import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image/src/common/power_Image_platform_channel.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image/src/external/power_external_image.dart';
import 'package:power_image/src/external/power_external_image_provider.dart';
import 'package:power_image/src/texture/power_texture_image.dart';
import 'package:power_image/src/texture/power_texture_image_provider.dart';
import 'package:power_image_ext/image_cache_ext.dart';
import 'package:power_image_ext/image_ext.dart';
import 'package:power_image_ext/image_info_ext.dart';

import 'test_utils.dart';

void main() {
  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    imageCache!
      ..clear()
      ..clearLiveImages()
      ..maximumSize = 1000
      ..maximumSizeBytes = 10485760;
  });

  group('PowerImage_Widget', () {
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

    testWidgets('errorBuilder', (WidgetTester tester) async {
      final UniqueKey errorKey = UniqueKey();
      Object? caughtException;
      final PowerImage networkImage = PowerImage.network(
        'net_test_src',
        width: 1,
        height: 2,
        imageWidth: 11,
        imageHeight: 22,
        alignment: Alignment.topLeft,
        excludeFromSemantics: true,
        renderingType: renderingTypeExternal,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          caughtException = error;
          return Container(
            key: errorKey,
          );
        },
      );
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        Container(
          key: key,
          child: networkImage,
        ),
        null,
        EnginePhase.layout,
      );

      RenderImage renderImage =
          key.currentContext!.findRenderObject() as RenderImage;
      expect(renderImage.image, isNull);

      expect(PowerImageLoader.completers.length == 1, true);

      Map mockCompleteMap = testCompleteMap(
          uniqueKey: PowerImageLoader.completers.keys.first, success: false);

      await sendComplete(platformChannel!, mockCompleteMap);

      expect(PowerImageLoader.completers.length == 0, true);

      await tester.idle();
      await tester.pump(null, EnginePhase.layout);
      expect(caughtException.toString(),
          PowerImageLoadException(nativeResult: mockCompleteMap).toString());
      expect(find.byKey(errorKey), findsOneWidget);
    });

    testWidgets('default_errorBuilder', (WidgetTester tester) async {
      final UniqueKey errorKey = UniqueKey();
      Object? caughtException;
      final PowerImage networkImage = PowerImage.network(
        'net_test_src',
        width: 1,
        height: 2,
        imageWidth: 11,
        imageHeight: 22,
        alignment: Alignment.topLeft,
        excludeFromSemantics: true,
        renderingType: renderingTypeExternal,
      );
      final GlobalKey key = GlobalKey();
      await tester.pumpWidget(
        Container(
          key: key,
          child: networkImage,
        ),
        null,
        EnginePhase.layout,
      );

      RenderImage renderImage =
      key.currentContext!.findRenderObject() as RenderImage;
      expect(renderImage.image, isNull);

      expect(PowerImageLoader.completers.length == 1, true);

      Map mockCompleteMap = testCompleteMap(
          uniqueKey: PowerImageLoader.completers.keys.first, success: false);

      await sendComplete(platformChannel!, mockCompleteMap);

      expect(PowerImageLoader.completers.length == 0, true);

      await tester.idle();
      await tester.pump(null, EnginePhase.layout);
      expect(caughtException == null, true);
      expect(find.byKey(errorKey), findsNothing);
    });

    test('default imageWidth/height', () {
      PowerImage networkImage = PowerImage.network(
        'net_test_src',
        width: 1,
        height: 2,
        alignment: Alignment.topLeft,
      );

      expect(networkImage.image.options.imageWidth == 1, true);
      expect(networkImage.image.options.imageHeight == 2.0, true);
    });

    test('default renderingType', () {
      PowerImage networkImage = PowerImage.network(
        'net_test_src',
        width: 1,
        height: 2,
        alignment: Alignment.topLeft,
      );

      expect(networkImage.image.options.renderingType == renderingTypeTexture,
          true);
    });

    group('PowerImage API', () {
      test('PowerImage.network', () {
        PowerImage networkImage = PowerImage.network(
          'net_test_src',
          width: 1,
          height: 2,
          imageWidth: 11,
          imageHeight: 22,
          alignment: Alignment.topLeft,
        );
        expect(
            networkImage.image.runtimeType == PowerTextureImageProvider, true);
        expect(networkImage.image.options.imageType == imageTypeNetwork, true);
        expect(networkImage.image.options.imageWidth == 11, true);
        expect(networkImage.image.options.imageHeight == 22.0, true);
        expect(networkImage.image.options.renderingType == renderingTypeTexture,
            true);
        expect(
            networkImage.image.options.src.runtimeType ==
                PowerImageRequestOptionsSrcNormal,
            true);
        expect(
            (networkImage.image.options.src
                        as PowerImageRequestOptionsSrcNormal)
                    .src ==
                'net_test_src',
            true);
      });

      test('PowerImage.file', () {
        PowerImage fileImage =
            PowerImage.file('file_test_src', imageWidth: 11, imageHeight: 22);
        expect(fileImage.image.runtimeType == PowerTextureImageProvider, true);
        expect(fileImage.image.options.imageType == imageTypeFile, true);
        expect(fileImage.image.options.imageWidth == 11.0, true);
        expect(fileImage.image.options.imageHeight == 22.0, true);
        expect(fileImage.image.options.renderingType == renderingTypeTexture,
            true);
        expect(
            fileImage.image.options.src.runtimeType ==
                PowerImageRequestOptionsSrcNormal,
            true);
        expect(
            (fileImage.image.options.src as PowerImageRequestOptionsSrcNormal)
                    .src ==
                'file_test_src',
            true);
      });

      test('PowerImage.nativeAsset', () {
        PowerImage nativeAssetImage = PowerImage.nativeAsset(
            'nativeAsset_test_src',
            imageWidth: 11,
            imageHeight: 22);
        expect(nativeAssetImage.image.runtimeType == PowerTextureImageProvider,
            true);
        expect(
            nativeAssetImage.image.options.imageType == imageTypeNativeAssert,
            true);
        expect(nativeAssetImage.image.options.imageWidth == 11.0, true);
        expect(nativeAssetImage.image.options.imageHeight == 22.0, true);
        expect(
            nativeAssetImage.image.options.renderingType ==
                renderingTypeTexture,
            true);
        expect(
            nativeAssetImage.image.options.src.runtimeType ==
                PowerImageRequestOptionsSrcNormal,
            true);
        expect(
            (nativeAssetImage.image.options.src
                        as PowerImageRequestOptionsSrcNormal)
                    .src ==
                'nativeAsset_test_src',
            true);
      });

      test('PowerImage.asset', () {
        PowerImage assetImage = PowerImage.asset('asset_test_src',
            package: 'asset_package', imageWidth: 11, imageHeight: 22);
        expect(assetImage.image.runtimeType == PowerTextureImageProvider, true);
        expect(assetImage.image.options.imageType == imageTypeAssert, true);
        expect(assetImage.image.options.imageWidth == 11.0, true);
        expect(assetImage.image.options.imageHeight == 22.0, true);
        expect(assetImage.image.options.renderingType == renderingTypeTexture,
            true);
        expect(
            assetImage.image.options.src.runtimeType ==
                PowerImageRequestOptionsSrcAsset,
            true);
        expect(
            (assetImage.image.options.src as PowerImageRequestOptionsSrcAsset)
                    .src ==
                'asset_test_src',
            true);
        expect(
            (assetImage.image.options.src as PowerImageRequestOptionsSrcAsset)
                    .package ==
                'asset_package',
            true);
      });

      test('PowerImage.type', () {
        PowerImageRequestOptionsSrcNormal normalSrc =
            PowerImageRequestOptionsSrcNormal(src: 'src');
        PowerImage srcImage = PowerImage.type(
          "my_imageType",
          src: normalSrc,
          width: 10,
          height: 20,
          renderingType: renderingTypeTexture,
        );
        expect(srcImage.image.runtimeType == PowerTextureImageProvider, true);
        expect(srcImage.image.options.src == normalSrc, true);
        expect(srcImage.image.options.imageType == "my_imageType", true);
        expect(srcImage.image.options.imageWidth == 10, true);
        expect(srcImage.image.options.imageHeight == 20, true);
      });

      test('PowerImage.options', () {
        PowerImageRequestOptions options = PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcNormal(src: 'src'),
            renderingType: renderingTypeExternal,
            imageType: 'test_custom',
            imageWidth: 11,
            imageHeight: 22);
        PowerImage optionsImage = PowerImage.options(options);
        expect(
            optionsImage.image.runtimeType == PowerExternalImageProvider, true);
        expect(optionsImage.image.options == options, true);

        //image
        PowerImageProvider powerImageProvider =
            PowerImageProvider.options(options);
        PowerImage powerImage = PowerImage(
          image: powerImageProvider,
        );
        expect(powerImage.image == powerImageProvider, true);
      });

      test('PowerImage()', () {
        PowerImageRequestOptions options = PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcNormal(src: 'src'),
            renderingType: renderingTypeExternal,
            imageType: 'test_custom',
            imageWidth: 11,
            imageHeight: 22);

        PowerImageProvider provider = PowerImageProvider.options(options);
        PowerImage powerImage = PowerImage(
          image: provider,
        );
        expect(powerImage.image == provider, true);
      });
    });

    testWidgets('PowerImageState', (WidgetTester tester) async {
      await tester.pumpWidget(
          PowerImage.network(
            'src',
            renderingType: renderingTypeTexture,
          ),
          null,
          EnginePhase.layout);
      expect(find.byType(PowerTextureImage), findsOneWidget);
      expect(find.byType(PowerExternalImage), findsNothing);
      await tester.pumpWidget(
          PowerImage.network(
            'src',
            renderingType: renderingTypeExternal,
          ),
          null,
          EnginePhase.layout);
      expect(find.byType(PowerExternalImage), findsOneWidget);
      expect(find.byType(PowerTextureImage), findsNothing);

      await tester.pumpWidget(
          PowerImage(
            image: TestPowerExternalImageProvider(testRequestOptions()),
          ),
          null,
          EnginePhase.layout);
      expect(find.byType(PowerExternalImage), findsNothing);
      expect(find.byType(PowerTextureImage), findsNothing);
      expect(find.byType(ImageExt), findsOneWidget);
    });

    testWidgets('PowerTextureImage', (WidgetTester tester) async {
      PowerTextureImage image =
          PowerTextureImage(provider: testPowerImageProvider() as PowerTextureImageProvider);

      await tester.pumpWidget(image, null, EnginePhase.layout);

      expect(find.byType(PowerTextureImage), findsOneWidget);
      expect(find.byType(ImageExt), findsOneWidget);
      ImageExt imageExt = tester.widget(find.byType(ImageExt));
      expect(imageExt.imageBuilder != null, true);

      PowerTextureState state = tester.state(find.byType(PowerTextureImage));

      PowerTextureImageInfo? textureImageInfo;

      await tester.runAsync(() async {
        textureImageInfo = await testTextureImageInfo(textureId: 11);
      });

      await tester.pumpWidget(Builder(builder: (BuildContext context) {
        return state.buildImage(context, textureImageInfo);
      }));

      final Texture texture = tester.widget(find.byType(Texture));
      expect(texture, isNotNull);
      expect(texture.textureId, 11);
    });
  });
}
