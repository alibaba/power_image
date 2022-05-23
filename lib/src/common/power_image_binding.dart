

import 'package:flutter/widgets.dart';
import 'package:power_image_ext/image_cache_ext.dart';

class PowerImageBinding extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    // TODO: implement createImageCache
    return ImageCacheExt();
  }
}