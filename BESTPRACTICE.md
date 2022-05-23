# PowerImage 最佳实践



# 1. 渐变展示（Gradient display）

```dart
PowerImage.network(
  'https://flutter.github.io/assets-for-api-docs/assets/widgets/puffin.jpg',
  frameBuilder: (BuildContext context, Widget child, int frame,
      bool wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) {
      return child;
    }
    return AnimatedOpacity(
      child: child,
      opacity: frame == null ? 0 : 1,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  },
)
```



# 2. Placeholder 渐变（Placeholder gradient）



```dart
PowerImage.type(
  Argument.album,
  src: PowerImageRequestOptionsSrcAlbum(
      asset: asset, quality: AssetQuality.micro),
  width: width / 4,
  height: width / 4,
  frameBuilder: (
    BuildContext context,
    Widget child,
    int frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) {
      return child;
    }
    final bool loading = frame == null;
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 50),
      child: Container(
        key: ValueKey<bool>(loading),
        child: loading
            ? Container(
                alignment: Alignment.center,
                color: Color(0xff1b1b1b),
                child: Image.asset(
                  'assets/image/ic_album_placeholder.png',
                  package: 'media_producer',
                  width: 36.0,
                  height: 36.0,
                ),
              )
            : child,
      ),
    );
  },
)
```



# 3. 小图 -> 原图（Thumbnail -> Original Image）

需求：先展示压缩的图，用户点击「展示原图」后，渐变为「原图」

## 需求拆解：

### 1. 如何实现加载原图？

首先，封装好的 `PowerImage.network('url')`，在native对应注册的Loader中，只能拿到url信息。此时如果需要有参数判断是否拉取原图，那么需要自定义src：抽象类

`PowerImageRequestOptionsSrc`，实现这个类，可以让native loader拿到这个类对应序列化的参数。

PowerImage使用如下接口：

```dart
PowerImage.type(String imageType,
      {@required PowerImageRequestOptionsSrc src,
      Key key,
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

原图可以这么实现：

```dart
PowerImage.type(imageTypeNetwork, 
                src: MyCustomNetworkSrc(src:src, isOriginImage:true));
```

对应src：

```dart
class MyCustomNetworkSrc extends PowerImageRequestOptionsSrc {
  final String src;
  final bool isOriginImage;

  PowerImageRequestOptionsSrcNormal({@required this.src, @required this.isOriginImage, });

  @override
  Map<String, String> encode() {
    return {"src": src, "isOriginImage": isOriginImage};
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PowerImageRequestOptionsSrcNormal && other.src == src && other.isOriginImage == isOriginImage;
  }

  @override
  int get hashCode => hashValues(src, isOriginImage);
}
```

native 对应 loader读取参数：

```objective-c
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
	bool isOriginImage = [requestConfig.src[@"isOriginImage"] boolValue];
}
```

### 2. 如何实现压缩图到原图的渐变

在 1.渐变展示 中使用framebuilder进行渐变，可以结合起来。

```dart
Widget _buildPowerImage(
    {bool isOriginImage = false,
    String url,
    double width,
    double height,
    BoxFit fit,
    ImageFrameBuilder frameBuilder}) {
  
  return PowerImage.type(
    imageTypeNetwork,
    src: MyCustomNetworkSrc(src: url, isOriginImage: isOriginImage),
    fit: fit,
    width: width,
    height: height,
    frameBuilder: (BuildContext context, Widget child, int frame,
        bool wasSynchronouslyLoaded) {
      if (frame == null && isOriginImage) {
        return PowerImage.type(
          imageTypeNetwork,
          src: MyCustomNetworkSrc(src: url, isOriginImage: false),
          fit: fit,
          width: width,
          height: height);
      }
      return frameBuilder(context, child, frame, wasSynchronouslyLoaded);
    },
  );
}
```

你看懂了吗？有些🪆，简单来讲，上面的代码其实就是将缩略图当作原图的 placeholder！ amazing！



# 4. 网络图添加锐化参数

dart 扩展

```dart
    PowerImage.type(
      imageTypeNetwork,
      src: PowerImageRequestOptionsSrcOrigin(
        src: url,
        isOriginImage: isOriginImage,
        enableSharpen: enableSharpen,
      ),
      fit: fit,
      height: height,
      width: width,
    );
```

native 对应 loader

```objectivec
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {

    NSDictionary<NSString *, id> *srcDict = requestConfig.src;
    NSString *srcString = srcDict[@"src"];
    
    BOOL isOriginImage = srcDict[@"isOriginImage"] ? [srcDict[@"isOriginImage"] boolValue] : NO;
    BOOL enableSharpen = srcDict[@"enableSharpen"] ? [srcDict[@"enableSharpen"] boolValue] : NO;
    
    if (isOriginImage) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:requestConfig.srcString]
                                                         module:TBCDNImageModuleDefault
                                                      imageSize:requestConfig.originSize
                                                        cutType:ImageCutType_None options:SDWebImageNoParse
                                                       progress:nil
                                                      completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image != nil) {
                completedBlock([PowerImageResult successWithImage:image]);
            }else {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }
        }];
    } else if (enableSharpen) {
        
        NSString *result = [TBCDNImageURLParser parseImageURLForCDNURL:[NSURL URLWithString:requestConfig.srcString] module:@"default" imageSize:CGSizeZero viewSize:requestConfig.originSize cutType:ImageCutType_None];
        NSString *result2 = [TBCDNImageURLParser parseImageURLForCDNURL:[NSURL URLWithString:requestConfig.srcString] module:@"xychannel" imageSize:CGSizeZero viewSize:requestConfig.originSize cutType:ImageCutType_None];
        
        NSLog(@"============\n result: %@ \n result: %@", result, result2);
        
        [FMToast showText:[NSString stringWithFormat:@"result: %@ \n result: %@", result, result2]];
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:requestConfig.srcString]
                                                         module:@"xychannel"
                                                      imageSize:CGSizeZero
                                                       viewSize:requestConfig.originSize
                                                        cutType:ImageCutType_None options:SDWebImageOptionNone
                                                       progress:nil
                                                      completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            [FMToast showText:[NSString stringWithFormat:@"imageURL: %@ ", imageURL.absoluteString]];
            if (image != nil) {
                completedBlock([PowerImageResult successWithImage:image]);
            }else {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }
        }];
    } else {
    
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:requestConfig.srcString] viewSize:requestConfig.originSize completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image != nil) {
                completedBlock([PowerImageResult successWithImage:image]);
            }else {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }
        }];
    }

}
```



# 5. 展示自定义来源图片

PowerImage 内置了几种类型的图片：网络图、本地图、assert等，但是有些场景需要自定义，比如相册图片，给 native 那边一些 id 用来获取资源。

方法：

1. 自定义 imageType，比如 “album”，然后在Android、iOS对应注册“album”的loader
2. 自定义 src（PowerImageRequestOptionsSrc），里面放需要传递给native的自定义参数。

使用接口：

```dart
  PowerImage.type(String imageType,
      {@required PowerImageRequestOptionsSrc src,
      Key key,
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

iOS 对应 loader 注册

```objective-c
[[PowerImageLoader sharedInstance] registerImageLoader:[AlbumAssetsImageLoader new] forType:@"album"];
- (void)handleRequest:(PowerImageRequestConfig *)requestConfig completed:(PowerImageLoaderCompletionBlock)completedBlock {
    NSString *assetId = requestConfig.src[@"assetId"];
    NSNumber *imageWidth = requestConfig.src[@"imageWidth"];
    NSNumber *imageHeight = requestConfig.src[@"imageHeight"];
    if (assetId) {
        if (imageWidth && imageHeight) {
            [[MPAssetManager sharedInstance] getImageWithAssetId:assetId
                                                       imageSize:CGSizeMake(imageWidth.doubleValue, imageHeight.doubleValue)
                                                  successHandler:^(UIImage *image) {
                completedBlock([PowerImageResult successWithImage:image]);
            } failureHandler:^(NSError *error) {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }];
        } else {
            [[MPAssetManager sharedInstance] getThumbnail:assetId
                                           successHandler:^(UIImage *image) {
                completedBlock([PowerImageResult successWithImage:image]);
            } failureHandler:^(NSError *error) {
                completedBlock([PowerImageResult failWithMessage:error.localizedDescription]);
            }];
        }
    } else {
        completedBlock([PowerImageResult failWithMessage:@"assetId is nil"]);
    }
}
```