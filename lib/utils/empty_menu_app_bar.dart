import 'package:flutter/material.dart';

class EmptyMenuAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    );
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}
