# FlutterHole

[![Coverage Status](https://coveralls.io/repos/github/sterrenburg/flutterhole/badge.svg?branch=master)](https://coveralls.io/github/sterrenburg/flutterhole?branch=master)

FlutterHole is a free third party Android application for interacting with your Pi-Hole® server.

## Features
- **Quick enable/disable** - toggle your Pi-hole® from your home screen or a single tap in FlutterHole.
- **Recently Blocked** - see a live view of requests that are currently being blocked.
- **Summary overview** - view the amount of queries sent and blocked.

##   Limitations
This application interacts with the [PHP API](https://discourse.pi-hole.net/t/pi-hole-api/1863) which has few features. For example, the Recently Blocked screen has to frequently ping the API to imitate a stream of domains being blocked.

A [new official API](https://github.com/pi-hole/api) is being built in Rust, but has no official documentation or release yet. Once the new API documentation becomes available, new cool features can be implemented so that FlutterHole is equal in capability to the dashboard.