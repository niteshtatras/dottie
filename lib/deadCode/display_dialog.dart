import 'package:dottie_inspector/res/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DisplayDialog extends StatefulWidget {
  DisplayDialog({
    this.onOkButtonClick,
    this.message
  });

  final void Function() onOkButtonClick;
  String message;

  @override
  _DisplayDialogState createState() => _DisplayDialogState();
}

class _DisplayDialogState extends State<DisplayDialog> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      displayDrawerDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

  void displayDrawerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        content: Text(
          widget.message,
          style: TextStyle(
            color: AppColor.TYPE_PRIMARY,
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
              child: const Text('Cancel'),
              isDefaultAction: true,
              onPressed: () {
//                  return Future.value(true);
                Navigator.pop(context, 'Cancel');
              }),
          CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () {
//                  return Future.value(true);
                Navigator.of(context).pop(true);
              }),
        ],
      ),
      barrierDismissible: true,
    );
//    Navigator.of(context).pop(false);
  }

}
