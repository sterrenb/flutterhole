
# FlutterHole #

[![Codemagic build status](https://api.codemagic.io/apps/5c659ea9c49a5000198d45f9/5c659ea9c49a5000198d45f8/status_badge.svg)](https://codemagic.io/apps/5c659ea9c49a5000198d45f9/5c659ea9c49a5000198d45f8/latest_build)
[![Coverage Status](https://coveralls.io/repos/github/sterrenburg/flutterhole/badge.svg?branch=master)](https://coveralls.io/github/sterrenburg/flutterhole?branch=master)
[![MIT Licenced](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Flutter-yellow.svg)](https://flutter.io)

FlutterHole is a free third party Android application for interacting with your Pi-Hole® server.    

 [<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"    
      alt="Get it on Google Play"    
      height="80">](https://play.google.com/store/apps/details?id=sterrenburg.github.flutterhole)    
## Features ##
- **Quick enable/disable:** Toggle your Pi-hole from your home screen with a single tap.
- **Multiple configurations:** Easily switch between every Pi-hole that you have access to.
- **Summary overview:** View top clients and the top used domains.
- **Query log:** Inspect & search your Pi-hole queries.

## Development ##
FlutterHole is developed using [Android Studio](https://developer.android.com/studio), which offers a complete, integrated IDE experience for Flutter.

Testing is done using a local Pi-hole installation on an internal network. Due to this, support for other network setups relies heavily on user feedback.

If you want to improve the network support for FlutterHole by testing against your own setups, you can build the app locally and debug any issues.

### Getting Started ###
After cloning this repository, perform the following steps before building your project.

All snippets assume your initial working directory is the root of the project.

#### Generate a debug signing key ####

Skip the questions, and confirm with `yes`.
```shell script
#!/bin/bash
cd android/app
keytool -genkey -v -keystore keystore.jks -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
```

#### Create a properties file for the signing key ####
```shell script
#!/bin/bash
cd android
touch key.properties
```

After creating the file, populate it with plaintext describing the debug key.

```
storePassword=android
keyPassword=android
keyAlias=androiddebugkey
storeFile=keystore.jks
```

#### Generate the icon assets ####
```shell script
#!/bin/bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

#### Generate code ####

To generate `freezed` classes, `injectable` injections etc.:

```shell script
flutter pub run build_runner build --delete-conflicting-outputs  
```

Or, build continuously:

```shell script
flutter pub run build_runner watch --delete-conflicting-outputs  
```

You can now build and run the app on either an emulator or a physical device using `flutter run`.

### Testing ###

To run the default integration test:

```shell script
flutter drive --target=test_driver/app.dart
```

## API ##
This application interacts with the [Pi-hole PHP API](https://discourse.pi-hole.net/t/pi-hole-api/1863).

A new API is in the works from the Pi-hole team. For progress, check the [pull request on GitHub](https://github.com/pi-hole/FTL/pull/659).