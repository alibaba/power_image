//
//  PowerImageFileImageLoader.swift
//  Runner
//
//  Created by wjr on 2022/5/30.
//
import power_image

class PowerImageFileImageLoader: NSObject, PowerImageLoaderProtocol{
    
    func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        
        let image = UIImage(contentsOfFile: requestConfig.srcString())
        
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else{
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageFileImageLoaderError!"))
        }
    }
}
