import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangolin/pangolin.dart';

//MethodChannel _channel;// = MethodChannel('com.luoyang.ad.pangolin')..setMethodCallHandler(_methodHandler);
//StreamController<BasePangolinResponse> _pangolinResponseEventHandlerController =
//    new StreamController.broadcast();
//
//Stream<BasePangolinResponse> get pangolinResponseEventHandler =>
//    _pangolinResponseEventHandlerController.stream;

MethodChannel _channel = MethodChannel('com.luoyang.ad.pangolin');

StreamController<Map<dynamic, dynamic>> _eventController =
    StreamController.broadcast();

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
    case 'rewardVideoRenderSuccess':
      String value = map['value'];
      print("rewardVideoRenderSuccess data:$value");
      _eventController.add(map);
      break;
    case 'expressAdRenderSuccess':
      String value = map['value'];
      print("rewardVideoRenderSuccess data:$value");
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

Future<void> loadSplashAd(
    {@required String slotId, @required bool debug}) async {
  await _channel
      .invokeMethod("loadSplashAd", {"slotId": slotId, "debug": debug});
  return;
}

Future<void> removeSplashView({@required bool debug}) async {
  return await _channel.invokeMethod("removeSplashView", {"debug": debug});
}

Future loadRewardAd(
    {@required bool isHorizontal,
    @required String slotId,
    @required String rewardName,
    @required bool debug}) async {
  return await _channel.invokeMethod("loadRewardAd", {
    "isHorizontal": isHorizontal,
    "slotId": slotId,
    "userId": "1000",
    "rewardName": rewardName,
    "debug": debug
  });
}

Future loadNativeAd({@required String slotId, @required int loadCount}) async {
  return await _channel
      .invokeMethod("loadNativeAd", {"slotId": slotId, "loadCount": loadCount});
}

Future<bool> loadExpressAd({@required String slotId}) async {
  return await _channel.invokeMethod("loadExpressAd", {"slotId": slotId});
}
//Future _methodHandler(MethodCall methodCall) {
//  var response =
//      BasePangolinResponse.create(methodCall.method, methodCall.arguments);
//  _pangolinResponseEventHandlerController.add(response);
//  return Future.value();
//}

//enum EventType { rewardVideoClose }

Future loadFullscreenVideoAdWithSlotID({@required String slotId}) async {
  return await _channel
      .invokeMethod("loadFullscreenVideoAdWithSlotID", {"slotId": slotId});
}

//Future showFullscreenVideoAd() async {
//  return await _channel.invokeMethod("showFullscreenVideoAd", {});
//}

Future loadInterstitialWithSlotID({@required String slotId}) async {
  return await _channel
      .invokeMethod("loadInterstitialWithSlotID", {"slotId": slotId});
}

//Future showInterstitial() async {
//  return await _channel.invokeMethod("showInterstitial", {});
//}


class ExpressAdView extends StatefulWidget {

  final String slotId;

  ExpressAdView({this.slotId});

  @override
  _ExpressAdViewState createState() => _ExpressAdViewState();
}

class _ExpressAdViewState extends State<ExpressAdView> {

  bool loadFinish=false;

  @override
  void initState() {
    super.initState();
    loadExpressAd(slotId: widget.slotId);
  }

  @override
  Widget build(BuildContext context) {
    if(Platform.isIOS) {
      return loadFinish?
      UiKitView(
        viewType: "ExpressAdView",
        creationParams: <String,dynamic>{
          "sloidId":widget.slotId,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ):Container();
    }else if(Platform.isAndroid){
      return Container();
    }else{
      return Container();
    }
  }
}
