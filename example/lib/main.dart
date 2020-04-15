import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:pangolin/pangolin.dart' as Pangolin;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    /*Pangolin.pangolinResponseEventHandler.listen((value)
    {
      if(value is Pangolin.onRewardResponse)
        {
          print("激励视频回调：${value.rewardVerify}");
          print("激励视频回调：${value.rewardName}");
          print("激励视频回调：${value.rewardAmount}");
        }
      else
        {
          print("回调类型不符合");
        }
    });*/
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.location,
      Permission.storage,
    ].request();
    //校验权限
    if (statuses[Permission.location] != PermissionStatus.granted) {
      print("无位置权限");
    }
    _initPangolin();
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

//  "5056758",
//  true,
//  "爱看",
//  true,
//  true,
//  true,
//  true
  _initPangolin() async {
    await Pangolin.registerPangolin(
            appId: "5059983",
            useTextureView: true,
            appName: "Bottle_test",
            allowShowNotify: true,
            allowShowPageWhenScreenLock: true,
            debug: true,
            supportMultiProcess: true);
    Pangolin.initEvent();
    Pangolin.eventController.listen((res){
      print(res);
    });
    print("注册结果true");
    _loadSplashAd();
  }

  _loadSplashAd() async {
    Pangolin.loadSplashAd(slotId: "887315461", debug: true);
  }

  _loadRewardAd() async {
    await Pangolin.loadRewardAd(
        isHorizontal: false, slotId: "945133267", debug: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Center(
            child: RaisedButton(
              onPressed: () {
                _loadRewardAd();
              },
              child: Text("加载激励视频"),
            ),
          ),
        ),
      ),
    );
  }
}
