import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:power_image/power_image.dart';

import 'power_image_channel.dart';
import 'power_image_request.dart';

typedef void EventHandler(Map<dynamic, dynamic> event);

class PowerImagePlatformChannel extends PowerImageChannelImpl {

  StreamSubscription? _subscription;

  PowerImagePlatformChannel() {
    eventHandlers['onReceiveImageEvent'] = (Map<dynamic, dynamic> event) {
      PowerImageLoader.instance.onImageComplete(event);
    };
  }

  @override
  void setup() {
    startListening();
  }

  StreamSubscription? startListening() {
    if (_subscription == null) {
      _subscription = eventChannel.receiveBroadcastStream().listen(onEvent);
    }
    return _subscription;
  }

  Map<String, EventHandler?> eventHandlers = <String, EventHandler?>{};

  void onEvent(dynamic val) {
    assert(val is Map<dynamic, dynamic>);
    final Map<dynamic, dynamic> event = val;
    String? eventName = event['eventName'];
    EventHandler? eventHandler = eventHandlers[eventName!];
    if (eventHandler != null) {
      eventHandler(event);
    } else {
      //TODO 发来了不认识的事件,需要处理一下
    }
  }

  void registerEventHandler(String eventName, EventHandler eventHandler) {
    assert(eventName.isNotEmpty);
    eventHandlers[eventName] = eventHandler;
  }

  void unregisterEventHandler(String eventName) {
    eventHandlers[eventName] = null;
  }

  @visibleForTesting
  final MethodChannel methodChannel = const MethodChannel('power_image/method');

  @visibleForTesting
  EventChannel eventChannel = const EventChannel('power_image/event');

  void startImageRequests(List<PowerImageRequest> requests) async {
    await methodChannel.invokeListMethod(
        'startImageRequests', encodeRequests(requests));
  }

  void releaseImageRequests(List<PowerImageRequest> requests) async {
    await methodChannel.invokeListMethod(
        'releaseImageRequests', encodeRequests(requests));
  }
}
