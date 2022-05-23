//
//  PowerFlutterMultiFrameImage.m
//  power_image
//
//  Created by 笙野 on 2021/11/18.
//

#import "PowerFlutterMultiFrameImage.h"
#import "PowerImageDispatcher.h"


@interface PowerFlutterMultiFrameImage()
@property (nonatomic, strong) CADisplayLink * displayLink;

@property (nonatomic, assign) int currentFrameIndex;// current frame
@property (nonatomic, assign) NSTimeInterval canShowDuration;// time difference between two frames

@property (nonatomic, strong, readwrite) PowerImageFrame *currentFrame;
@property (nonatomic, assign) BOOL needsDisplayWhenImageBecomesAvailable;

@property (nonatomic,weak) PowerImageTexture *flutterTexture;
@property (nonatomic,weak) id<FlutterTextureRegistry> textureRegistry;

@property (nonatomic, strong) NSArray<PowerImageFrame *> *frames;

@end

@implementation PowerFlutterMultiFrameImage


- (instancetype)initWithImage:(UIImage *)image frames:(NSArray<PowerImageFrame *> *)frames {
    if (self = [super initWithImage:image]) {
        self.frames = frames;
        self.canShowDuration = 0.0;
    }
    return self;
}


- (NSUInteger)frameCount {
    return self.frames.count;
}

- (void)draw:(PowerImageTexture *)texture textureRegistry:(id<FlutterTextureRegistry>)registry size:(CGSize)size {
    self.flutterTexture = texture;
    self.textureRegistry = registry;
    [[PowerImageDispatcher sharedInstance] runOnMainThread:^{
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateGif:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }];
    
}


- (void)updateGif:(CADisplayLink *)displayLink{
    if (!self.image) {
        return;
    }
    
    if (self.frameCount == 0) {
        self.displayLink.paused = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
        return;
    }
    
    if (self.currentFrameIndex >= self.frameCount) {
        self.currentFrameIndex = 0;
        return;
    }
    
    PowerImageFrame *currentFrame = self.frames[self.currentFrameIndex];
    if (currentFrame) {
        self.currentFrame = currentFrame;
        
        if (self.needsDisplayWhenImageBecomesAvailable) {
            [self updatePixelBufferWithImage];
            self.needsDisplayWhenImageBecomesAvailable = NO;
        }
        
        self.canShowDuration += displayLink.duration;
        while (self.canShowDuration >= self.frames[self.currentFrameIndex].duration) {
            self.canShowDuration -= self.frames[self.currentFrameIndex].duration;
            self.currentFrameIndex++;
            if (self.currentFrameIndex >= self.frameCount) {
                self.currentFrameIndex = 0;
            }
            self.needsDisplayWhenImageBecomesAvailable = YES;
        }
    }
}

- (void)updatePixelBufferWithImage {
    BOOL getRightBufferRef = [self.flutterTexture updatePixelBufferWithMultiImage:self.currentFrame.image andSize:self.currentFrame.image.size];
    if (getRightBufferRef) {
        [self.textureRegistry textureFrameAvailable:[self.flutterTexture.textureId longLongValue]];
    }
}


- (void)destory {
    [[PowerImageDispatcher sharedInstance] runOnMainThread:^{
        self.displayLink.paused = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }];
}

@end


@interface PowerImageFrame ()
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@end

@implementation PowerImageFrame

+ (instancetype)frameWithImage:(UIImage *)image duration:(NSTimeInterval)duration {
    PowerImageFrame *frame = [PowerImageFrame new];
    frame.image = image;
    frame.duration = duration;
    return frame;
}

@end
