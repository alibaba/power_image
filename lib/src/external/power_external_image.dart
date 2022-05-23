import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_image/src/external/power_external_image_provider.dart';
import 'package:power_image_ext/image_ext.dart';

class PowerExternalImage extends StatefulWidget {
  PowerExternalImage({
    required this.provider,
    this.frameBuilder,
    this.errorBuilder,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final PowerExternalImageProvider provider;
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
  PowerExteralState createState() => PowerExteralState();
}

class PowerExteralState extends State<PowerExternalImage> {
  @override
  Widget build(BuildContext context) {
    return ImageExt(
      frameBuilder: widget.frameBuilder,
      errorBuilder: widget.errorBuilder,
      image: widget.provider,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      alignment: widget.alignment,
      semanticLabel: widget.semanticLabel,
      excludeFromSemantics: widget.excludeFromSemantics,
    );
  }
}
