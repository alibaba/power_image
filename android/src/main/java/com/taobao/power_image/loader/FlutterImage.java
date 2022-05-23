package com.taobao.power_image.loader;

import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.view.Surface;

/**
 */
public abstract class FlutterImage {
    protected Drawable drawable;
    protected boolean needRecycle;
    
    public FlutterImage(Drawable drawable) {
        this(drawable, false);
    }

    /**
     *
     * @param drawable actual drawable to render
     * @param needRecycle if true,  when power_image stopTask, we will invoke Bitmap.recycle/GifDrawable.stop
     */
    public FlutterImage(Drawable drawable, boolean needRecycle) {
        if (drawable == null) {
            throw new IllegalArgumentException("Empty input drawable!");
        }

        this.drawable = drawable;
        this.needRecycle = needRecycle;
    }


    /**
     * SingleFrame return 1、 MultiFrame should return actual frameCount
     * @return
     */
    public abstract int getFrameCount();

    /**
     * release some object for memory consideration
     */
    public abstract void release();

    /**
     * draw the actual bitmap to the surface with specific destRect
     * @param surface
     * @param destRect
     */
    public abstract void draw(Surface surface, Rect destRect);

    /**
     * Returns the drawable's intrinsic width.
     * @return
     */
    public int getWidth() {
        return drawable.getIntrinsicWidth();
    }

    /**
     * Returns the drawable's intrinsic height.
     * @return
     */
    public int getHeight() {
        return drawable.getIntrinsicHeight();
    }

    /**
     * Returns the actual drawable(BitmapDrawable、GifDrawable)
     * @return
     */
    public Drawable getDrawable(){
        return drawable;
    }
    
    public boolean isValid(){
        return drawable != null;
    }

}
