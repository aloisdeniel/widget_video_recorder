#import "WidgetVideoRecorderPlugin.h"
#if __has_include(<widget_video_recorder/widget_video_recorder-Swift.h>)
#import <widget_video_recorder/widget_video_recorder-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "widget_video_recorder-Swift.h"
#endif

@implementation WidgetVideoRecorderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWidgetVideoRecorderPlugin registerWithRegistrar:registrar];
}
@end
