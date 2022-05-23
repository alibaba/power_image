//
//  PowerBitmapHelper.h
//  power_image
//
//  Created by 王振辉 on 2021/7/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//case abgr
//case argb
//case bgra
//case rgba

typedef NS_ENUM(NSUInteger, PowerPixelFormat) {
    /**
     * rgba
     */
    PowerPixelFormatRGBA = 0,
    /**
     * bgra
     */
    PowerPixelFormatBGRA,
    /**
     * abgr
     */
    PowerPixelFormatABGR,
    /**
     * argb
     */
    PowerPixelFormatARGB,
    /**
     * others
     */
    PowerPixelFormatOthers,
};

typedef NS_ENUM(NSUInteger, FlutterPixelFormat) {
    /**
     * rgba8888
     */
    FlutterPixelFormatRGBA8888 = 0,
    /**
     * bgra8888
     */
    FlutterPixelFormatBGRA8888,
};



@interface PowerBitmapHelper : NSObject

+ (PowerPixelFormat)pixelFormatOfImageRef:(CGImageRef)cgImageRef;

+ (CGImageRef)createBGRAFormatImageFromImageRef:(CGImageRef)cgImage;

@end


