//
//  PowerImageEngineContext.m
//  power_image
//
//  Created by 杨正灿 on 2023/10/9.
//

#import "PowerImageEngineContext.h"
#import "PowerImageRequestManager.h"

@interface PowerImageEngineContext ()
@property (nonatomic, copy) FlutterEventSink eventSink;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *sendQueue;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) PowerImageRequestManager *powerImageRequestManager;
@end

@implementation PowerImageEngineContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.powerImageRequestManager = [[PowerImageRequestManager alloc] initWithEngineContext:self];
        self.sendQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    self.pluginRegistry = registrar.textures;
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:@"power_image/method" binaryMessenger:[registrar messenger]];
    __weak typeof(self) weakSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        __strong typeof(self) self = weakSelf;
        [self handleMethodCall:call result:result];
    }];
    
    self.eventChannel = [FlutterEventChannel eventChannelWithName:@"power_image/event" binaryMessenger:[registrar messenger]];
    [self.eventChannel setStreamHandler:self];
    
    [self.powerImageRequestManager configWithTextureRegistry:registrar.textures];
}

- (void)onDetached {
    if (self.methodChannel != nil) {
        [self.methodChannel setMethodCallHandler:nil];
    }
    
    if (self.eventChannel != nil) {
        [self.eventChannel setStreamHandler:nil];
    }
}

- (void)setMyEventSkin: (FlutterEventSink) eventSkin {
    self.eventSink = eventSkin;
    // 当捕捉到eventSkin后, 从预回传的数据队列中一个个回传
    for (NSMutableDictionary *sendDic in self.sendQueue) {
        self.eventSink(sendDic);
    }
    // 回传完毕清空队列
    [self.sendQueue removeAllObjects];
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
  eventSink:(FlutterEventSink)eventSink {
    [self setMyEventSkin:eventSink];
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (void)sendImageStateEvent:(NSMutableDictionary *)event success:(BOOL)success {
    if (!event) {
        return;
    }
    
    // 多引擎下, evenSkin获取会有延迟, 所以这里加个队列,保存所有等待回传的数据
    if (!self.eventSink) {
        event[@"eventName"] = @"onReceiveImageEvent";
        event[@"success"] = @(success);
        [self.sendQueue addObject:event];
    } else {
        event[@"eventName"] = @"onReceiveImageEvent";
        event[@"success"] = @(success);
        self.eventSink(event);
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"startImageRequests" isEqualToString:call.method]) {
        NSArray *arguments = call.arguments;
        NSArray *results = [self.powerImageRequestManager configRequestsWithArguments:arguments];
        result(results);
        [self.powerImageRequestManager startLoadingWithArguments:arguments]; // 开始图片加载任务
    } else if ([@"releaseImageRequests" isEqualToString:call.method]) {
        NSArray *arguments = call.arguments;
        NSArray *results = [self.powerImageRequestManager releaseRequestsWithArguments:arguments];
        result(results);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
