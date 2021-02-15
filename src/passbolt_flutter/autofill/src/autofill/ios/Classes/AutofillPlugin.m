#import "AutofillPlugin.h"
#if __has_include(<autofill/autofill-Swift.h>)
#import <autofill/autofill-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "autofill-Swift.h"
#endif

@implementation AutofillPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAutofillPlugin registerWithRegistrar:registrar];
}
@end
