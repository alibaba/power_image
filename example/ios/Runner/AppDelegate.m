#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

#import <power_image/PowerImageLoader.h>

#import "PowerImageNetworkImageLoader.h"
#import "PowerImageAssetsImageLoader.h"
#import "PowerImageFlutterAssetImageLoader.h"
#import "PowerImageFileImageLoader.h"
#import <SDWebImage/SDWebImage.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageNetworkImageLoader new] forType:kPowerImageImageTypeNetwork];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageAssetsImageLoader new] forType:kPowerImageImageTypeNativeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFlutterAssetImageLoader new] forType:kPowerImageImageTypeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFileImageLoader new] forType:kPowerImageImageTypeFile];
    [SDImageCacheConfig defaultCacheConfig].maxMemoryCount = 20;
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
