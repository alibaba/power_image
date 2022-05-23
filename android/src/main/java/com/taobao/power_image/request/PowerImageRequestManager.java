package com.taobao.power_image.request;

import static com.taobao.power_image.request.PowerImageBaseRequest.RENDER_TYPE_EXTERNAL;
import static com.taobao.power_image.request.PowerImageBaseRequest.RENDER_TYPE_TEXTURE;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.view.TextureRegistry;

/**
 * created by Muke on 2021/7/21
 */
public class PowerImageRequestManager {

    private Map<String, PowerImageBaseRequest> requests;
    private WeakReference<TextureRegistry> textureRegistryWrf;

    private PowerImageRequestManager() {
        requests = new HashMap<>();
    }

    private static class Holder {
        private final static PowerImageRequestManager instance = new PowerImageRequestManager();
    }

    public static PowerImageRequestManager getInstance() {
        return Holder.instance;
    }

    public void configWithTextureRegistry(TextureRegistry textureRegistry) {
        textureRegistryWrf = new WeakReference<>(textureRegistry);
    }

    public List<Map<String, Object>> configRequestsWithArguments(List<Map<String, Object>> list) {
        List<Map<String, Object>> results = new ArrayList<>();
        if (list == null || list.isEmpty()) {
            return results;
        }
        for (int i = 0; i < list.size(); i++) {
            Map<String, Object> arguments = list.get(i);
            String renderType = (String) arguments.get("renderingType");
            PowerImageBaseRequest request;
            if (RENDER_TYPE_EXTERNAL.equals(renderType)) {
                request = new PowerImageExternalRequest(arguments);
            } else if (RENDER_TYPE_TEXTURE.equals(renderType)) {
                request = new PowerImageTextureRequest(arguments, textureRegistryWrf.get());
            } else {
                continue;
            }
            requests.put(request.requestId, request);
            boolean success = request.configTask();
            Map<String, Object> requestInfo = request.encode();
            requestInfo.put("success", success);
            results.add(requestInfo);
        }
        return results;
    }

    public void startLoadingWithArguments(List arguments) {
        if (arguments == null || arguments.isEmpty()) {
            return;
        }
        for (int i = 0; i < arguments.size(); i++) {
            Map arg = (Map) arguments.get(i);
            String requestId = (String) arg.get("uniqueKey");
            PowerImageBaseRequest request = requests.get(requestId);
            request.startLoading();
        }
    }

    public List<Map<String, Object>> releaseRequestsWithArguments(List arguments) {
        List<Map<String, Object>> results = new ArrayList<>();
        if (arguments == null || arguments.isEmpty()) {
            return results;
        }
        for (int i = 0; i < arguments.size(); i++) {
            Map arg = (Map) arguments.get(i);
            String requestId = (String) arg.get("uniqueKey");
            PowerImageBaseRequest request = requests.get(requestId);
            if (request != null) {
                requests.remove(requestId);
                boolean success = request.stopTask();
                Map<String, Object> requestInfo = request.encode();
                requestInfo.put("success", success);
                results.add(requestInfo);
            }
        }
        return results;
    }
}