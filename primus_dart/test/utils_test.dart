@TestOn('vm')

import 'package:test/test.dart';
import 'package:primus_dart/src/utils.dart';

void main() {
  test('Generate primus url', () {
    var url = generatePrimusUrl('base');

    expect(url, allOf([startsWith('base'), endsWith('/websocket')]));
  });
}
