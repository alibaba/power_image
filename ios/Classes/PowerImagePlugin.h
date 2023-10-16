#import <Flutter/Flutter.h>

@interface PowerImagePlugin : NSObject<FlutterPlugin>
+ (instancetype)sharedInstance;
- (void)detachForRegistrar:(NSObject<FlutterTextureRegistry>*)registry;
@end
