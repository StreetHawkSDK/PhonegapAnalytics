/*
 * Copyright 2012 StreetHawk
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Created by Christine XYS
 */

#import <Cordova/CDV.h>
#import "StreetHawkCore.h"

/*
 * Class hosting streethawk's API for phonegap
 */
#ifdef SH_FEATURE_NOTIFICATION
@interface Streethawk : CDVPlugin <ISHPhonegapObserver, ISHCustomiseHandler>
#else
@interface Streethawk : CDVPlugin
#endif

//////////////////  Functions  ///////////////////////////////////

/**
 * Initialise Streethawk. Command argument is empty. Before calling this function, make sure following properties are setup correctly, otherwise default value will be used.
 * shSetEnableLogs(true/false), by default use false.
 * shSetiTunesId(string_value), by default use null.
 */
- (void)streethawkinit:(CDVInvokedUrlCommand *)command;

/**
 * Tag unique id for a sh_cuid. Command argument is [unique_string];
 */
- (void)tagCuid:(CDVInvokedUrlCommand *)command;

/**
 * Tag language for a sh_language. Command argument is [string_userlang];
 */
- (void)tagUserLanguage:(CDVInvokedUrlCommand *)command;

/**
 * Tag numeric for a key. Command argument is [key_string, number_value];
 */
- (void)tagNumeric:(CDVInvokedUrlCommand *)command;

/**
 * Tag string for a key. Command argument is [key_string, string_value];
 */
- (void)tagString:(CDVInvokedUrlCommand *)command;

/**
 * Tag datetime for a key. Command argument is [key_string, datetime_value];
 */
- (void)tagDatetime:(CDVInvokedUrlCommand *)command;

/**
 * Increment tag for a key. Command argument is [key_string];
 */
- (void)incrementTag:(CDVInvokedUrlCommand *)command;

/**
 * Remove tag for a key. Command argument is [key_string];
 */
- (void)removeTag:(CDVInvokedUrlCommand *)command;

/**
 * Get StreetHawk formatted date time string, such as `2016-10-21 16:23:18`. Command argument is miliseconds since 1970 (miliseconds_int).
 */
- (void)getFormattedDateTime:(CDVInvokedUrlCommand *)command;

/**
 * Send log to trace current page is entered. Command argument is [pageName_string].
 */
- (void)notifyViewEnter:(CDVInvokedUrlCommand *)command;

/**
 * Send log to trace current page is exit. Command argument is [pageName_string].
 */
- (void)notifyViewExit:(CDVInvokedUrlCommand *)command;

/**
 * Send feedback with only title and message to StreetHawk server. Command argument is [title_string, message_string].
 */
- (void)shSendSimpleFeedback:(CDVInvokedUrlCommand *)command;

/**
 * Callback for install register successfully. Callback get a string for `installid`.
 */
- (void)registerInstallEventCallback:(CDVInvokedUrlCommand *)command;

/**
 * Get stored view name for launching page notification, this is used for App launches and check whether a 8004 push notification occured. If this App is waken up by 8004 push notification, the view name is stored locally and read by this function, so that App knows a specific page should be loaded.
 */
- (void)shGetViewName:(CDVInvokedUrlCommand *)command;

/**
 * Callback for launching page notification. Callback get a string for `html_fileName`.
 */
- (void)shRegisterViewCallback:(CDVInvokedUrlCommand *)command;

/**
 * Callback for handling custom json push. Callback get a dictionary `{"title": <string>, "message", <string>, "json", <string>}`.
 */
- (void)shRawJsonCallback:(CDVInvokedUrlCommand *)command;

/**
 * Callback for showing custom dialog for one push. Callback get a dictionary `{"action": <enum>, "msgid": <int>, "title", <string>, "message": <string>, "data": <string>, "portion": <float>, "orientation": <enum>, "speed": <float>, "sound": <string>, "badge": <int>, "displaywihtoutdialog": <bool>}`. Customer's js using these information to create custom confirm dialog.
 * Please note:
 * 1. once `registerPushDataCallback` set, all custom dialog must be implemented by customer's js, StreetHawk's default dialog will not show.
 * 2. must call `sendPushResult` to let process continue.
 */
- (void)registerPushDataCallback:(CDVInvokedUrlCommand *)command;

/**
 * Continue process after show custom dialog using `- (void)registerPushDataCallback:(CDVInvokedUrlCommand *)command`. Command argument is [msgid_int, pushresult_enum(1:accept, 0:postpone, -1:decline)].
 */
- (void)sendPushResult:(CDVInvokedUrlCommand *)command;

/**
 * Callback for handling when customer decides one push result. Callback get a dictionary `{"result": <int>, "action": <enum>, "msgid": <int>, "title", <string>, "message": <string>, "data": <string>, "portion": <float>, "orientation": <enum>, "speed": <float>, "sound": <string>, "badge": <int>, "displaywihtoutdialog": <bool>}`. Customer's js using these information to know what result is chosen.
 */
- (void)registerPushResultCallback:(CDVInvokedUrlCommand *)command;

/**
 * Callback for handling open url. Callback get open url string.
 */
- (void)shDeeplinking:(CDVInvokedUrlCommand *)command;

/**
 * Callback for handling none StreetHawk payload. Callback get a dictionary of payload.
 */
- (void)registerNonSHPushPayloadObserver:(CDVInvokedUrlCommand *)command;

/**
 * Add a pair to memory, must call `setInteractivePushBtnPair` to submit to server. Command argument is [string_b1, string_I1, string_b2, string_I2, string_pairname].
 */
- (void)addInteractivePushButtonPairWithIcons:(CDVInvokedUrlCommand *)command;

/**
 * Add a pair to memory, must call `setInteractivePushBtnPair` to submit to server. Command argument is [string_b1, string_b2, string_pairname].
 */
- (void)addInteractivePushButtonPair:(CDVInvokedUrlCommand *)command;

/**
 * Submit all memory pairs to server and register categories. Command argument is empty.
 */
- (void)setInteractivePushBtnPair:(CDVInvokedUrlCommand *)command;

/**
 * Callback when new feed arrives. Callback get empty.
 */
- (void)notifyNewFeedCallback:(CDVInvokedUrlCommand *)command;

/**
 * Callback when server fetch feeds. Callback get feeds array.
 */
- (void)registerFeedItemCallback:(CDVInvokedUrlCommand *)command;

/**
 * Fetch feeds from server. Command argument is [offset_int]. Result is get by callback `registerFeedItemCallback`.
 */
- (void)shGetFeedDataFromServer:(CDVInvokedUrlCommand *)command;

/**
 * Send logline to server for feed ack. Command argument is [feedId_int].
 */
- (void)shReportFeedAck:(CDVInvokedUrlCommand *)command;

/**
 * Send logline to server for feed result. Command argument is [feedId_int, result_enum(1:accept, 0:postpone, -1:decline)].
 */
- (void)shReportFeedResult:(CDVInvokedUrlCommand *)command;

/**
 * Send logline to server for feed result. Command argument is [feedId_int, stepId_string, feedResult_string, feedDelete_bool, completed_bool].
 * feedResult_string must be accepted|postponed|rejected.
 */
- (void)notifyFeedResult:(CDVInvokedUrlCommand *)command;

/**
 * Get Pointzi link to invite friend. Command argument is [utm_campaign_string, shareUrl_string, default_url_string].
 */
- (void)originateShareWithCampaign:(CDVInvokedUrlCommand *)command;

/**
 * Get Pointzi link to invite friend. Command argument is [utm_campaign_string, utm_source_string, utm_medium_string, utm_content_string, utm_term_string, shareUrl_string, default_url_string], callback get share url if not error, otherwise get error description. 
 */
- (void)getShareUrlForAppDownload:(CDVInvokedUrlCommand *)command;

/**
 * Set a flag to only report logline 19 to save battery. No logline 20 is report. Command argument is [flag_bool].
 */
- (void)shReportWorkHomeLocationOnly:(CDVInvokedUrlCommand *)command;

/**
 * Update logline 20 frequency for reporting location change. Command argument is [interval_FG_int, distance_FG_int, interval_BG_int, distance_BG_int], interval measured in minutes, distance measured in meters.
 */
- (void)shUpdateLocationMonitoringParams:(CDVInvokedUrlCommand *)command;

/**
 * Callback sent when enter or exit a server monitoring beacon. The beacons are configured in web console. Callback get a NSDictionary representing one server monitor beacon.
 */
- (void)setNotifyBeaconDetectCallback:(CDVInvokedUrlCommand *)command;

/**
 * Callback sent when enter or exit a server monitoring geofence. The geofences are configured in web console. Callback get a NSDictionary representing one server monitor geofence.
 */
- (void)setNotifyGeofenceEventCallback:(CDVInvokedUrlCommand *)command;

//////////////////  Properties  ///////////////////////////////////

/**
 * API to set app key. Command argument is [appKey_string].
 */
- (void)setAppKey:(CDVInvokedUrlCommand *)command;

/**
 * Get StreetHawk register App key.
 */
- (void)shGetAppKey:(CDVInvokedUrlCommand *)command;

/**
 * Set advertisement identifier. Command argument is [ads_string];
 */
- (void)setAdvertisementId:(CDVInvokedUrlCommand *)command;

/**
 * Get current install's unique id. Command return string like "JULCYINRVOU1TONL".
 */
- (void)getInstallId:(CDVInvokedUrlCommand *)command;

/**
 * Get current Streethawk library version. Command return string like "1.3.3".
 */
- (void)getSHLibraryVersion:(CDVInvokedUrlCommand *)command;

/**
 * Get current datetime string in Streethawk format (UTC and yyyy-MM-dd HH:mm:ss). Command return string like "2014-12-26 50:32:17".
 */
- (void)getCurrentFormattedDateTime:(CDVInvokedUrlCommand *)command;

/**
 * Set whether enable console log for debugging. Command argument is [bool_value].
 */
- (void)shSetEnableLogs:(CDVInvokedUrlCommand *)command;

/**
 * Set iTunes registered App Id. Command argument is [string_value] like ['507040546'] or [''] or [null] if not register yet.
 */
- (void)shSetiTunesId:(CDVInvokedUrlCommand *)command;

/**
 * Get iTunes registered App Id. Command returns string value.
 */
- (void)shiTunesId:(CDVInvokedUrlCommand *)command;

/**
 * Set is push notification is enabled by default, set this to false to avoid asking system permission when App launch. Command argument is [bool_value].
 */
- (void)shSetDefaultNotificationService:(CDVInvokedUrlCommand *)command;

/**
 * Set whether support push notification, set this later to have push notification enabled and ask for permission. Command argument is [bool_value].
 */
- (void)shSetNotificationEnabled:(CDVInvokedUrlCommand *)command;

/**
 * Get whether support push notification. Command return bool.
 */
- (void)shGetNotificationEnabled:(CDVInvokedUrlCommand *)command;

/**
 * Set is location service is enabled by default, set this to false to avoid asking system permission when App launch. Command argument is [bool_value].
 */
- (void)shSetDefaultLocationService:(CDVInvokedUrlCommand *)command;

/**
 * Set whether enable location service, set this later to have location service enabled and ask for permission. Command argument is [bool_value].
 */
- (void)shSetLocationEnabled:(CDVInvokedUrlCommand *)command;

/**
 * Get whether enable location service. Command return bool.
 */
- (void)shGetLocationEnabled:(CDVInvokedUrlCommand *)command;

/**
 * Set alert settings times measured by minutes. Command argument is [int_value].
 */
- (void)shSetAlertSetting:(CDVInvokedUrlCommand *)command;

/**
 * Get alert settings times measured by minutes. Command return int.
 */
- (void)shAlertSettings:(CDVInvokedUrlCommand *)command;

//////////////////  None iOS Implementation  ///////////////////////////////////

/**
 * Android needs this function to send install/log when App from BG to FG. iOS SDK has handle this inside already, this function is empty.
 */
- (void)shOnResume:(CDVInvokedUrlCommand *)command;

/**
 * Android needs this function to send install/log when App from FG to BG. iOS SDK has handle this inside already, this function is empty.
 */
- (void)shOnPause:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios, not need this.
 */
- (void)setUseCustomDialog:(CDVInvokedUrlCommand *)command;

/**
 * Nothing to do in iOS part. ios doesn't support third party beacon library.
 */
- (void)startBeaconMonitoring:(CDVInvokedUrlCommand *)command;

/**
 * Nothing to do in iOS part. ios doesn't support third party beacon library.
 */
- (void)stopBeaconMonitoring:(CDVInvokedUrlCommand *)command;

/**
 * Nothing to do in iOS part. ios doesn't support third party beacon library.
 */
- (void)shEnterBeacon:(CDVInvokedUrlCommand *)command;

/**
 * Nothing to do in iOS part. ios doesn't support third party beacon library.
 */
- (void)shExitBeacon:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios.
 */
- (void)shSetGcmSenderId:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios.
 */
- (void)forcePushToNotificationBar:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios.
 */
- (void)getIcon:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios.
 */
- (void)setLargeIconResID:(CDVInvokedUrlCommand *)command;

/**
 * Android function, ignored in ios.
 */
- (void)setSmallIconResID:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStartLocationReporting:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStopLocationReporting:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStartLocationWithPermissionDialog:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStartGeofenceMonitoring:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStopGeofenceMonitoring:(CDVInvokedUrlCommand *)command;

/**
 * Android permission function, ignored in ios.
 */
- (void)shStartGeofenceWithPermissionDialog:(CDVInvokedUrlCommand *)command;

@end
