package com.taobao.power_image_example;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.Drawable;

import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.taobao.power_image.loader.FlutterMultiFrameImage;

import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 */
public class GlideMultiFrameImage extends FlutterMultiFrameImage {


    private static Field sGifState;
    private static Method sCurrentFrameMethod;
    private static Field sFrameloader;

    static {
        try {
            sGifState = GifDrawable.class.getDeclaredField("state");
            sGifState.setAccessible(true);
            sFrameloader = sGifState.getType().getDeclaredField("frameLoader");
            sFrameloader.setAccessible(true);
            sCurrentFrameMethod = sFrameloader.getType().getDeclaredMethod("getCurrentFrame");
            sCurrentFrameMethod.setAccessible(true);
        } catch (Throwable  e1) {
            e1.printStackTrace();
        }
    }

    private final Canvas tmpCanvas = new Canvas();


    public GlideMultiFrameImage(GifDrawable drawable, boolean needRecycle) {
        super(drawable,  needRecycle);

    }

    @Override
    public Bitmap getCurrentFrame(Drawable who) {
        who.draw(tmpCanvas);
        Bitmap bitmap = null;
        try {
            Object gifState = sGifState.get(who);
            Object frameLoader = sFrameloader.get(gifState);
            bitmap = (Bitmap) sCurrentFrameMethod.invoke(frameLoader);
        } catch (Throwable t) {
            t.printStackTrace();
        }

        return bitmap;
    }

    @Override
    protected void onStart(Drawable who) {
        ((GifDrawable) who).start();
    }

    @Override
    protected void onRelease(Drawable who) {
        ((GifDrawable) who).stop();
    }

    @Override
    public int getFrameCount() {
        return ((GifDrawable)drawable).getFrameCount();
    }
}
