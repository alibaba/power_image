//
//  PowerImageTexture.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>



@interface PowerImageTexture : NSObject<FlutterTexture>

@property (nonatomic, strong) NSNumber *textureId;

///https://github.com/flutter/engine/pull/27441/files
///use metal or flutter  >= 2.8.0, should not call this;
///https://medium.com/flutter/announcing-flutter-1-17-4182d8af7f8e
///flutter 1.17, On the iOS devices that fully support Metal, Flutter now uses it by default
+ (void)patchMemoryLeakForOpenGLES;

- (instancetype)initWithLock:(NSLock *)lock;

- (void)clear;

- (void)updatePixelBufferWithImage:(UIImage *)image andSize:(CGSize)size;

- (BOOL)updatePixelBufferWithMultiImage:(UIImage *)image andSize:(CGSize)size;

@property (nonatomic, copy) void (^textureDestoryBlock)(id<FlutterTexture> texture);

@end


