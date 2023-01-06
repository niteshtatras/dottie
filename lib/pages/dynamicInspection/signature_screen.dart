import 'dart:developer';
import 'dart:typed_data';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/res/size.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:dottie_inspector/widget/dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hand_signature/signature.dart';
import 'package:dottie_inspector/pages/menu/drawer_page.dart';

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  ByteData imgBytes;
  Image mainImage;

  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  ValueNotifier<String> svg = ValueNotifier<String>(null);

  ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);

  ByteData imgData;

  bool isDarkMode = false;
  Color themeColor = AppColor.BLACK_COLOR;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    getThemeData();
  }

  void getThemeData() async {
    await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
      setState(() {
        var themeMode = value == null ? "" : value;
        log("ThemeData===$themeMode");
        if(themeMode == "auto") {
          var brightness = MediaQuery.of(context).platformBrightness;
          themeMode = Brightness.dark ==  brightness ? "dark" : "light";
        }
        isDarkMode = themeMode == "dark";
        themeColor = isDarkMode ? AppColor.WHITE_COLOR : AppColor.BLACK_COLOR;
      });
    });
  }

  Widget _buildImageView() => Container(
    width: 192.0,
    height: 96.0,
    decoration: BoxDecoration(
      border: Border.all(),
      color: Colors.white30,
    ),
    child: ValueListenableBuilder<ByteData>(
      valueListenable: rawImage,
      builder: (context, data, child) {
        if (data == null) {
          return Container(
            color: Colors.red,
            child: Center(
              child: Text('not signed yet (png)'),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Image.memory(data.buffer.asUint8List()),
          );
        }
      },
    ),
  );

  Widget _buildSvgView() => Container(
    width: 192.0,
    height: 96.0,
    decoration: BoxDecoration(
      border: Border.all(),
      color: Colors.white30,
    ),
    child: ValueListenableBuilder<String>(
      valueListenable: svg,
      builder: (context, data, child) {
        return HandSignatureView.svg(
          data: data,
          padding: EdgeInsets.all(8.0),
          placeholder: Container(
            color: Colors.red,
            child: Center(
              child: Text('not signed yet (svg)'),
            ),
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(isDarkMode: isDarkMode),
      body: SafeArea(
        child: Container(
          color: isDarkMode ? Colors.black : Colors.white,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.only(left: 16.0, right: 0.0),
                      icon: Icon(
                        Icons.clear,
                        color: themeColor,
                        size: 32.0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: DottedBorder(
                        color: AppColor.TRANSPARENT,
                        radius: Radius.circular(16.0),
                        borderType: BorderType.RRect,
                        strokeWidth: 4.0,
                        strokeCap: StrokeCap.square,
                        dashPattern: [5,8],
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(3.0),
                                constraints: BoxConstraints.expand(),
                                color: isDarkMode
                                ? Color(0xff1f1f1f)
                                : Colors.white,
                                child: HandSignaturePainterView(
                                  control: control,
                                  color: isDarkMode ? Colors.white : Color(0xFF1B202B),
                                  type: SignatureDrawType.arc,
                                  width: 2.0,
                                ),
                              ),
                              CustomPaint(
                                painter: DebugSignaturePainterCP(
                                  control: control,
                                  cp: false,
                                  cpStart: false,
                                  cpEnd: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: control.clear,
                        child: Container(
                          height: 45.0,
                          width: 200.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: isDarkMode ? Color(0xff1f1f1f) : AppColor.DIVIDER,
                              borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          child: Text(
                            'CLEAR SIGNATURE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeColor,
                              fontSize: TextSize.bodyText,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0,),
                      InkWell(
                        onTap: () async {
                          imgData = null;
                          svg.value = control.toSvg(
                            color: Colors.blueGrey,
                            size: 2.0,
                            maxSize: 15.0,
                            type: SignatureDrawType.shape,
                          );

                          rawImage.value = await control.toImage(
                            color: Colors.blueAccent,
                          );

                          imgData = await control.toImage();
                          print("Signature====>>>${rawImage.value}");
                          Navigator.of(context).pop({
                            "image": imgData
                          });
                        },
                        child: Container(
                          height: 45.0,
                          width: 200.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColor.gradientColor(1.0)
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(16.0))
                          ),
                          child: Text(
                            'DONE SIGNING',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.WHITE_COLOR,
                              fontSize: TextSize.bodyText,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  /*RawImage(
                    width: 100.0,
                    height: 20.0,
                    image: mainImage,
                    fit: BoxFit.contain,
                  ),*/
                  SizedBox(
                    height: 16.0,
                  ),
                ],
              ),
              /*Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildImageView(),
                    _buildSvgView(),
                  ],
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class Signature1 extends CustomPainter {
  List<Path> paths = new List<Path>();

  Signature1({this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    for (Path p in paths) {
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(Signature1 oldDelegate) => true;
}

/// create_password_screen_page_1
/// reset_confirm_account  --- Dark Mode Missing

/// create_account
/// forgot_password
/// login_page
/// privacy_policy_page
/// register_email
/// register_user
/// reset_password
/// reset_password_success

/// password_success
/// privacy_easial_page

/// sign_up_conduction_pool_page
/// sign_up_experience_pool
/// sign_up_onboarding_ques_page
