//
//  MyAssetsImageLoader.m
//  Runner
//
//  Created by 王振辉 on 2021/7/20.
//

#import "PowerImageAssetsImageLoader.h"
#import <UIKit/UIKit.h>

@implementation PowerImageAssetsImageLoader

- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    UIImage *image = [UIImage imageNamed:requestConfig.srcString];
    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    }else {
        completedBlock([PowerImageResult failWithMessage:@"MyAssetsImageLoader UIImage imageNamed: nil"]);
    }
}

@end
