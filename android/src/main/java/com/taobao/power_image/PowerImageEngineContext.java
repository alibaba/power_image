package com.taobao.power_image;

import androidx.annotation.NonNull;

import com.taobao.power_image.request.PowerImageRequestManager;

import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

/**
 * created by Yangjiakang on 2022/11/19
 */
public class PowerImageEngineContext implements MethodChannel.MethodCallHandler {

    private final PowerImageRequestManager powerImageRequestManager;
    private final PowerImageEventSink powerImageEventSink;

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel eventChannel;

    public PowerImageEngineContext(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        powerImageRequestManager = new PowerImageRequestManager(this);
        powerImageEventSink = new PowerImageEventSink();

        methodChannel = new MethodChannel(
                flutterPluginBinding.getBinaryMessenger(), "power_image/method");
        methodChannel.setMethodCallHandler(this);
        eventChannel = new EventChannel(
                flutterPluginBinding.getBinaryMessenger(), "power_image/event");
        eventChannel.setStreamHandler(powerImageEventSink);

        configWithTextureRegistry(flutterPluginBinding.getTextureRegistry());
    }

    public void configWithTextureRegistry(TextureRegistry textureRegistry) {
        powerImageRequestManager.configWithTextureRegistry(textureRegistry);
    }

    public List<Map<String, Object>> configRequestsWithArguments(List<Map<String, Object>> list) {
        return powerImageRequestManager.configRequestsWithArguments(list);
    }

    public void startLoadingWithArguments(List arguments) {
        powerImageRequestManager.startLoadingWithArguments(arguments);
    }

    public List<Map<String, Object>> releaseRequestsWithArguments(List arguments) {
        return powerImageRequestManager.releaseRequestsWithArguments(arguments);
    }

    public PowerImageEventSink getPowerImageEventSink() {
        return powerImageEventSink;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if ("startImageRequests".equals(call.method)) {
            if (call.arguments instanceof List) {
                List arguments = (List) call.arguments;
                List results = configRequestsWithArguments(arguments);
                result.success(results);
                startLoadingWithArguments(arguments);
            } else {
                throw new IllegalArgumentException("startImageRequests require List arguments");
            }
        } else if ("releaseImageRequests".equals(call.method)) {
            if (call.arguments instanceof List) {
                List arguments = (List) call.arguments;
                List results = releaseRequestsWithArguments(arguments);
                result.success(results);
            } else {
                throw new IllegalArgumentException("stopImageRequests require List arguments");
            }
        } else {
            result.notImplemented();
        }
    }

    public void onDetached() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    public static class PowerImageEventSink implements EventChannel.StreamHandler {

        private EventChannel.EventSink eventSink;

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
