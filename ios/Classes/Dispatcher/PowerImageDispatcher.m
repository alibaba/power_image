//
//  PowerImageDispatcher.m
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import "PowerImageDispatcher.h"

@interface PowerImageDispatcher ()
@property (nonatomic, strong) dispatch_queue_t workQueue;
@end

@implementation PowerImageDispatcher

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PowerImageDispatcher *instance;
    dispatch_once(&onceToken, ^{
        instance = [[PowerImageDispatcher alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _workQueue = dispatch_queue_create("com.taobao.power.image.work", NULL);
    }
    return self;
}

- (void)runOnWorkThread:(dispatch_block_t)block {
    if (!block) {
        return;
    }
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL),
               dispatch_queue_get_label(self.workQueue)) == 0) {
        block();
    } else {
        dispatch_async(self.workQueue, block);
    }
}

- (void)runOnMainThread:(dispatch_block_t)block {
   if (!block) {
       return;
   }
   
   if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL),
              dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
       block();
   } else {
       dispatch_async(dispatch_get_main_queue(), block);
   }
}
@end
