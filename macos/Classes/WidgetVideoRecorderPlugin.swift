import Cocoa
import FlutterMacOS

public class WidgetVideoRecorderPlugin: NSObject, FlutterPlugin, SpitfireDelegate {
  lazy var spitfire: Spitfire = {
          return Spitfire(delegate: self)
  }()
    
  var videoResult : FlutterResult?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.aloisdeniel/widget_video_recorder", binaryMessenger: registrar.messenger)
    let instance = WidgetVideoRecorderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "buildVideo":
       self.buildVideo(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

       

  private func buildVideo(call: FlutterMethodCall, result: @escaping (FlutterResult)) {
    if(self.videoResult != nil) {
      result(FlutterError(code: "ALREADY_RUNNING",
        message: "A video is already being built",
        details: nil));
      return;
    }
    else {
      self.videoResult = result;
        
        if let arguments = call.arguments as? Dictionary<String, Any> {
            if let imagePaths = arguments["images"] as? [String] {
                do {
                    try spitfire.makeVideo(with: imagePaths)
                }
                catch {
                  result(FlutterError(code: "FAILED_LOAD_IMAGE",
                    message: error.localizedDescription,
                    details: nil));
                }
            }
        }
    }
  }
    
   public func videoProgress(progress: Progress) {
    // IGNORED
   }
    
   public func videoCompleted(url: URL) {
    if let result = self.videoResult {
        result(url.absoluteString);
        self.videoResult = nil;
    }
   }
    
   public func videoFailed(error: SpitfireError){
    if let result = self.videoResult {
        result(FlutterError(code: "BUILD_VIDEO_FAILED",
      message: error.localizedDescription,
      details: nil));
     self.videoResult = nil;
    }
  }
}
