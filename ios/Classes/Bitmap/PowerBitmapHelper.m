//
//  PowerBitmapHelper.m
//  power_image
//
//  Created by 王振辉 on 2021/7/20.
//

#import "PowerBitmapHelper.h"

@implementation PowerBitmapHelper

/// This Class Forked from SDWebImage/SDWebImage of [SDImageCoderHelper] Class.
/// see https://github.com/SDWebImage/SDWebImage/blob/fda0a57de98d391e8244cc0f80c583e2c67d9e8f/SDWebImage/Core/SDImageCoderHelper.m#L215
/// 
+ (CGImageRef)createBGRAFormatImageFromImageRef:(CGImageRef)cgImage {
    if (!cgImage) {
        return NULL;
    }
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    if (width == 0 || height == 0) return NULL;
    
    BOOL hasAlpha = [self CGImageContainsAlpha:cgImage];
    // iOS prefer BGRA8888 (premultiplied) or BGRX8888 bitmapInfo for screen rendering, which is same as `UIGraphicsBeginImageContext()` or `- [CALayer drawInContext:]`
    // Though you can use any supported bitmapInfo (see: https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/dq_context.html#//apple_ref/doc/uid/TP30001066-CH203-BCIBHHBB ) and let Core Graphics reorder it when you call `CGContextDrawImage`
    // But since our build-in coders use this bitmapInfo, this can have a little performance benefit
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, [self colorSpaceGetDeviceRGB], bitmapInfo);
    if (!context) {
        return NULL;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage); // The rect is bounding box of CGImage, don't swap width & height
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return newImageRef;
}

+ (CGColorSpaceRef)colorSpaceGetDeviceRGB {

    static CGColorSpaceRef colorSpace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        if (@available(iOS 9.0, tvOS 9.0, *)) {
            colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        } else {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }

    });
    return colorSpace;
}

+ (BOOL)CGImageContainsAlpha:(CGImageRef)cgImage {
    if (!cgImage) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}


+ (PowerPixelFormat)pixelFormatOfImageRef:(CGImageRef)cgImageRef {
    // AlphaFirst – the alpha channel is next to the red channel, argb and bgra are both alpha first formats.
    // AlphaLast – the alpha channel is next to the blue channel, rgba and abgr are both alpha last formats.
    // LittleEndian – blue comes before red, bgra and abgr are little endian formats.
    // Little endian ordered pixels are BGR (BGRX, XBGR, BGRA, ABGR, BGR).
    // BigEndian – red comes before blue, argb and rgba are big endian formats.
    // Big endian ordered pixels are RGB (XRGB, RGBX, ARGB, RGBA, RGB).

    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImageRef);
    BOOL alphaFirst = alphaInfo == kCGImageAlphaNoneSkipFirst || alphaInfo == kCGImageAlphaFirst || alphaInfo == kCGImageAlphaPremultipliedFirst;
    BOOL alphaLast = alphaInfo == kCGImageAlphaPremultipliedLast || alphaInfo == kCGImageAlphaNoneSkipLast || alphaInfo == kCGImageAlphaLast;
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImageRef);
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL endianLittle = kCGBitmapByteOrder32Little == byteOrderInfo || kCGBitmapByteOrder16Little == byteOrderInfo;
    
    if (alphaFirst && endianLittle) {
        return PowerPixelFormatBGRA;
    }else if (alphaFirst) {
        return PowerPixelFormatARGB;
    }else if (alphaLast && endianLittle) {
        return PowerPixelFormatABGR;
    }else if (alphaLast) {
        return PowerPixelFormatRGBA;
    }else {
        return PowerPixelFormatOthers;
    }
}

@end
