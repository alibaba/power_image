//
//  PowerImageTextureRequest.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageTextureRequest.h"
#import "PowerImageRequestConfig.h"
#import "PowerImageTexture.h"
#import "PowerImageDispatcher.h"
#import "PowerImagePlugin.h"
#import "PowerImageLoader.h"
#import "PowerFlutterImage.h"

@interface PowerImageTextureRequest ()
@property (nonatomic, strong) PowerImageRequestConfig *imageRequest;
@property (nonatomic, weak) id<FlutterTextureRegistry> textureRegistry;
@property (nonatomic, strong) PowerImageTexture *flutterTexture;
@property (nonatomic, assign) BOOL isStopped;
@property (nonatomic, assign) NSInteger imageRealWidth;
@property (nonatomic, assign) NSInteger imageRealHeight;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation PowerImageTextureRequest

- (instancetype)initWithEngineContext:(PowerImageEngineContext *)context arguments:(NSDictionary *)arguments textureRegistry:(id<FlutterTextureRegistry>)textureRegistry {
    self = [super initWithEngineContext:context arguments:arguments];
    if (self) {
        _textureRegistry = textureRegistry;
        _isStopped = NO;
        _lock = [NSLock new];
    }
    return self;
}

- (void)performLoadImage {
    __weak typeof(self) weakSelf = self;
    [[PowerImageLoader sharedInstance] handleRequest:self.imageRequestConfig completed:^(PowerImageResult *powerImageResult){
        __strong typeof(self) self = weakSelf;
        [self requestResultWithPowerImageResult:powerImageResult];
    }];
}


- (void)requestResultWithPowerImageResult:(PowerImageResult *)powerImageResult {
    [super requestResultWithPowerImageResult:powerImageResult];
    if (powerImageResult == nil) {
        [self onLoadFailed:@"PowerImageTextureRequest requestResultWithPowerImageResult PowerImageResult nil"];
        return;
    }

    
    if (!powerImageResult.success) {
        [self onLoadFailed:powerImageResult.errMsg];
        return;
    }
           
    if (self.isStopped) {
        [self onLoadFailed:@"PowerImageTextureRequest requestResultWithPowerImageResult isStopped"];
        return;
    }

    if (!powerImageResult.image) {
        [self onLoadFailed:@"PowerImageTextureRequest requestResultWithPowerImageResult image nil"];
        return;
    }
    
    self.imageRealWidth = CGImageGetWidth(powerImageResult.image.image.CGImage);
    self.imageRealHeight = CGImageGetHeight(powerImageResult.image.image.CGImage);
    
    @try {
        [self.lock lock];
        if (!self.flutterTexture) {
            self.flutterTexture = [[PowerImageTexture alloc] initWithLock:self.lock];
            self.flutterTexture.textureId = @([self.textureRegistry registerTexture:self.flutterTexture]);
            [self.flutterTexture setTextureDestoryBlock:^(id<FlutterTexture>  _Nonnull texture) {
                [powerImageResult.image destory];
            }];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [self.lock unlock];
    }

    [self performDrawWithImage:powerImageResult.image andSize:CGSizeZero];
}

- (void)performDrawWithImage:(PowerFlutterImage *)image andSize:(CGSize)size {
    __weak typeof(self) weakSelf = self;
    [[PowerImageDispatcher sharedInstance] runOnWorkThread:^{
        __strong typeof(self) self = weakSelf;
        if (self.isStopped) {
            [self onLoadFailed:@"PowerImageTextureRequest performDrawWithImage isStopped"];
            return;
        }
        
        @try {
            [self.lock lock];
            [image draw:self.flutterTexture textureRegistry:self.textureRegistry size:size];
//            [self.flutterTexture updatePixelBufferWithImage:image andSize:size];
            
//            [self.textureRegistry textureFrameAvailable:[self.flutterTexture.textureId longLongValue]];
        } @catch (NSException *exception) {
            
        } @finally {
            [self.lock unlock];
        }
        
        [self onLoadSuccess];
    }];
}



- (BOOL)stopTask {
    self.isStopped = YES;
    
    @try {
        [self.lock lock];
        if (self.flutterTexture) {
            
            [self.flutterTexture clear];
            //TODO 有可能之前因为isStopped，并没有注册进去
            [self.textureRegistry unregisterTexture:[self.flutterTexture.textureId longLongValue]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        [self.lock unlock];
    }
    self.imageTaskState = PowerImageRequestStateReleaseSucceed;
    return YES;
}

- (NSMutableDictionary *)encode {
    NSMutableDictionary *encodedRequest = [super encode];
    encodedRequest[@"width"] = @(self.imageRealWidth);
    encodedRequest[@"height"] = @(self.imageRealHeight);
    if (self.flutterTexture) {
        encodedRequest[@"textureId"] = self.flutterTexture.textureId;
    }
    return encodedRequest;
}


@end
