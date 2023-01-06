import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  var _controller;
  Stream get myStream => _controller.stream;

  void initialise() async {
    _controller = StreamController.broadcast();
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();

  bool getConnectivityResult (source) {
    if((source.keys.toList()[0] == ConnectivityResult.mobile) || (source.keys.toList()[0] == ConnectivityResult.wifi)) {
      return true;
    } else if(source.keys.toList()[0] == ConnectivityResult.none) {
      return false;
    }
    return false;
  }
}