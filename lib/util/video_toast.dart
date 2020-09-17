import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

/// toast弹框
class VideoToastHelper {
  ///
  /// 初始化,使用之前必须初始化
  ///
  static OKToast initialize(child) {
    return OKToast(
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white),
      backgroundColor: Colors.black.withOpacity(0.7),
      radius: 3.0,
      animationCurve: Curves.easeInOutSine,
      animationDuration: Duration(milliseconds: 200),
      duration: Duration(milliseconds: 1500),
      child: child,
    );
  }

  /// 纯文本提示
  static ToastFuture showText(String text, {int duration = 1500}) {
    dismiss();
    return showToast(
      text,
      duration: Duration(milliseconds: duration),
      position: ToastPosition.center,
      textStyle: TextStyle(fontSize: 14.0, color: Colors.white, decoration: TextDecoration.none,fontWeight: FontWeight.w400)
    );
  }

  /// 关闭提示
  static dismiss() {
    dismissAllToast();
  }
}
