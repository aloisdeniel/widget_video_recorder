import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

enum RecordVideoFormat {
  hevc,
  h264,
  gif,
}

class WidgetVideoRecorderPlugin {
  static const platform =
      const MethodChannel('com.aloisdeniel/widget_video_recorder');

  /// Generate a video from the list of given [images].
  static Future<File> buildVideo(
      List<File> images, RecordVideoFormat format) async {
    final path = await platform.invokeMethod<String>('buildVideo', {
      'images': images.map((x) => x.path).toList(),
      'format': format.toString().replaceAll('RecordVideoFormat.', ''),
    });
    return File(path!.replaceAll('file://', ''));
  }
}
