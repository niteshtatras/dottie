import 'package:dottie_inspector/res/color.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomToast {
  FToast fToast;

  static void showLongToast(String message) {
    // This is Long Toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  static void showColoredToast(String message) {
    // This is Colored Toast with android duration of 5 Sec
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }

  static void showDottieToast(String message) {
    // This is Colored Toast with android duration of 5 Sec
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Color(0xff4090C2),
        gravity: ToastGravity.TOP,
        fontSize: 16.0,
        textColor: Colors.white
    );
  }

  static void showShortToast(String message) {
    // This is Short Toast
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 1);
  }

  static void showTopShortToast(String message) {
    // This is Top Short Toast
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1);
  }

  static void showCenterShortToast(String message) {
    // This is Center Short Toast
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }

  static void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void cancelToast() {
    Fluttertoast.cancel();
  }
}
