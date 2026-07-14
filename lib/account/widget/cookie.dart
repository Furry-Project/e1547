import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CookieCapturePage extends StatefulWidget {
  const CookieCapturePage({super.key, this.title});

  final Widget? title;

  @override
  State<CookieCapturePage> createState() => _CookieCapturePageState();
}

class _CookieCapturePageState extends State<CookieCapturePage> {
  late final WebViewController controller = WebViewController()
    ..setUserAgent(AppInfo.instance.userAgent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Theme.of(context).colorScheme.surface)
    ..loadRequest(Uri.parse(normalizeHostUrl(context.read<Client>().host)));

  Future<void> setCookies(BuildContext context) async {
    IdentityClient client = context.read<IdentityClient>();
    WebviewCookieManager cookieManager = WebviewCookieManager();
    List<Cookie> cookies = await cookieManager.getCookies(client.identity.host);

    Map<String, String> headers = Map.of(client.identity.headers ?? {});
    // Drop cookies the old logic wrongly stored as top-level headers.
    Set<String> captured = cookies.map((cookie) => cookie.name).toSet();
    headers.removeWhere(
      (key, value) => isCloudflareCookie(key) || captured.contains(key),
    );

    Map<String, String> jar = {};
    String? existing = headers[HttpHeaders.cookieHeader];
    if (existing != null) {
      for (final pair in existing.split('; ')) {
        int split = pair.indexOf('=');
        if (split <= 0) continue;
        String name = pair.substring(0, split);
        if (isCloudflareCookie(name)) jar[name] = pair.substring(split + 1);
      }
    }

    for (final cookie in cookies) {
      if (isCloudflareCookie(cookie.name)) jar[cookie.name] = cookie.value;
    }

    if (jar.isEmpty) return;

    headers[HttpHeaders.cookieHeader] = jar.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('; ');
    client.replace(client.identity.copyWith(headers: headers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CloseButton(), title: widget.title),
      body: WebViewWidget(controller: controller),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          setCookies(context);
          Navigator.of(context).maybePop();
        },
      ),
    );
  }
}

bool isCloudflareCookie(String name) {
  // Challenge state cookies are transient and pointless to persist.
  if (name.startsWith('cf_chl')) return false;
  return name.startsWith('cf_') || name.startsWith('__cf');
}
