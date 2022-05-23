package com.taobao.power_image_example.power_image_loader;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.transition.Transition;
import com.taobao.power_image.loader.PowerImageLoaderProtocol;
import com.taobao.power_image.loader.PowerImageResult;
import com.taobao.power_image.request.PowerImageRequestConfig;

/**
 * created by Muke on 2021/7/27
 */
public class PowerImageNativeAssetLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageNativeAssetLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        Resources resources = context.getResources();
        int resourceId = 0;
        try {
            resourceId = resources.getIdentifier(request.srcString(),
                    "drawable", context.getPackageName());
        } catch (Resources.NotFoundException e) {
            // 资源未找到
            e.printStackTrace();
        }
        if (resourceId == 0) {
            response.onResult(PowerImageResult.genFailRet("资源未找到"));
            return;
        }
        Glide.with(context).asBitmap().load(resourceId).listener(new RequestListener<Bitmap>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                response.onResult(PowerImageResult.genSucRet(resource));
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }
}
