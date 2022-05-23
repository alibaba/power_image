//
//  PowerFlutterImage.h
//  power_image
//
//  Created by 笙野 on 2021/11/18.
//

#import <Foundation/Foundation.h>
#import "PowerImageTexture.h"

@interface PowerFlutterImage : NSObject

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic,strong) UIImage *image;


- (NSUInteger)frameCount;
- (CGFloat)width;
- (CGFloat)height;
- (void)draw:(PowerImageTexture *)texture textureRegistry:(id<FlutterTextureRegistry>)registry size:(CGSize)size;
/**
 销毁
 */
- (void)destory;

@end

