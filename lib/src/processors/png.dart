import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'processor.dart';

class WidgetRecorderPngProcessor extends WidgetRecorderProcessor {
  WidgetRecorderPngProcessor({
    this.fileNameTemplate = '{{index}}',
    Directory? directory,
  }) : _directory = directory;

  Directory? _directory;
  final String fileNameTemplate;
  List<File> _pngFiles = <File>[];
  List<File> get pngFiles => [
        ..._pngFiles,
      ];

  @override
  Future<void> start() async {
    _pngFiles = <File>[];
    _directory ??= await getTemporaryDirectory();
  }

  @override
  Future<void> processFrame(int index, int total, Uint8List bytes) async {
    final name =
        this.fileNameTemplate.replaceAll('{{index}}', index.toString());
    final file = File(path.join(_directory!.path, name));
    await file.writeAsBytes(bytes);
    _pngFiles.add(file);
  }

  @override
  Future<void> complete() => Future.value();

  @override
  Future<void> dispose() => Future.value();
}
