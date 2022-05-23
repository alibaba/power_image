import 'package:power_image/src/options/power_image_request_options.dart';
import 'package:power_image/src/options/power_image_request_options_src.dart';

class PowerImageRequest {
  PowerImageRequest.create(PowerImageRequestOptions options)
      : this.imageWidth = options.imageWidth,
        this.imageHeight = options.imageHeight,
        this.imageType = options.imageType,
        this.renderingType = options.renderingType,
        this.src = options.src;

  /// need use string params to native, avoid setting object in map,
  /// so this is not <String, dynamic>
  final PowerImageRequestOptionsSrc src;
  final String imageType;
  final String? renderingType;
  final double? imageWidth;
  final double? imageHeight;
  Map<String, dynamic>? _encodedRequest;
  String? _uniqueKey;

  Map<String, dynamic>? encode() {
    _encodedRequest ??= <String, dynamic>{
      'src': src.encode(),
      'width': imageWidth,
      'height': imageHeight,
      'imageType': imageType,
      'renderingType': renderingType,
      'uniqueKey': uniqueKey()
    };

    return _encodedRequest;
  }

  String? uniqueKey() {
    _uniqueKey ??=
        '${src.encode().toString()}_imageType:${imageType}_imageWidth:${imageWidth}_imageHeight:${imageHeight}_renderingType:$renderingType'; //TODO 修改
    return _uniqueKey;
  }
}
