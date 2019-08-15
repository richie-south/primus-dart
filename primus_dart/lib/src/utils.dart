import 'dart:math';

String _randomCharacterFromDictionary() {
  String dictionary = 'abcdefghijklmnopqrstuvwxyz0123456789_';
  var random = Random();
  int rand = random.nextInt(dictionary.length - 1);
  return dictionary[rand];
}

String _randomStringOfLength(int length) {
  String s = '';
  for (int i = 0; i < length; i++) {
    s += _randomCharacterFromDictionary();
  }
  return s;
}

String generatePrimusUrl(String base) {
  Random r = Random();
  int server = r.nextInt(1000);
  String connId = _randomStringOfLength(8);
  return base + "/" + server.toString() + "/" + connId + "/websocket";
}
