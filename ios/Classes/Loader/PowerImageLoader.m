//
//  PowerImageLoader.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageLoader.h"
#import "PowerImageRequestConfig.h"


@interface PowerImageLoader ()
@property (nonatomic, strong) NSMutableDictionary *imageLoaders;
@end

@implementation PowerImageLoader
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PowerImageLoader *instance;
    dispatch_once(&onceToken, ^{
        instance = [[PowerImageLoader alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageLoaders = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerImageLoader:(id<PowerImageLoaderProtocol>)request forType:(NSString *)type {
    self.imageLoaders[type] = request;
}

- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    id <PowerImageLoaderProtocol>handler = self.imageLoaders[requestConfig.imageType];
    [handler handleRequest:requestConfig completed:completedBlock];
}
@end
