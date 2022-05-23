//
//  PowerImageResult.h
//  power_image
//
//  Created by 王振辉 on 2021/8/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PowerFlutterImage.h"
#import "PowerFlutterMultiFrameImage.h"

@interface PowerImageResult : NSObject
/// loaded image
@property (nonatomic, readonly, strong) PowerFlutterImage *image;
/// success
@property (nonatomic, readonly, assign) BOOL success;
/// error message
@property (nonatomic, readonly, copy)   NSString *errMsg;


/// success
+ (instancetype)successWithImage:(UIImage *)image;

/// Animated image
/// See PowerFlutterMultiFrameImage for detail
+ (instancetype)successWithPowerFlutterImage:(PowerFlutterImage *)image;

/// fail
+ (instancetype)failWithMessage:(NSString *)errMsg;

@end

