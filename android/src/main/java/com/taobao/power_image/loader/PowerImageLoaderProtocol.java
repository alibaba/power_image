package com.taobao.power_image.loader;

import android.graphics.Bitmap;

import com.taobao.power_image.request.PowerImageRequestConfig;

/**
 * created by Muke on 2021/7/22
 */
public interface PowerImageLoaderProtocol {

    interface PowerImageResponse {
        void onResult(PowerImageResult result);
    }

    void handleRequest(PowerImageRequestConfig request, PowerImageResponse response);

}
