package com.taobao.power_image;


import android.content.Context;

import androidx.annotation.NonNull;

import com.taobao.power_image.dispatcher.PowerImageDispatcher;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

/**
 * PowerImagePlugin
 */
public class PowerImagePlugin implements FlutterPlugin {

    private static Context sContext;
    public static Map<String, PowerImageEngineContext> powerImageEngineContextMap = new HashMap<>();

    public static Context getContext() {
        return sContext;
    }

    static {
        System.loadLibrary("powerimage");
    }

    private String engineId;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        if (sContext == null) {
            sContext = flutterPluginBinding.getApplicationContext();
        }
        PowerImageEngineContext engineContext = new PowerImageEngineContext(flutterPluginBinding);
        engineId = String.valueOf(flutterPluginBinding.getFlutterEngine().hashCode());
        powerImageEngineContextMap.put(engineId, engineContext);
        PowerImageDispatcher.getInstance().prepare();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        PowerImageEngineContext engineContext = getEngineContext();
        if (engineContext != null) {
            engineContext.onDetached();
        }
        powerImageEngineContextMap.remove(engineId);
    }

    public PowerImageEngineContext getEngineContext() {
        return powerImageEngineContextMap.get(engineId);
    }
}
