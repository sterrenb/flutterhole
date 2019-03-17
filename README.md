# FlutterHole

[![Codemagic build status](https://api.codemagic.io/apps/5c659ea9c49a5000198d45f9/5c659ea9c49a5000198d45f8/status_badge.svg)](https://codemagic.io/apps/5c659ea9c49a5000198d45f9/5c659ea9c49a5000198d45f8/latest_build)
[![Travis Build Status](https://travis-ci.org/sterrenburg/flutterhole.svg?branch=master)](https://travis-ci.org/sterrenburg/flutterhole)
[![Coverage Status](https://coveralls.io/repos/github/sterrenburg/flutterhole/badge.svg?branch=master)](https://coveralls.io/github/sterrenburg/flutterhole?branch=master)
[![Beerpay](https://beerpay.io/sterrenburg/flutterhole/make-wish.svg?style=flat)](https://beerpay.io/sterrenburg/flutterhole)
[![MIT Licenced](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Flutter-yellow.svg)](https://flutter.io)

FlutterHole is a free third party Android application for interacting with your Pi-Hole® server.

[<img src="https://f-droid.org/badge/get-it-on.png"
      alt="Get it on F-Droid"
      height="80">](https://f-droid.org/app/sterrenburg.github.flutterhole)

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
      alt="Get it on Google Play"
      height="80">](https://play.google.com/store/apps/details?id=sterrenburg.github.flutterhole)

## Features
- **Quick enable/disable** - toggle your Pi-hole® from your home screen or a single tap in FlutterHole.
- **Multiple configurations** - Easily switch between every Pi-hole® that you have access to.
- **Recently Blocked** - see a live view of requests that are currently being blocked.
- **Summary overview** - view the amount of queries sent and blocked.
- **Dark mode** - because we can.

## Development

Flutterhole is developed using [Android Studio](https://developer.android.com/studio), which offers a complete, integrated IDE experience for Flutter.

Testing is done using a local Pi-hole installation on an internal network. Due to this, support for other network setups relies heavily on user feedback. 

If you want to improve the network support for FlutterHole by testing against your own setups, you can build the app locally and debug any issues.

## Limitations
This application interacts with the [PHP API](https://discourse.pi-hole.net/t/pi-hole-api/1863) which has few features. For example, the Recently Blocked screen has to frequently ping the API to imitate a stream of domains being blocked.

A [new official API](https://github.com/pi-hole/api) is being built in Rust, but has no official documentation or release yet. Once the new API documentation becomes available, new cool features can be implemented so that FlutterHole is equal in capability to the dashboard.