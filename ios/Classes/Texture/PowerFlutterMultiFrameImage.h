//
//  PowerFlutterMultiFrameImage.h
//  power_image
//
//  Created by 笙野 on 2021/11/18.
//

#import "PowerFlutterImage.h"
@class PowerImageFrame;

@interface PowerFlutterMultiFrameImage : PowerFlutterImage
- (instancetype)initWithImage:(UIImage *)image frames:(NSArray<PowerImageFrame *> *)frames;
@end


@interface PowerImageFrame : NSObject
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
+ (instancetype)frameWithImage:(UIImage *)image duration:(NSTimeInterval)duration;
@end
