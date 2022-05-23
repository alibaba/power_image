//
//  PowerImageTexture.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageTexture.h"

@interface PowerImageTexture ()
@property (nonatomic, assign) CVPixelBufferRef pixelBufferRef;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, assign) BOOL shouldRelease;
@end

@implementation PowerImageTexture

- (instancetype)initWithLock:(NSLock *)lock;
{
    self = [super init];
    if (self) {
        _lock = lock;
    }
    return self;
}

- (void)updatePixelBufferWithImage:(UIImage *)image andSize:(CGSize)size {
    if (!self.pixelBufferRef) {
        self.pixelBufferRef = [self createPixelBufferFromImage:image.CGImage andSize:size];
        self.shouldRelease = YES;
    }
}

- (BOOL)updatePixelBufferWithMultiImage:(UIImage *)image andSize:(CGSize)size {
    [self.lock lock];
    [self clear];
    self.pixelBufferRef = [self createPixelBufferFromImage:image.CGImage andSize:size];
    self.shouldRelease = YES;
    [self.lock unlock];
    if (self.pixelBufferRef != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (CVPixelBufferRef)createPixelBufferFromImage:(CGImageRef)image andSize:(CGSize)size {
    NSDictionary *options = @{
        (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @NO,
        (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @NO
    };
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGSize imageSize = [self _calculateTextureSizeWithRequestSize:size image:image];
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          imageSize.width,
                                          imageSize.height,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    if(status != kCVReturnSuccess || pxbuffer == NULL){
        return nil;
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace,
                                                 kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    
    
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width,
                                           imageSize.height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}



- (CGSize)_calculateTextureSizeWithRequestSize:(CGSize)requestSize image:(CGImageRef)image {
    if (CGSizeEqualToSize(requestSize, CGSizeZero)) {
        return CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    }else if (requestSize.width == 0) {
        
        CGFloat height = requestSize.height;
        CGFloat imageHeight = CGImageGetHeight(image);
        CGFloat width = height;
        if (imageHeight != 0) {
            width = height * CGImageGetWidth(image) / imageHeight;
        }
        return CGSizeMake(width, height);
        
    }else if (requestSize.height == 0){
        
        CGFloat width = requestSize.width;
        CGFloat imageWidth = CGImageGetWidth(image);
        CGFloat height = width;
        if (imageWidth != 0) {
            height = width * CGImageGetHeight(image) / imageWidth;
        }
        return CGSizeMake(width, height);
        
    }else {
        return requestSize;
    }
}


- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    @try {
        [self.lock lock];
        if (_patchMemoryLeakForOpenGLES) {
            self.shouldRelease = NO;
        }else {
            CVPixelBufferRetain(self.pixelBufferRef);
        }
        return self.pixelBufferRef;
    } @catch (NSException *exception) {
        
    } @finally {
        [self.lock unlock];
    }
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture> *)texture {
    [self.lock lock];
    if (self.textureDestoryBlock) {
        self.textureDestoryBlock(texture);
    }
    [self.lock unlock];
}

- (void)clear {
    if (_patchMemoryLeakForOpenGLES) {
        if (self.pixelBufferRef && self.shouldRelease) {
            CVPixelBufferRelease(self.pixelBufferRef);
            self.pixelBufferRef = nil;
        }
    }else {
        CVPixelBufferRelease(self.pixelBufferRef);
        self.pixelBufferRef = nil;
    }
}

static BOOL _patchMemoryLeakForOpenGLES = false;
+ (void)patchMemoryLeakForOpenGLES {
    _patchMemoryLeakForOpenGLES = true;
}

@end

