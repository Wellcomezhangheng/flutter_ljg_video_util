/// Supported storage locations.
///
/// * [temporaryDirectory]
///
/// * [applicationDocumentsDirectory]
///
/// * [externalStorageDirectory]
///
class FileStorageDir {
  const FileStorageDir._(this.index);

  final int index;

  static const FileStorageDir temporaryDirectory = FileStorageDir._(0);
  static const FileStorageDir applicationDocumentsDirectory = FileStorageDir._(1);
  static const FileStorageDir externalStorageDirectory = FileStorageDir._(2);

  static const List<FileStorageDir> values = <FileStorageDir>[
    temporaryDirectory,
    applicationDocumentsDirectory,
    externalStorageDirectory,
  ];

  @override
  String toString() {
    return const <int, String>{
      0: 'temporaryDirectory',
      1: 'applicationDocumentsDirectory',
      2: 'externalStorageDirectory',
    }[index];
  }
}
