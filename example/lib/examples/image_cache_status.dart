import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageCacheStatusWidget extends StatefulWidget {
  const ImageCacheStatusWidget({Key? key}) : super(key: key);

  @override
  _ImageCacheStatusWidgetState createState() => _ImageCacheStatusWidgetState();
}

class _ImageCacheStatusWidgetState extends State<ImageCacheStatusWidget> {
  @override
  void initState() {
    super.initState();
    _needUpdate();
  }

  void _needUpdate() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {});
      _needUpdate();
    });
  }

  @override
  Widget build(BuildContext context) {
    int sizeBytes = imageCache!.currentSizeBytes;
    String sizeStr;
    if (sizeBytes >= 1 << 20) {
      sizeStr = '${(sizeBytes / (1 << 20)).toStringAsFixed(2)} MiB';
    } else if (sizeBytes >= 1 << 10) {
      sizeStr = '${(sizeBytes / (1 << 10)).toStringAsFixed(2)} KiB';
    } else {
      sizeStr = '${(sizeBytes)} B';
    }

    return Container(
      padding: const EdgeInsets.all(5),
      color: Colors.blueGrey,
      child: Column(
        children: [
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(style: const TextStyle(fontSize: 12), children: [
                TextSpan(text: '_cache.length: ${imageCache!.currentSize}\n'),
                TextSpan(text: 'sizeBytes: $sizeStr\n'),
                TextSpan(
                    text: 'liveImageCount: ${imageCache!.liveImageCount}\n'),
                TextSpan(
                    text: 'pendingImageCount: ${imageCache!.pendingImageCount}')
              ])),
          GestureDetector(
            onTap: () => imageCache!.clear(),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
