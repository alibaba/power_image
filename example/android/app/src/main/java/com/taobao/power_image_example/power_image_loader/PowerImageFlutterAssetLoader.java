package com.taobao.power_image_example.power_image_loader;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.target.Target;
import com.bumptech.glide.request.transition.Transition;
import com.taobao.power_image.loader.PowerImageLoaderProtocol;
import com.taobao.power_image.loader.PowerImageResult;
import com.taobao.power_image.request.PowerImageRequestConfig;

import io.flutter.view.FlutterMain;

/**
 * created by Muke on 2021/8/12
 */
public class PowerImageFlutterAssetLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageFlutterAssetLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        String name = request.srcString();
        if (name == null || name.length() <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"));
            return;
        }
        String assetPackage = "";
        if (request.src != null) {
            assetPackage = (String) request.src.get("package");
        }
        String path;
        if (assetPackage != null && assetPackage.length() > 0) {
            path = FlutterMain.getLookupKeyForAsset(name, assetPackage);
        } else {
            path = FlutterMain.getLookupKeyForAsset(name);
        }
        if (path == null || path.length() <= 0) {
            response.onResult(PowerImageResult.genFailRet("path 为空"));
            return;
        }
        Uri asset = Uri.parse("file:///android_asset/" + path);
        Glide.with(context).asBitmap().load(asset).listener(new RequestListener<Bitmap>() {
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
