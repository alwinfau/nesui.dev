// import 'package:flutter_test/flutter_test.dart';

// import 'package:nesui/nesui.dart';

// void main() {
//   test('adds one to input values', () {
//     final calculator = Calculator();
//     expect(calculator.addOne(2), 3);
//     expect(calculator.addOne(-7), -6);
//     expect(calculator.addOne(0), 1);
//   });
// }

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesui/component/nesui.dart';

void main() {
  test('NesuiTheme defaults', () {
    final theme = NesuiTheme.defaults(Brightness.light);
    expect(theme.radius, greaterThan(0));
  });
}
