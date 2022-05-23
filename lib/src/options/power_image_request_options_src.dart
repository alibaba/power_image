import 'dart:ui';

import 'package:flutter/cupertino.dart';
///
/// this is abstract class for custom Src to native laoder
///
///
///
abstract class PowerImageRequestOptionsSrc {
  /// the encode map will transparent to native Biz Loader
  /// avoid save too much data in it;
  Map<String, dynamic> encode();

  /// you need override these two method: == /  hashCode
  /// to ensure several PowerImageRequestOptionsSrc is Equal when you need use same cache
  ///
  /// example
  ///
  /// class Test extends PowerImageRequestOptionsSrc {
  /// final String a;
  /// final bool b;
  ///
  /// @override
  /// bool operator ==(Object other) {
  ///   if (other.runtimeType != runtimeType) {
  ///     return false;
  ///   }
  ///
  ///   return other is PowerImageRequestOptionsSrcNormal && other.a == a && other.b == b;
  /// }
  ///
  /// @override
  /// int get hashCode => hashValues(a, b);
  ///
  @override
  bool operator ==(Object other) {
    throw UnimplementedError();
  }

  /// you need override these two method: == /  hashCode
  /// to ensure several PowerImageRequestOptionsSrc is Equal when you need use same cache
  /// 
  @override
  int get hashCode => throw UnimplementedError();
}

class PowerImageRequestOptionsSrcNormal extends PowerImageRequestOptionsSrc {
  final String src;

  PowerImageRequestOptionsSrcNormal({required this.src});

  @override
  Map<String, String> encode() {
    return {"src": src};
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PowerImageRequestOptionsSrcNormal && other.src == src;
  }

  @override
  int get hashCode => src.hashCode;
}

class PowerImageRequestOptionsSrcAsset extends PowerImageRequestOptionsSrc {
  final String src;
  final String? package;

  PowerImageRequestOptionsSrcAsset(
      {required this.src, this.package});

  @override
  Map<String, String?> encode() {
    return {"src": src, "package": package};
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PowerImageRequestOptionsSrcAsset &&
        other.src == src &&
        other.package == package;
  }

  @override
  int get hashCode => hashValues(src, package);
}
