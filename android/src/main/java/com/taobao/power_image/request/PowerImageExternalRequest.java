package com.taobao.power_image.request;

import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;

import com.taobao.power_image.PowerImageEngineContext;
import com.taobao.power_image.loader.FlutterMultiFrameImage;
import com.taobao.power_image.loader.PowerImageResult;

import java.util.Map;
/**
 * created by Muke on 2021/7/21
 */
public class PowerImageExternalRequest extends PowerImageBaseRequest {

    private static final String TAG = "PowerImageExternalRequest";

    private static final int FLUTTER_PIXEL_FORMAT_RGBA8888 = 0;
    private static final int FLUTTER_PIXEL_FORMAT_BGRA8888 = 1;

    private boolean stoped;
    private Bitmap bitmap;
    private int bitmapWidth;
    private int bitmapHeight;
    private int flutterPixelFormat;
    private int rowBytes;
    private long handle;
    private int length;

    public PowerImageExternalRequest(PowerImageEngineContext context, Map<String, Object> arguments) {
        super(context, arguments);
    }

    @Override
    void onLoadResult(PowerImageResult result) {
        super.onLoadResult(result);
        if (result == null) {
            onLoadFailed(TAG + ":onLoadResult(PowerImageResult result) result is null");
            return;
        }
        if (!result.success) {
            onLoadFailed(result.errMsg);
            return;
        }
        if (stoped) {
            onLoadFailed(TAG + ":onLoadResult isStopped");
            return;
        }
        if(result.image == null || !result.image.isValid()){
            onLoadFailed(TAG + ":onLoadResult FlutterImage/bitmap is null or bitmap has recycled");
            return;
        }
        Drawable imageDrawable = result.image.getDrawable();
        if(result.image instanceof FlutterMultiFrameImage){
            bitmap = ((FlutterMultiFrameImage) result.image).getCurrentFrame(imageDrawable);
        }else {
            if(!(imageDrawable instanceof BitmapDrawable)){
                onLoadFailed(TAG + ":onLoadResult drawable isn't a BitmapDrawable");
                return;
            }
            bitmap = ((BitmapDrawable) imageDrawable).getBitmap();
        }
        if (bitmap == null) {
            onLoadFailed(TAG + ":onLoadResult bitmap is null or bitmap has recycled");
            return;
        }
        // convert to ARGB_8888 for flutter decoding
        if (bitmap.getConfig() != Bitmap.Config.ARGB_8888) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && bitmap.getConfig() == Bitmap.Config.HARDWARE) {
                onLoadFailed(TAG + ":onLoadResult bitmap config HARDWARE is not supported");
                return;
            }
            bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, false);
        }
        handle = getBitmapPixelsPtr(bitmap);
        if (handle == 0) {
            onLoadFailed(TAG + ":onLoadResult bitmap pixels pointer is 0");
            return;
        }
        bitmapWidth = bitmap.getWidth();
        bitmapHeight = bitmap.getHeight();
        flutterPixelFormat = FLUTTER_PIXEL_FORMAT_RGBA8888;
        rowBytes = bitmap.getRowBytes();
        length = bitmap.getByteCount();

        onLoadSuccess();
    }

    @Override
    public boolean stopTask() {
        stoped = true;
        imageTaskState = REQUEST_STATE_RELEASE_SUCCEED;
        releaseBitmapPixels(bitmap);
        bitmap = null;
        return true;
    }

    @Override
    public Map<String, Object> encode() {
        Map<String, Object> encodedRequest = super.encode();
        encodedRequest.put("width", bitmapWidth);
        encodedRequest.put("height", bitmapHeight);
        encodedRequest.put("rowBytes", rowBytes);
        encodedRequest.put("length", length);
        encodedRequest.put("handle", handle);
        encodedRequest.put("flutterPixelFormat", flutterPixelFormat);
        return encodedRequest;
    }

    public native long getBitmapPixelsPtr(Bitmap bitmap);

    public native void releaseBitmapPixels(Bitmap bitmap);
}
