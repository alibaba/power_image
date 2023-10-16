//
//  PowerImageTextureRequest.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <UIKit/UIKit.h>
#import "PowerImageBaseRequest.h"
#import <Flutter/Flutter.h>


@interface PowerImageTextureRequest : PowerImageBaseRequest
- (instancetype)initWithEngineContext:(PowerImageEngineContext *)context arguments:(NSDictionary *)arguments textureRegistry:(id<FlutterTextureRegistry>)textureRegistry;

@end

