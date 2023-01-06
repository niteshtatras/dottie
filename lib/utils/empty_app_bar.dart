import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final isDarkMode;

  EmptyAppBar({Key key, @required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? Colors.black : Colors.white
    );
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);

}

