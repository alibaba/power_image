//
//  PowerImageRequestManager.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>


@interface PowerImageRequestManager : NSObject
+ (instancetype)sharedInstance;

- (void)configWithTextureRegistry:(id<FlutterTextureRegistry>)textureRegistry;

- (NSArray *)configRequestsWithArguments:(NSArray *)list;

- (void)startLoadingWithArguments:(NSArray *)list;

- (NSArray *)releaseRequestsWithArguments:(NSArray *)list;

@end

