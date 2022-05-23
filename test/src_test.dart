import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/power_image.dart';

void main() {
  //test initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  group('src_test', () {

    setUp(() {

    });

    group('PowerImageRequestOptionsSrcNormal', () {
      test('equal_hashCode', () {
        PowerImageRequestOptionsSrcNormal srcNormal_1 = PowerImageRequestOptionsSrcNormal(src: 'test');
        PowerImageRequestOptionsSrcNormal srcNormal_2 = PowerImageRequestOptionsSrcNormal(src: 'test');
        Map<PowerImageRequestOptionsSrcNormal, dynamic> testMap = <PowerImageRequestOptionsSrcNormal, dynamic>{};
        testMap[srcNormal_1] = 'srcNormal_1';
        testMap[srcNormal_2] = 'srcNormal_2';
        expect(testMap.length == 1, true);
        expect(testMap[srcNormal_1] == 'srcNormal_2', true);

        PowerImageRequestOptionsSrcNormal srcNormal_3 = PowerImageRequestOptionsSrcNormal(src: 'test_3');
        testMap[srcNormal_3] = 'srcNormal_3';
        expect(testMap.length == 2, true);
        expect(testMap[srcNormal_2] == 'srcNormal_2', true);
        expect(testMap[srcNormal_3] == 'srcNormal_3', true);
      });

      test('encode()', () {
        PowerImageRequestOptionsSrcNormal srcNormal_1 = PowerImageRequestOptionsSrcNormal(src: 'test');
        expect(srcNormal_1.encode()['src'] == 'test', true);
      });
    });

    group('PowerImageRequestOptionsSrcAsset', () {
      test('equal_hashCode', () {
        PowerImageRequestOptionsSrcAsset srcAsset_1 = PowerImageRequestOptionsSrcAsset(src: 'test', package: 'package');
        PowerImageRequestOptionsSrcAsset srcAsset_2 = PowerImageRequestOptionsSrcAsset(src: 'test', package: 'package');
        Map<PowerImageRequestOptionsSrcAsset, dynamic> testMap = <PowerImageRequestOptionsSrcAsset, dynamic>{};
        testMap[srcAsset_1] = 'srcAsset_1';
        testMap[srcAsset_2] = 'srcAsset_2';
        expect(testMap.length == 1, true);
        expect(testMap[srcAsset_1] == 'srcAsset_2', true);

        PowerImageRequestOptionsSrcAsset srcAsset_3 = PowerImageRequestOptionsSrcAsset(src: 'test_3', package: 'package');
        testMap[srcAsset_3] = 'srcAsset_3';
        expect(testMap.length == 2, true);
        expect(testMap[srcAsset_2] == 'srcAsset_2', true);
        expect(testMap[srcAsset_3] == 'srcAsset_3', true);
      });

      test('encode()', () {
        PowerImageRequestOptionsSrcAsset srcAsset_1 = PowerImageRequestOptionsSrcAsset(src: 'test', package: 'package');
        expect(srcAsset_1.encode()['src'] == 'test', true);
        expect(srcAsset_1.encode()['package'] == 'package', true);

        PowerImageRequestOptionsSrcAsset srcAsset_2 = PowerImageRequestOptionsSrcAsset(src: 'test2');
        expect(srcAsset_2.encode()['src'] == 'test2', true);
      });
    });

    test('error', () {
      TestSrc src1 = TestSrc();
      TestSrc src2 = TestSrc();

      expect(() => src1 == src2, throwsA(isA<UnimplementedError>()));
      expect(() => src1.hashCode, throwsA(isA<UnimplementedError>()));
    });

  });
}

class TestSrc extends PowerImageRequestOptionsSrc {
  @override
  Map<String, dynamic> encode() {
    // TODO: implement encode ,
    throw UnimplementedError();
  }
}

