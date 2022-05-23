//
//  PowerImageResult.m
//  power_image
//
//  Created by 王振辉 on 2021/8/3.
//

#import "PowerImageResult.h"

@interface PowerImageResult ()
@property (nonatomic, readwrite, strong) PowerFlutterImage *image;
@property (nonatomic, readwrite, assign) BOOL success;
@property (nonatomic, readwrite, copy)   NSString *errMsg;
@end

@implementation PowerImageResult

/// success
+ (instancetype)successWithImage:(UIImage *)image {
    return [self successWithPowerFlutterImage:[[PowerFlutterImage alloc] initWithImage:image]];
}

+ (instancetype)successWithPowerFlutterImage:(PowerFlutterImage *)image {
    PowerImageResult *result = [PowerImageResult new];
    result.success = true;
    result.image = image;
    return result;
}

/// fail
+ (instancetype)failWithMessage:(NSString *)errMsg {
    PowerImageResult *result = [PowerImageResult new];
    result.success = false;
    result.errMsg = errMsg;
    return result;
}

@end
