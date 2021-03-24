import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:async';

import 'package:path/path.dart' as path;
import 'package:widget_video_recorder/widget_video_recorder.dart';

void main() {
  runApp(
    MaterialApp(
      home: RecorderExample(),
    ),
  );
}

class RecorderExample extends StatefulWidget {
  const RecorderExample({
    Key? key,
  }) : super(key: key);

  @override
  _RecorderExampleState createState() => _RecorderExampleState();
}

class _RecorderExampleState extends State<RecorderExample>
    with TickerProviderStateMixin {
  AnimationController? controller;
  WidgetRecorderController? recorderController;
  WidgetRecorderVideoProcessor videoProcessor = WidgetRecorderVideoProcessor();

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    recorderController = WidgetRecorderController();
    super.initState();
  }

  @override
  void dispose() {
    controller!.dispose();
    recorderController!.dispose();
    videoProcessor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: recorderController!,
        builder: (context, _) => Stack(
          children: [
            Positioned.fill(
              child: WidgetRecorder(
                controller: recorderController!,
                animationController: controller!,
                processor: videoProcessor,
                onCompleted: () async {
                  print('COMPLETED');

                  if (Platform.isMacOS) {
                    final file = XFile.fromData(
                      await videoProcessor.video.readAsBytes(),
                      name: 'video.mov',
                      mimeType: "video/quicktime",
                    );
                    final savePath = await getSavePath(
                        suggestedName:
                            path.basename(videoProcessor.video.path));
                    if (savePath != null) {
                      await file.saveTo(savePath);
                    }
                  } else {
                    try {
                      await FlutterFileDialog.saveFile(
                        params: SaveFileDialogParams(
                          sourceFilePath: videoProcessor.video.path,
                          fileName: 'video.mov',
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                previewBackgroundColor: Color(0xFF3DD69D),
                child: AnimatedExample(
                  animation: controller!,
                ),
              ),
            ),
            if (recorderController!.isRendering)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => recorderController!.start(),
        icon: Icon(Icons.save),
        label: Text('Export'),
      ),
    );
  }
}

class AnimatedExample extends StatelessWidget {
  const AnimatedExample({
    Key? key,
    required this.animation,
  }) : super(key: key);

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: Center(
          child: Container(
            color: Colors.red,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
