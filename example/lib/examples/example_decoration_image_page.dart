import 'package:flutter/material.dart';
import 'package:power_image/power_image.dart';

class ExampleDecorationImagePage extends StatefulWidget {
  const ExampleDecorationImagePage({Key? key}) : super(key: key);

  @override
  State<ExampleDecorationImagePage> createState() =>
      _ExampleDecorationImagePageState();
}

class _ExampleDecorationImagePageState
    extends State<ExampleDecorationImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('DecorationImageExample'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.indigo,
                image: DecorationImage(
                    image: NetworkImage(
                        'http://gw.alicdn.com/bao/uploaded/i1/O1CN01aVbGSM1bLgj8i2Bgw_!!0-fleamarket.jpg_760x760q90.jpg'))),
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: Text(
              'DecorationImage',
              style:
                  TextStyle(color: Colors.white, backgroundColor: Colors.red),
            ),
          ),
          Container(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.indigo,
                image: DecorationImage(
                    image: PowerImageProvider.options(
                        PowerImageRequestOptions.network(
                            'http://gw.alicdn.com/bao/uploaded/i1/O1CN01aVbGSM1bLgj8i2Bgw_!!0-fleamarket.jpg_760x760q90.jpg',
                            renderingType: renderingTypeExternal,
                            imageHeight: 100,
                            imageWidth: 100)))),
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: Text(
              'PowerDecorationImage',
              style:
                  TextStyle(color: Colors.white, backgroundColor: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}
