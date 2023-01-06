import 'package:dottie_inspector/res/size.dart';
import 'package:flutter/material.dart';

import 'color.dart';

abstract class Styles{
  static const textWhiteStyle = TextStyle(
      color: AppColor.WHITE_COLOR,
      fontSize: TextSize.bodyText,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      height: 1.3
  );
}