# dottie_inspector

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Solution For crashlytics issue in ios
edit this file
nano ~/.pub-cache/hosted/pub.dartlang.org/firebase_crashlytics-0.2.4/ios/firebase_crashlytics.podspec
----------------------------
add below line 
s.dependency 'Flutter'
-------------
above 
s.dependency 'firebase_core'
----------------
# For Reference : https://fantashit.com/fatal-error-flutter-flutter-h-file-not-found/
