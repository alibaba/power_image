//
//  PowerImageRequestConfig.h
//  power_image
//
//  Created by 王振辉 on 2021/7/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PowerImageRequestConfig : NSObject

/// {
///     "src":"imageURL",
///     "package":"package",
///     "...":"..."
/// }
/// see abstract class PowerImageRequestOptionsSrc in dart
@property (nonatomic, readonly, strong) NSDictionary *src;

/// imageType , see PowerImageLoader.h
@property (nonatomic, readonly, copy) NSString *imageType;
/// texture or external
@property (nonatomic, readonly, copy) NSString *renderingType;

/// default is widget size
/// CGSizeMake(self.originWidth, self.originHeight);
@property (nonatomic, readonly, assign) CGSize originSize;

/// scaledSize = originSize * screen scale
/// CGSizeMake(self.scaledWidth, self.scaledHeight);
@property (nonatomic, readonly, assign) CGSize scaledSize;

/// args from flutter
+ (instancetype)requestConfigWithArguments:(NSDictionary *)arguments;

///
/// PowerImage.network(src:"srcString");
/// ...
/// static NSString * const kPowerImageImageTypeNetwork = @"network";
/// static NSString * const kPowerImageImageTypeNativeAsset = @"nativeAsset";
/// static NSString * const kPowerImageImageTypeFile = @"file";
/// get src url from src which from flutter options.src
- (NSString *)srcString;

/// PowerImage.assert(src:"xxx", package:"xxx")
/// static NSString * const kPowerImageImageTypeAsset = @"asset";
- (NSString *)srcPackage;

@end
