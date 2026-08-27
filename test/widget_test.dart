import 'package:flutter_test/flutter_test.dart';
import 'package:lively/core/theme/app_theme.dart';

void main() {
  test('light theme builds without throwing', () {
    expect(AppTheme.light, isNotNull);
  });
}
