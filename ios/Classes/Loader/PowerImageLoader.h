//
//  PowerImageLoader.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import "PowerImageLoaderProtocol.h"

// PowerImage retain image type
static NSString * const kPowerImageImageTypeNetwork = @"network";
static NSString * const kPowerImageImageTypeNativeAsset = @"nativeAsset";
static NSString * const kPowerImageImageTypeAsset = @"asset";
static NSString * const kPowerImageImageTypeFile = @"file";

@interface PowerImageLoader : NSObject <PowerImageLoaderProtocol>
+ (instancetype)sharedInstance;
- (void)registerImageLoader:(id<PowerImageLoaderProtocol>)request forType:(NSString *)type;
@end

