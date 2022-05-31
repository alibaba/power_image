//
//  PowerImageNetworkImageLoader.swift
//  Runner
//
//  Created by wjr on 2022/5/30.
//

import power_image
import SDWebImage

class PowerImageNetworkImageLoader:NSObject,PowerImageLoaderProtocol{
    
    func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        let reqSize:CGSize = requestConfig.originSize
        let url = URL(string: requestConfig.srcString())
        SDWebImageManager.shared.loadImage(with: url, progress: nil) { image, data, error, cacheType, finished, url in
            
            if let image = image {
                if (image.sd_isAnimated) {
                    let frames:[SDImageFrame] = SDImageCoderHelper.frames(from: image)!
                    if frames.count > 0 {
                        var arr:[PowerImageFrame] = []
                        for index in 0..<frames.count {
                            let frame:SDImageFrame = frames[index]
                            arr.append(PowerImageFrame(image: frame.image, duration: frame.duration))
                        }
                        let flutterImage = PowerFlutterMultiFrameImage(image: image, frames: arr)
                        completedBlock(PowerImageResult.success(with: flutterImage))
                        return
                    }
                }
                
                completedBlock(PowerImageResult.success(with: image))
                
            }else{
                completedBlock(PowerImageResult.fail(withMessage: error?.localizedDescription ?? "PowerImageNetworkLoaderError!"))
            }   
        }
    }
}
