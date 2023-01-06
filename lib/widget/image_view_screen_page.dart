import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:dottie_inspector/widget/bottom_general_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hand_signature/signature.dart';
import 'package:progress_hud/progress_hud.dart';

class ImageViewScreenPage extends StatefulWidget {
  final imageFile;
  final noteImagePath;

  const ImageViewScreenPage({Key key, this.imageFile, this.noteImagePath}) : super(key: key);

  @override
  _ImageViewScreenPageState createState() => _ImageViewScreenPageState();
}

class _ImageViewScreenPageState extends State<ImageViewScreenPage> {
  String imageFile;
  GlobalKey _globalKey = new GlobalKey();
  ProgressHUD _progressHUD;
  var _loading = false;

  final control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  

  void initState() {
    super.initState();
    _progressHUD = ProgressHUD(
      backgroundColor: Colors.transparent,
      color: Colors.white,
      containerColor: AppColor.LOADER_COLOR,
      borderRadius: 5.0,
      loading: _loading,
      text: 'Loading...',
    );

    setImageData();
  }

  void setImageData() async {
    setState(() {
      imageFile = widget.imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BLACK_COLOR,
      appBar: AppBar(
        backgroundColor: AppColor.BLACK_COLOR,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/ic_close.png',
              fit: BoxFit.cover,
              height: 28.0,
              width: 28.0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 120.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Container(
                    child: imageFile != ""
                      ? Container(
                          child: Image.file(
                          File(imageFile),
                          width: double.infinity ,
                          height: double.infinity * 80,
                          fit: BoxFit.contain,
                        ),
                      )
                      : Container(),
                  ),
                  RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      child: Stack(
                        children: [
                          Container(
                            child: widget.noteImagePath != null
                                ? Container(
                              child: Image.file(
                                widget.noteImagePath,
                                width: double.infinity ,
                                height: double.infinity * 80,
                                fit: BoxFit.contain,
                              ),
                            )
                                : Container(),
                          ),

                          Container(
                            margin: EdgeInsets.all(3.0),
                            constraints: BoxConstraints.expand(),
                            color: Colors.transparent,
                            child: HandSignaturePainterView(
                              control: control,
                              color: Color(0xFFEE5555),
                              type: SignatureDrawType.arc,
                              width: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          BottomGeneralButton(
            isActive: true,
            buttonName: "SAVE",
            onStartButton: (){
              capturePng();
            },
          ),

          _progressHUD
        ],
      ),
    );
  }

  Future<Uint8List> capturePng() async {
    try {
      _progressHUD.state.show();
      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      print('BYTE_DATA====>>>$byteData');

      DateTime now = DateTime.now();
      var fileName = HelperClass.getFileNameFormat("$now");
      print(fileName);
      var newFile = await HelperClass.getFile(byteData, "${fileName}_image");

      _progressHUD.state.dismiss();
      /*setState(() {
        imageFile = null;
        imageFile = newFile;
      });*/
      Navigator.of(context).pop(newFile);
      return null;
    } catch (e) {
      print(e);
    }
  }
}
