import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:luojigou_image_picker/luojigou_image_picker.dart';
import 'package:luojigou_image_picker/util/video_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TempScaffold(),
    );
  }
}


class TempScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                onPressed: () => _onTapImage(context),
                child: Text('选择照片'),
              ),
              SizedBox(height: 50,),
              RaisedButton(
                onPressed: () => _onTapVideo(context),
                child: Text('选择视频'),
              )
            ],
          ),
        )
    );
  }

  _onTapImage(BuildContext context) async {
    var temp = await LjgImagePicker.pickerImage();
    print('temp===$temp');
  }

  _onTapVideo(BuildContext context) async {
    LJGVideoCutModel temp = await LjgImagePicker.pickerVideo(context);
    print('temp===${temp.path}}');
  }
}

