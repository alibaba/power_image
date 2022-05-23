package com.taobao.power_image.loader;

import com.taobao.power_image.request.PowerImageRequestConfig;

import java.util.HashMap;
import java.util.Map;

/**
 * created by Muke on 2021/7/22
 */
public class PowerImageLoader implements PowerImageLoaderProtocol {

    private final Map<String, PowerImageLoaderProtocol> imageLoaders;

    private PowerImageLoader() {
        imageLoaders = new HashMap<>();
    }

    private static class Holder {
        private final static PowerImageLoader instance = new PowerImageLoader();
    }

    public static PowerImageLoader getInstance() {
        return PowerImageLoader.Holder.instance;
    }

    public void registerImageLoader(PowerImageLoaderProtocol loader, String imageType) {
        imageLoaders.put(imageType, loader);
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        PowerImageLoaderProtocol imageLoader = imageLoaders.get(request.imageType);
        if (imageLoader == null) {
            throw new IllegalStateException("PowerImageLoader for "
                    + request.imageType + " has not been registered.");
        }
        imageLoader.handleRequest(request, response);
    }
}
