import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'processors/processor.dart';

part 'controller.dart';

class WidgetRecorder extends StatefulWidget {
  const WidgetRecorder({
    Key? key,
    required this.child,
    required this.controller,
    required this.processor,
    required this.animationController,
    this.onCompleted,
    this.onProgress,
    this.onStarted,
    this.width = 1920,
    this.height = 1080,
    this.fps = 30,
    this.previewBackgroundColor = const Color(0x00000000),
  }) : super(key: key);

  final Widget child;
  final double width;
  final double height;
  final double fps;
  final Color previewBackgroundColor;
  final AnimationController animationController;
  final WidgetRecorderProcessor processor;
  final WidgetRecorderController controller;
  final VoidCallback? onStarted;
  final ValueChanged<double>? onProgress;
  final VoidCallback? onCompleted;

  @override
  _WidgetRecorderState createState() => _WidgetRecorderState();
}

class _WidgetRecorderState extends State<WidgetRecorder> {
  GlobalKey previewContainer = GlobalKey();

  Future<void> _start() async {
    assert(!widget.controller.isRendering);
    widget.onStarted?.call();
    widget.controller._updateRendering(true);
    await widget.processor.start();
    await renderFrame(0);
    widget.onProgress?.call(0.0);
    widget.controller._updateProgress(0.0);
  }

  double _frameInterval() {
    final totalDurationInSeconds =
        widget.animationController.duration!.inMilliseconds / 1000.0;
    return 1 / (totalDurationInSeconds * widget.fps);
  }

  double _valueForIndex(int index) {
    return index * _frameInterval();
  }

  int _totalFrames() {
    return (1 / _frameInterval()).ceil();
  }

  double _progress(int index) {
    return _valueForIndex(index) * 0.8;
  }

  Future<void> renderFrame(int index) async {
    final newValue = _valueForIndex(index);
    final lastFrame = newValue >= 1;

    widget.animationController.value = newValue.clamp(0, 1);
    setState(() {});

    // Waiting for frame to be rendered
    await Future.delayed(const Duration(milliseconds: 50));

    final boundary = previewContainer.currentContext?.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    await widget.processor.processFrame(index, _totalFrames(), pngBytes);
    final progress = _progress(index);
    widget.onProgress?.call(progress);
    widget.controller._updateProgress(progress);
    if (!lastFrame) {
      renderFrame(index + 1);
    } else {
      await widget.processor.complete();
      widget.onCompleted?.call();
      widget.onProgress?.call(1.0);
      widget.controller._updateProgress(1.0);
      widget.controller._updateRendering(false);
    }
  }

  @override
  void initState() {
    widget.controller._state = this;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WidgetRecorder oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      widget.controller._state = this;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller._state = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        width: widget.width,
        height: widget.height,
        color: widget.previewBackgroundColor,
        child: RepaintBoundary(
          key: previewContainer,
          child: widget.child,
        ),
      ),
    );
  }
}
