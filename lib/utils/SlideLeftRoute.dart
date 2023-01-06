import 'package:flutter/material.dart';

class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  SlideLeftRoute({this.page})
      : super(
      pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          ) =>
      page,
      transitionsBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
          ) =>
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
  //            begin: const Offset(0.0, 0.0),
  //            end: const Offset(-1.0, 0.0),
            ).animate(animation),
            child: child,
          ),
    );
   /* pageBuilder: (
        BuildContext context,
        Animation<double> secondaryAnimation,
        Animation<double> animation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> secondaryAnimation,
        Animation<double> animation,
        Widget child,
        ) =>
        SlideTransition(
          position: Tween<Offset>(
//            begin: const Offset(1.0, 0.0),
//            end: Offset.zero,
            begin: Offset.zero,
            end: const Offset(1.0, 0.0),
          ).animate(animation),
          child: child,
        ),
  );*/
}