import UIKit
import Flutter
import power_image
import SDWebImage

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        ///添加注册
        PowerImageLoader.sharedInstance().register(PowerImageNetworkImageLoader.init(), forType: kPowerImageImageTypeNetwork)
        
        PowerImageLoader.sharedInstance().register(PowerImageAssetsImageLoader.init(), forType: kPowerImageImageTypeNativeAsset)
        
        PowerImageLoader.sharedInstance().register(PowerImageFlutterAssertImageLoader.init(), forType: kPowerImageImageTypeAsset)
        
        PowerImageLoader.sharedInstance().register(PowerImageFileImageLoader.init(), forType: kPowerImageImageTypeFile)
        
        SDImageCacheConfig.default.maxMemoryCount = 20
        
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
