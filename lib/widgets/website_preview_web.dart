import "dart:ui_web" as ui_web;

import "package:flutter/material.dart";
import "package:web/web.dart" as web;

class WebsitePreview extends StatefulWidget {
  final Uri uri;
  final String title;

  const WebsitePreview({super.key, required this.uri, required this.title});

  @override
  State<WebsitePreview> createState() => _WebsitePreviewState();
}

class _WebsitePreviewState extends State<WebsitePreview> {
  static const _viewType = "thg-website-preview";
  static bool _isViewFactoryRegistered = false;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
  }

  static void _registerViewFactory() {
    if (_isViewFactoryRegistered) return;

    _isViewFactoryRegistered = true;
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (
      int viewId, {
      Object? params,
    }) {
      final preview = params! as Map<Object?, Object?>;
      final iframe = web.HTMLIFrameElement()
        ..src = preview["url"]! as String
        ..loading = "lazy"
        ..referrerPolicy = "strict-origin-when-cross-origin";

      iframe
        ..setAttribute("title", preview["title"]! as String)
        ..setAttribute(
          "sandbox",
          "allow-forms allow-popups allow-popups-to-escape-sandbox "
              "allow-same-origin allow-scripts",
        );
      iframe.style
        ..border = "0"
        ..height = "100%"
        ..width = "100%";
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
      creationParams: <String, String>{
        "url": widget.uri.toString(),
        "title": "${widget.title} website preview",
      },
    );
  }
}
