//
//  PowerImageAssetsImageLoader.swift
//  Runner
//
//  Created by wjr on 2022/5/30.
//

import power_image

class PowerImageAssetsImageLoader: NSObject, PowerImageLoaderProtocol{
    
    func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        
        let image = UIImage(named: requestConfig.srcString())
        
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else{
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageAssetsImageLoaderError!"))
        }
    }
}
