import 'package:flutter/widgets.dart';

import 'package:power_image_ext/image_ext.dart';
import 'package:power_image_ext/image_info_ext.dart';
import 'power_texture_image_provider.dart';

class PowerTextureImage extends StatefulWidget {
  const PowerTextureImage({
    Key? key,
    required this.provider,
    this.frameBuilder,
    this.errorBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  }):super(key: key);

  final PowerTextureImageProvider provider;
  final ImageFrameBuilder? frameBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;

  /// same as [Image]
  ///
  /// A Semantic description of the image.
  ///
  /// Used to provide a description of the image to TalkBack on Android, and
  /// VoiceOver on iOS.
  final String? semanticLabel;

  /// Whether to exclude this image from semantics.
  ///
  /// Useful for images which do not contribute meaningful information to an
  /// application.
  final bool excludeFromSemantics;

  @override
  PowerTextureState createState() {
    return PowerTextureState();
  }
}

class PowerTextureState extends State<PowerTextureImage> {
  @override
  Widget build(BuildContext context) {
    return ImageExt(
      image: widget.provider,
      frameBuilder: widget.frameBuilder,
      errorBuilder: widget.errorBuilder,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      imageBuilder: buildImage,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
    );
  }

  Widget buildImage(BuildContext context, ImageInfo? imageInfo) {
    if (imageInfo == null || imageInfo is! PowerTextureImageInfo) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    PowerTextureImageInfo textureImageInfo = imageInfo;
    return ClipRect(
      child: SizedBox(
        child: FittedBox(
          fit: widget.fit ?? BoxFit.contain,
          child: SizedBox(
            width: textureImageInfo.width?.toDouble() ?? widget.width,
            height: textureImageInfo.height?.toDouble() ?? widget.height,
            child: Texture(
              textureId: textureImageInfo.textureId!,
            ),
          ),
        ),
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
