import 'package:e1547/app/app.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:fox_secure_switcher/fox_secure_switcher.dart';

class SecureDisplay extends StatelessWidget {
  const SecureDisplay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubValueListener(
      initialize: true,
      listenable: context.watch<Settings>().secureDisplay,
      listener: (value) {
        if (!PlatformCapabilities.hasSecureDisplay) return;
        if (value) {
          SecureAppSwitcher.on(iosStyle: SecureMaskStyle.blurDark);
        } else {
          SecureAppSwitcher.off();
        }
      },
      builder: (context, value) => child,
    );
  }
}
