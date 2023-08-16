// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';


class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget tabletScaffold;
  final Widget desktopScaffold;

  ResponsiveLayout({
    required this.mobileScaffold,
    required this.tabletScaffold,
    required this.desktopScaffold,
  });

  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 2000) {
          return mobileScaffold;
        } else if (constraints.maxWidth < 5000) {
          return tabletScaffold;
        } else {
          return desktopScaffold;
        }
      },
    );
  }
}
