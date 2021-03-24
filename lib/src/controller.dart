part of 'recorder.dart';

class WidgetRecorderController extends ChangeNotifier {
  void start() {
    if (_state == null) {
      throw Exception(
          'The controller should be affected to a widget recorder.');
    }
    _state!._start();
  }

  bool _isRendering = false;
  bool get isRendering => _isRendering;

  void _updateRendering(bool value) {
    if (value != _isRendering) {
      _isRendering = value;
      notifyListeners();
    }
  }

  double _progress = 0.0;
  double get progress => _progress;

  void _updateProgress(double value) {
    if (value != _progress) {
      _progress = value;
      notifyListeners();
    }
  }

  _WidgetRecorderState? _state;
}
