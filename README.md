# FlutterHole #  
[![Codemagic build status](https://api.codemagic.io/apps/5c659ea9c49a5000198d45f9/5c65b2f4b66bc70009aaa202/status_badge.svg)](https://codemagic.io/apps/5c659ea9c49a5000198d45f9/5c65b2f4b66bc70009aaa202/latest_build)  
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
 ## Features ##  
 - **Quick enable/disable:** Toggle your Pi-hole from your home screen with a single tap.
 - **Multiple configurations:** Easily switch between every Pi-hole that you have access to.
 - **Manage your blacklist & whitelist:** Add or remove domains, wildcards and regular expressions from your lists.
 - **Query log:** View recent queries and add them to your blacklist or whitelist.
 - **Summary overview:** View top clients and the top used domains.
 - **Custom themes:** Because we can.

## Development ##  
  FlutterHole is developed using [Android Studio](https://developer.android.com/studio), which offers a complete, integrated IDE experience for Flutter.    
    
Testing is done using a local Pi-hole installation on an internal network. Due to this, support for other network setups relies heavily on user feedback.     
    
If you want to improve the network support for FlutterHole by testing against your own setups, you can build the app locally and debug any issues.    
    
## API  ##
This application interacts with the [PHP API](https://discourse.pi-hole.net/t/pi-hole-api/1863).  
    
A [new official API](https://github.com/pi-hole/api) is being built in Rust, but has no official release yet. Once the new API documentation becomes available, new cool features can be implemented!