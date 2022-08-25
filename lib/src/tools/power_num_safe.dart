/// null is valid number in power_image
double? makeNumValid(double? num, double? defaultNum) {
  if (!isNumValid(num)) {
    return defaultNum;
  }
  return num;
}

/// null is valid number in power_image
bool isNumValid(double? num) {
  if (num != null && (num.isNaN || num.isInfinite || num.isNegative)) {
    return false;
  }
  return true;
}
