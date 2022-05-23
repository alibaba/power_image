//
//  PowerFlutterImage.m
//  power_image
//
//  Created by 笙野 on 2021/11/18.
//

#import "PowerFlutterImage.h"

@implementation PowerFlutterImage

- (instancetype)initWithImage:(UIImage *)image{
    if (self = [super init]) {
        self.image = image;
    }
    return self;
}

- (NSUInteger)frameCount {
    return 1;
}

- (CGFloat)width {
    return self.image.size.width;
}
- (CGFloat)height {
    return self.image.size.height;

}
- (void)draw:(PowerImageTexture *)texture textureRegistry:(id<FlutterTextureRegistry>)registry size:(CGSize)size {
    [texture updatePixelBufferWithImage:self.image andSize:size];
    [registry textureFrameAvailable:[texture.textureId longLongValue]];
}

- (void)destory {
    
}

@end
