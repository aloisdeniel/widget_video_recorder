import Flutter
import UIKit

public class SwiftWidgetVideoRecorderPlugin: NSObject, FlutterPlugin, SpitfireDelegate {
   lazy var spitfire: Spitfire = {
          return Spitfire(delegate: self)
  }()
    
  var videoResult : FlutterResult?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.aloisdeniel/widget_video_recorder", binaryMessenger: registrar.messenger())
    let instance = SwiftWidgetVideoRecorderPlugin()
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
            let format = arguments["format"] as? String;
            if let imagePaths = arguments["images"] as? [String] {
                
                do {
                if(format == "gif") {
                    let images = try imagePaths.map{ UIImage(data: try Data(contentsOf: URL(fileURLWithPath: $0)))! }
                   
                    guard let url = UIImage.animatedGif(from: images) else {
                        throw VideoExportError.failed("Failed gif export")
                    }
                    result(url.absoluteString);
                    self.videoResult = nil;
                    
                }
                else {
                    try spitfire.makeVideo(with: imagePaths, format: format == "hevc" ? VideoDataFormat.hevc : VideoDataFormat.h264)
                }
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

enum VideoExportError: Error {
    case failed(String)
}
