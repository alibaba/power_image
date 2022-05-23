//
//  PowerImageDispatcher.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PowerImageDispatcher : NSObject
+ (instancetype)sharedInstance;

- (void)runOnWorkThread:(dispatch_block_t)block;

- (void)runOnMainThread:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
