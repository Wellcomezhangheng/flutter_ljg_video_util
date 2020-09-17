
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luojigou_image_picker/video_cut/video_dialog_loading.dart';
import 'package:luojigou_image_picker/util/video_toast.dart';
import 'package:luojigou_image_picker/video_cut/video_editor.dart';
import 'package:luojigou_image_picker/video_cut/video_editor_cut.dart';
import 'package:luojigou_image_picker/video_cut/video_viewer.dart';

class VideoCutPage extends StatefulWidget {
  final VideoCut _trimmer;
  VideoCutPage(this._trimmer);
  @override
  _CutVideoPageState createState() => _CutVideoPageState();
}

class _CutVideoPageState extends State<VideoCutPage> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer.saveTrimmedVideo(startValue: _startValue, endValue: _endValue).then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }
  @override
  Widget build(BuildContext context) {
    return VideoToastHelper.initialize(
        Scaffold(
          appBar: AppBar(
            title: Text('视频裁剪'),
            elevation: 0.6,
            actions: <Widget>[
              confirmWidget(),
            ],
          ),
          body: Builder(
            builder: (context) => Center(
              child: Container(
                padding: EdgeInsets.only(bottom: 20+ MediaQuery.of(context).padding.bottom),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ///  保存的进度条
                    Container(
                      height: 2,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Visibility(
                        visible: _progressVisibility,
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFF23D321),
                        ),
                      ),
                    ),

                    Expanded(
                      child: VideoViewer(),
                    ),

                    Center(
                      child: VideoEditor(
                        viewerHeight: 50.0,
                        circlePaintColor: Color(0xFF23D321),
                        borderPaintColor: Color(0xFF23D321),
                        viewerWidth: MediaQuery.of(context).size.width,
                        onChangeStart: (value) {
                          _startValue = value;
                        },
                        onChangeEnd: (value) {
                          _endValue = value;
                        },
                        onChangePlaybackState: (value) {
                          setState(() {
                            _isPlaying = value;
                          });
                        },
                      ),
                    ),
                    ///  播放暂停按钮
                    FlatButton(
                      child: _isPlaying
                          ? Icon(
                        Icons.pause,
                        size: 50.0,
                        color: Colors.white,
                      )
                          : Icon(
                        Icons.play_arrow,
                        size: 50.0,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }


  ///  确定按钮
  confirmWidget() {
    return Row(
      children: <Widget>[
        InkWell(
          onTap:  _progressVisibility
              ? null
              : () async {
            if ((_endValue - _startValue) / 1000 >= 16) {
              VideoToastHelper.showText('视频上传仅支持15秒及15秒以内的视频');
              return;
            }
            String filePath = await _saveVideo();
            if (filePath != null) {///  创建渠道
              const platform = const MethodChannel("com.luojigou.app/video");

              VideoDialogLoading.show(context);
              try {
                ///  渠道上面的压缩方法
                List result = await platform.invokeListMethod("compress", filePath);//分析2
                VideoDialogLoading.hide(context);
                Navigator.pop(context, result);
              } on PlatformException catch (e) {
                print(e.toString());
              }
            } else {
              VideoToastHelper.showText('视频截取失败');
            }
          },
          child: Container(
            margin: EdgeInsets.only(right: 16),
            height: 30,
            width: 56,
            decoration: BoxDecoration(
                color: Color(0xFF23D321),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Center(
                child: Text(
                  "确定",
                  style: TextStyle(color: Colors.white),
                )),
          ),
        )
      ],
    );
  }

  EventChannel _eventChannel = const EventChannel('com.luojigou.app/video_compress');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 监听开始

    if (Platform.isAndroid) {
      _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError, onDone: _onDone);
      // Android-specific code
    }

  }

  void _onEvent(Object event) {
    print('返回的内容: $event');
    LJGVideoCompressChange.fireEventBusText('正在压缩（${event.toString()} / 100）');
  }

  void _onError(Object error) {
    print('返回的错误');
  }

  void _onDone() {
    print('返回的完成');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}