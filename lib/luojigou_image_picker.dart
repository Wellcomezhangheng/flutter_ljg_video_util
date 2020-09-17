import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_pickers/CropConfig.dart';
import 'package:image_pickers/Media.dart';
import 'package:flutter/material.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:image_pickers/UIConfig.dart';
import 'package:luojigou_image_picker/util/video_cut_page.dart';
import 'package:luojigou_image_picker/util/video_model.dart';

import 'video_cut/video_editor_cut.dart';

/// 带两个动态返回值的回调

class LjgImagePicker {
  static const MethodChannel _channel = const MethodChannel('ljg_image_picker');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 返回的是filePath
  static Future<List<String>> pickerImage({
    Color themeColor = Colors.white,
    int selectCount: 9,
    bool showCamera: true,
    CropConfig cropConfig,
    int compressSize: 500,
  }) async {
    List<Media> mediaList = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.image,
      selectCount: selectCount,
      showCamera: showCamera,
      cropConfig: cropConfig,
      compressSize: compressSize,
      uiConfig: UIConfig(uiThemeColor: themeColor),
    );
    return mediaList.map((e) => e.path).toList();
  }

  ///  返回的是filePath
  ///  获取视频
  ///  视频需要压缩
  static Future<LJGVideoCutModel> pickerVideo(
      BuildContext context, {
        bool isCompression = true,
        Color themeColor = Colors.white,
        bool showCamera: true,
      }) async {
    List<Media> mediaList = await ImagePickers.pickerPaths(
      galleryMode: GalleryMode.video,
      selectCount: 1,
      showCamera: showCamera,
      uiConfig: UIConfig(uiThemeColor: themeColor),
    );

    if (mediaList == null || mediaList.length == 0) {
      return null;
    }

    if (!isCompression) {
      return LJGVideoCutModel(thumbImageData: File(mediaList.first.thumbPath).readAsBytesSync(), path: mediaList.first.path);
    }

    VideoCut _videoCut = VideoCut();
    await _videoCut.loadVideo(videoFile: File(mediaList.first.path));
    return Navigator.push(context,
        CupertinoPageRoute(builder: (_) {
          return VideoCutPage(_videoCut);
        })).then((value) {
      if (value != null) {
        String videoFilePath = value[0];
        Uint8List imageData;
        if (Platform.isAndroid) {
          imageData = File(value[1]).readAsBytesSync();
        } else {
          imageData = value[1];
        }

        // ignore: missing_return
        return LJGVideoCutModel(thumbImageData: imageData, path: videoFilePath);

      }
      return null;
    });
  }

}
