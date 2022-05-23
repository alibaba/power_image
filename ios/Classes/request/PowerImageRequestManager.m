//
//  PowerImageRequestManager.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageRequestManager.h"
#import <Flutter/Flutter.h>
#import "PowerImageBaseRequest.h"
#import "PowerImageTextureRequest.h"
#import "PowerImageExternalRequest.h"

@interface PowerImageRequestManager ()

@property (nonatomic, strong) NSMutableDictionary <NSString *, PowerImageBaseRequest *> * requests;
@property (nonatomic, weak) id<FlutterTextureRegistry> textureRegistry;

@end

@implementation PowerImageRequestManager


+ (instancetype)sharedInstance {
    static PowerImageRequestManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PowerImageRequestManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _requests = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)configWithTextureRegistry:(id<FlutterTextureRegistry>)textureRegistry {
    self.textureRegistry = textureRegistry;
}

/**
 * 初始化任务
 */
- (NSArray *)configRequestsWithArguments:(NSArray *)list{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < list.count; i++) {
        NSDictionary *arguments = list[i];

        NSString *renderType = [self _renderingType:arguments];
        PowerImageBaseRequest *request;
        if ([renderType isEqualToString:PowerImageRequestRenderTypeExternal]) {
            request = [[PowerImageExternalRequest alloc] initWithArguments:arguments];
        }else if ([renderType isEqualToString:PowerImageRequestRenderTypeTexture]) {
            request = [[PowerImageTextureRequest alloc] initWithArguments:arguments textureRegistry:self.textureRegistry];
        }else {
            continue;
        }
        
        self.requests[request.uniqueKey] = request;
        BOOL success = [request configTask];
        
        NSMutableDictionary *requestInfo = [request encode];
        requestInfo[@"success"] = @(success);
        [results addObject:requestInfo];
    }
    return results;
}

/**
* 取消任务
*/
- (NSArray *)releaseRequestsWithArguments:(NSArray *)list{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < list.count;  i++) {
        NSDictionary *arguments = list[i];
        NSString *uniqueKey = [self _uniqueKey:arguments];
        PowerImageBaseRequest *request = self.requests[uniqueKey];
        [self.requests removeObjectForKey:uniqueKey];
        if (!request) {
            continue;
        }
        BOOL success = [request stopTask];
        NSMutableDictionary *requestInfo = [request encode];
        requestInfo[@"success"] = @(success);
        [results addObject:requestInfo];
    }
    return results;
}

 /**
  * 开始图片加载的逻辑
  * 加载结果异步上报
  */
- (void)startLoadingWithArguments:(NSArray *)list {
    if (list.count == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < list.count; i++) {
        NSDictionary *arguments = list[i];
        NSString *uniqueKey = [self _uniqueKey:arguments];
        PowerImageBaseRequest *request = self.requests[uniqueKey];
        [request startLoading];
    }
}

- (NSString *)_uniqueKey:(NSDictionary *)arguments {
    return arguments[@"uniqueKey"];
}

- (NSString *)_renderingType:(NSDictionary *)arguments {
    return arguments[@"renderingType"];
}

@end
