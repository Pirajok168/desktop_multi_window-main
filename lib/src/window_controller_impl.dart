import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

import 'channels.dart';
import 'window_controller.dart';

class WindowControllerMainImpl extends WindowController {
  final MethodChannel _channel = multiWindowChannel;

  // the id of this window
  final int _id;

  WindowControllerMainImpl(this._id);

  @override
  int get windowId => _id;

  @override
  Future<void> close() {
    return _channel.invokeMethod('close', _id);
  }

  @override
  Future<void> hide() {
    return _channel.invokeMethod('hide', _id);
  }

  @override
  Future<void> show({bool isNotification = false}) {
    return _channel.invokeMethod('show', <String, dynamic>{
      'windowId': _id,
      'isNotification': isNotification,
    });
  }

  @override
  Future<void> center() {
    return _channel.invokeMethod('center', _id);
  }

  @override
  Future<void> setFrame(Rect frame) {
    return _channel.invokeMethod('setFrame', <String, dynamic>{
      'windowId': _id,
      'left': frame.left,
      'top': frame.top,
      'width': frame.width,
      'height': frame.height,
    });
  }

  @override
  Future<void> setBoundsWithAnimation(Rect frame) {
    return _channel.invokeMethod('setBoundsWithAnimation', <String, dynamic>{
      'windowId': _id,
      'left': frame.left,
      'top': frame.top,
      'width': frame.width,
      'height': frame.height,
    });
  }

  @override
  Future<void> setTitle(String title) {
    return _channel.invokeMethod('setTitle', <String, dynamic>{
      'windowId': _id,
      'title': title,
    });
  }

  @override
  Future<void> resizable(bool resizable) {
    if (Platform.isMacOS) {
      return _channel.invokeMethod('resizable', <String, dynamic>{
        'windowId': _id,
        'resizable': resizable,
      });
    } else {
      throw MissingPluginException(
        'This functionality is only available on macOS',
      );
    }
  }

  @override
  Future<void> setFrameAutosaveName(String name) {
    return _channel.invokeMethod('setFrameAutosaveName', <String, dynamic>{
      'windowId': _id,
      'name': name,
    });
  }

  @override
  Future<void> startDragging() {
    return _channel.invokeMethod('startDragging',<String, dynamic>{
      'windowId': _id,
    });
  }

  @override
  Future<void> setNewReact(double width, double height) {
    return _channel.invokeMethod('setNewReact',<String, dynamic>{
      'windowId': _id,
      'width': width,
      'height': height,
    });
  }

  @override
  Future<void> setOpacity(double opacity) async {
    if(!(opacity >= 0 && opacity <= 1)) return;
    print("setOpacity $opacity");
    final Map<String, dynamic> arguments = {
      'windowId': _id,
      'opacity' : opacity
    };
    await _channel.invokeMethod('setOpacity', arguments);
  }

  @override
  Future<Rect> getBounds(double devicePixelRatio) async {
    final Map<String, dynamic> arguments = {
      'windowId': _id,
      'devicePixelRatio': devicePixelRatio,
    };
    final Map<dynamic, dynamic> resultData = await _channel.invokeMethod(
      'getBounds',
      arguments,
    );

    return Rect.fromLTWH(
      resultData['x'],
      resultData['y'],
      resultData['width'],
      resultData['height'],
    );
  }

  @override
  Future<void> focus() async{
    return _channel.invokeMethod('focus',<String, dynamic>{
      'windowId': _id,
    });
  }

  @override
  Future<void> downNotification() {
    return _channel.invokeMethod('downNotification',<String, dynamic>{
      'windowId': _id,
    });
  }

  @override
  Future<void> upNotification() {
    return _channel.invokeMethod('upNotification',<String, dynamic>{
      'windowId': _id,
    });
  }
}
