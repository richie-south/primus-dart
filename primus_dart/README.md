A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:primus_dart/primus_dart.dart';

main() {
  Primus socket = Primus(socketUrl);

  /*
   * available listeners
   * 'open', 'close', 'data', 'error'
   */
  socket.addListener('open', (data) {

  });

  // send data as string
  socket.send(json.encode({  }));

}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/richie-south/primus-dart/issues
