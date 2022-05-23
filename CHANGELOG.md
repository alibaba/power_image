## 0.0.5
Feature:
- add errorCallbackSamplingRate in PowerImageSetupOptions

Others:
- For easier aggregation problems, changed PowerImageLoadException message to 'Power Image request failed', inserted of error msg

## 0.0.4
Feature:
- add errorCallback in PowerImageSetupOptions
- add default errorWidgetBuilder

Others:
- remove log in dispose

## 0.0.3
Bugs:
- fix：iOS srcString - NSString Class

## 0.0.2
Bugs:
- fix：build sized container before complete

## 0.0.1
release tag, use custom ImageInfo not ui.Image


## 0.0.1-pre.11-flutter-2.2.3

Bugs:

- OpenGLES memory leak.



## 0.0.1-pre.10-flutter_1.22

## 0.0.1-pre.10-flutter_2.2.3

Bugs:

- Android texture size limit, width and height not equal. fix max height 1920, width 1080 to 1920 and 1920.





## 0.0.1-pre.9-flutter_2.2.3

## 0.0.1-pre.9-flutter_1.22

1. Bugs:
- fix: same image url with different size will hits same cache.
  
2. Features:
- tests: add '!=' in provider_test.dart to avoid this bug.
