//
//  PowerImageRequest.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import "PowerImageRequestConfig.h"
#import "PowerImageLoader.h"
#import "PowerImageEngineContext.h"

static NSString * const PowerImageRequestStateInitializeSucceed = @"initializeSucceed";
static NSString * const PowerImageRequestStateInitializeFailed = @"initializeFailed";
static NSString * const PowerImageRequestStateLoadSucceed = @"loadSucceed";
static NSString * const PowerImageRequestStateLoadFailed = @"loadFailed";
static NSString * const PowerImageRequestStateReleaseSucceed = @"releaseSucceed";
static NSString * const PowerImageRequestStateReleaseFailed = @"releaseFailed";

static NSString * const PowerImageRequestRenderTypeExternal = @"external";
static NSString * const PowerImageRequestRenderTypeTexture = @"texture";

@interface PowerImageBaseRequest : NSObject
@property (nonatomic, strong) PowerImageRequestConfig *imageRequestConfig;
@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, copy) NSString *imageTaskState;


- (instancetype)initWithEngineContext:(PowerImageEngineContext *)context arguments:(NSDictionary *)arguments;

- (BOOL)configTask;

- (BOOL)startLoading;

- (BOOL)stopTask;

- (void)onLoadSuccess;
- (void)onLoadFailed:(NSString *)errMsg;
- (void)requestResultWithPowerImageResult:(PowerImageResult *)imageResult;

- (NSMutableDictionary *)encode;
@end

