import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_image/power_image.dart';

import 'example_tools.dart';

class ExamplePrefetchPage extends StatefulWidget {
  const ExamplePrefetchPage({Key? key}) : super(key: key);

  @override
  _ExamplePrefetchPageState createState() => _ExamplePrefetchPageState();
}

class _ExamplePrefetchPageState extends State<ExamplePrefetchPage> {
  bool externalOK = false;
  bool textureOK = false;
  late ExampleSrc externalOptions;
  late ExampleSrc textureOptions;

  @override
  void initState() {
    externalOptions =
        ExampleTool.exampleOptionsWithRenderType(renderingTypeExternal).first;
    textureOptions =
        ExampleTool.exampleOptionsWithRenderType(renderingTypeTexture).first;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    PowerImageLoader.instance.prefetch(ExampleTool.optionsFromExampleSrc(externalOptions), context).then((value) {
      setState(() {
        externalOK = true;
      });
    });
    PowerImageLoader.instance.prefetch(ExampleTool.optionsFromExampleSrc(textureOptions), context).then((value) {
      setState(() {
        textureOK = true;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('prefetch_demo'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
                '${externalOK ? 'done' : 'loading'}\n${externalOptions.toString()}'),
          ),
          ListTile(
              title: Text(
                  '${textureOK ? 'done' : 'loading'}\n${textureOptions.toString()}'))
        ],
      ),
    );
  }
}
