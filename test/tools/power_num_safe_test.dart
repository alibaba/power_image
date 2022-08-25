
import 'package:flutter_test/flutter_test.dart';
import 'package:power_image/src/tools/power_num_safe.dart';

void main() {
  group('power_number_safe_test', () {
    setUp(() {});

    test('isNumValid', () {

      expect(isNumValid(1000), true);
      expect(isNumValid(1), true);
      expect(isNumValid(0.001), true);
      expect(isNumValid(0), true);
      /// special, null is OK
      expect(isNumValid(null), true);

      expect(isNumValid(-0.001), false);
      expect(isNumValid(-1), false);

      expect(isNumValid(double.nan), false);
      expect(isNumValid(double.infinity), false);
      expect(isNumValid(double.negativeInfinity), false);
    });

    test('validNum', () {

      expect(makeNumValid(1000, null) == 1000, true);
      expect(makeNumValid(1000, 1) == 1000, true);
      expect(makeNumValid(0.001, null) == 0.001, true);
      expect(makeNumValid(0.001, 20) == 0.001, true);
      expect(makeNumValid(0, 20) == 0, true);
      expect(makeNumValid(null, 1) == null, true);


      expect(makeNumValid(-1, 1) == 1, true);
      expect(makeNumValid(-1, null) == null, true);
      expect(makeNumValid(-1000, 1) == 1, true);
      expect(makeNumValid(-0.0001, 1) == 1, true);

      expect(makeNumValid(double.nan, 1) == 1, true);
      expect(makeNumValid(double.infinity, 2) == 2, true);
      expect(makeNumValid(double.negativeInfinity, 2) == 2, true);
      expect(makeNumValid(double.negativeInfinity, 3) == 3, true);

    });
  });
}
