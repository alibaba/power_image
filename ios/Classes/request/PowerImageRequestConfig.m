//
//  PowerImageRequestConfig.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageRequestConfig.h"

@interface PowerImageRequestConfig ()
@property (nonatomic, readwrite, strong) NSDictionary *src;
@property (nonatomic, readwrite, copy)   NSString *imageType;
@property (nonatomic, readwrite, copy)   NSString *renderingType;
@property (nonatomic, readwrite, assign) CGSize originSize;
@property (nonatomic, readwrite, assign) CGSize scaledSize;
@end

@implementation PowerImageRequestConfig

+ (instancetype)requestConfigWithArguments:(NSDictionary *)arguments {
    
    PowerImageRequestConfig *requestConfig = [[PowerImageRequestConfig alloc] init];
    requestConfig.src = arguments[@"src"];
    requestConfig.imageType = arguments[@"imageType"];
    requestConfig.renderingType = arguments[@"renderingType"];
    
    double width = 0.0;
    double height = 0.0;
    if ([arguments[@"width"] isKindOfClass:[NSNumber class]]) {
        width = [arguments[@"width"] doubleValue];
    }
    if ([arguments[@"height"] isKindOfClass:[NSNumber class]]) {
        height = [arguments[@"height"] doubleValue];
    }
    CGFloat scale = [UIScreen mainScreen].scale;

    requestConfig.originSize = CGSizeMake(width, height);
    requestConfig.scaledSize = CGSizeMake(width * scale, height * scale);
    
    return requestConfig;
}

- (NSString *)srcString {
    if (_src && [_src isKindOfClass:[NSDictionary class]]) {
        NSString *srcStr = _src[@"src"];
        if (srcStr && [srcStr isKindOfClass:[NSString class]]) {
            return srcStr;
        }
    }
    return nil;
}

- (NSString *)srcPackage {
    if (_src && [_src isKindOfClass:[NSDictionary class]]) {
        return _src[@"package"];
    }
    return nil;
}

@end
