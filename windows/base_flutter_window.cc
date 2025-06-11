//
// Created by yangbin on 2022/1/27.
//

#include "base_flutter_window.h"
#include <thread>
#include <chrono>

namespace {
void CenterRectToMonitor(LPRECT prc) {
  HMONITOR hMonitor;
  MONITORINFO mi;
  RECT rc;
  int w = prc->right - prc->left;
  int h = prc->bottom - prc->top;

  //
  // get the nearest monitor to the passed rect.
  //
  hMonitor = MonitorFromRect(prc, MONITOR_DEFAULTTONEAREST);

  //
  // get the work area or entire monitor rect.
  //
  mi.cbSize = sizeof(mi);
  GetMonitorInfo(hMonitor, &mi);

  rc = mi.rcMonitor;

  prc->left = rc.left + (rc.right - rc.left - w) / 2;
  prc->top = rc.top + (rc.bottom - rc.top - h) / 2;
  prc->right = prc->left + w;
  prc->bottom = prc->top + h;

}

std::wstring Utf16FromUtf8(const std::string &string) {
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, string.c_str(), -1, nullptr, 0);
  if (size_needed == 0) {
    return {};
  }
  std::wstring wstrTo(size_needed, 0);
  int converted_length = MultiByteToWideChar(CP_UTF8, 0, string.c_str(), -1, &wstrTo[0], size_needed);
  if (converted_length == 0) {
    return {};
  }
  return wstrTo;
}

}

void BaseFlutterWindow::Center() {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }
  RECT rc;
  GetWindowRect(handle, &rc);
  CenterRectToMonitor(&rc);
  SetWindowPos(handle, nullptr, rc.left, rc.top, 0, 0, SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
}

void BaseFlutterWindow::SetBounds(double_t x, double_t y, double_t width, double_t height) {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }
  MoveWindow(handle, int32_t(x), int32_t(y),
             static_cast<int>(width),
             static_cast<int>(height),
             TRUE);
}

void BaseFlutterWindow::SetBoundsWithAnimation(double_t x, double_t y, double_t width, double_t height) {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }

    int durationMs = 150;
    RECT rect;
    GetWindowRect(handle, &rect);
    int x0 = rect.left;
    int y0 = rect.top;
    int steps = 30;
    int delay = durationMs / steps;
    double dx = (x - x0) / steps;
    double dy = (y - y0) / steps;

    std::thread([=](){
        for (int i = 1; i <= steps; ++i) {
            int xi = static_cast<int>(x0 + dx * i);
            int yi = static_cast<int>(y0 + dy * i);

            MoveWindow(handle, xi, yi, static_cast<int>(width), static_cast<int>(height), TRUE);

            std::this_thread::sleep_for(std::chrono::milliseconds(delay));
        }
    }).detach();
}

void BaseFlutterWindow::SetTitle(const std::string &title) {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }
  SetWindowText(handle, Utf16FromUtf8(title).c_str());
}

void BaseFlutterWindow::Close() {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }
  PostMessage(handle, WM_SYSCOMMAND, SC_CLOSE, 0);
}

void BaseFlutterWindow::Show(bool isNotification) {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }

  RECT rect;
  GetWindowRect(handle, &rect);
  int width = rect.right - rect.left;
  int height = rect.bottom - rect.top;
  HRGN hRgn = CreateRoundRectRgn(0, 0, width, height, 20, 20);
  SetWindowRgn(handle, hRgn, TRUE);

  if (isNotification) {
    LONG exStyle = GetWindowLong(handle, GWL_EXSTYLE);
    int screenWidth = GetSystemMetrics(SM_CXSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYSCREEN);

    exStyle &= ~WS_EX_APPWINDOW;
    exStyle |= WS_EX_TOOLWINDOW | WS_EX_LAYERED;
    SetWindowLong(handle, GWL_EXSTYLE, exStyle);

    // изначально происходит запуск уведомления с полной прозрачностю
    SetLayeredWindowAttributes(handle, 0, 0, LWA_ALPHA);

    SetWindowPos(
            handle,
            HWND_TOPMOST,
            screenWidth - width,
            screenHeight - height, 0, 0,
            SWP_NOSIZE | SWP_SHOWWINDOW | SWP_NOACTIVATE);
  }
  ShowWindow(handle, SW_SHOW);
}

void BaseFlutterWindow::Hide() {
  auto handle = GetWindowHandle();
  if (!handle) {
    return;
  }
  ShowWindow(handle, SW_HIDE);
}

void BaseFlutterWindow::StartDragging() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }
    ReleaseCapture();
    //Undock();
    SendMessage(handle, WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0);
}

void BaseFlutterWindow::SetNewReact(double_t width, double_t height) {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }
    RECT rect;
    GetWindowRect(handle, &rect);
    int x = rect.left;
    int y = rect.top;


    SetWindowPos(handle, nullptr, x, y, static_cast<int>(width), static_cast<int>(height), SWP_NOZORDER | SWP_SHOWWINDOW);

    HRGN hRgn = CreateRoundRectRgn(0, 0, static_cast<int>(width), static_cast<int>(height), 20, 20);
    SetWindowRgn(handle, hRgn, TRUE);
}

void BaseFlutterWindow::SetOpacity(double_t opacity) {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }
    long gwlExStyle = GetWindowLong(handle, GWL_EXSTYLE);
    SetWindowLong(handle, GWL_EXSTYLE, gwlExStyle | WS_EX_LAYERED);
    SetLayeredWindowAttributes(handle, 0, static_cast<int8_t>(255 * opacity),0x02);
}

flutter::EncodableMap BaseFlutterWindow::GetBounds(double_t devicePixelRatio) {
    auto handle = GetWindowHandle();
    if (!handle) {
        return flutter::EncodableMap();
    }
    flutter::EncodableMap resultMap = flutter::EncodableMap();
    RECT rect;
    if (GetWindowRect(handle, &rect)) {
        double x = rect.left / devicePixelRatio * 1.0f;
        double y = rect.top / devicePixelRatio * 1.0f;
        double width = (rect.right - rect.left) / devicePixelRatio * 1.0f;
        double height = (rect.bottom - rect.top) / devicePixelRatio * 1.0f;

        resultMap[flutter::EncodableValue("x")] = flutter::EncodableValue(x);
        resultMap[flutter::EncodableValue("y")] = flutter::EncodableValue(y);
        resultMap[flutter::EncodableValue("width")] =
                flutter::EncodableValue(width);
        resultMap[flutter::EncodableValue("height")] =
                flutter::EncodableValue(height);
    }
    return resultMap;
}

void BaseFlutterWindow::Restore() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(handle, &windowPlacement);

    if (windowPlacement.showCmd != SW_NORMAL) {
        PostMessage(handle, WM_SYSCOMMAND, SC_RESTORE, 0);
    }
}

bool BaseFlutterWindow::IsMinimized() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return false;
    }
    WINDOWPLACEMENT windowPlacement;
    GetWindowPlacement(handle, &windowPlacement);

    return windowPlacement.showCmd == SW_SHOWMINIMIZED;
}


void BaseFlutterWindow::Focus() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }

    if (IsMinimized()) {
        Restore();
    }

    ::SetWindowPos(handle, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
    SetForegroundWindow(handle);
}

void BaseFlutterWindow::UpNotification() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }

    const int durationMs = 150;
    RECT rect;
    if (!GetWindowRect(handle, &rect)) {
        return;
    }

    int x0 = rect.left;
    int y0 = rect.top;
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    int steps = 30;
    int delay = durationMs / steps;

    // Поднимаем окно вверх на его высоту
    double dy = static_cast<double>(-height) / steps;
    double dx = 0.0;  // перемещать по горизонтали не нужно

    std::thread([handle, x0, y0, width, height, steps, delay, dx, dy]() {
        for (int i = 1; i <= steps; ++i) {
            int xi = x0 + static_cast<int>(dx * i);
            int yi = y0 + static_cast<int>(dy * i);  // поднимаемся вверх

            MoveWindow(handle, xi, yi, width, height, TRUE);
            std::this_thread::sleep_for(std::chrono::milliseconds(delay));
        }
    }).detach();
}


void BaseFlutterWindow::DownNotification() {
    auto handle = GetWindowHandle();
    if (!handle) {
        return;
    }

    const int durationMs = 150;
    RECT rect;
    if (!GetWindowRect(handle, &rect)) {
        return;
    }

    int x0 = rect.left;
    int y0 = rect.top;
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    int steps = 30;
    int delay = durationMs / steps;

    // Опускаем окно вниз на его высоту
    double dy = static_cast<double>(height) / steps;
    double dx = 0.0;  // по горизонтали без смещения

    std::thread([handle, x0, y0, width, height, steps, delay, dx, dy]() {
        for (int i = 1; i <= steps; ++i) {
            int xi = x0 + static_cast<int>(dx * i);
            int yi = y0 + static_cast<int>(dy * i);  // движение вниз

            MoveWindow(handle, xi, yi, width, height, TRUE);
            std::this_thread::sleep_for(std::chrono::milliseconds(delay));
        }
    }).detach();
}

