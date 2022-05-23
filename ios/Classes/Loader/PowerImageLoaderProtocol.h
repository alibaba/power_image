//
//  PowerImageLoaderProtocol.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import "PowerImageRequestConfig.h"
#import "PowerImageResult.h"

typedef void(^PowerImageLoaderCompletionBlock)(PowerImageResult *powerImageResult);

@protocol PowerImageLoaderProtocol <NSObject>
@required
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock;
@end

