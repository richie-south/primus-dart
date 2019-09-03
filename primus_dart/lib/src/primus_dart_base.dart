import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import './utils.dart';

class Primus {
  final String url;

  String status = '';
  String _server_address;
  IOWebSocketChannel _channel;

  List<Map<String, Function>> _listeners = List<Map<String, Function>>();

  Primus(this.url) {
    _server_address = generatePrimusUrl(this.url);
    _open();
  }

  void sendRawToWebSocket(String data) {
    String message = '[\"\\"' + data + '\\\""]';
    send(message);
  }

  void send(String message) {
    if (_channel != null) {
      if (_channel.sink != null && status == 'open') {
        _channel.sink.add(message);
      }
    }
  }

  void addListener(String channel, Function(dynamic data) callback) {
    _listeners.add({channel: callback});
  }

  void _reset() {
    if (_channel != null) {
      if (_channel.sink != null) {
        _channel.sink.close();
        status = 'closed';
      }
    }
  }

  void _sendToListeners(String key, dynamic data) {
    _listeners.forEach((Map<String, Function> keyFn) {
      if (keyFn.containsKey(key)) {
        try {
          keyFn[key](data);
        } catch (e) {
          // swallow listeners errors
          print(e);
        }
      }
    });
  }

  void _open() {
    _reset();

    try {
      _channel =
          IOWebSocketChannel.connect(_server_address, protocols: ['https']);

      _channel.stream.handleError((error) {
        _sendToListeners('error', error);
      });
      _channel.stream.listen(_onReceptionOfMessageFromServer, onError: (error) {
        _sendToListeners('error', error);
      });
    } catch (e) {
      print(e);
    }
  }

  void _pong() {
    String data =
        'primus::pong::' + DateTime.now().millisecondsSinceEpoch.toString();
    sendRawToWebSocket(data);
  }

  void _onReceptionOfMessageFromServer(dynamic message) {
    status = 'open';
    if (message.toString().contains('primus::ping')) {
      return _pong();
    }

    if (message is String) {
      if (message.startsWith('o')) {
        _sendToListeners('open', message);
      } else if (message.startsWith('a')) {
        if (!message.contains('primus::')) {
          try {
            var arrayWithString = json.decode(message.substring(1));
            var jsonObject = json.decode(arrayWithString[0]);

            _sendToListeners('data', jsonObject);
          } catch (error) {
            _sendToListeners('error', error);
          }
        }
      } else if (message.startsWith("c")) {
        _sendToListeners('close', message);
      } else {
        try {
          _sendToListeners('data', message);
        } catch (error) {
          _sendToListeners('error', error);
        }
      }
    }
  }
}
