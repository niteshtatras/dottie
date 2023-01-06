import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dottie_inspector/preferences/app_shared_preferences.dart';
import 'package:dottie_inspector/utils/globalInstance.dart';
import 'package:dottie_inspector/utils/http_override.dart';
import 'package:dottie_inspector/utils/lock_file.dart';
import 'package:dottie_inspector/webServices/config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

import 'main.dart';

const simplePeriodicTask = "simplePeriodicTask";
// Workmanager workManager = Workmanager();
// flutter local notification setup

// Future initializeWorkManagerAndPushNotification() async {
//   await workManager.initialize(
//     callbackDispatcher,
//     isInDebugMode: true,
//   ); //to true if still in testing lev turn it to false whenever you are launching the app
// }


void main() async {
  runZonedGuarded<Future<void>>(() async {
    //  https://api.dev.edu-collab.com/
    WidgetsFlutterBinding.ensureInitialized();

    GlobalInstance.apiBaseUrl = 'https://inspectordottie.com/';
    // GlobalInstance.apiBaseUrl = 'https://dev.inspectordottie.com/';

    // final themeNotifier = Provider.of<ThemeNotifier>(context);

    LockSynchronized.getLockInstance();
    // await Firebase.initializeApp();
    // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    ///Tablet View
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

/*  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColor.THEME_PRIMARY.withOpacity(0.6),
      systemNavigationBarColor: AppColor.THEME_PRIMARY
    )
  );*/

    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //   statusBarColor: isDarkMode ? AppColor.BLACK_COLOR : AppColor.THEME_PRIMARY.withOpacity(0.4), // Color for Android
    //   statusBarBrightness: Brightness.light, // Dark == white status bar -- for IOS.
    // ));



    // FlutterBackgroundService.initialize(onStart);
    // Workmanager().initialize(
    //     callbackDispatcher,
    //   isInDebugMode: true
    // );

    // await initializeWorkManagerAndPushNotification();
    // InAppPurchaseConnection.enablePendingPurchases();

    SharedPreferences.getInstance().then((prefs) async {
      var configuredApp = new AppConfig(
        appName: 'Inspector-Dottie',
        envName: 'development',
        apiBaseUrl: 'https://dev.inspectordottie.com/',
        child: new MyApp(prefs: prefs),
      );

      try{
        await Firebase.initializeApp(
          name: "inspector-dottie",
          options: const FirebaseOptions(
            apiKey: 'AIzaSyCVBYr1YIEPCNaJX9rXRuW41O16FlWU-wc',
            appId: '1:311722230009:ios:d43b436f5a8bb166832228',
            messagingSenderId: '311722230009',
            projectId: 'inspector-dottie-ai',
            authDomain: 'inspector-dottie-ai.firebaseapp.com',
            iosClientId: '311722230009-id5g60ggr8n9gq36s6lvfc9j5kal96ql.apps.googleusercontent.com',
          ),
        );
      } on FirebaseException catch (e) {
        print("Firebase Exception====$e");
      }

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
//      // pass your key api of bugsnag to the plugin to setup
//      BugsnagCrashlytics.instance.register(androidApiKey: "c9cf3c0ef60ae325ede8f78dab482725", iosApiKey: "2068e8f1281ed59ee4ebb1773dbe6dac", releaseStage: 'RELEASE_STAGE', appVersion: '0.0.1');
//
//      // Pass all uncaught errors from the framework to Crashlytics.
//      FlutterError.onError = BugsnagCrashlytics.instance.recordFlutterError;

      // await initializeWorkManagerAndPushNotification();
      // if(Firebase.apps.isEmpty) {
      //   await Firebase.initializeApp(
      //     options: const FirebaseOptions(
      //         apiKey: 'AIzaSyCgQzex64TQkdbV2Lv0vk8vLnfkhjO4xxs',
      //         appId: '1:1022801748027:ios:4b4819163ad1613b353c1e',
      //         projectId: 'dottie-inspector',
      //         messagingSenderId: "1022801748027"
      //     ),
      //   ).whenComplete(() {
      //     print("Firebase initialization completed");
      //   });
      // }
      //
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      runApp(configuredApp);
      HttpOverrides.global = MyHttpOverrides();
      // runZonedGuarded(() async {
      //
      // }, (error, stackTrace){
      //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
      // });
    });
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

/***
// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    sendPendingRequest();
    BackgroundFetch.finish(taskId);
    return;
  }
  // print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}
***/

Future<bool> getThemeData() async {
  await PreferenceHelper.getPreferenceData(PreferenceHelper.THEME_MODE).then((value){
    var themeMode = value == null ? "" : value;
    log("ThemeData1111===$themeMode");
    if(themeMode == "auto") {
      var brightness = MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness;
      log("Brigthness===$brightness");
      themeMode = Brightness.dark ==  brightness ? "dark" : "light";
    }
    bool isDarkMode = themeMode == "dark";
    log("isDarkMode1111===$isDarkMode");
    return isDarkMode;
  });

  return false;
}




