package com.taobao.power_image.loader;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;

import com.taobao.power_image.PowerImagePlugin;

import java.util.Map;

/**
 * created by Muke on 2021/10/21
 */
public class PowerImageResult {
    public final FlutterImage image;
    public final boolean success;
    public final String errMsg;
    public final ExtData ext;

    public interface ExtData {
        Map<String, Object> encode();
    }

    public PowerImageResult(FlutterImage image, boolean success, String errMsg, ExtData ext) {
        this.image = image;
        this.success = success;
        this.errMsg = errMsg;
        this.ext = ext;
    }

    public PowerImageResult(Bitmap bitmap, boolean success, String errMsg, ExtData ext) {
        if(bitmap != null){
            Context context = PowerImagePlugin.getContext();
            if(context != null){
                this.image = new FlutterSingleFrameImage(new BitmapDrawable(context.getResources(), bitmap));
            }else {
                this.image = null;
            }
        }else {
            this.image = null;
        }
        this.success = success;
        this.errMsg = errMsg;
        this.ext = ext;
    }


    public static PowerImageResult genSucRet(Bitmap bitmap) {
        return genSucRet(bitmap, null);
    }

    public static PowerImageResult genSucRet(Bitmap bitmap, ExtData ext) {
        return new PowerImageResult(bitmap, true, null, ext);
    }


    public static PowerImageResult genSucRet(FlutterImage image) {
        return genSucRet(image, null);
    }

    public static PowerImageResult genSucRet(FlutterImage image, ExtData ext) {
        return new PowerImageResult(image, true, null, ext);
    }



    public static PowerImageResult genFailRet(String errMsg, ExtData ext) {
        return new PowerImageResult((FlutterImage)null, false, errMsg, ext);
    }

    public static PowerImageResult genFailRet(String errMsg) {
        return genFailRet(errMsg, null);
    }


}
