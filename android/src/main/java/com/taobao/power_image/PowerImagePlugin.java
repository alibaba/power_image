package com.taobao.power_image;


import android.content.Context;

import androidx.annotation.NonNull;

import com.taobao.power_image.dispatcher.PowerImageDispatcher;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * PowerImagePlugin
 */
public class PowerImagePlugin implements FlutterPlugin {

    private static Context sContext;

    public static Context getContext() {
        return sContext;
    }

    static {
        System.loadLibrary("powerimage");
    }

    private PowerImageEngineContext engineContext;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        if (sContext == null) {
            sContext = flutterPluginBinding.getApplicationContext();
        }
        if (engineContext == null) {
            engineContext = new PowerImageEngineContext();
        }
        engineContext.onAttachedToEngine(flutterPluginBinding);
        PowerImageDispatcher.getInstance().prepare();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        if (engineContext != null) {
            engineContext.onDetached();
            engineContext = null;
        }
    }
}
