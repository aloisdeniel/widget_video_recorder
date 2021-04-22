import 'dart:io';

import '../platform.dart';
import 'png.dart';

class WidgetRecorderVideoProcessor extends WidgetRecorderPngProcessor {
  WidgetRecorderVideoProcessor({
    required this.format,
  });

  File? _video;
  File get video => _video!;

  final RecordVideoFormat format;

  @override
  Future<void> complete() async {
    await super.complete();
    _video = await WidgetVideoRecorderPlugin.buildVideo(pngFiles, format);
  }
}
