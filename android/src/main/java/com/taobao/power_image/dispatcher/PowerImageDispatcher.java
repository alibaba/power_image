package com.taobao.power_image.dispatcher;

import android.os.Handler;
import android.os.Looper;

/**
 * @version Created on 2020/4/22.
 * @Author Pan Xuerui
 * @Email xuerui.pxr@alibaba-inc.com
 * @Company Alibaba Group
 * @Description 主要用来处理纹理相关的创建和回收工作
 */
public class PowerImageDispatcher {

    private static volatile PowerImageDispatcher sInstance;

    private Handler workHandler;
    private Handler mainHandler;
    private Looper workLooper;

    public static PowerImageDispatcher getInstance() {
        if (sInstance == null) {
            synchronized (PowerImageDispatcher.class) {
                if (sInstance == null) {
                    sInstance = new PowerImageDispatcher();
                }
            }
        }
        return sInstance;
    }

    public void prepare() {
        mainHandler = new Handler(Looper.getMainLooper());
        Thread workThread = new Thread(new Runnable() {
            @Override
            public void run() {
                Looper.prepare();
                workLooper = Looper.myLooper();
                workHandler = new Handler();
                Looper.loop();
            }
        });
        workThread.setName("com.taobao.power_image.work");
        workThread.start();
    }

    public void runOnWorkThread(Runnable runnable) {
        if (runnable == null || workHandler == null) {
            return;
        }

        if (Looper.myLooper() == workLooper) {
            runnable.run();
            return;
        }
        workHandler.post(runnable);
    }

    public void runOnMainThread(Runnable runnable) {
        if (runnable == null || mainHandler == null) {
            return;
        }

        if (Looper.myLooper() == Looper.getMainLooper()) {
            runnable.run();
            return;
        }

        mainHandler.post(runnable);
    }

    public void runOnMainThreadDelayed(Runnable runnable, long delayMillis) {
        if (runnable == null || mainHandler == null) {
            return;
        }

        mainHandler.postDelayed(runnable, delayMillis);
    }
}
