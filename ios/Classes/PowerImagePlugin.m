#import "PowerImagePlugin.h"
#import "PowerImageRequestManager.h"

@interface PowerImagePlugin ()
@property (nonatomic, copy) FlutterEventSink eventSink;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
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
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"power_image/method" binaryMessenger:[registrar messenger]];
    PowerImagePlugin* instance = [PowerImagePlugin sharedInstance];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    instance.eventChannel = [FlutterEventChannel eventChannelWithName:@"power_image/event" binaryMessenger:[registrar messenger]];
    [instance.eventChannel setStreamHandler:instance];
    
    [[PowerImageRequestManager sharedInstance] configWithTextureRegistry:registrar.textures];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"startImageRequests" isEqualToString:call.method]) {
        NSArray *arguments = call.arguments;
        NSArray *results = [[PowerImageRequestManager sharedInstance] configRequestsWithArguments:arguments];
        result(results);
        [[PowerImageRequestManager sharedInstance] startLoadingWithArguments:arguments]; // 开始图片加载任务
    } else if ([@"releaseImageRequests" isEqualToString:call.method]) {
        NSArray *arguments = call.arguments;
        NSArray *results = [[PowerImageRequestManager sharedInstance] releaseRequestsWithArguments:arguments];
        result(results);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (void)sendImageStateEvent:(NSMutableDictionary *)event success:(BOOL)success {
    if (!self.eventSink || !event) {
        return;
    }
    
    event[@"eventName"] = @"onReceiveImageEvent";
    event[@"success"] = @(success);
    self.eventSink(event);
}


@end
