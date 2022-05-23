package com.taobao.power_image.loader;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.view.Surface;



import java.lang.ref.WeakReference;

/**
 * created by wayne.xie on 2021/7/22
 * A MultiFrame Object。 such as format: gif、apng
 */
public abstract class FlutterMultiFrameImage extends FlutterImage implements Drawable.Callback {

    private static final String TAG = "FlutterMultiFrameImage";
    // schedule thread for multi-frame
    private static final Handler gAnimateScheduler;

    static {
        final HandlerThread schedulerThead = new HandlerThread("multi-frame-image-scheduler");
        schedulerThead.start();

        gAnimateScheduler = new Handler(schedulerThead.getLooper());
    }


    private WeakReference<Bitmap> curBitmapRef = new WeakReference<>(null);

    private volatile Surface surface;
    private volatile Rect destRect;

    private volatile boolean released = false;

    private final Paint painter = new Paint();

    private final Rect srcRect;
    private boolean needRecycle=false;

    public FlutterMultiFrameImage(Drawable drawable) {
        this(drawable,  false);
    }

    public FlutterMultiFrameImage(Drawable drawable, boolean needRecycle) {
        super(drawable,  needRecycle);
        drawable.setCallback(this);

        srcRect = new Rect(0, 0, getWidth(), getHeight());
    }

    @Override
    public final void invalidateDrawable(final Drawable who) {
        if (released) {
            return;
        }

        runOnScheduler(new Runnable() {
            @Override
            public void run() {
                try {
                    final Bitmap newly = getCurrentFrame(who);
                    if (newly == null) {
                        return;
                    }

                    if (newly != curBitmapRef.get()) {
                        curBitmapRef = new WeakReference<>(newly);


                        if (!surface.isValid()) {
                            return;
                        }

                        final Canvas canvas = surface.lockCanvas(null);
                        if (canvas == null) {
                            return;
                        }

                        painter.setXfermode(new PorterDuffXfermode(android.graphics.PorterDuff.Mode.CLEAR));
                        canvas.drawPaint(painter);
                        painter.setXfermode(new PorterDuffXfermode(android.graphics.PorterDuff.Mode.DST_OVER));

                        canvas.drawBitmap(newly, srcRect, destRect, painter);
                        surface.unlockCanvasAndPost(canvas);

                    }
                } catch (Throwable t) {
                    t.printStackTrace();
                }
            }
        }, true);
    }

    public abstract Bitmap getCurrentFrame(Drawable who);

    @Override
    public final void scheduleDrawable(Drawable who, Runnable what, long when) {
        if (released) {
            return;
        }

        final long delay = when - SystemClock.uptimeMillis();
        gAnimateScheduler.postDelayed(what, delay);
    }

    @Override
    public final void unscheduleDrawable(Drawable who, Runnable what) {
        gAnimateScheduler.removeCallbacks(what);
    }

    @Override
    public final void draw(Surface surface, Rect destRect) {
        if (released) {
            return;
        }


        this.destRect = destRect;
        this.surface = surface;


        final Canvas canvas = surface.lockCanvas(null);
        canvas.drawColor(Color.argb(1, 255, 255, 255));
        surface.unlockCanvasAndPost(canvas);

        runOnScheduler(new Runnable() {
            @Override
            public void run() {
                if (drawable != null) {
                    onStart(drawable);
                }
            }
        }, false);
    }

    /**
     * we should play the GifDrawable
     * @param who
     */
    protected abstract void onStart(Drawable who);

    /**
     * we should stop the gifDrawable and do some gc work
     */
    @Override
    public final void release() {
        released = true;


        runOnScheduler(new Runnable() {
            @Override
            public void run() {
                if (drawable != null) {
                    onRelease(drawable);
                    drawable = null;
                }

                if (surface != null) {
                    surface.release();
                    surface = null;
                }
            }
        }, false);
    }

    protected abstract void onRelease(Drawable who);

    private void runOnScheduler(Runnable task, boolean forceNextLoop) {
        if (Thread.currentThread() == gAnimateScheduler.getLooper().getThread() && !forceNextLoop) {
            task.run();
        } else {
            gAnimateScheduler.post(task);
        }
    }
}
