package com.taobao.power_image_example.power_image_loader;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.Transformation;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.engine.Resource;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.transition.Transition;
import com.taobao.power_image.dispatcher.PowerImageDispatcher;
import com.taobao.power_image.loader.FlutterSingleFrameImage;
import com.taobao.power_image.loader.PowerImageLoaderProtocol;
import com.taobao.power_image.loader.PowerImageResult;
import com.taobao.power_image.request.PowerImageRequestConfig;
import com.taobao.power_image_example.GlideMultiFrameImage;

import java.security.MessageDigest;

/**
 * created by Muke on 2021/7/25
 */
public class PowerImageNetworkLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageNetworkLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        Glide.with(context).asDrawable().load(request.srcString()).listener(new RequestListener<Drawable>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                if (resource instanceof GifDrawable) {
                    response.onResult(PowerImageResult.genSucRet(new GlideMultiFrameImage((GifDrawable) resource, false)));
                } else {
                    if (resource instanceof BitmapDrawable) {
                        response.onResult(PowerImageResult.genSucRet(new FlutterSingleFrameImage((BitmapDrawable) resource)));
                    } else {
                        response.onResult(PowerImageResult.genFailRet("Native加载失败:  resource : " + String.valueOf(resource)));
                    }
                }
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }
}
