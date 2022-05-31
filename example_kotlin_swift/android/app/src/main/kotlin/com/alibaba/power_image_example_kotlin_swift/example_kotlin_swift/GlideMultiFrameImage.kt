package com.taobao.power_image_example

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import com.bumptech.glide.load.resource.gif.GifDrawable
import com.taobao.power_image.loader.FlutterMultiFrameImage
import java.lang.reflect.Field
import java.lang.reflect.Method

/**
 */
class GlideMultiFrameImage(drawable: GifDrawable?, needRecycle: Boolean) : FlutterMultiFrameImage(drawable, needRecycle) {
    companion object {
        private var sGifState: Field? = null
        private var sCurrentFrameMethod: Method? = null
        private var sFrameloader: Field? = null

        init {
            try {
                sGifState = GifDrawable::class.java.getDeclaredField("state")
                sGifState?.isAccessible = true
                sFrameloader = sGifState?.type?.getDeclaredField("frameLoader")
                sFrameloader?.isAccessible = true
                sCurrentFrameMethod = sFrameloader?.type?.getDeclaredMethod("getCurrentFrame")
                sCurrentFrameMethod?.isAccessible = true
            } catch (e1: Throwable) {
                e1.printStackTrace()
            }
        }
    }

    private val tmpCanvas = Canvas()
    override fun getCurrentFrame(who: Drawable): Bitmap? {
        who.draw(tmpCanvas)
        var bitmap: Bitmap? = null
        try {
            val gifState = sGifState!![who]
            val frameLoader = sFrameloader!![gifState]
            bitmap = sCurrentFrameMethod!!.invoke(frameLoader) as Bitmap
        } catch (t: Throwable) {
            t.printStackTrace()
        }
        return bitmap
    }

    protected override fun onStart(who: Drawable) {
        (who as GifDrawable).start()
    }

    protected override fun onRelease(who: Drawable) {
        (who as GifDrawable).stop()
    }

    override fun getFrameCount(): Int {
        return (drawable as GifDrawable).frameCount
    }
}