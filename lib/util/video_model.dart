import 'dart:typed_data';

class LJGVideoCutModel {
  ///视频缩略图图片data
  final Uint8List thumbImageData;

  ///视频路径路径
  final String path;

  LJGVideoCutModel({this.thumbImageData, this.path});
}