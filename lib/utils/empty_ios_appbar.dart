import 'package:flutter/material.dart';

class EmptyIOSAppBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);

}

