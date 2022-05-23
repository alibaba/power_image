# PowerImage

一个充分利用原生图片库能力、高扩展性的flutter图片库。

[English document](README.md)

**特点：**

- 支持加载 ui.Image 能力。在基于外接纹理的方案中，使用方无法拿到真正的 ui.Image 去使用，这导致图片库在这种特殊的使用场景下无能为力。

- 支持图片预加载能力。正如原生precacheImage一样。这在某些对图片展示速度要求较高的场景下非常有用。

- 新增纹理缓存，与原生图片库缓存打通！统一图片缓存，避免原生图片混用带来的内存问题。

- 支持模拟器。在 flutter-1.23.0-18.1.pre之前的版本，模拟器无法展示 Texture Widget。

- 完善自定义图片类型通道。解决业务自定义图片获取诉求。

- 完善的异常捕获与收集。

- 支持动图。

# 使用

## 安装

- power_image：推荐使用最新版本
- power_image_ext：你需要根据你使用的flutter版本来选择版本

将下方配置加入到 `pubspec.yaml` 文件中:

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

## 初始化

### Flutter

#### 1. 用 `ImageCacheExt`替换 `ImageCache` .

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



#### 2. 初始化 PowerImageLoader

初始化并设置全局的默认的渲染方式，renderingTypeTexture为texture方式，renderingTypeExternal为ffi方式

另外`PowerImageSetupOptions`里面也有异常上报，以及异常上报采样率。

```dart
    PowerImageLoader.instance.setup(PowerImageSetupOptions(renderingTypeTexture,
        errorCallbackSamplingRate: 1.0,
        errorCallback: (PowerImageLoadException exception) {

    }));
```



### iOS

PowerImage 提供了基础的图片类型，包括网络图（network）、文件（file）、native 资源（nativeAsset）、flutter 资源（asset），使用方需要自定义对应的加载器。

```objectivec
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageNetworkImageLoader new] forType:kPowerImageImageTypeNetwork];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageAssetsImageLoader new] forType:kPowerImageImageTypeNativeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFlutterAssertImageLoader new] forType:kPowerImageImageTypeAsset];
    [[PowerImageLoader sharedInstance] registerImageLoader:[PowerImageFileImageLoader new] forType:kPowerImageImageTypeFile];
```


loader 需要遵循 PowerImageLoaderProtocol 协议：

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


### Android

PowerImage 提供了基础的图片类型，包括网络图（network）、文件（file）、native 资源（nativeAsset）、flutter 资源（asset），使用方需要自定义对应的加载器。

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

loader 需要遵循 PowerImageLoaderProtocol 协议：

```java
public interface PowerImageLoaderProtocol {
    void handleRequest(PowerImageRequestConfig request, PowerImageResult result);
}
```


Network image loader example:

```java
@Override
public void handleRequest(PowerImageRequestConfig request, PowerImageResult result) {
    Glide.with(context).load(request.srcString()).into(new CustomTarget<Drawable>(
        request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
        request.height <= 0 ? Target.SIZE_ORIGINAL : request.height){

        @Override
        public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
            if (resource instanceof BitmapDrawable) {
                BitmapDrawable bitmapDrawable = (BitmapDrawable)resource;
                result.onResult(true, bitmapDrawable.getBitmap());
            } else if (resource instanceof GifDrawable) {
                result.onResult(true, ((GifDrawable) resource).getFirstFrame());
            } else {
                result.onResult(false, null);
            }
        }

        @Override
        public void onLoadFailed(@Nullable Drawable errorDrawable) {
            super.onLoadFailed(errorDrawable);
            result.onResult(false, null);
        }

        @Override
        public void onLoadCleared(@Nullable Drawable placeholder) {

        }
    });
}
```

native asset loader example:

```java
@Override
public void handleRequest(PowerImageRequestConfig request, PowerImageResult result) {
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
        result.onResult(false, null);
        return;
    }
    Glide.with(context).load(resourceId).into(
        new CustomTarget<Drawable>(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                                   request.height <= 0 ? Target.SIZE_ORIGINAL : request.height) {
            @Override
            public void onResourceReady(@NonNull Drawable resource,
                                        @Nullable Transition<? super Drawable> transition) {
                if (resource instanceof BitmapDrawable) {
                    BitmapDrawable bitmapDrawable = (BitmapDrawable) resource;
                    result.onResult(true, bitmapDrawable.getBitmap());
                } else {
                    result.onResult(false, null);
                }
            }

            @Override
            public void onLoadFailed(@Nullable Drawable errorDrawable) {
                super.onLoadFailed(errorDrawable);
                result.onResult(false, null);
            }

            @Override
            public void onLoadCleared(@Nullable Drawable placeholder) {

            }
        });
}
```


flutter asset loader example:

```java
@Override
public void handleRequest(PowerImageRequestConfig request, PowerImageResult result) {
    String name = request.srcString();
    if (name == null || name.length() <= 0) {
        result.onResult(false, null);
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
        result.onResult(false, null);
        return;
    }
    Uri asset = Uri.parse("file:///android_asset/" + path);
    Glide.with(context).load(asset).into(
        new CustomTarget<Drawable>(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                                   request.height <= 0 ? Target.SIZE_ORIGINAL : request.height) {
            @Override
            public void onResourceReady(@NonNull Drawable resource,
                                        @Nullable Transition<? super Drawable> transition) {
                if (resource instanceof BitmapDrawable) {
                    BitmapDrawable bitmapDrawable = (BitmapDrawable) resource;
                    result.onResult(true, bitmapDrawable.getBitmap());
                } else if (resource instanceof GifDrawable) {
                    result.onResult(true, ((GifDrawable) resource).getFirstFrame());
                }
            }

            @Override
            public void onLoadCleared(@Nullable Drawable placeholder) {

            }

            @Override
            public void onLoadFailed(@Nullable Drawable errorDrawable) {
                super.onLoadFailed(errorDrawable);
                result.onResult(false, null);
            }
        });
}
```


file loader example:

```java
@Override
public void handleRequest(PowerImageRequestConfig request, PowerImageResult result) {
    String name = request.srcString();
    if (name == null || name.length() <= 0) {
        result.onResult(false, null);
        return;
    }
    Uri asset = Uri.parse("file://" + name);
    Glide.with(context).load(asset).into(
        new CustomTarget<Drawable>(request.width <= 0 ? Target.SIZE_ORIGINAL : request.width,
                                   request.height <= 0 ? Target.SIZE_ORIGINAL : request.height) {
            @Override
            public void onResourceReady(@NonNull Drawable resource,
                                        @Nullable Transition<? super Drawable> transition) {
                if (resource instanceof BitmapDrawable) {
                    BitmapDrawable bitmapDrawable = (BitmapDrawable) resource;
                    result.onResult(true, bitmapDrawable.getBitmap());
                } else if (resource instanceof GifDrawable) {
                    result.onResult(true, ((GifDrawable) resource).getFirstFrame());
                }
            }

            @Override
            public void onLoadCleared(@Nullable Drawable placeholder) {

            }

            @Override
            public void onLoadFailed(@Nullable Drawable errorDrawable) {
                super.onLoadFailed(errorDrawable);
                result.onResult(false, null);
            }
        });
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



# 例子

Network

```dart
          return PowerImage.network(
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            width: 100,
            height: 100,
          );
```



# 最佳实践

[最佳实践](BESTPRACTICE.md)



# 原理

https://mp.weixin.qq.com/s/TdTGK21S-Yd3aD-yZDoYyQ

