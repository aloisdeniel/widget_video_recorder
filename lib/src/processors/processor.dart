import 'dart:typed_data';

abstract class WidgetRecorderProcessor {
  Future<void> start();
  Future<void> processFrame(
    int index,
    int total,
    Uint8List bytes,
  );
  Future<void> complete();

  Future<void> dispose();
}
