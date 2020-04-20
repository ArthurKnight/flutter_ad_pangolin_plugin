import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:pangolin/pangolin.dart' as Pangolin;

import 'index_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }

}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    //_loadSplashAd();
  }

  _loadSplashAd() async {
    Pangolin.loadSplashAd(slotId: "887315461", debug: true).timeout(Duration(seconds: 5),onTimeout: (){
      print("加载开屏超时");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IndexPage();
      }));
    }).catchError((e){
      print("catch error $e");
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return IndexPage();
      }));
    });
  }

  _loadRewardAd() async {
    var result = await Pangolin.loadRewardAd(
      //isHorizontal: false, slotId: "945133267", debug: true);
        isHorizontal: false, slotId: "945134382",rewardName: "getOneBottle", debug: true);
    print("加载完成");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Center(
              child: RaisedButton(
                onPressed: () {
                  _loadRewardAd();
                },
                child: Text("加载激励视频"),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Pangolin.loadExpressAd(slotId: "945141670");
              },
              child: Text("加载原生广告"),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return IndexPage();
                }));
              },
              child: Text("加载信息流"),
            ),
            /*RaisedButton(
              onPressed: (){
                Pangolin.loadFullscreenVideoAdWithSlotID(slotId: "945142947");
              },
              child: Text("加载全屏视频"),
            ),
            RaisedButton(
              onPressed: () {
                Pangolin.showFullscreenVideoAd();
              },
              child: Text("展示全屏视频"),
            ),*/
            RaisedButton(
              onPressed: (){
                Pangolin.loadFullscreenVideoAdWithSlotID(slotId: "945142947");
              },
              child: Text("加载并展示全屏视频"),
            ),
            /*RaisedButton(
              onPressed: () {
                Pangolin.loadInterstitialWithSlotID(slotId: "945143188");
              },
              child: Text("加载插屏广告"),
            ),
            RaisedButton(
              onPressed: () {
                Pangolin.showInterstitial();
              },
              child: Text("展示全屏视频"),
            ),*/
            RaisedButton(
              onPressed: (){
                Pangolin.loadInterstitialWithSlotID(slotId: "945143188");
              },
              child: Text("加载并展示插屏广告"),
            ),


          ],
        ),
      )
    );
  }
}

