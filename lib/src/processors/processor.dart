import 'dart:typed_data';

abstract class WidgetRecorderProcessor<T> {
  Future<void> start();
  Future<void> processFrame(
    int index,
    int total,
    Uint8List bytes,
  );
  Future<T> complete();

  Future<void> dispose();
}
