//
//  MyNetworkImageLoader.m
//  Runner
//
//  Created by 王振辉 on 2021/7/15.
//

#import "PowerImageNetworkImageLoader.h"
#import <SDWebImage/SDWebImage.h>
#import "PowerFlutterImage.h"
#import "PowerFlutterMultiFrameImage.h"

@implementation PowerImageNetworkImageLoader
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    
    /// CDN optimization, you need transfer reqSize to native image loader!
    /// CDN optimization, you need transfer reqSize to native image loader!
    /// like this: [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:requestConfig.srcString] viewSize:reqSize completed:
    CGSize reqSize = requestConfig.originSize;
    /// attention.

    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:requestConfig.srcString] options:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image != nil) {
                if (image.sd_isAnimated) {
                    NSArray<SDImageFrame *> *frames = [SDImageCoderHelper framesFromAnimatedImage:image];
                    if (frames.count > 0) {
                        NSMutableArray *array = [NSMutableArray new];
                        for (int i = 0; i < frames.count; i++) {
                            SDImageFrame *frame = frames[i];
                            [array addObject:[PowerImageFrame frameWithImage:frame.image duration:frame.duration]];
                        }

                        PowerFlutterImage *flutterImage = [[PowerFlutterMultiFrameImage alloc] initWithImage:image frames:array];
                        completedBlock([PowerImageResult successWithPowerFlutterImage:flutterImage]);
                        return;
                    }
                }
                completedBlock([PowerImageResult successWithImage:image]);
            }else {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }
    }];
    
}


@end
