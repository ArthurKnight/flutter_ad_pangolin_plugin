
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding:EdgeInsets.all(10),
            child: Platform.isIOS?Container(
              width: 1080,
              height: 100,
              child: UiKitView(
                  viewType: "flutter_express_ad_view",
                  creationParams: <String, dynamic>{"text": "iOS Label"},
                  creationParamsCodec: StandardMessageCodec()),
            ):Container(),
          ),
          Container(
            padding:EdgeInsets.all(10),
            child: Container(),
          ),
          Container(
            padding:EdgeInsets.all(10),
            child: Platform.isIOS?Container(
              width: 1080,
              height: 100,
              child: UiKitView(
                  viewType: "flutter_express_ad_view",
                  creationParams: <String, dynamic>{"text": "iOS Label"},
                  creationParamsCodec: StandardMessageCodec()),
            ):Container(),
          )
        ],
      ),
    );
  }
}
