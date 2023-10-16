//
//  PowerImageEngineContext.h
//  power_image
//
//  Created by 杨正灿 on 2023/10/9.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface PowerImageEngineContext: NSObject<FlutterStreamHandler>
@property (nonatomic, strong) NSObject<FlutterTextureRegistry>* pluginRegistry;
- (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)onDetached;
- (void)sendImageStateEvent:(NSMutableDictionary *)event success:(BOOL)success;
@end

NS_ASSUME_NONNULL_END
