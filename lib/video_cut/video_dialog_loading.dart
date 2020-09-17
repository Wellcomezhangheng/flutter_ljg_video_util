import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:event_bus/event_bus.dart';

EventBus ljgEventBus = EventBus();

class VideoDialogLoading {

  static void show(BuildContext context) {
    Navigator.of(context).push(_DialogRouter(_LJGLoadingWidget()));
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _DialogRouter extends PageRouteBuilder{

  final Widget page;

  _DialogRouter(this.page)
      : super(
    opaque: false,
    barrierColor: Color(0x00000001),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

class _LJGLoadingWidget extends Dialog {

  final String loadingText;

  _LJGLoadingWidget({this.loadingText});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Material(
          //创建透明层
            type: MaterialType.transparency, //透明类型
            child: _StarParentDialogContentWidget()
        ),
        onWillPop: () async {
          return Future.value(false);
        });
  }
}

class _StarParentDialogContentWidget extends StatefulWidget {
  @override
  _StarParentDialogContentWidgetState createState() => _StarParentDialogContentWidgetState();
}

class _StarParentDialogContentWidgetState extends State<_StarParentDialogContentWidget> {

  var _event;
  String _uploadText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupState();
    _addListen();
  }

  // 初始化
  void _setupState() {
    _uploadText = '正在压缩';
  }

  // 添加信息状态改变监听
  _addListen() {
    _event = ljgEventBus.on<LJGVideoCompressTextChange>().listen((event) async{
      _uploadText = event.uploadText;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _event?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      //保证控件居中效果
      child: Container(
        height: 125,
        width: 125,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset(
                'assets/loading/loading.json',
                package: 'luojigou_image_picker',
                height: 80,
                width: 80,
              ),

              _uploadText == null ? Container() : Text(_uploadText, style: TextStyle(fontSize: 12, color: Colors.white),),
            ],
          ),
        ),
      ) ,
    );
  }
}


/// 发送上传状态信息通知
class LJGVideoCompressTextChange {
  // 状态
  String uploadText;
  LJGVideoCompressTextChange(this.uploadText);
}

/// 发送上传状态信息通知
class LJGVideoCompressChange {
  static void fireEventBusText(String text) {
    ljgEventBus.fire(LJGVideoCompressTextChange(text));
  }
}


