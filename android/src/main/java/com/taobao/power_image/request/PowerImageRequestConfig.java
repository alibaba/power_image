package com.taobao.power_image.request;

import android.content.res.Resources;
import android.text.TextUtils;

import java.util.Map;

/**
 * created by Muke on 2021/7/21
 */
public class PowerImageRequestConfig {
    public static final String RENDERING_TYPE_EXTERNAL = "external";
    public static final String RENDERING_TYPE_TEXTURE = "texture";

    public Map<String, Object> src;
    public String imageType;
    public String renderingType;
    public int width;
    public int height;
    public int originWidth;
    public int originHeight;

    public static PowerImageRequestConfig requestConfigWithArguments(Map<String, Object> arguments) {
        Map<String, Object> src = (Map<String, Object>) arguments.get("src");
        String imageType = (String) arguments.get("imageType");
        String renderingType = (String) arguments.get("renderingType");
        double width = .0;
        if (arguments.get("width") instanceof Double) {
            width = (double) arguments.get("width");
        }
        double height = .0;
        if (arguments.get("height") instanceof Double) {
            height = (double) arguments.get("height");
        }
        float scale = Resources.getSystem().getDisplayMetrics().density;

        PowerImageRequestConfig config = new PowerImageRequestConfig();
        config.src = src;
        config.imageType = imageType;
        config.renderingType = renderingType;
        config.width = (int) (width * scale);
        config.height = (int) (height * scale);
        config.originWidth = (int) width;
        config.originHeight = (int) height;
        return config;
    }

    public String srcString() {
        return src != null ? (String) src.get("src") : null;
    }

    public boolean isExternal() {
        return TextUtils.equals(renderingType, RENDERING_TYPE_EXTERNAL);
    }

    public boolean isTexture() {
        return TextUtils.equals(renderingType, RENDERING_TYPE_TEXTURE);
    }

}
