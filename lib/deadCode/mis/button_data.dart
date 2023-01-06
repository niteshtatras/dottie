import 'dart:io';

import 'package:dottie_inspector/res/color.dart';
import 'package:dottie_inspector/utils/helper_class.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ButtonData extends StatefulWidget {
  const ButtonData({Key key}) : super(key: key);

  @override
  _ButtonDataState createState() => _ButtonDataState();
}

class _ButtonDataState extends State<ButtonData> {
  bool _isElevated = true;
  var imagePath = '';
  var buttonName = "Subscribe";

  ImagePicker _picker = ImagePicker();

  Future getImageFromCamera() async {
    var image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // setState(() {
      //   imagePath = image.path;
      // });
      if (image != null) {
        File compressedFile = await HelperClass.getCompressedImageFile(File(image.path));

        setState(() {
          imagePath = compressedFile.path;
        });
        // setState(() {
        //   uploadLocationImage(compressedFile.path);
        // });
      }
      // openCropImageOption(image, type, state);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text('Data'),
      ),
      body: Center(
        child: Column(
          children: [
            imagePath != ""
            ? Container(
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                height: 250,
                width: 250,
              ),
            )
            : Container(),
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 16),
                child: GestureDetector(
                  onTap: ()async {
                    setState(() {
                      _isElevated = !_isElevated;
                    });
                    await Permission.camera.request().then((status) {
                      if (status.isGranted) {
                        print("Camera Permission Granted");
                      } else if (status.isDenied) {
                        print("Camera Permission Denied");
                      } else
                      if (status.isPermanentlyDenied) {
                        print("Camera Permission Permanently Denied");
                        // openAppSettings();
                      }
                    });

                    await Permission.location.request().then((status) {
                      if (status.isGranted) {
                        print("Granted");
                      } else if (status.isDenied) {
                        print("Denied");
                      } else
                      if (status.isPermanentlyDenied) {
                        print("Permanently Denied");
                        openAppSettings();
                      }
                    });

                    // bool isShown = await Permission.contacts.shouldShowRequestRationale;
                    // if(await Permission.location.isPermanentlyDenied) {
                    //
                    // } else {
                    //   // openAppSettings();
                    // }
                    // getImageFromCamera();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    width: 200,
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: _isElevated
                      ? [
                        BoxShadow(
                          color: Colors.grey[500],
                          offset: Offset(4, 4),
                          blurRadius: 15,
                          spreadRadius: 1
                        ),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(-4, -4),
                            blurRadius: 15,
                            spreadRadius: 1
                        )
                      ]
                      : [
                        BoxShadow(
                            color: Colors.grey[500],
                            offset: Offset(0, 0),
                            blurRadius: 15,
                            spreadRadius: 1
                        ),
                        BoxShadow(
                            color: Colors.white,
                            offset: Offset(-1, -1),
                            blurRadius: 15,
                            spreadRadius: 1
                        )
                      ],
                    ),
                    // child: Center(child: Container(child: Text('Edit'))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


