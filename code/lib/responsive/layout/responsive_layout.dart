import 'package:flutter/material.dart';
import 'package:unite/responsive/dimensions/dimensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileWidget;
  final Widget desktopWidget;

  ResponsiveLayout({super.key, required this.desktopWidget, required this.mobileWidget});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder:  (context, constraints){
      if(constraints.maxWidth < mobileWidth){
        return mobileWidget;
      }
      else{
        return desktopWidget;
      }
    });
  }
}