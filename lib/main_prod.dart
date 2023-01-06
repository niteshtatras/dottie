import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/webServices/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

void main() {
//  https://api.dev.edu-collab.com/
  GlobalInstance.apiBaseUrl = 'https://inspectordottie.com/';
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SharedPreferences.getInstance().then((prefs) {
      var configuredApp = new AppConfig(
        appName: 'Inspector-Dottie',
        envName: 'development',
        apiBaseUrl: 'https://dev.inspectordottie.com/',
        child: new MyApp(prefs: prefs),
      );
      runApp(configuredApp);
  });
}

