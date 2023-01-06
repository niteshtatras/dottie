import 'package:flutter/material.dart';

abstract class AppColor{
  static const PAGE_COLOR = const Color(0xffF8F6F4);
  static const LOADER_COLOR = const Color(0xff229DF5);
  static const WHITE_COLOR = const Color(0xffFFFFFF);
  static const BLACK_COLOR = const Color(0xff000000);
  static const GREY_COLOR = const Color(0xffD2D0CE);
  static const RED_COLOR = const Color(0xffD92C2C);
  static const SUCCESS_COLOR = const Color(0xff37D4BC);
  static const HEADER_COLOR = const Color(0xff438f92);
  static const DARK_BLUE_COLOR = const Color(0xff007AFF);
  static const TRANSPARENT = const Color(0x00000000);
  static const DEACTIVATE = const Color(0xFFA19F9D);

  static const TYPE_PRIMARY = const Color(0xff404E63);
  static const TYPE_PRIMARY_1 = const Color(0xff1B202B);
  static const TYPE_SECONDARY = const Color(0xff98A0AB);
  static const TYPE_PRIMARY_ALT = const Color(0xff3B3A39);
  static const TYPE_SECONDARY_ALT = const Color(0xff605E5C);
  static const TYPE_DISABLE = const Color(0xffa19f9d);
  static const TYPE_NEUTRAL = const Color(0xffFFFFFF);

  static const THEME_PRIMARY = const Color(0xff229DF5);
  static const SECONDARY_BREEZE = const Color(0xff509BCC);
  static const THEME_SECONDARY = const Color(0xffFF8E27);
  static const THEME_ALT = const Color(0xff37D4BC);

  static const DIVIDER = const Color(0xffE5E5E5);
  static const SEC_DIVIDER = const Color(0xffF4F4F4);
  static const BARRIER_COLOR = const Color(0xffF2F6FA);

  static const BG_PRIMARY = const Color(0xffFFFFFF);
  static const BG_PRIMARY_ALT = const Color(0xffF8F6F4);
  static const BG_SECONDARY = const Color(0xffF9F9FA);
  static const BG_SECONDARY_ALT = const Color(0xffF4F4F5);

  static const STATUS_DESTRUCTIVE = const Color(0xffF4F4F5);
  static const STATUS_ALERT = const Color(0xffF4F4F5);
  static const STATUS_WARNING = const Color(0xffF4F4F5);
  static const STATUS_SUCCESS = const Color(0xffF4F4F5);

  static const INSPECTION_ICON = const Color(0xFFEBB06C);
  static const BACKGROUND_COLOR = const Color(0xff4790C2);

  static const ACCENT_COLOR = const Color(0xffEBB06C);
  static const SKY_COLOR = const Color(0xffA4C7E2);

  static const MaterialColor themeColor = MaterialColor(
      0xff000000,
      const <int, Color>  {
        50: AppColor.BLACK_COLOR,
        100:AppColor.BLACK_COLOR,
        200:AppColor.BLACK_COLOR,
        300:AppColor.BLACK_COLOR,
        400:AppColor.BLACK_COLOR,
        500:AppColor.BLACK_COLOR,
        600:AppColor.BLACK_COLOR,
        700:AppColor.BLACK_COLOR,
        800:AppColor.BLACK_COLOR,
        900:AppColor.BLACK_COLOR,
      }
  );

  static List<Color> gradientColor(opacity) {
    return [
      Color(0xff764BA2).withOpacity(opacity),
      Color(0xff667EEA).withOpacity(opacity)
    ];
  }
}

