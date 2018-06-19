# StreetHawk's Analytics Plugin

## Introduction
The repository hosts Phonegap plugin of StreetHawk SDK's Analytics module. The plugin  reports various vital raw data to StreetHawk servers which is further processed and used for various analytic for your application. The module also provides API for tagging the install, identifying the users and tracking various important events inside your application. 

## Integration Steps
Execute below mentioned command to add StreetHawk Analytics plugin to your application. In the command below, replace YOUR_APPLICATIONS_APP_KEY with application’s app_key registered with StreetHawk and URL_SCHEME_OF_APP with url scheme of your application for deeplinking. 

```
$ cd <APPLICATION_DIRECTORY>
$ cordova plugin add streethawkanalytics  --variable APP_KEY=<YOUR_APPLICATIONS_APP_KEY> --variable URL_SCHEME=<URL_SCHEME_OF_APP>
```
## Documentation
Click [here](https://dashboard.streethawk.com/docs/sdks/phonegap/analytics/) for detailed documentation of StreetHawk's Analytics plugin.

## Other StreetHawk Phonegap plugins

1. [Growth](https://github.com/StreetHawkSDK/PhonegapGrowth) for Viral and organic growth
2. [Push](https://github.com/StreetHawkSDK/PhonegapPush) Push messaging in your application
3. [Geofence](https://github.com/StreetHawkSDK/PhonegapGeofence) for running geofence based campaigns 
4. [Beacon](https://github.com/StreetHawkSDK/PhonegapBeacon) for running beacon based campaigns
5. [Location](https://github.com/StreetHawkSDK/PhonegapLocations) for running campaigns based on user's location
6. [Feeds](https://github.com/StreetHawkSDK/PhonegapFeeds) for sending feeds in your application
