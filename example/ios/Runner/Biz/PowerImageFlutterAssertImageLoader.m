//
//  MyFlutterAssertImageLoader.m
//  Runner
//
//  Created by 王振辉 on 2021/8/6.
//

#import "PowerImageFlutterAssertImageLoader.h"
#import <Flutter/Flutter.h>

@implementation PowerImageFlutterAssertImageLoader
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    UIImage *image = [self flutterImageWithName:requestConfig];
    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    } else {
        completedBlock([PowerImageResult failWithMessage:@"flutterImageWithName nil"]);
    }
}

- (UIImage*)flutterImageWithName:(PowerImageRequestConfig *)requestConfig {
    NSString *name = requestConfig.srcString;
    NSString *package = requestConfig.src[@"package"];
    NSString *filename = [name lastPathComponent];
    NSString *path = [name stringByDeletingLastPathComponent];
    for (int screenScale = [UIScreen mainScreen].scale; screenScale > 1; --screenScale) {
        NSString *key = [self lookupKeyForAsset:[NSString stringWithFormat:@"%@/%d.0x/%@", path, screenScale, filename] fromPackage:package];
        UIImage *image = [UIImage imageNamed:key inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        if (image) {
            return image;
        }
    }
    NSString *key = [self lookupKeyForAsset:name fromPackage:package];
    return [UIImage imageNamed:key inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

- (NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package {
    if (package && [package isKindOfClass:[NSString class]] && ![package isEqualToString:@""]) {
        return [FlutterDartProject lookupKeyForAsset:asset fromPackage:package];
    }else {
        return [FlutterDartProject lookupKeyForAsset:asset];
    }
}


@end
