//
//  MyFileImageLoader.m
//  Runner
//
//  Created by 王振辉 on 2021/8/6.
//

#import "PowerImageFileImageLoader.h"
#import <UIKit/UIKit.h>

@implementation PowerImageFileImageLoader
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:requestConfig.srcString];

    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    } else {
        completedBlock([PowerImageResult failWithMessage:@"UIImage initWithContentsOfFile nil"]);
    }
}
@end
