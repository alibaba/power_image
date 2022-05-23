import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:power_image/src/common/power_image_provider.dart';
import 'package:power_image_ext/image_info_ext.dart';
import '../../power_image.dart';
import 'power_Image_platform_channel.dart';
import 'power_image_channel.dart';
import 'power_image_request.dart';
import '../options/power_image_request_options.dart';
import 'power_image_setup_options.dart';

class PowerImageCompleter {
  PowerImageRequest? request;
  Completer? completer;
}

class PowerImageLoader {
  static Map<String?, PowerImageCompleter> completers =
      <String?, PowerImageCompleter>{};

  static PowerImageLoader instance = PowerImageLoader._();

  PowerImageChannel channel = PowerImageChannel();

  String get globalRenderType => _globalRenderType;
  String _globalRenderType = defaultGlobalRenderType;

  PowerImageLoader._() {
    channel.impl = PowerImagePlatformChannel();
  }

  void setup(PowerImageSetupOptions? options) {
    _globalRenderType = options?.globalRenderType ?? defaultGlobalRenderType;
    PowerImageMonitor.instance().errorCallback = options?.errorCallback;
    PowerImageMonitor.instance().errorCallbackSamplingRate = options?.errorCallbackSamplingRate;
    channel.setup();
  }

  PowerImageCompleter loadImage(
    PowerImageRequestOptions options,
  ) {
    PowerImageRequest request = PowerImageRequest.create(options);
    channel.startImageRequests(<PowerImageRequest>[request]);
    PowerImageCompleter completer = PowerImageCompleter();
    completer.request = request;
    completer.completer = Completer<Map>();
    completers[request.uniqueKey()] = completer;
    return completer;
  }

  void onImageComplete(Map<dynamic, dynamic> map) async {
    String? uniqueKey = map['uniqueKey'];
    PowerImageCompleter? completer = completers.remove(uniqueKey);
    //todo null case
    completer?.completer?.complete(map);
  }

  void releaseImageRequest(PowerImageRequestOptions options) async {
    PowerImageRequest request = PowerImageRequest.create(options);
    channel.releaseImageRequests(<PowerImageRequest>[request]);
  }

  /// prefetch imageTypeNetwork image
  /// base of
  /// Future<ImageInfo> prefetch(
  ///       PowerImageRequestOptions options, BuildContext context)
  Future<PowerImageInfo?> prefetchNetworkImage(String url, BuildContext context,
      {String? renderingType,
      double? imageWidth,
      double? imageHeight,
      ImageErrorListener? onError}) {
    return prefetch(
        PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcNormal(src: url),
            renderingType: renderingType,
            imageType: imageTypeNetwork,
            imageWidth: imageWidth,
            imageHeight: imageHeight),
        context,
        onError: onError);
  }

  /// prefetch imageTypeNativeAssert image
  /// base of
  /// Future<ImageInfo> prefetch(
  ///       PowerImageRequestOptions options, BuildContext context)
  Future<PowerImageInfo?> prefetchNativeAssetImage(String src, BuildContext context,
      {String? renderingType,
      double? imageWidth,
      double? imageHeight,
      ImageErrorListener? onError}) {
    return prefetch(
        PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcNormal(src: src),
            renderingType: renderingType,
            imageType: imageTypeNativeAssert,
            imageWidth: imageWidth,
            imageHeight: imageHeight),
        context,
        onError: onError);
  }

  /// prefetch imageTypeAssert image
  /// base of
  /// Future<ImageInfo> prefetch(
  ///       PowerImageRequestOptions options, BuildContext context)
  Future<PowerImageInfo?> prefetchAssetImage(String src, BuildContext context,
      {String? renderingType,
      double? imageWidth,
      double? imageHeight,
      String? package,
      ImageErrorListener? onError}) {
    return prefetch(
        PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcAsset(src: src, package: package),
            renderingType: renderingType,
            imageType: imageTypeAssert,
            imageWidth: imageWidth,
            imageHeight: imageHeight),
        context,
        onError: onError);
  }

  /// prefetch imageTypeFile image
  /// base of
  /// Future<ImageInfo> prefetch(
  ///       PowerImageRequestOptions options, BuildContext context)
  Future<PowerImageInfo?> prefetchFileImage(String src, BuildContext context,
      {String? renderingType,
      double? imageWidth,
      double? imageHeight,
      ImageErrorListener? onError}) {
    return prefetch(
        PowerImageRequestOptions(
            src: PowerImageRequestOptionsSrcNormal(src: src),
            renderingType: renderingType,
            imageType: imageTypeFile,
            imageWidth: imageWidth,
            imageHeight: imageHeight),
        context,
        onError: onError);
  }

  /// prefetch image with type
  /// go [PowerImage.type] for more detail
  ///
  Future<PowerImageInfo?> prefetchTypeImage(
      String imageType, PowerImageRequestOptionsSrc src, BuildContext context,
      {String? renderingType,
      double? imageWidth,
      double? imageHeight,
      ImageErrorListener? onError}) {
    return prefetch(
        PowerImageRequestOptions(
            src: src,
            renderingType: renderingType,
            imageType: imageType,
            imageWidth: imageWidth,
            imageHeight: imageHeight),
        context,
        onError: onError);
  }

  /// prefetch image with options
  /// this will add image to ImageCache
  /// so the next time ,when you use equal options (==\hashCode),
  /// will directly use the cached image
  Future<PowerImageInfo?> prefetch(
      PowerImageRequestOptions options, BuildContext context,
      {ImageErrorListener? onError}) {
    ImageProvider provider = PowerImageProvider.options(options);
    return _precacheImage(provider, context, onError: onError);
  }

  Future<PowerImageInfo?> _precacheImage(
    ImageProvider provider,
    BuildContext context, {
    Size? size,
    ImageErrorListener? onError,
  }) {
    final ImageConfiguration config =
        createLocalImageConfiguration(context, size: size);
    final Completer<PowerImageInfo?> completer = Completer<PowerImageInfo?>();
    final ImageStream stream = provider.resolve(config);
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo image, bool sync) {
        if (!completer.isCompleted) {
          completer.complete(image as PowerImageInfo);
        }
        // Give callers until at least the end of the frame to subscribe to the
        // image stream.
        // See ImageCache._liveImages
        SchedulerBinding.instance!.addPostFrameCallback((Duration timeStamp) {
          stream.removeListener(listener);
        });
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
        stream.removeListener(listener);
        if (onError != null) {
          onError(exception, stackTrace);
        } else {
          FlutterError.reportError(FlutterErrorDetails(
            context: ErrorDescription('image failed to precache'),
            library: 'image resource service',
            exception: exception,
            stack: stackTrace,
            silent: true,
          ));
        }
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
