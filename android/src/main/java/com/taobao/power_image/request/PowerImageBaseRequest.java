package com.taobao.power_image.request;

import com.taobao.power_image.PowerImageEngineContext;
import com.taobao.power_image.dispatcher.PowerImageDispatcher;
import com.taobao.power_image.loader.FlutterMultiFrameImage;
import com.taobao.power_image.loader.PowerImageLoader;
import com.taobao.power_image.loader.PowerImageLoaderProtocol;
import com.taobao.power_image.loader.PowerImageResult;

import java.util.HashMap;
import java.util.Map;

/**
 * created by Muke on 2021/7/21
 */
public abstract class PowerImageBaseRequest {
    protected static final String REQUEST_STATE_INITIALIZE_SUCCEED = "initializeSucceed";
    protected static final String REQUEST_STATE_INITIALIZE_FAILED = "initializeFailed";
    protected static final String REQUEST_STATE_LOAD_SUCCEED = "loadSucceed";
    protected static final String REQUEST_STATE_LOAD_FAILED = "loadFailed";
    protected static final String REQUEST_STATE_RELEASE_SUCCEED = "releaseSucceed";
    protected static final String REQUEST_STATE_RELEASE_FAILED = "releaseFailed";

    public static final String RENDER_TYPE_EXTERNAL = "external";
    public static final String RENDER_TYPE_TEXTURE = "texture";

    private final PowerImageEngineContext engineContext;
    private PowerImageRequestConfig imageRequestConfig;
    String requestId;
    protected String imageTaskState;
    protected PowerImageResult realResult;

    public PowerImageBaseRequest(PowerImageEngineContext context, Map<String, Object> arguments) {
        engineContext = context;
        requestId = (String) arguments.get("uniqueKey");
        imageRequestConfig = PowerImageRequestConfig.requestConfigWithArguments(arguments);
    }

    public boolean configTask() {
        boolean inited = imageRequestConfig != null;
        imageTaskState = inited ? REQUEST_STATE_INITIALIZE_SUCCEED
                : REQUEST_STATE_INITIALIZE_FAILED;
        return inited;
    }

    public boolean startLoading() {
        if (!REQUEST_STATE_INITIALIZE_SUCCEED.equals(imageTaskState)
                && !REQUEST_STATE_LOAD_FAILED.equals(imageTaskState)) {
            // 只有初始化好 或者 加载失败的情况可以重新加载
            return false;
        }
        if (imageRequestConfig == null) {
            return false;
        }
        performLoadImage();
        return true;
    }

    private void performLoadImage() {
        PowerImageLoader.getInstance().handleRequest(
                imageRequestConfig,
                new PowerImageLoaderProtocol.PowerImageResponse() {
                    @Override
                    public void onResult(PowerImageResult result) {
                        PowerImageBaseRequest.this.onLoadResult(result);
                    }
                }
        );
    }

    void onLoadResult(PowerImageResult result) {
        this.realResult = result;
    }

    public void onLoadSuccess() {
        PowerImageDispatcher.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                PowerImageBaseRequest.this.imageTaskState = REQUEST_STATE_LOAD_SUCCEED;
                engineContext.getPowerImageEventSink()
                        .sendImageStateEvent(PowerImageBaseRequest.this.encode(), true);
            }
        });
    }

    public void onLoadFailed(final String errMsg) {
        PowerImageDispatcher.getInstance().runOnMainThread(new Runnable() {
            @Override
            public void run() {
                PowerImageBaseRequest.this.imageTaskState = REQUEST_STATE_LOAD_FAILED;
                Map<String, Object> event = PowerImageBaseRequest.this.encode();
                event.put("errMsg", errMsg != null ? errMsg : "failed!");
                engineContext.getPowerImageEventSink()
                        .sendImageStateEvent(event, false);
            }
        });
    }

    public boolean stopTask() {
        return false;
    }

    public Map<String, Object> encode() {
        Map<String, Object> encodedTask = new HashMap<>();
        encodedTask.put("uniqueKey", requestId);
        encodedTask.put("state", imageTaskState);
        if (realResult != null && realResult.success && realResult.image instanceof FlutterMultiFrameImage) {
            encodedTask.put("_multiFrame", true);
        }
        return encodedTask;
    }

}
