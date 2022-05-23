package com.taobao.power_image.request;

import android.graphics.Rect;
import android.view.Surface;

import com.taobao.power_image.dispatcher.PowerImageDispatcher;
import com.taobao.power_image.loader.FlutterImage;
import com.taobao.power_image.loader.FlutterSingleFrameImage;
import com.taobao.power_image.loader.PowerImageResult;

import java.lang.ref.WeakReference;
import java.util.Map;

import io.flutter.view.TextureRegistry;

/**
 * created by Muke on 2021/7/27
 */
public class PowerImageTextureRequest extends PowerImageBaseRequest {
    private static final String TAG = "PowerImageTextureRequest";

    public static final int MAX_RESIZE_HEIGHT = 1920;
    public static final int MAX_RESIZE_WIDTH = 1920;

    private final WeakReference<TextureRegistry> textureRegistryWrf;
    private volatile boolean stopped;
    private volatile TextureRegistry.SurfaceTextureEntry textureEntry;
    private volatile Surface surface;
    private volatile int imageTextureWidth;
    private volatile int imageTextureHeight;
    private int bitmapWidth;
    private int bitmapHeight;

    public PowerImageTextureRequest(Map<String, Object> arguments, TextureRegistry textureRegistry) {
        super(arguments);
        textureRegistryWrf = new WeakReference<>(textureRegistry);
        stopped = false;
    }

    @Override
    void onLoadResult(final PowerImageResult result) {
        super.onLoadResult(result);
        if (result == null) {
            onLoadFailed(TAG + ":onLoadResult(PowerImageResult result) result is null");
            return;
        }
        if (!result.success) {
            onLoadFailed(result.errMsg);
            return;
        }
        if (stopped) {
            onLoadFailed(TAG + ":onLoadResult isStopped");
            return;
        }
        if (result.image == null || !result.image.isValid()) {
            onLoadFailed(TAG + ":onLoadResult FlutterImage/bitmap is null or bitmap has recycled");
            return;
        }
        realResult = result;
        bitmapWidth = result.image.getWidth();
        bitmapHeight = result.image.getHeight();

        PowerImageDispatcher.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                TextureRegistry textureRegistry = textureRegistryWrf.get();
                if (textureEntry == null && textureRegistry != null) {
                    // 纹理创建，需要运行在有Looper的线程
                    textureEntry = textureRegistry.createSurfaceTexture();
                }
                if (textureEntry == null) {
                    onLoadFailed(TAG + ":onLoadResult SurfaceTextureEntry create failed");
                    return;
                }
                if (stopped) {
                    onLoadFailed(TAG + ":onLoadResult isStopped 2");
                    return;
                }
                // 切到子线程进行图片加载和纹理绘制
                performDraw(result.image);
            }
        });

    }

    @Override
    public boolean stopTask() {
        stopped = true;
        imageTaskState = REQUEST_STATE_RELEASE_SUCCEED;
        textureRegistryWrf.clear();

        // 延迟2S 释放 纹理资源
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                if (textureEntry != null) {
                    synchronized (textureEntry) {
                        try {
                            if (textureEntry != null) {
                                textureEntry.release();
                                textureEntry = null;
                                if(realResult.image != null){
                                    realResult.image.release();
                                }
                            }
                            if (surface != null) {
                                surface.release();
                                surface = null;
                            }
                        } catch (Exception e) {
                        }
                    }
                }
            }
        };

        PowerImageDispatcher.getInstance().runOnMainThreadDelayed(runnable, 2000);
        return true;
    }

    @Override
    public Map<String, Object> encode() {
        Map<String, Object> encodedRequest = super.encode();
        encodedRequest.put("width", bitmapWidth);
        encodedRequest.put("height", bitmapHeight);
        if (textureEntry != null) {
            encodedRequest.put("textureId", textureEntry.id());
        }
        return encodedRequest;
    }

    // 独立线程中完成纹理绘制工作
    void performDraw(final FlutterImage image) {
        PowerImageDispatcher.getInstance().runOnWorkThread(new Runnable() {
            @Override
            public void run() {
                if (textureEntry == null || stopped || image == null) {
                    onLoadFailed(TAG + ":performDraw "
                            + (textureEntry == null ? "textureEntry:null " : "")
                            + (stopped ? "stopped:true " : "")
                            + (image == null ? "image:null " : ""));
                    return;
                }
                synchronized (textureEntry) {
                    if (textureEntry == null || stopped) {
                        onLoadFailed(TAG + ":performDraw synchronized"
                                + (textureEntry == null ? "textureEntry:null " : "")
                                + (stopped ? "stopped:true " : ""));
                        return;
                    }

                    // 显示纹理
                    checkImageTextureSize(image);

                    if (surface == null) {
                        surface = new Surface(textureEntry.surfaceTexture());
                    }
                    textureEntry.surfaceTexture().setDefaultBufferSize(imageTextureWidth,
                            imageTextureHeight);
                    if (surface != null && surface.isValid()) {
                        try {
                            Rect destRect = new Rect(0, 0, imageTextureWidth, imageTextureHeight);
                            image.draw(surface, destRect);
                            onLoadSuccess();
                        } catch (Exception e) {
                            e.printStackTrace();
                            onLoadFailed(TAG + ":performDraw drawBitmap " + e.getMessage());
                        }
                    } else {
                        onLoadFailed(TAG + ":performDraw drawBitmap "
                                + (surface == null ? "surface:null " : "")
                                + (surface != null && !surface.isValid() ? "surface invalid" : ""));
                    }
                }
            }
        });
    }

    //  确保图片的大小不超过系统的纹理大小的限制
    void checkImageTextureSize(FlutterImage imageBitmap) {
        if (imageBitmap == null) {
            return;
        }
        int originWidth = imageBitmap.getWidth();
        int originHeight = imageBitmap.getHeight();


        double widthRatio = originWidth / (double) MAX_RESIZE_WIDTH;
        double heightRatio = originHeight / (double) MAX_RESIZE_HEIGHT;

        if (widthRatio <= 1 && heightRatio <= 1) {
            imageTextureWidth = originWidth;
            imageTextureHeight = originHeight;
            return;
        }

        double ratio = Math.max(widthRatio, heightRatio);
        imageTextureWidth = (int) (originWidth / ratio);
        imageTextureHeight = (int) (originHeight / ratio);
    }
}
