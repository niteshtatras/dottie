import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/widget/masked_phone_number.dart';
import 'package:flutter/material.dart';

class DemoMaskedTextField extends StatefulWidget {
  @override
  _DemoMaskedTextFieldState createState() => _DemoMaskedTextFieldState();
}

class _DemoMaskedTextFieldState extends State<DemoMaskedTextField> {
  var maskedController = MaskedTextController(mask: '(000) 000-0000');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    controller: maskedController,
                    style: TextStyle(
                      color: AppColor.TYPE_PRIMARY,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    ),
                    maxLines: 1,
                  ),
                ]
            ),
          )
        ]
      ),
    );
  }
}
