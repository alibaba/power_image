//
//  PowerImageFlutterAssertImageLoader.swift
//  Runner
//
//  Created by wjr on 2022/5/30.
//

import power_image

class PowerImageFlutterAssertImageLoader: NSObject, PowerImageLoaderProtocol{
    
    func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        let image = self.flutterImage(requestConfig: requestConfig)
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else {
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageFlutterAssertImageLoaderError"))
        }
    }
    
    
    private func flutterImage(requestConfig:PowerImageRequestConfig) -> UIImage? {
        
        let name:String = requestConfig.srcString()!
        let package:String? = requestConfig.src["package"] as? String
        let fileName:String = NSString(string: name).lastPathComponent
        let path:String = NSString(string: name).deletingLastPathComponent
        
        
        let scaleArr:[Int] = (2...Int(UIScreen.main.scale)).reversed()
        
        for scale in scaleArr {
            let key:String = self.lookupKeyForAsset(asset: String(format: "%s/%d.0x/%s", path,scale,fileName), package: package)
            let image = UIImage(named: key,in: Bundle.main,compatibleWith: nil)
            if image != nil {
                return image!
            }
        }
        
        let key = self.lookupKeyForAsset(asset: name, package: package)
        return UIImage(named: key,in: Bundle.main,compatibleWith: nil)
    }
    
    private func lookupKeyForAsset(asset:String,package:String?) -> String {
        if let package = package, package != "" {
            return FlutterDartProject.lookupKey(forAsset: asset,fromPackage: package)
        }else{
            return FlutterDartProject.lookupKey(forAsset: asset)
        }
    }
}

