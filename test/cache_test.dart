import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';
import 'package:power_image_ext/image_cache_ext.dart';

void main() {
  setUp(() {
    PowerImageBinding();
  });

  tearDown(() {
    imageCache!
      ..clear()
      ..clearLiveImages()
      ..maximumSize = 1000
      ..maximumSizeBytes = 10485760;
  });

  group('cache_test', () {
    setUp(() {});

    test('PowerImageBinding', () {
      expect(imageCache.runtimeType == ImageCacheExt, true);
    });
  });
}
