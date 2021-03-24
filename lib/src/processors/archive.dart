import 'dart:typed_data';
import 'package:archive/archive.dart';

import 'processor.dart';

class WidgetRecorderArchiveProcessor extends WidgetRecorderProcessor {
  WidgetRecorderArchiveProcessor({
    this.fileNameTemplate = '{{index}}',
  });

  final String fileNameTemplate;
  Archive? _archive;
  Archive get archive => _archive!;

  @override
  Future<void> start() async {
    _archive = Archive();
  }

  @override
  Future<void> processFrame(int index, int total, Uint8List bytes) async {
    final name =
        this.fileNameTemplate.replaceAll('{{index}}', index.toString());
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  }

  @override
  Future<void> complete() => Future.value();

  @override
  Future<void> dispose() => Future.value();
}
