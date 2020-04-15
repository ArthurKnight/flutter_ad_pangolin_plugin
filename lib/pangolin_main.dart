import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pangolin/pangolin.dart';


//MethodChannel _channel;// = MethodChannel('com.luoyang.ad.pangolin')..setMethodCallHandler(_methodHandler);
//StreamController<BasePangolinResponse> _pangolinResponseEventHandlerController =
//    new StreamController.broadcast();
//
//Stream<BasePangolinResponse> get pangolinResponseEventHandler =>
//    _pangolinResponseEventHandlerController.stream;

MethodChannel _channel = MethodChannel('com.luoyang.ad.pangolin');

StreamController<Map<dynamic, dynamic>> _eventController = StreamController.broadcast();

Stream<Map<dynamic, dynamic>> get eventController => _eventController.stream;

//事件
StreamSubscription<dynamic> _eventSubscription;

void initEvent() {
  _eventSubscription = EventChannel('com.luoyang.ad.pangolin.event')
      .receiveBroadcastStream()
      .listen(eventListener, onError: errorListener);
}

void eventListener(dynamic event) {
  final Map<dynamic, dynamic> map = event;
  switch (map['event']) {
    case 'rewardVideoClose':
      String value = map['value'];
      print("收到rewardVideoClose data:$value");
      _eventController.add(map);
      break;
  }
}

void errorListener(Object obj) {
  final PlatformException e = obj;
  throw e;
}

Future<bool> registerPangolin(
    {@required String appId,
    @required bool useTextureView,
    @required String appName,
    @required bool allowShowNotify,
    @required bool allowShowPageWhenScreenLock,
    @required bool debug,
    @required bool supportMultiProcess}) async {
  return await _channel.invokeMethod("register", {
    "appId": appId,
    "useTextureView": useTextureView,
    "appName": appName,
    "allowShowNotify": allowShowNotify,
    "allowShowPageWhenScreenLock": allowShowPageWhenScreenLock,
    "debug": debug,
    "supportMultiProcess": supportMultiProcess
  });
}

Future<bool> loadSplashAd(
    {@required String slotId, @required bool debug}) async {
  return await _channel
      .invokeMethod("loadSplashAd", {"slotId": slotId, "debug": debug});
}

Future loadRewardAd(
    {@required bool isHorizontal,
    @required String slotId,
    @required bool debug}) async {
  return await _channel.invokeMethod("loadRewardAd", {
    "isHorizontal": isHorizontal,
    "slotId": slotId,
    "userId": "1000",
    "debug": debug
  });
}

//Future _methodHandler(MethodCall methodCall) {
//  var response =
//      BasePangolinResponse.create(methodCall.method, methodCall.arguments);
//  _pangolinResponseEventHandlerController.add(response);
//  return Future.value();
//}

//enum EventType { rewardVideoClose }
