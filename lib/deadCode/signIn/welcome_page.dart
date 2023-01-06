import 'package:dottie_inspector/deadCode/signIn/app_intro.dart';
import 'package:dottie_inspector/utils/empty_app_bar.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  static String tag = 'welcome-page';

  @override
  _WelcomePageState createState() => new _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  BuildContext context;
  SingleButtonIntro _appIntro;
  List<Slide> _slides = [
    Slide(
        'Dottie will fundamentally change the way you run your pool business.',
        'screen1'
    ),

    Slide(
        'Dottie will fundamentally change the way you run your pool business.',
        'screen2'
    ),

    Slide(
        'Dottie will fundamentally change the way you run your pool business.',
        'screen3'
    ),

    Slide(
        'Dottie will fundamentally change the way you run your pool business.',
        'screen4'
    )
  ];

  @override
  void initState() {
    super.initState();

    _appIntro = SingleButtonIntro(
        _slides,
    );
  }

  @override
  Widget build(BuildContext context) {
   this.context = context;
   return Scaffold(
      appBar: EmptyAppBar(isDarkMode: false,),
      body: _appIntro,
    );
  }
}
