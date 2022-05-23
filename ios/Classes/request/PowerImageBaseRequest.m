//
//  PowerImageRequest.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageBaseRequest.h"
#import "PowerImageDispatcher.h"
#import "PowerImagePlugin.h"
#import "PowerFlutterMultiFrameImage.h"

@interface PowerImageBaseRequest()

@property (nonatomic, strong) PowerImageResult *result;

@end

@implementation PowerImageBaseRequest

- (instancetype)initWithArguments:(NSDictionary *)arguments {
    self = [super init];
    if (self) {
        _uniqueKey = arguments[@"uniqueKey"];
        _imageRequestConfig = [PowerImageRequestConfig requestConfigWithArguments:arguments];
    }
    return self;
}

- (BOOL)configTask {
    if (!self.imageRequestConfig) {
        self.imageTaskState = PowerImageRequestStateInitializeFailed;
        return NO;
    }
    self.imageTaskState = PowerImageRequestStateInitializeSucceed;
    return YES;
}


- (BOOL)startLoading {
    // TODO 如果开始加载失败  是否要上报状态
    if (![self.imageTaskState isEqualToString:PowerImageRequestStateInitializeSucceed] &&
            ![self.imageTaskState isEqualToString:PowerImageRequestStateLoadFailed]) {
            // 只有初始化好 或者 加载失败的情况可以重新加载
            return NO;
    }
    if (!self.imageRequestConfig) {
       // 保险起见 还是再做一次判空
       return NO;
    }
    
    [self performLoadImage];
    return YES;
}

- (void)performLoadImage {
    __weak typeof(self) weakSelf = self;
    [[PowerImageLoader sharedInstance] handleRequest:self.imageRequestConfig completed:^(PowerImageResult *powerImageResult){
        __strong typeof(self) self = weakSelf;
        [self requestResultWithPowerImageResult:powerImageResult];
    }];
}

- (void)requestResultWithPowerImageResult:(PowerImageResult *)powerImageResult {
    self.result = powerImageResult;
}

- (void)onLoadSuccess {
    __weak typeof(self) weakSelf = self;
    [[PowerImageDispatcher sharedInstance] runOnMainThread:^{
       __strong typeof(self) self = weakSelf;
       self.imageTaskState = PowerImageRequestStateLoadSucceed;
       [[PowerImagePlugin sharedInstance] sendImageStateEvent:[self encode] success:YES];
    }];
}

- (void)onLoadFailed:(NSString *)errMsg {
    __weak typeof(self) weakSelf = self;
    [[PowerImageDispatcher sharedInstance] runOnMainThread:^{
        __strong typeof(self) self = weakSelf;
        self.imageTaskState = PowerImageRequestStateLoadFailed;
        NSMutableDictionary *event = [self encode];
        event[@"errMsg"] = errMsg;
        [[PowerImagePlugin sharedInstance] sendImageStateEvent:event success:NO];
    }];
}

- (BOOL)stopTask {
    return false;
}

- (NSMutableDictionary *)encode {
    NSMutableDictionary *encodedTask = [[NSMutableDictionary alloc] init];
    encodedTask[@"uniqueKey"] = self.uniqueKey;
    encodedTask[@"state"] = self.imageTaskState;
    if (self.result != nil && self.result.success && [self.result.image isKindOfClass:[PowerFlutterMultiFrameImage class]]) {
        encodedTask[@"_multiFrame"] = @YES;
    }
    return encodedTask;
}

@end
