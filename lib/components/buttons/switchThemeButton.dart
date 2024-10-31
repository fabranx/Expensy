import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:expensy/components/navBarColorHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SwitchThemeButton extends StatefulWidget {
  const SwitchThemeButton({super.key});

  @override
  State<SwitchThemeButton> createState() => _SwitchThemeButtonState();
}

class _SwitchThemeButtonState extends State<SwitchThemeButton>{
  // final theme = AdaptiveTheme.getThemeMode();
  late bool switchValue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AdaptiveTheme.getThemeMode(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          AdaptiveThemeMode? themeMode = snapshot.data;
          switchValue = themeMode!.isDark ? true : false;
          return Switch(
              value: switchValue,
              onChanged: (prev) {
                AdaptiveTheme.of(context).toggleThemeMode(useSystem: false);
                setNavBarColor(themeMode.next());  // change themeMode between dark and light (system theme mode is disabled)
                setState(() {
                  switchValue = prev;
                });
              }
          );
        } else {
          return const SpinKitDoubleBounce(
              color: Colors.blueGrey,
              size: 20,
            );
        }
      }
    );
  }
}