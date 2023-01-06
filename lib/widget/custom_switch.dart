import 'package:dottie_inspector/res/color.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  CustomSwitch({
    Key key,
    this.value,
    this.onChanged})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 10));
    _circleAnimation = AlignmentTween(
        begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
        parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false
                ? widget.onChanged(true)
                : widget.onChanged(false);
          },
          child: Container(
            width: 48.0,
            height: 32.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32.0),
              gradient: LinearGradient(
                colors: !widget.value
                    ? [AppColor.TYPE_PRIMARY.withOpacity(0.6), AppColor.TYPE_PRIMARY.withOpacity(0.6)]
                    : [Color(0xff013399), Color(0xffBC96E6)]
              ),
              border: Border.all(
                color: !widget.value
                  ? AppColor.TRANSPARENT
                  : AppColor.TRANSPARENT,
                width: 1.0
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child:  Container(
                alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !widget.value
                          ? AppColor.WHITE_COLOR
                          : AppColor.WHITE_COLOR,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}