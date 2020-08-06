import 'dart:convert';
import 'package:json_isolate/json_isolate.dart';
import 'package:web_socket_channel/io.dart';
import './utils.dart';

enum PrimusListenerOn {
  Open,
  Close,
  Data,
  Error,
}

class Primus {
  final String url;
  final bool parseInThread;
  final bool autoReconnect;
  String status = '';
  IOWebSocketChannel _channel;
  JsonIsolate jsonIsolate;

  final List<Map<PrimusListenerOn, Function>> _listeners =
      <Map<PrimusListenerOn, Function>>[];

  Primus(this.url, {this.parseInThread = false, this.autoReconnect = true}) {
    jsonIsolate = JsonIsolate();

    var serverAddress = generatePrimusUrl(url);
    _open(serverAddress);

    if (autoReconnect) {
      addListener(PrimusListenerOn.Close, (data) {
        _open(serverAddress);
      });
    }
  }

  void sendRawToWebSocket(String data) {
    var message = '[\"\\"' + data + '\\\""]';
    send(message);
  }

  void send(String message) {
    if (_channel != null) {
      if (_channel.sink != null && status == 'open') {
        _channel.sink.add(message);
      }
    }
  }

  void addListener(PrimusListenerOn channel, Function(dynamic data) callback) {
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

  void _sendToListeners(PrimusListenerOn code, dynamic data) {
    _listeners.forEach((Map<PrimusListenerOn, Function> keyFn) {
      if (keyFn.containsKey(code)) {
        try {
          keyFn[code](data);
        } catch (e) {
          // swallow listeners errors
          print(e);
        }
      }
    });
  }

  void _open(String serverAddress) {
    _reset();

    try {
      _channel =
          IOWebSocketChannel.connect(serverAddress, protocols: ['https']);

      _channel.stream.handleError((error) {
        _sendToListeners(PrimusListenerOn.Error, error);
      });
      _channel.stream.listen(_onServerMessage, onError: (error) {
        _sendToListeners(PrimusListenerOn.Error, error);
      });
    } catch (e) {
      print(e);
    }
  }

  void _pong() {
    var data =
        'primus::pong::' + DateTime.now().millisecondsSinceEpoch.toString();
    sendRawToWebSocket(data);
  }

  void _onServerMessage(dynamic message) async {
    status = 'open';
    if (message.toString().contains('primus::ping')) {
      return _pong();
    }

    if (message is String) {
      if (message.startsWith('o')) {
        _sendToListeners(PrimusListenerOn.Open, message);
      } else if (message.startsWith('a')) {
        if (!message.contains('primus::')) {
          try {
            if (parseInThread) {
              var arrayWithString =
                  await jsonIsolate.convert(message.substring(1));
              var jsonObject = await jsonIsolate.convert(arrayWithString[0]);
              _sendToListeners(PrimusListenerOn.Data, jsonObject);
            } else {
              var arrayWithString = json.decode(message.substring(1));
              var jsonObject = json.decode(arrayWithString[0]);
              _sendToListeners(PrimusListenerOn.Data, jsonObject);
            }
          } catch (error) {
            _sendToListeners(PrimusListenerOn.Error, error);
          }
        }
      } else if (message.startsWith('c')) {
        // send close command?
        _sendToListeners(PrimusListenerOn.Close, message);
      } else {
        try {
          _sendToListeners(PrimusListenerOn.Data, message);
        } catch (error) {
          _sendToListeners(PrimusListenerOn.Error, error);
        }
      }
    }
  }
}
