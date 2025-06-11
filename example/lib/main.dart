import 'dart:convert';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_window_example/rt_toast_model.dart';
import 'package:flutter_multi_window_example/toast_manager.dart';

import 'common_toast_widget.dart';
import 'event_widget.dart';
import 'external_windows.dart';

void main(List<String> args) {
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;

    final type = ExternalWindowType.values
        .firstWhere((elem) => elem.name == argument['type']);

    runApp(MaterialApp(
      home: CommonToastWidget(
        windowId: windowId,
        model: ToastSuccessDownloadGame.fromJson(jsonDecode(argument['model'])),
        controller: WindowController.fromWindowId(windowId),
      ),
    ));
  } else {
    runApp(const _ExampleMainWindow());
  }
}

class _ExampleMainWindow extends StatefulWidget {
  const _ExampleMainWindow({Key? key}) : super(key: key);

  @override
  State<_ExampleMainWindow> createState() => _ExampleMainWindowState();
}

class _ExampleMainWindowState extends State<_ExampleMainWindow> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                ToastManager.instance.showNotification(
                    const ToastSuccessDownloadGame(
                      gameName: 'Balarto',
                      imageUrl:
                          'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2834460/header.jpg?t=1708456012',
                    ),
                    MediaQuery.of(context).devicePixelRatio);
              },
              child: const Text('Create a new World!'),
            ),
            TextButton(
              child: const Text('Send event to all sub windows'),
              onPressed: () async {
                final subWindowIds =
                    await DesktopMultiWindow.getAllSubWindowIds();
                for (final windowId in subWindowIds) {
                  DesktopMultiWindow.invokeMethod(
                    windowId,
                    'broadcast',
                    'Broadcast from main window',
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Фокус окна дочернего'),
              onPressed: () async {
                WindowController.fromWindowId(1).focus();
              },
            ),
            Expanded(
              child: EventWidget(controller: WindowController.fromWindowId(0)),
            )
          ],
        ),
      ),
    );
  }
}

class _ExampleSubWindow extends StatefulWidget {
  const _ExampleSubWindow({
    Key? key,
    required this.windowController,
    required this.args,
  }) : super(key: key);

  final WindowController windowController;
  final Map? args;

  @override
  State<_ExampleSubWindow> createState() => _ExampleSubWindowState();
}

class _ExampleSubWindowState extends State<_ExampleSubWindow> {
  FocusNode _focusNode = FocusNode();

  bool _isDragging = false;

  Offset _previousOffset = Offset.zero;

  void _onMouseDown(Offset position) {
    _isDragging = true;
    _previousOffset = position;
  }

  void _onMouseMove(Offset position) async {
    await widget.windowController.startDragging();
    // if (_isDragging) {
    //   print('123123');
    //   final dx = position.dx - _previousOffset.dx;
    //   final dy = position.dy - _previousOffset.dy;
    //   const windowTitle = 'Another window';
    //
    //   final titlePtr = windowTitle.toNativeUtf16();
    //   final hWnd = FindWindow(nullptr, titlePtr);
    //
    //
    //
    //   // Выделяем память для RECT
    //   final rectPtr = calloc<RECT>();
    //   GetWindowRect(hWnd, rectPtr);
    //
    //   // Получаем новые координаты
    //   final newX = rectPtr.ref.left + dx.toInt();
    //   final newY = rectPtr.ref.top + dy.toInt();
    //
    //   // Устанавливаем новое положение окна
    //   SetWindowPos(hWnd, 0, newX, newY, 0, 0, SWP_NOZORDER | SWP_NOSIZE);
    //
    //   // Освобождаем выделенную память
    //   calloc.free(rectPtr);
    //
    //   _previousOffset = position;
    // }
  }

  void _onMouseUp() {
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            GestureDetector(
              onPanStart: (details) => _onMouseDown(details.localPosition),
              onPanUpdate: (details) => _onMouseMove(details.localPosition),
              onPanEnd: (_) => _onMouseUp(),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: Container(
                  color: Colors.red,
                ),
              ),
            ),
            if (widget.args != null)
              Text(
                'Arguments: ${widget.args.toString()}',
                style: const TextStyle(fontSize: 20),
              ),
            ValueListenableBuilder<bool>(
              valueListenable: DesktopLifecycle.instance.isActive,
              builder: (context, active, child) {
                if (active) {
                  return const Text('Window Active');
                } else {
                  return const Text('Window Inactive');
                }
              },
            ),
            TextButton(
              onPressed: () async {
                widget.windowController.close();
              },
              child: const Text('Close this window'),
            ),
            TextButton(
              onPressed: () async {
                widget.windowController.setNewReact(400, 400);
              },
              child: const Text('Resize Window'),
            ),
            TextButton(
              onPressed: () async {
                widget.windowController.setNewReact(400, 540);
              },
              child: const Text('Resize Window 2'),
            ),
            Expanded(child: EventWidget(controller: widget.windowController)),
          ],
        ),
      ),
    );
  }
}
