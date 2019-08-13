import 'dart:convert';

import 'package:web_socket_channel/io.dart';
import './utils.dart';

class Primus {

  final String url;
  final List<String> strategy;

  static const String OPEN = '';
  static const String OPENING = '';

  String status = '';
  String _server_address;
  IOWebSocketChannel _channel;

  List<Map<String, Function>> _listeners = List<Map<String, Function>>();

  Primus(this.url, { this.strategy }) {
    _server_address = generatePrimusUrl(this.url);
    open();
  }

  void sendRawToWebSocket(String data) {
    String message = '[\"\\"' + data + '\\\""]';
    send(message);
  }

  void send(String message) {
    if (_channel != null){
      if (_channel.sink != null && status == 'open'){
        _channel.sink.add(message);
      }
    }
  }

  void reset() {
    if (_channel != null){
      if (_channel.sink != null) {
        _channel.sink.close();
        status = 'closed';
      }
    }
  }

  void open() {
    reset();

    try {

      _channel = IOWebSocketChannel.connect(_server_address, protocols: ['https']);

      _channel.stream.handleError((error) {
        print(error);
      });
      _channel.stream.listen(_onReceptionOfMessageFromServer,
        onDone: () {
          print('on done');
        },
        onError: (error) {
          print(error);
        });

    } catch(e){
      print(e);
    }
  }

  void addListener(String channel, Function(dynamic data) callback){
    _listeners.add({ channel: callback });
  }

  void pong() {
    String data = "primus::pong::" + DateTime.now().millisecondsSinceEpoch.toString();
    sendRawToWebSocket(data);
  }


  void _onReceptionOfMessageFromServer(dynamic message) {
    status = 'open';
    if (message.toString().contains('primus::ping')) {
      return pong();
    }

    if (message is String) {

      if (message.startsWith('o')) {

        _listeners.forEach((Map<String, Function> keyFn) {
          if (keyFn.containsKey('open')) {
            keyFn['open'](message);
          }
        });
      } else if (message.startsWith('a')) {

        if (!message.contains('primus::')) {
          try {
            var arrayWithString = json.decode(message.substring(1));
            var jsonObject = json.decode(arrayWithString[0]);

            _listeners.forEach((Map<String, Function> keyFn) {
              if (keyFn.containsKey('data')) {
                keyFn['data'](jsonObject);
              }
            });

          } catch (e) {
            print(e);
          }
        }
      } else if (message.startsWith("c")) {

        _listeners.forEach((Map<String, Function> keyFn) {
          if (keyFn.containsKey('close')) {
            keyFn['close'](message);
          }
        });
      } else {
        // json string
        try {
          var jsonObject = json.decode(message);

          _listeners.forEach((Map<String, Function> keyFn) {
            if (keyFn.containsKey('data')) {
              keyFn['data'](jsonObject);
            }
          });
        } catch (e) {
          print(e);
        }
      }
    }
  }
}
