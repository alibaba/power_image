# PowerImage

A powerful plugin that fully uses the native image library's ability to display images on the flutter side.

[中文文档](README_CN.md)

**Features:**

- Supports the ability to load ui.Image. In the solution based on external texture, the user could not get the real ui.Image to use, which made the image library powerless in this special usage scenario.

- Support image preloading capability. Just like flutter precacheImage. This is very useful in some scenarios that require high image display speed.

- Added texture cache to connect with flutter's imageCache! Unified image cache to avoid memory problems caused by mixing native images.

- Emulators are supported. Before flutter-1.23.0-18.1.pre, the emulator could not display Texture Widget.

- Improve the custom image type channel. Solve the demand for business custom image acquisition.

- Perfect exception capture and collection.

- Support animation.


# Usage

## Installation

- power_image：It is recommended to use the latest version
- power_image_ext：You need to choose the version based on the flutter version you are using.  Go to [power_image_ext](https://github.com/alibaba/power_image_ext) for details！

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  power_image:
    git:
      url: 'git@github.com:alibaba/power_image.git'
      ref: '0.1.0'
      
dependency_overrides:
  power_image_ext:
    git:
      url: 'git@github.com:alibaba/power_image_ext.git'
      ref: '2.5.3'
```

## Setup

### Flutter
#### 1. Replace `ImageCache` with `ImageCacheExt`.

```dart
/// call before runApp()
PowerImageBinding();
```
or
```dart
/// return ImageCacheExt in createImageCache(), 
/// if you have extends with WidgetsFlutterBinding
class XXX extends WidgetsFlutterBinding {
  @override
  ImageCache createImageCache() {
    return ImageCacheExt();
  }
}
```



#### 2. Setup PowerImageLoader
Initialize and set the global default rendering mode, renderingTypeTexture is texture mode, renderingTypeExternal is ffi mode
In addition, there are exception reports in PowerImageSetupOptions, and the sampling rate of exception reports can be set.
```dart
    PowerImageLoader.instance.setup(PowerImageSetupOptions(renderingTypeTexture,
        errorCallbackSamplingRate: 1.0,
        errorCallback: (PowerImageLoadException exception) {

    }));
```



### iOS

PowerImage provides basic image types, including network, file, nativeAsset, and flutter assets. Users need to customize their corresponding loaders.

```objectivec
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageNetworkImageLoader new] forType:kPowerImageImageTypeNetwork];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageAssetsImageLoader new] forType:kPowerImageImageTypeNativeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFlutterAssertImageLoader new] forType:kPowerImageImageTypeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFileImageLoader new] forType:kPowerImageImageTypeFile];
```

```swift
        PowerImageLoader.sharedInstance().register(PowerImageNetworkImageLoader.init(), forType: kPowerImageImageTypeNetwork)
        PowerImageLoader.sharedInstance().register(PowerImageAssetsImageLoader.init(), forType: kPowerImageImageTypeNativeAsset)
        PowerImageLoader.sharedInstance().register(PowerImageFlutterAssertImageLoader.init(), forType: kPowerImageImageTypeAsset)
        PowerImageLoader.sharedInstance().register(PowerImageFileImageLoader.init(), forType: kPowerImageImageTypeFile)
```


The loader needs to follow the PowerImageLoaderProtocol protocol:

```objectivec
typedef void(^PowerImageLoaderCompletionBlock)(BOOL success, PowerImageResult *imageResult);

@protocol PowerImageLoaderProtocol <NSObject>
@required
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock;
@end
```



Network image loader example:

```objectivec
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    
    /// CDN optimization, you need transfer reqSize to native image loader!
    /// CDN optimization, you need transfer reqSize to native image loader!
    /// like this: [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:requestConfig.srcString] viewSize:reqSize completed:
    CGSize reqSize = requestConfig.originSize;
    /// attention.

    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:requestConfig.srcString] options:nil progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {

        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image != nil) {
                completedBlock([PowerImageResult successWithImage:image]);
            }else {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }
    }];

}
```

```swift

func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        let reqSize:CGSize = requestConfig.originSize
        let url = URL(string: requestConfig.srcString())
        SDWebImageManager.shared.loadImage(with: url, progress: nil) { image, data, error, cacheType, finished, url in
            
            if let image = image {
                if (image.sd_isAnimated) {
                    let frames:[SDImageFrame] = SDImageCoderHelper.frames(from: image)!
                    if frames.count > 0 {
                        var arr:[PowerImageFrame] = []
                        for index in 0..<frames.count {
                            let frame:SDImageFrame = frames[index]
                            arr.append(PowerImageFrame(image: frame.image, duration: frame.duration))
                        }
                        let flutterImage = PowerFlutterMultiFrameImage(image: image, frames: arr)
                        completedBlock(PowerImageResult.success(with: flutterImage))
                        return
                    }
                }
                
                completedBlock(PowerImageResult.success(with: image))
                
            }else{
                completedBlock(PowerImageResult.fail(withMessage: error?.localizedDescription ?? "PowerImageNetworkLoaderError!"))
            }   
       }
}
```

native asset loader example:
```objectivec
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    UIImage *image = [UIImage imageNamed:requestConfig.srcString];
    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    }else {
        completedBlock([PowerImageResult failWithMessage:@"MyAssetsImageLoader UIImage imageNamed: nil"]);
    }
}
```

```swift

func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        
        let image = UIImage(named: requestConfig.srcString())
        
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else{
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageAssetsImageLoaderError!"))
        }
    }

```

flutter asset loader example:
```objectivec
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    UIImage *image = [self flutterImageWithName:requestConfig];
    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    } else {
        completedBlock([PowerImageResult failWithMessage:@"flutterImageWithName nil"]);
    }
}

- (UIImage*)flutterImageWithName:(PowerImageRequestConfig *)requestConfig {
    NSString *name = requestConfig.srcString;
    NSString *package = requestConfig.src[@"package"];
    NSString *filename = [name lastPathComponent];
    NSString *path = [name stringByDeletingLastPathComponent];
    for (int screenScale = [UIScreen mainScreen].scale; screenScale > 1; --screenScale) {
        NSString *key = [self lookupKeyForAsset:[NSString stringWithFormat:@"%@/%d.0x/%@", path, screenScale, filename] fromPackage:package];
        UIImage *image = [UIImage imageNamed:key inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        if (image) {
            return image;
        }
    }
    NSString *key = [self lookupKeyForAsset:name fromPackage:package];

    /// webp iOS < 14 not support 
    if ([name hasSuffix:@".webp"] && !(@available(ios 14.0, *))) {
        NSString *mPath = [[NSBundle mainBundle] pathForResource:key ofType:nil];
        NSData *webpData = [NSData dataWithContentsOfFile:mPath];
        return [UIImage sd_imageWithWebPData:webpData];
    }
    return [UIImage imageNamed:key inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
}

- (NSString *)lookupKeyForAsset:(NSString *)asset fromPackage:(NSString *)package {
    if (package && [package isKindOfClass:[NSString class]] && ![package isEqualToString:@""]) {
        return [FlutterDartProject lookupKeyForAsset:asset fromPackage:package];
    }else {
        return [FlutterDartProject lookupKeyForAsset:asset];
    }
}

```

```swift

func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        let image = self.flutterImage(requestConfig: requestConfig)
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else {
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageFlutterAssertImageLoaderError"))
        }
    }
    
    
    private func flutterImage(requestConfig:PowerImageRequestConfig) -> UIImage? {
        
        let name:String = requestConfig.srcString()!
        let package:String? = requestConfig.src["package"] as? String
        let fileName:String = NSString(string: name).lastPathComponent
        let path:String = NSString(string: name).deletingLastPathComponent
        
        
        let scaleArr:[Int] = (2...Int(UIScreen.main.scale)).reversed()
        
        for scale in scaleArr {
            let key:String = self.lookupKeyForAsset(asset: String(format: "%s/%d.0x/%s", path,scale,fileName), package: package)
            let image = UIImage(named: key,in: Bundle.main,compatibleWith: nil)
            if image != nil {
                return image!
            }
        }
        
        let key = self.lookupKeyForAsset(asset: name, package: package)
        return UIImage(named: key,in: Bundle.main,compatibleWith: nil)
    }
    
    private func lookupKeyForAsset(asset:String,package:String?) -> String {
        if let package = package, package != "" {
            return FlutterDartProject.lookupKey(forAsset: asset,fromPackage: package)
        }else{
            return FlutterDartProject.lookupKey(forAsset: asset)
        }
    }

```

file loader example:
```objectivec
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:requestConfig.srcString];

    if (image) {
        completedBlock([PowerImageResult successWithImage:image]);
    } else {
        completedBlock([PowerImageResult failWithMessage:@"UIImage initWithContentsOfFile nil"]);
    }
}
```

```swift

func handleRequest(_ requestConfig: PowerImageRequestConfig!, completed completedBlock: PowerImageLoaderCompletionBlock!) {
        
        let image = UIImage(contentsOfFile: requestConfig.srcString())
        
        if let image = image {
            completedBlock(PowerImageResult.success(with: image))
        }else{
            completedBlock(PowerImageResult.fail(withMessage: "PowerImageFileImageLoaderError!"))
        }
    }

```


### Android
PowerImage provides basic image types, including network, file, nativeAsset, and flutter assets. Users need to customize their corresponding loaders.

#### Java

```java
PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageNetworkLoader(this.getApplicationContext()), "network");
PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageNativeAssetLoader(this.getApplicationContext()), "nativeAsset");
PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageFlutterAssetLoader(this.getApplicationContext()), "asset");
PowerImageLoader.getInstance().registerImageLoader(
                new PowerImageFileLoader(this.getApplicationContext()), "file");
```

#### Kotlin

```kotlin
PowerImageLoader.getInstance().registerImageLoader(
            PowerImageNetworkLoader(this.applicationContext), "network"
)
PowerImageLoader.getInstance().registerImageLoader(
            PowerImageNativeAssetLoader(this.applicationContext), "nativeAsset"
)
PowerImageLoader.getInstance().registerImageLoader(
            PowerImageFlutterAssetLoader(this.applicationContext), "asset"
)
PowerImageLoader.getInstance().registerImageLoader(
            PowerImageFileLoader(this.applicationContext), "file"
)
```

The loader needs to follow the PowerImageLoaderProtocol protocol:

```java
public interface PowerImageLoaderProtocol {
    void handleRequest(PowerImageRequestConfig request, PowerImageResult result);
}
```


Network image loader example:

#### Java

```java
public class PowerImageNetworkLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageNetworkLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        Glide.with(context).asDrawable().load(request.srcString()).listener(new RequestListener<Drawable>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Drawable> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Drawable resource, Object model, Target<Drawable> target, DataSource dataSource, boolean isFirstResource) {
                if (resource instanceof GifDrawable) {
                    response.onResult(PowerImageResult.genSucRet(new GlideMultiFrameImage((GifDrawable) resource, false)));
                } else {
                    if (resource instanceof BitmapDrawable) {
                        response.onResult(PowerImageResult.genSucRet(new FlutterSingleFrameImage((BitmapDrawable) resource)));
                    } else {
                        response.onResult(PowerImageResult.genFailRet("Native加载失败:  resource : " + String.valueOf(resource)));
                    }
                }
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }
}
```

#### Kotlin

```kotlin
class PowerImageNetworkLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        Glide.with(context).asDrawable().load(request.srcString())
            .listener(object : RequestListener<Drawable> {
                override fun onLoadFailed(
                    e: GlideException?,
                    model: Any,
                    target: Target<Drawable>,
                    isFirstResource: Boolean
                ): Boolean {
                    response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                    return true
                }

                override fun onResourceReady(
                    resource: Drawable,
                    model: Any,
                    target: Target<Drawable>,
                    dataSource: DataSource,
                    isFirstResource: Boolean
                ): Boolean {
                    if (resource is GifDrawable) {
                        response.onResult(
                            PowerImageResult.genSucRet(
                                GlideMultiFrameImage(
                                    resource as GifDrawable,
                                    false
                                )
                            )
                        )
                    } else {
                        if (resource is BitmapDrawable) {
                            response.onResult(
                                PowerImageResult.genSucRet(
                                    FlutterSingleFrameImage(
                                        resource as BitmapDrawable
                                    )
                                )
                            )
                        } else {
                            response.onResult(PowerImageResult.genFailRet("Native加载失败:  resource : $resource"))
                        }
                    }
                    return true
                }
            }).submit(
                if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
                if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
            )
    }
}
```

native asset loader example:

#### Java

```java
public class PowerImageNativeAssetLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageNativeAssetLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        Resources resources = context.getResources();
        int resourceId = 0;
        try {
            resourceId = resources.getIdentifier(request.srcString(),
                    "drawable", context.getPackageName());
        } catch (Resources.NotFoundException e) {
            // 资源未找到
            e.printStackTrace();
        }
        if (resourceId == 0) {
            response.onResult(PowerImageResult.genFailRet("资源未找到"));
            return;
        }
        Glide.with(context).asBitmap().load(resourceId).listener(new RequestListener<Bitmap>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                response.onResult(PowerImageResult.genSucRet(resource));
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }
}
```

#### Kotlin

```kotlin
class PowerImageNativeAssetLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        val resources = context.resources
        var resourceId = 0
        try {
            resourceId = resources.getIdentifier(
                request.srcString(),
                "drawable", context.packageName
            )
        } catch (e: Resources.NotFoundException) {
            // 资源未找到
            e.printStackTrace()
        }
        if (resourceId == 0) {
            response.onResult(PowerImageResult.genFailRet("资源未找到"))
            return
        }
        Glide.with(context).asBitmap().load(resourceId).listener(object : RequestListener<Bitmap?> {
            override fun onLoadFailed(
                e: GlideException?,
                model: Any,
                target: Target<Bitmap?>,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                return true
            }

            override fun onResourceReady(
                resource: Bitmap?,
                model: Any,
                target: Target<Bitmap?>,
                dataSource: DataSource,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genSucRet(resource))
                return true
            }
        }).submit(
            if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
            if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
        )
    }
}

```

flutter asset loader example:

#### Java

```java
public class PowerImageFlutterAssetLoader implements PowerImageLoaderProtocol {

    private Context context;

    public PowerImageFlutterAssetLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        String name = request.srcString();
        if (name == null || name.length() <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"));
            return;
        }
        String assetPackage = "";
        if (request.src != null) {
            assetPackage = (String) request.src.get("package");
        }
        String path;
        if (assetPackage != null && assetPackage.length() > 0) {
            path = FlutterMain.getLookupKeyForAsset(name, assetPackage);
        } else {
            path = FlutterMain.getLookupKeyForAsset(name);
        }
        if (path == null || path.length() <= 0) {
            response.onResult(PowerImageResult.genFailRet("path 为空"));
            return;
        }
        Uri asset = Uri.parse("file:///android_asset/" + path);
        Glide.with(context).asBitmap().load(asset).listener(new RequestListener<Bitmap>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                response.onResult(PowerImageResult.genSucRet(resource));
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }

}
```

#### Kotlin

```kotlin
class PowerImageFlutterAssetLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        val name = request.srcString()
        if (name == null || name.length <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"))
            return
        }
        var assetPackage: String? = ""
        if (request.src != null) {
            assetPackage = request.src["package"] as String?
        }
        val path: String = if (assetPackage != null && assetPackage.length > 0) {
            FlutterMain.getLookupKeyForAsset(name, assetPackage)
        } else {
            FlutterMain.getLookupKeyForAsset(name)
        }
        if (path.isEmpty()) {
            response.onResult(PowerImageResult.genFailRet("path 为空"))
            return
        }
        val asset = Uri.parse("file:///android_asset/$path")
        Glide.with(context).asBitmap().load(asset).listener(object : RequestListener<Bitmap?> {
            override fun onLoadFailed(
                e: GlideException?,
                model: Any,
                target: Target<Bitmap?>,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                return true
            }

            override fun onResourceReady(
                resource: Bitmap?,
                model: Any,
                target: Target<Bitmap?>,
                dataSource: DataSource,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genSucRet(resource))
                return true
            }
        }).submit(
            if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
            if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
        )
    }
}
```

file loader example:

#### Java

```java
public class PowerImageFileLoader implements PowerImageLoaderProtocol {

    private final Context context;

    public PowerImageFileLoader(Context context) {
        this.context = context;
    }

    @Override
    public void handleRequest(PowerImageRequestConfig request, PowerImageResponse response) {
        String name = request.srcString();
        if (name == null || name.length() <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"));
            return;
        }
        Uri asset = Uri.parse("file://" + name);
        Glide.with(context).asBitmap().load(asset).listener(new RequestListener<Bitmap>() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target<Bitmap> target, boolean isFirstResource) {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + (e != null ? e.getMessage() : "null")));
                return true;
            }

            @Override
            public boolean onResourceReady(Bitmap resource, Object model, Target<Bitmap> target, DataSource dataSource, boolean isFirstResource) {
                response.onResult(PowerImageResult.genSucRet(resource));
                return true;
            }
        }).submit(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                request.height <= 0 ? Target.SIZE_ORIGINAL : request.height);
    }
}
```

#### Kotlin

```kotlin
class PowerImageFileLoader(private val context: Context) : PowerImageLoaderProtocol {
    override fun handleRequest(request: PowerImageRequestConfig, response: PowerImageResponse) {
        val name = request.srcString()
        if (name == null || name.length <= 0) {
            response.onResult(PowerImageResult.genFailRet("src 为空"))
            return
        }
        val asset = Uri.parse("file://$name")
        Glide.with(context).asBitmap().load(asset).listener(object : RequestListener<Bitmap?> {
            override fun onLoadFailed(
                e: GlideException?,
                model: Any,
                target: Target<Bitmap?>,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genFailRet("Native加载失败: " + if (e != null) e.message else "null"))
                return true
            }

            override fun onResourceReady(
                resource: Bitmap?,
                model: Any,
                target: Target<Bitmap?>,
                dataSource: DataSource,
                isFirstResource: Boolean
            ): Boolean {
                response.onResult(PowerImageResult.genSucRet(resource))
                return true
            }
        }).submit(
            if (request.width <= 0) Target.SIZE_ORIGINAL else request.width,
            if (request.height <= 0) Target.SIZE_ORIGINAL else request.height
        )
    }
}
```



## API
network image:
```dart
  PowerImage.network(
    String src, {
    Key? key,
    String? renderingType,
    double? imageWidth,
    double? imageHeight,
    this.width,
    this.height,
    this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })
```

nativeAsset:

```dart
PowerImage.nativeAsset(
    String src, {
    Key? key,
    String? renderingType,
    double? imageWidth,
    double? imageHeight,
    this.width,
    this.height,
    this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })
```

Flutter asset:

```dart
  PowerImage.asset(
    String src, {
    Key? key,
    String? renderingType,
    double? imageWidth,
    double? imageHeight,
    String? package,
    this.width,
    this.height,
    this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })
```

File:

```dart
  PowerImage.file(String src,
      {Key key,
      this.width,
      this.height,
      this.frameBuilder,
      this.errorBuilder,
      this.fit = BoxFit.cover,
      this.alignment = Alignment.center,
      String renderingType,
      double imageWidth,
      double imageHeight})
```

Custom Image Type:

```dart
  /// 自定义 imageType\src
  /// 效果：将src encode 后，完成地传递给 native 对应 imageType 注册的 loader
  /// 使用场景：
  /// 例如，自定义加载相册照片，通过自定义 imageType 为 "album"，
  /// native 侧注册 "album" 类型的 loader 自定义图片的加载。  
PowerImage.type(
    String imageType, {
    required PowerImageRequestOptionsSrc src,
    Key? key,
    String? renderingType,
    double? imageWidth,
    double? imageHeight,
    this.width,
    this.height,
    this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })
```

.options

```dart
  /// 更加灵活的方式，通过自定义options来展示图片
  ///
  /// PowerImageRequestOptions({
  ///   @required this.src,   //资源
  ///   @required this.imageType, //资源类型，如网络图，本地图或者自定义等
  ///   this.renderingType, //渲染方式，默认全局
  ///   this.imageWidth,  //图片的渲染的宽度
  ///   this.imageHeight, //图片渲染的高度
  /// });
  ///
  /// PowerExternalImageProvider（FFI[bitmap]方案）
  /// PowerTextureImageProvider（texture方案）
  ///
  /// 使用场景：
  /// 例如，自定义加载相册照片，通过自定义 imageType 为 "album"，
  /// native 侧注册 "album" 类型的 loader 自定义图片的加载。
  ///
PowerImage.options(
    PowerImageRequestOptions options, {
    Key? key,
    this.width,
    this.height,
    this.frameBuilder,
    this.errorBuilder,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  })
```



# Example

Network

```dart
          return PowerImage.network(
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            width: 100,
            height: 100,
          );
```



# Best practice

[Best practice](BESTPRACTICE.md)



# How it works

https://mp.weixin.qq.com/s/TdTGK21S-Yd3aD-yZDoYyQ

