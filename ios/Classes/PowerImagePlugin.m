#import "PowerImagePlugin.h"
#import "PowerImageRequestManager.h"
#import "PowerImageEngineContext.h"

@interface PowerImagePlugin ()
@property (nonatomic, strong) NSMutableArray<PowerImageEngineContext *> *engineContexts;
@end

@implementation PowerImagePlugin

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PowerImagePlugin *instance;
    dispatch_once(&onceToken, ^{
        instance = [[PowerImagePlugin alloc] init];
    });
    return instance;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    if ([PowerImagePlugin sharedInstance].engineContexts == nil) {
        [PowerImagePlugin sharedInstance].engineContexts = [[NSMutableArray alloc] init];
    }
    PowerImageEngineContext *engineContext = [[PowerImageEngineContext alloc] init];
    [engineContext registerWithRegistrar:registrar];
    [[PowerImagePlugin sharedInstance].engineContexts addObject:engineContext];
}

- (void)detachForRegistrar:(NSObject<FlutterTextureRegistry>*)registry {
    for (int i = 0; i< self.engineContexts.count; i++) {
        PowerImageEngineContext *engineContext = self.engineContexts[i];
        if (engineContext.pluginRegistry == registry) {
            [engineContext onDetached];
            [self.engineContexts removeObject:engineContext];
            break;
        }
    }
}

@end
