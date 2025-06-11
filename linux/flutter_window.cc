//
// Created by yangbin on 2022/1/11.
//

#include "flutter_window.h"

#include <iostream>

#include "include/desktop_multi_window/desktop_multi_window_plugin.h"
#include "desktop_multi_window_plugin_internal.h"
#include <cstdio>

namespace {

WindowCreatedCallback _g_window_created_callback = nullptr;

}

gboolean on_close_clicked(GtkWidget *widget, GdkEvent *event, gpointer user_data) {
    gtk_widget_destroy(widget);
    return TRUE;
}

bool isNotificationType(const char *jsonString) {
  
  if (jsonString == NULL || strlen(jsonString) == 0) {
    return false;
  }

  
  const char *typeKey = strstr(jsonString, "\"type\"");
  if (typeKey == NULL) {
    return false; 
  }

 
  const char *typeValueStart = strchr(typeKey, ':');
  if (typeValueStart == NULL) {
    return false; 
  }
  typeValueStart++;
  
  
  while (*typeValueStart == ' ') {
    typeValueStart++;
  }

  
  if (*typeValueStart != '"') {
    return false; 
  }
  typeValueStart++; 

 
  if (strncmp(typeValueStart, "notification", strlen("notification")) == 0) {
   
    if (typeValueStart[strlen("notification")] == '"') {
      return true; 
    } else {
        return false; 
    }
  }

  return false; 
}


static void on_size_allocate(GtkWidget* widget, GdkRectangle* allocation, gpointer user_data) {
    
    GdkDisplay* display = gtk_widget_get_display(widget);
    GdkMonitor* monitor = gdk_display_get_primary_monitor(display);
    if (!monitor) return;

    GdkRectangle monitor_geometry;
    gdk_monitor_get_geometry(monitor, &monitor_geometry);

    
    int margin = 20;
    int x = monitor_geometry.x + monitor_geometry.width - allocation->width - margin;
    int y = monitor_geometry.y + monitor_geometry.height - allocation->height - margin;

    
    gtk_window_move(GTK_WINDOW(widget), x, y);

    
    g_signal_handlers_disconnect_by_func(widget, (gpointer)on_size_allocate, user_data);
}


FlutterWindow::FlutterWindow(
    int64_t id,
    const std::string &args,
    const std::shared_ptr<FlutterWindowCallback> &callback
) : callback_(callback), id_(id) {
  bool isNotification =  isNotificationType(args.c_str());
  window_ = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  if(isNotification) {
    gtk_window_set_default_size(GTK_WINDOW(window_), 300, 200);
  } else {
    gtk_window_set_default_size(GTK_WINDOW(window_), 1280, 720);
  }
  
  gtk_window_set_title(GTK_WINDOW(window_), "");
  
  if(isNotification) {
    GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(window_));
    GdkMonitor* monitor = gdk_display_get_primary_monitor(display);
    if (monitor) {
      GdkRectangle monitor_geometry;
      gdk_monitor_get_geometry(monitor, &monitor_geometry);
      int margin = 20;
      int x = monitor_geometry.x + monitor_geometry.width - margin;
      int y = monitor_geometry.y + monitor_geometry.height - margin;
      gtk_window_move(GTK_WINDOW(window_), x, y);
    } else {
      gtk_window_move(GTK_WINDOW(window_), 500,500);
    }

  } else{
    gtk_window_set_position(GTK_WINDOW(window_), GTK_WIN_POS_CENTER);
  }

  gtk_window_set_decorated(GTK_WINDOW(window_), false);
  gtk_widget_show(GTK_WIDGET(window_));
  
  g_signal_connect(G_OBJECT(window_), "delete-event", G_CALLBACK(on_close_clicked), NULL);
  g_signal_connect(window_, "destroy", G_CALLBACK(+[](GtkWidget *, gpointer arg) {
    auto *self = static_cast<FlutterWindow *>(arg);
    if (auto callback = self->callback_.lock()) {
      callback->OnWindowClose(self->id_);
      callback->OnWindowDestroy(self->id_);
    }
  }), this);

  g_autoptr(FlDartProject)
      project = fl_dart_project_new();
  const char *entrypoint_args[] = {"multi_window", g_strdup_printf("%ld", id_), args.c_str(), nullptr};
  fl_dart_project_set_dart_entrypoint_arguments(project, const_cast<char **>(entrypoint_args));

  auto fl_view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(fl_view));
  gtk_container_add(GTK_CONTAINER(window_), GTK_WIDGET(fl_view));

  if (_g_window_created_callback) {
    _g_window_created_callback(FL_PLUGIN_REGISTRY(fl_view));
  }
  g_autoptr(FlPluginRegistrar)
      desktop_multi_window_registrar =
      fl_plugin_registry_get_registrar_for_plugin(FL_PLUGIN_REGISTRY(fl_view), "DesktopMultiWindowPlugin");
  desktop_multi_window_plugin_register_with_registrar_internal(desktop_multi_window_registrar);

  window_channel_ = WindowChannel::RegisterWithRegistrar(desktop_multi_window_registrar, id_);

  gtk_widget_grab_focus(GTK_WIDGET(fl_view));

 
  if(isNotification) {
    g_signal_connect(GTK_WIDGET(window_), "size-allocate", G_CALLBACK(on_size_allocate), nullptr);
    gtk_widget_set_opacity(GTK_WIDGET(window_), 0);
  } else {
    gtk_widget_hide(GTK_WIDGET(window_));
  }  
}

WindowChannel *FlutterWindow::GetWindowChannel() {
  return window_channel_.get();
}

FlutterWindow::~FlutterWindow() = default;

void desktop_multi_window_plugin_set_window_created_callback(WindowCreatedCallback callback) {
  _g_window_created_callback = callback;
}