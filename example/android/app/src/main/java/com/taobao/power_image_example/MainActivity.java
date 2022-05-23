package com.taobao.power_image_example;

import android.os.Bundle;

import com.taobao.power_image.loader.PowerImageLoader;
import com.taobao.power_image_example.power_image_loader.PowerImageFileLoader;
import com.taobao.power_image_example.power_image_loader.PowerImageFlutterAssetLoader;
import com.taobao.power_image_example.power_image_loader.PowerImageNativeAssetLoader;
import com.taobao.power_image_example.power_image_loader.PowerImageNetworkLoader;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageNetworkLoader(this.getApplicationContext()), "network");
        PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageNativeAssetLoader(this.getApplicationContext()), "nativeAsset");
        PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageFlutterAssetLoader(this.getApplicationContext()), "asset");
        PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageFileLoader(this.getApplicationContext()), "file");
    }
}
