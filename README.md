# FlutterHole

[![Codemagic build status](https://api.codemagic.io/apps/5c659ea9c49a5000198d45f9/5c65b2f4b66bc70009aaa202/status_badge.svg)](https://codemagic.io/apps/5c659ea9c49a5000198d45f9/5c65b2f4b66bc70009aaa202/latest_build)
[![Beerpay](https://beerpay.io/sterrenburg/flutterhole/make-wish.svg?style=flat)](https://beerpay.io/sterrenburg/flutterhole)
[![MIT licenced](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Flutter-yellow.svg)](https://flutter.io)
[![Beerpay](https://beerpay.io/sterrenburg/flutterhole/badge.svg?style=flat)](https://beerpay.io/sterrenburg/flutterhole)

FlutterHole is a free third party Android application for interacting with your Pi-Hole® server.

## Features
- **Quick enable/disable** - toggle your Pi-hole® from your home screen or a single tap in FlutterHole.
- **Multiple configurations** - Easily switch between every Pi-hole® that you have access to.
- **Recently Blocked** - see a live view of requests that are currently being blocked.
- **Summary overview** - view the amount of queries sent and blocked.
- **Dark mode** - because we can.

##   Limitations
This application interacts with the [PHP API](https://discourse.pi-hole.net/t/pi-hole-api/1863) which has few features. For example, the Recently Blocked screen has to frequently ping the API to imitate a stream of domains being blocked.

A [new official API](https://github.com/pi-hole/api) is being built in Rust, but has no official documentation or release yet. Once the new API documentation becomes available, new cool features can be implemented so that FlutterHole is equal in capability to the dashboard.