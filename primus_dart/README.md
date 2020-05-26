Primus client for dart

Still in early development, missing some features and might not work for your needs right now.

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

## options

```dart
main() {
  Primus socket = Primus(socketUrl, {
    parseInThread: false // default false - parses json in seperate thread
  });
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/richie-south/primus-dart/issues
