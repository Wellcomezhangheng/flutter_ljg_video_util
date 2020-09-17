#import "LuojigouImagePickerPlugin.h"
#if __has_include(<luojigou_image_picker/luojigou_image_picker-Swift.h>)
#import <luojigou_image_picker/luojigou_image_picker-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "luojigou_image_picker-Swift.h"
#endif

@implementation LuojigouImagePickerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftLuojigouImagePickerPlugin registerWithRegistrar:registrar];
}
@end
