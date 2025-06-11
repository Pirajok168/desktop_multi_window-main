import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_window_example/rt_toast_model.dart';


part 'toast_success_download_game_widget.dart';

class CommonToastWidget extends StatefulWidget {
  final RTToastModel model;
  final int windowId;
  final WindowController controller;
  final bool isEnvironment;

  const CommonToastWidget({
    super.key,
    required this.model,
    required this.windowId,
    required this.controller,
    this.isEnvironment = false,
  });

  @override
  State<CommonToastWidget> createState() => _CommonToastWidgetState();
}

class _CommonToastWidgetState extends State<CommonToastWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.isEnvironment) return;

    awaitFirstRenderFrame();
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) {
      return _handleMethodCallback(call, fromWindowId);
    });
  }

  Future<dynamic> _handleMethodCallback(
    MethodCall call,
    int fromWindowId,
  ) async {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (call.method.toString() == "bottom") {
      final bounds = await widget.controller
          .getBounds(MediaQuery.of(context).devicePixelRatio);

      double y;

      if (Platform.isWindows) {
        y = bounds.bottom;
      } else {
        y = bounds.bottom + 35;
      }

      widget.controller.downNotification();
    } else if (call.method.toString() == "up") {
      widget.controller.upNotification();
    }
  }

  Future<void> awaitFirstRenderFrame() async {
    await SchedulerBinding.instance.endOfFrame;
    if(Platform.isLinux) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    await DesktopMultiWindow.invokeMethod(
      0,
      "notificationReady",
      widget.windowId,
    );

    await Future.delayed(const Duration(milliseconds: 150));

    animatedOpacity(widget.controller);
  }

  Future<void> animatedOpacity(WindowController window) async {
    double opacity = 0;
    while (opacity + 0.15 <= 1) {
      opacity = opacity + 0.15;
      window.setOpacity(opacity);
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await window.setOpacity(1);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      child: switch (widget.model) {
        ToastSuccessDownloadGame() => _ToastSuccessDownloadGameWidget(
            model: widget.model as ToastSuccessDownloadGame,
            onRemoveNotification: () {
              DesktopMultiWindow.invokeMethod(
                0,
                "removeNotification",
                widget.windowId,
              );
            },
            onTap: (action) {
              DesktopMultiWindow.invokeMethod(
                0,
                "onTapNotification",
                {
                  "windowId": widget.windowId,
                  "action" : action
                },
              );
            },
          ),
      },
    );
  }
}
