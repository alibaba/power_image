//
//  PowerImageExternalRequest.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageExternalRequest.h"
#import "PowerBitmapHelper.h"

@interface PowerImageExternalRequest ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) BOOL isStopped;
@property (nonatomic, assign) long handle;
@property (nonatomic, assign) NSInteger imageRealWidth;
@property (nonatomic, assign) NSInteger imageRealHeight;
@property (nonatomic, assign) size_t rowBytes;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) FlutterPixelFormat flutterPixelFormat;
@end

@implementation PowerImageExternalRequest


- (void)requestResultWithPowerImageResult:(PowerImageResult *)powerImageResult {
    [super requestResultWithPowerImageResult:powerImageResult];
    if (powerImageResult == nil) {
        [self onLoadFailed:@"PowerImageExternalRequest requestResultWithPowerImageResult PowerImageResult nil"];
        return;
    }
    
    if (!powerImageResult.success) {
        [self onLoadFailed:powerImageResult.errMsg];
        return;
    }
           
    if (self.isStopped) {
        [self onLoadFailed:@"PowerImageExternalRequest requestResultWithPowerImageResult isStopped"];
        return;
    }

    if (!powerImageResult.image) {
        [self onLoadFailed:@"PowerImageExternalRequest requestResultWithPowerImageResult image nil"];
        return;
    }
    
    CGImageRef cgImage = powerImageResult.image.image.CGImage;
    self.imageRealWidth = CGImageGetWidth(cgImage);
    self.imageRealHeight = CGImageGetHeight(cgImage);
    
    //PixelFormat
    cgImage = [self _checkPixelFormat:cgImage];
    

    _rowBytes = CGImageGetBytesPerRow(cgImage);
    
    CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef rawDataRef = CGDataProviderCopyData(dataProvider);
    _handle = (long)CFDataGetBytePtr(rawDataRef);
    
    NSData *data = CFBridgingRelease(rawDataRef);
    self.data = data;
    _length = data.length;
    
    [self onLoadSuccess];
}

- (CGImageRef)_checkPixelFormat:(CGImageRef)cgImageRef {
    PowerPixelFormat pixelFormat = [PowerBitmapHelper pixelFormatOfImageRef:cgImageRef];
    
    if (pixelFormat == PowerPixelFormatRGBA) {
        _flutterPixelFormat = FlutterPixelFormatRGBA8888;
    }else if (pixelFormat == PowerPixelFormatBGRA) {
        _flutterPixelFormat = FlutterPixelFormatBGRA8888;
    }else {
        cgImageRef = [PowerBitmapHelper createBGRAFormatImageFromImageRef:cgImageRef];
        _flutterPixelFormat = FlutterPixelFormatBGRA8888;
    }

    return cgImageRef;;
}

- (BOOL)stopTask {
    self.isStopped = true;
    self.data = nil;
    self.imageTaskState = PowerImageRequestStateReleaseSucceed;
    return true;
}

- (NSMutableDictionary *)encode {
    NSMutableDictionary *encodedRequest = [super encode];
    encodedRequest[@"width"] = @(self.imageRealWidth);
    encodedRequest[@"height"] = @(self.imageRealHeight);
    encodedRequest[@"rowBytes"] = @(self.rowBytes);
    encodedRequest[@"length"] = @(self.length);
    encodedRequest[@"handle"] = @(self.handle);
    encodedRequest[@"flutterPixelFormat"] = @(self.flutterPixelFormat);
    return encodedRequest;
}

@end
