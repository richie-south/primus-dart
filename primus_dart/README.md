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
   * PrimusListenerOn.Open
   * PrimusListenerOn.Close
   * PrimusListenerOn.Data
   * PrimusListenerOn.Error
   */
  socket.addListener(PrimusListenerOn.Open, (data) {

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

## TODO

- [ ] reconnect
- [ ] disconnect
- [ ] error message for first connection
  - we register listeners after connection so error on first connect will never be sent to user.
- [ ] testing
  - mock IOWebSocketChannel
- [ ] thread testing
