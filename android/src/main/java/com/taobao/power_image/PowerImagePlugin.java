package com.taobao.power_image;


import android.content.Context;

import com.taobao.power_image.dispatcher.PowerImageDispatcher;
import com.taobao.power_image.request.PowerImageRequestManager;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * PowerImagePlugin
 */
public class PowerImagePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private static Context sContext;
    
    public static Context getContext(){
        return sContext;
    }

    static {
        System.loadLibrary("powerimage");
    }

    private String engineId;

    @Override
    public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
        if(sContext == null){
            sContext = flutterPluginBinding.getApplicationContext();
        }
        engineId = String.valueOf(flutterPluginBinding.getFlutterEngine().hashCode());
        methodChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(), "power_image/method");
        methodChannel.setMethodCallHandler(this);
        eventChannel = new EventChannel(
                flutterPluginBinding.getBinaryMessenger(), "power_image/event");
        eventChannel.setStreamHandler(PowerImageEventSink.getInstance());
        PowerImageRequestManager.getInstance()
                .configWithTextureRegistry(engineId, flutterPluginBinding.getTextureRegistry());
        PowerImageDispatcher.getInstance().prepare();
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if ("startImageRequests".equals(call.method)) {
            if (call.arguments instanceof List) {
                List arguments = (List) call.arguments;
                List results = PowerImageRequestManager.getInstance()
                        .configRequestsWithArguments(engineId, arguments);
                result.success(results);
                PowerImageRequestManager.getInstance().startLoadingWithArguments(arguments);
            } else {
                throw new IllegalArgumentException("startImageRequests require List arguments");
            }
        } else if ("releaseImageRequests".equals(call.method)) {
            if (call.arguments instanceof List) {
                List arguments = (List) call.arguments;
                List results = PowerImageRequestManager.getInstance().releaseRequestsWithArguments(arguments);
                result.success(results);
            } else {
                throw new IllegalArgumentException("stopImageRequests require List arguments");
            }
        } else {
            result.notImplemented();
        }
    }

    public static class PowerImageEventSink implements EventChannel.StreamHandler {

        private EventChannel.EventSink eventSink;

        private PowerImageEventSink() {
        }

        private static class Holder {
            private final static PowerImageEventSink instance = new PowerImageEventSink();
        }

        public static PowerImageEventSink getInstance() {
            return PowerImageEventSink.Holder.instance;
        }

        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
            eventSink = events;
        }

        @Override
        public void onCancel(Object arguments) {
            eventSink = null;
        }

        public void sendImageStateEvent(Map<String, Object> event, boolean success) {
            if (eventSink == null || event == null) {
                return;
            }

            event.put("eventName", "onReceiveImageEvent");
            event.put("success", success);
            eventSink.success(event);
        }

    }
}
