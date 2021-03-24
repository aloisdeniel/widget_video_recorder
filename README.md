# widget_video_recorder

Recording an animated widget and export it as a video.

## Quickstart

```dart
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
      body: WidgetRecorder(
        controller: recorderController!,
        animationController: controller!,
        processor: videoProcessor,
        onCompleted: () async {
            print('Video file path : ${videoProcessor.video}')
        },
        child: AnimatedExample(
            animation: controller!,
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
```

## Usage

### Recorder widget

The recorder widget will take a snapshot of your widget after moving its animation value for each frame.

```dart
WidgetRecorder(
  controller: recorderController!,
  animationController: controller!,
  processor: videoProcessor,
  onCompleted: () async {
    /// The processor has the result data
  },
  previewBackgroundColor: Color(0xFF3DD69D),
  child: AnimatedExample(
    animation: controller!,
  ),
)
```

### Export as a video

The recorded frames are exported as a video file.

```dart
final processor = WidgetRecorderVideoProcessor();
/// ... after completion
final file = processor.video;
```

# Platform compatibility

- [X] macOS - `.mov` - HEVC with transparency encoding - native APIs
- [X] iOS *(should be easy to add)*
- [ ] Android *(mmfpeg but transparency is probably not possible)*
- [ ] Windows
- [ ] Linux
- [ ] Web

### Export as PNG image files

The recorded frames are exported as independent `.png` files on local storage.

```dart
final processor = WidgetRecorderPngProcessor();
/// ... after completion
final files = processor.pngImages;
```

# Platform compatibility

- [X] macOS
- [X] iOS
- [X] Android
- [X] Windows
- [X] Linux
- [ ] Web

### Export as PNG images files in a zip archive

The recorded frames are exported as independent `.png` files stored in a `.zip` archive.

```dart
final processor = WidgetRecorderArchiveProcessor();
/// ... after completion
final archive = processor.archive;
```

# Platform compatibility

- [X] macOS
- [X] iOS
- [X] Android
- [X] Windows
- [X] Linux
- [X] Web