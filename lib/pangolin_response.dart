import 'dart:typed_data';

import 'package:pangolin/pangolin.dart';

const String _errCode = "errCode";
const String _errStr = "errStr";

typedef BasePangolinResponse _PangolinResponseInvoker(Map argument);

Map<String, _PangolinResponseInvoker> _nameAndResponseMapper = {
  "rewardCloseEvent": (Map argument) =>
      onRewardResponse.fromMap(argument),
  "onRewardResponse": (Map argument) =>
      onRewardResponse.fromMap(argument),
};

class BasePangolinResponse {
  final int errCode;
  final String errStr;

  bool get isSuccessful => errCode == 0;

  BasePangolinResponse._(this.errCode, this.errStr);

  /// create response from response pool
  factory BasePangolinResponse.create(String name, Map argument) =>
      _nameAndResponseMapper[name](argument);
}

class onRewardResponse extends BasePangolinResponse {
  final bool rewardVerify;
  final int rewardAmount;
  final String rewardName;

  onRewardResponse.fromMap(Map map)
  : rewardVerify = map["rewardVerify"],
        rewardAmount = map["rewardAmount"],
        rewardName = map["rewardName"],
  super._(map[_errCode], map[_errStr]);
}