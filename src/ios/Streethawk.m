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

#import "Streethawk.h"
#import "SHUtils.h" //for shParseDate and shStrIsEmpty

@interface Streethawk ()

//remember command to be used for callback
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForRegisterInstall;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForRegisterView;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForRawJson;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForPushData;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForPushResult;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForOpenUrl;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForNoneStreetHawkPayload;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForNewFeeds;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForFetchFeeds;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForShareUrl;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForBeaconEnterExit;
@property (nonatomic, strong) CDVInvokedUrlCommand *callbackCommandForGeofenceEnterExit;
@property (nonatomic, strong) NSMutableDictionary *dictPushMsgHandler; //remember msg and click handler, to continue between `- (BOOL)onReceive:(PushDataForApplication *)pushData clickButton:(ClickButtonHandler)handler` and `sendPushResult`.
@property (nonatomic, strong) NSMutableArray *arrayInteractiveButtonPairs; //memory button pairs for submission.

- (void)installRegistrationSuccessHandler:(NSNotification *)notification;
- (void)noneStreetHawkPayloadHandler:(NSNotification *)notification;
- (void)beaconEnterExitHandler:(NSNotification *)notification;
- (void)geofenceEnterExitHandler:(NSNotification *)notification;

@end

@implementation Streethawk

#pragma mark - functions

- (void)streethawkinit:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(installRegistrationSuccessHandler:) name:SHInstallRegistrationSuccessNotification object:nil];
#ifdef SH_FEATURE_NOTIFICATION
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noneStreetHawkPayloadHandler:) name:SHNMOtherPayloadNotification object:nil];
#endif
#ifdef SH_FEATURE_IBEACON
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconEnterExitHandler:) name:SHLMEnterExitBeaconNotification object:nil];
#endif
#ifdef SH_FEATURE_GEOFENCE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(geofenceEnterExitHandler:) name:SHLMEnterExitGeofenceNotification object:nil];
#endif
    [StreetHawk registerInstallForApp:nil/*read from Info.plist APP_KEY*/ withDebugMode:StreetHawk.isDebugMode];
#ifdef SH_FEATURE_NOTIFICATION
    [StreetHawk shPGHtmlReceiver:self]; //register as html page load observer.
    [StreetHawk shSetCustomiseHandler:self]; //register as customise handler.
#endif
    self.dictPushMsgHandler = [NSMutableDictionary dictionary];
    self.arrayInteractiveButtonPairs = [NSMutableArray array];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)tagCuid:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *unique_id = command.arguments[0];
            BOOL ret = [StreetHawk tagCuid:unique_id];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)tagUserLanguage:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *userlang = command.arguments[0];
            BOOL ret = [StreetHawk tagUserLanguage:userlang];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)tagNumeric:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] respondsToSelector:@selector(doubleValue)])
        {
            NSString *key = command.arguments[0];
            double value = [command.arguments[1] doubleValue];
            BOOL ret = [StreetHawk tagNumeric:value forKey:key];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string and [1] expects double."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)tagString:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] isKindOfClass:[NSString class]])
        {
            NSString *key = command.arguments[0];
            NSString *value = command.arguments[1];
            BOOL ret = [StreetHawk tagString:value forKey:key];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string and [1] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)tagDatetime:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && ([command.arguments[1] isKindOfClass:[NSDate class]] || [command.arguments[1] isKindOfClass:[NSString class]]))
        {
            NSString *key = command.arguments[0];
            NSDate *value = nil;
            if ([command.arguments[1] isKindOfClass:[NSDate class]])
            {
                value = command.arguments[1];
            }
            if ([command.arguments[1] isKindOfClass:[NSString class]])
            {
                value = shParseDate(command.arguments[1], 0);
            }
            if (value != nil)
            {
                BOOL ret = [StreetHawk tagDatetime:value forKey:key];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
            }
            else
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [1] expects correct datetime format like \"2014-12-26 50:32:17\"."];
            }
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string and [1] expects datetime."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)incrementTag:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *key = command.arguments[0];
            BOOL ret = [StreetHawk incrementTag:key];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] respondsToSelector:@selector(intValue)])
        {
            NSString *key = command.arguments[0];
            int value = [command.arguments[1] intValue];
            BOOL ret = [StreetHawk incrementTag:value forKey:key];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string and [1] expects int."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1 or 2."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)removeTag:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *key = command.arguments[0];
            BOOL ret = [StreetHawk removeTag:key];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getFormattedDateTime:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(intValue)])
        {
            int miliseconds = [command.arguments[0] intValue];
            NSString *ret = [StreetHawk getFormattedDateTime:miliseconds/1000];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:ret];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects int."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)notifyViewEnter:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && ((NSString *)command.arguments[0]).length > 0)
        {
            NSString *page = command.arguments[0];
            NSString *previousPage = [[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousPage"];
            if ([previousPage isKindOfClass:[NSString class]] && !shStrIsEmpty(previousPage))
            {
                [StreetHawk shNotifyPageExit:previousPage];
            }
            [StreetHawk shNotifyPageEnter:page];
            [[NSUserDefaults standardUserDefaults] setObject:page forKey:@"PreviousPage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects a non-empty string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)notifyViewExit:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && ((NSString *)command.arguments[0]).length > 0)
        {
            NSString *page = command.arguments[0];
            [StreetHawk shNotifyPageExit:page];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"PreviousPage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects a non-empty string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSendSimpleFeedback:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] isKindOfClass:[NSString class]])
        {
            NSString *title = command.arguments[0];
            NSString *message = command.arguments[1];
            [StreetHawk shSendFeedbackWithTitle:title withContent:message withHandler:nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expects [title_string, message_string]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerInstallEventCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForRegisterInstall = command; //remember this command to be used install register successfully.
}

- (void)shGetViewName:(CDVInvokedUrlCommand *)command
{
#ifdef SH_FEATURE_NOTIFICATION
    NSString *viewName  = [StreetHawk shGetViewName];
    if (viewName != nil && viewName.length > 0)  //check not empty to avoid infinit loop
    {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:viewName];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
#else
    NSString *missPluginMsg = @"\"shGetViewName\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
#endif
}

- (void)shRegisterViewCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForRegisterView = command;  //remember this command to be used when 8004 comes at FG.
}

- (void)shRawJsonCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForRawJson = command;  //remember this command to be used when 8049 push json
}

- (void)registerPushDataCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForPushData = command;
}

- (void)sendPushResult:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 2)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] isKindOfClass:[NSNumber class]])
        {
            NSString *msgId = command.arguments[0];
            NSInteger pushResult = [command.arguments[1] integerValue];
            if (pushResult < -1 || pushResult > 1)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Push result should be: 1 for accept, 0 for postpone, -1 for decline."];
            }
            else
            {
                NSAssert([self.dictPushMsgHandler.allKeys containsObject:msgId], @"Cannot find msgid %@ match.", msgId);
                if ([self.dictPushMsgHandler.allKeys containsObject:msgId])
                {
                    ClickButtonHandler handler = self.dictPushMsgHandler[msgId];
                    handler((SHResult)pushResult);
                    [self.dictPushMsgHandler removeObjectForKey:msgId];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [string_msgid, int_pushresult]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
#else
    NSString *missPluginMsg = @"\"sendPushResult\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerPushResultCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForPushResult = command;
}

- (void)shDeeplinking:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForOpenUrl = command; //remember this command to be used when open url happen
    StreetHawk.openUrlHandler = ^(NSURL *openUrl)
    {
        if (self.callbackCommandForOpenUrl != nil)
        {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:openUrl.absoluteString];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForOpenUrl.callbackId];
        }
    };
}

- (void)registerNonSHPushPayloadObserver:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForNoneStreetHawkPayload = command;
}

- (void)addInteractivePushButtonPairWithIcons:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 5)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] //1 and 3 are icon, not used in iOS
            && [command.arguments[2] isKindOfClass:[NSString class]]
            && [command.arguments[4] isKindOfClass:[NSString class]])
        {
            NSString *b1 = command.arguments[0];
            NSString *b2 = command.arguments[2];
            NSString *pairname = command.arguments[4];
            InteractivePush *pair = [[InteractivePush alloc] initWithPairTitle:pairname withButton1:b1 withButton2:b2];
            [self.arrayInteractiveButtonPairs addObject:pair];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [string_b1, string_I1, string_b2, string_I2, string_pairname]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 5."];
    }
#else
    NSString *missPluginMsg = @"\"addInteractivePushButtonPairWithIcons\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addInteractivePushButtonPair:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 3)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]]
            && [command.arguments[1] isKindOfClass:[NSString class]]
            && [command.arguments[2] isKindOfClass:[NSString class]])
        {
            NSString *b1 = command.arguments[0];
            NSString *b2 = command.arguments[1];
            NSString *pairname = command.arguments[2];
            InteractivePush *pair = [[InteractivePush alloc] initWithPairTitle:pairname withButton1:b1 withButton2:b2];
            [self.arrayInteractiveButtonPairs addObject:pair];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [string_b1, string_b2, string_pairname]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 3."];
    }
#else
    NSString *missPluginMsg = @"\"addInteractivePushButtonPair\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setInteractivePushBtnPair:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (self.arrayInteractiveButtonPairs.count > 0)
    {
        [StreetHawk setInteractivePushBtnPairs:self.arrayInteractiveButtonPairs];
        [self.arrayInteractiveButtonPairs removeAllObjects];
    }
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
#else
    NSString *missPluginMsg = @"\"setInteractivePushBtnPair\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)notifyNewFeedCallback:(CDVInvokedUrlCommand *)command
{
#ifdef SH_FEATURE_FEED
    self.callbackCommandForNewFeeds = command;
    StreetHawk.newFeedHandler = ^()
    {
        if (self.callbackCommandForNewFeeds != nil)
        {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForNewFeeds.callbackId];
        }
    };
#else
    NSString *missPluginMsg = @"\"notifyNewFeedCallback\" fail. Please add com.streethawk.feed plugin.";
    NSLog(@"%@", missPluginMsg);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
#endif
}

- (void)registerFeedItemCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForFetchFeeds = command;
}

- (void)shGetFeedDataFromServer:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_FEED
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSNumber class]])
        {
            NSInteger offset = [command.arguments[0] integerValue];
            [StreetHawk feed:offset withHandler:^(NSArray *arrayFeeds, NSError *error)
            {
                if (self.callbackCommandForFetchFeeds)
                {
                    //arrayFeeds's element is SHFeedObject which is not compatible with NSJSONSerialization. Convert to NSDictionary to make Phonegap work.
                    NSMutableArray *arrayDict = [NSMutableArray arrayWithCapacity:arrayFeeds.count];
                    for (SHFeedObject *feedObj in arrayFeeds)
                    {
                        [arrayDict addObject:[feedObj serializeToDictionary]];
                    }
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:arrayDict];
                    [pluginResult setKeepCallbackAsBool:YES];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForFetchFeeds.callbackId];
                }
            }];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [int_offset]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shGetFeedDataFromServer\" fail. Please add com.streethawk.feed plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shReportFeedAck:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_FEED
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSNumber class]] || [command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *feedId = nil;
            if ([command.arguments[0] isKindOfClass:[NSNumber class]])
            {
                feedId = [NSString stringWithFormat:@"%ld", (long)[command.arguments[0] integerValue]];
            }
            else
            {
                feedId = command.arguments[0];
            }
            [StreetHawk sendFeedAck:feedId];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [int_feedId]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shReportFeedAck\" fail. Please add com.streethawk.feed plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shReportFeedResult:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_FEED
    if (command.arguments.count == 2)
    {
        if (([command.arguments[0] isKindOfClass:[NSNumber class]] || [command.arguments[0] isKindOfClass:[NSString class]])
            && [command.arguments[1] isKindOfClass:[NSNumber class]])
        {
            NSString *feedId = nil;
            if ([command.arguments[0] isKindOfClass:[NSNumber class]])
            {
                feedId = [NSString stringWithFormat:@"%ld", (long)[command.arguments[0] integerValue]];
            }
            else
            {
                feedId = command.arguments[0];
            }
            NSInteger feedResult = [command.arguments[1] integerValue];
            if (feedResult < -1 || feedResult > 1)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Feed result should be: 1 for accept, 0 for postpone, -1 for decline."];
            }
            else
            {
                [StreetHawk notifyFeedResult:feedId withResult:(SHResult)feedResult];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [int_feedid, int_feedresult]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 2."];
    }
#else
    NSString *missPluginMsg = @"\"reportFeedRead\" fail. Please add com.streethawk.feed plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)notifyFeedResult:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_FEED
    if (command.arguments.count == 5)
    {
        if (([command.arguments[0] isKindOfClass:[NSNumber class]] || [command.arguments[0] isKindOfClass:[NSString class]])
            && [command.arguments[1] isKindOfClass:[NSString class]]
            && [command.arguments[2] isKindOfClass:[NSString class]]
            && [command.arguments[3] isKindOfClass:[NSNumber class]]
            && [command.arguments[4] isKindOfClass:[NSNumber class]])
        {
            NSString *feedId = nil;
            if ([command.arguments[0] isKindOfClass:[NSNumber class]])
            {
                feedId = [NSString stringWithFormat:@"%ld", (long)[command.arguments[0] integerValue]];
            }
            else
            {
                feedId = command.arguments[0];
            }
            NSString *stepId = command.arguments[1];
            NSString *result = command.arguments[2];
            BOOL deleted = [command.arguments[3] boolValue];
            BOOL completed = [command.arguments[4] boolValue];
            SHResult feedResult = SHResult_Accept;
            if ([result.lowercaseString containsString:@"accepted"])
            {
                feedResult = SHResult_Accept;
            }
            else if ([result.lowercaseString containsString:@"postponed"])
            {
                feedResult = SHResult_Postpone;
            }
            else if ([result.lowercaseString containsString:@"rejected"])
            {
                feedResult = SHResult_Decline;
            }
            [StreetHawk notifyFeedResult:feedId withResult:feedResult withStepId:stepId deleteFeed:deleted completed:completed];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [feedId_int, stepId_string, feedResult_string, feedDelete_bool, completed_bool]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 5."];
    }
#else
    NSString *missPluginMsg = @"\"notifyFeedResult\" fail. Please add com.streethawk.feed plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)originateShareWithCampaign:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_GROWTH
    if (command.arguments.count == 3)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] isKindOfClass:[NSString class]] && [command.arguments[2] isKindOfClass:[NSString class]])
        {
            NSString *utm_campaign = command.arguments[0];
            NSString *shareUrlStr = command.arguments[1];
            NSString *defaultUrlStr = command.arguments[2];
            NSURL *shareUrl = nil;
            if (!shStrIsEmpty(shareUrlStr))
            {
                shareUrl = [NSURL URLWithString:shareUrlStr];
                if (shareUrl == nil)
                {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Command 2 is not valid url format, correct it or set empty."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
            }
            NSURL *defaultUrl = nil;
            if (!shStrIsEmpty(defaultUrlStr))
            {
                defaultUrl = [NSURL URLWithString:defaultUrlStr];
                if (defaultUrl == nil)
                {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Command 3 is not valid url format, correct it or set empty."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
            }
            [StreetHawk originateShareWithCampaign:utm_campaign withMedium:nil withContent:nil withTerm:nil shareUrl:shareUrl withDefaultUrl:defaultUrl withMessage:nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [utm_campaign_string, shareUrl_string, default_url_string]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 3."];
    }
#else
    NSString *missPluginMsg = @"\"originateShareWithSourceSelection\" fail. Please add com.streethawk.growth plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    if (pluginResult != nil)
    {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)getShareUrlForAppDownload:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForShareUrl = command;
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_GROWTH
    if (command.arguments.count == 7)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]] && [command.arguments[1] isKindOfClass:[NSString class]] && [command.arguments[2] isKindOfClass:[NSString class]] && [command.arguments[3] isKindOfClass:[NSString class]] && [command.arguments[4] isKindOfClass:[NSString class]] && [command.arguments[5] isKindOfClass:[NSString class]] && [command.arguments[6] isKindOfClass:[NSString class]])
        {
            NSString *utm_campaign = command.arguments[0];
            NSString *utm_source = command.arguments[1];
            NSString *utm_medium = command.arguments[2];
            NSString *utm_content = command.arguments[3];
            NSString *utm_term = command.arguments[4];
            NSString *shareUrlStr = command.arguments[5];
            NSString *defaultUrlStr = command.arguments[6];
            NSURL *shareUrl = nil;
            if (!shStrIsEmpty(shareUrlStr))
            {
                shareUrl = [NSURL URLWithString:shareUrlStr];
                if (shareUrl == nil)
                {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Command 6 is not valid url format, correct it or set empty."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
            }
            NSURL *defaultUrl = nil;
            if (!shStrIsEmpty(defaultUrlStr))
            {
                defaultUrl = [NSURL URLWithString:defaultUrlStr];
                if (defaultUrl == nil)
                {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Command 7 is not valid url format, correct it or set empty."];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    return;
                }
            }
            [StreetHawk originateShareWithCampaign:utm_campaign withSource:utm_source withMedium:utm_medium withContent:utm_content withTerm:utm_term shareUrl:shareUrl withDefaultUrl:defaultUrl streetHawkGrowth_object:^(NSObject *result, NSError *error)
            {
                if (self.callbackCommandForShareUrl != nil) //do automatically handling
                 {
                     CDVPluginResult *pluginResult = nil;
                     if (error == nil)
                     {
                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:(NSString *)result];
                     }
                     else
                     {
                         pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:error.localizedDescription];
                     }
                     [pluginResult setKeepCallbackAsBool:YES];
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForShareUrl.callbackId];
                 }
             }];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [utm_campaign_string, utm_source_string, utm_medium_string, utm_content_string, utm_term_string, shareUrl_string, default_url_string]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 7."];
    }
#else
    NSString *missPluginMsg = @"\"originateShareWithCampaign\" fail. Please add com.streethawk.growth plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    if (pluginResult != nil)
    {
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)shReportWorkHomeLocationOnly:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_LATLNG
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSNumber class]] && [command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            BOOL isWorkHomeLocationOnly = [command.arguments[0] boolValue];
            StreetHawk.reportWorkHomeLocationOnly = isWorkHomeLocationOnly;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shReportWorkHomeLocationOnly\" fail. Please add com.streethawk.locations plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shUpdateLocationMonitoringParams:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_LATLNG
    if (command.arguments.count == 4)
    {
        if ([command.arguments[0] isKindOfClass:[NSNumber class]]
            && [command.arguments[1] isKindOfClass:[NSNumber class]]
            && [command.arguments[2] isKindOfClass:[NSNumber class]]
            && [command.arguments[3] isKindOfClass:[NSNumber class]])
        {
            int interval_FG = [command.arguments[0] intValue];
            int distance_FG = [command.arguments[1] intValue];
            int interval_BG = [command.arguments[2] intValue];
            int distance_BG = [command.arguments[3] intValue];
            [StreetHawk setLocationUpdateFrequencyForFGInterval:interval_FG forFGDistance:distance_FG forBGInterval:interval_BG forBGDistance:distance_BG];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter expects [interval_FG_int, distance_FG_int, interval_BG_int, distance_BG_int]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 4."];
    }
#else
    NSString *missPluginMsg = @"\"shUpdateLocationMonitoringParams\" fail. Please add com.streethawk.locations plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setNotifyBeaconDetectCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForBeaconEnterExit = command;
}

- (void)setNotifyGeofenceEventCallback:(CDVInvokedUrlCommand *)command
{
    self.callbackCommandForGeofenceEnterExit = command;
}

#pragma mark - properties

- (void)setAppKey:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            StreetHawk.appKey = command.arguments[0];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameters expect [appKey_string]."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shGetAppKey:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:StreetHawk.appKey];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAdvertisementId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            NSString *ads = command.arguments[0];
            StreetHawk.advertisingIdentifier = ads;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getInstallId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:StreetHawk.currentInstall.suid];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getSHLibraryVersion:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:StreetHawk.version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getCurrentFormattedDateTime:(CDVInvokedUrlCommand *)command
{
    NSString *dateStr = [StreetHawk getCurrentFormattedDateTime];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:dateStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetEnableLogs:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            BOOL isEnabled = [command.arguments[0] boolValue];
            StreetHawk.isDebugMode = isEnabled;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetiTunesId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] isKindOfClass:[NSString class]])
        {
            StreetHawk.itunesAppId = command.arguments[0];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects string."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shiTunesId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:StreetHawk.itunesAppId];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetDefaultNotificationService:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            StreetHawk.isDefaultNotificationEnabled = [command.arguments[0] boolValue];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shSetDefaultNotificationService\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetNotificationEnabled:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            StreetHawk.isNotificationEnabled = [command.arguments[0] boolValue];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shSetNotificationEnabled\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shGetNotificationEnabled:(CDVInvokedUrlCommand *)command
{
#ifdef SH_FEATURE_NOTIFICATION
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:StreetHawk.isNotificationEnabled];
#else
    NSString *missPluginMsg = @"\"shGetNotificationEnabled\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetDefaultLocationService:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#if defined(SH_FEATURE_LATLNG) || defined(SH_FEATURE_GEOFENCE) || defined(SH_FEATURE_IBEACON)
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            StreetHawk.isDefaultLocationServiceEnabled = [command.arguments[0] boolValue];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shSetDefaultLocationService\" fail. Please add com.streethawk.locations or com.streethawk.geofence or com.streethawk.beacons plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetLocationEnabled:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#if defined(SH_FEATURE_LATLNG) || defined(SH_FEATURE_GEOFENCE) || defined(SH_FEATURE_IBEACON)
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(boolValue)])
        {
            StreetHawk.isLocationServiceEnabled = [command.arguments[0] boolValue];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects bool."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shSetLocationEnabled\" fail. Please add com.streethawk.locations or com.streethawk.geofence or com.streethawk.beacons plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shGetLocationEnabled:(CDVInvokedUrlCommand *)command
{
#if defined(SH_FEATURE_LATLNG) || defined(SH_FEATURE_GEOFENCE) || defined(SH_FEATURE_IBEACON)
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:StreetHawk.isLocationServiceEnabled];
#else
    NSString *missPluginMsg = @"\"shGetLocationEnabled\" fail. Please add com.streethawk.locations or com.streethawk.geofence or com.streethawk.beacons plugin.";
    NSLog(@"%@", missPluginMsg);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetAlertSetting:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = nil;
#ifdef SH_FEATURE_NOTIFICATION
    if (command.arguments.count == 1)
    {
        if ([command.arguments[0] respondsToSelector:@selector(intValue)])
        {
            [StreetHawk shSetAlertSetting:[command.arguments[0] intValue] finish:nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Parameter [0] expects int."];
        }
    }
    else
    {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Wrong number of parameters, expect 1."];
    }
#else
    NSString *missPluginMsg = @"\"shSetAlertSetting\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shAlertSettings:(CDVInvokedUrlCommand *)command
{
#ifdef SH_FEATURE_NOTIFICATION
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:(int)[StreetHawk getAlertSettingMinutes]];
#else
    NSString *missPluginMsg = @"\"shGetAlertSettings\" fail. Please add com.streethawk.push plugin.";
    NSLog(@"%@", missPluginMsg);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:missPluginMsg];
#endif
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - none iOS implementation

- (void)shOnResume:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shOnPause:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setUseCustomDialog:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startBeaconMonitoring:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)stopBeaconMonitoring:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shEnterBeacon:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shExitBeacon:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shSetGcmSenderId:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)forcePushToNotificationBar:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getIcon:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLargeIconResID:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setSmallIconResID:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStartLocationReporting:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStopLocationReporting:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStartLocationWithPermissionDialog:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStartGeofenceMonitoring:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStopGeofenceMonitoring:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)shStartGeofenceWithPermissionDialog:(CDVInvokedUrlCommand *)command
{
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - override

#ifdef SH_FEATURE_NOTIFICATION

- (void)shPGDisplayHtmlFileName:(NSString *)html_fileName
{
    //If Phonegap App js not implement callback function, nothing happen. Not crash App.
    if (self.callbackCommandForRegisterView != nil)
    {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:html_fileName];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForRegisterView.callbackId];
    }
}

- (void)shRawJsonCallbackWithTitle:(NSString *)title withMessage:(NSString *)message withJson:(NSString *)json
{
    if (self.callbackCommandForRawJson != nil)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"title"] = NONULL(title);
        dict[@"message"] = NONULL(message);
        dict[@"json"] = NONULL(json);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForRawJson.callbackId];
    }
}

- (BOOL)onReceive:(PushDataForApplication *)pushData clickButton:(ClickButtonHandler)handler
{
    if (self.callbackCommandForPushData != nil)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"action"] = @(pushData.action);
        dict[@"msgid"] = NONULL(pushData.msgID);
        dict[@"title"] = NONULL(pushData.title);
        dict[@"message"] = NONULL(pushData.message);
        dict[@"data"] = NONULL(pushData.data.description);
        dict[@"portion"] = @(pushData.portion);
        dict[@"orientation"] = @(pushData.orientation);
        dict[@"speed"] = @(pushData.speed);
        dict[@"sound"] = NONULL(pushData.sound);
        dict[@"badge"] = @(pushData.badge);
        dict[@"displaywihtoutdialog"] = @(pushData.displayWithoutDialog);
        //insert into memory cache
        if (handler)
        {
            NSAssert(![self.dictPushMsgHandler.allKeys containsObject:pushData.msgID], @"msg id %@ is inside cache.", pushData.msgID);
            if (![self.dictPushMsgHandler.allKeys containsObject:pushData.msgID])
            {
                [self.dictPushMsgHandler setObject:handler forKey:pushData.msgID];
            }
        }
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForPushData.callbackId];
        return YES; //not able to get return value from js, so once implement `registerPushDataCallback` all confirm dialog use js, not like native sdk which can override some and leave others not affected.
    }
    return NO;
}

- (void)onReceiveResult:(PushDataForApplication *)pushData withResult:(SHResult)result
{
    if (self.callbackCommandForPushResult != nil)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[@"result"] = @(result);
        dict[@"action"] = @(pushData.action);
        dict[@"msgid"] = NONULL(pushData.msgID);
        dict[@"title"] = NONULL(pushData.title);
        dict[@"message"] = NONULL(pushData.message);
        dict[@"data"] = NONULL(pushData.data.description);
        dict[@"portion"] = @(pushData.portion);
        dict[@"orientation"] = @(pushData.orientation);
        dict[@"speed"] = @(pushData.speed);
        dict[@"sound"] = NONULL(pushData.sound);
        dict[@"badge"] = @(pushData.badge);
        dict[@"displaywihtoutdialog"] = @(pushData.displayWithoutDialog);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForPushResult.callbackId];
    }
}

#endif

#pragma mark - private functions

- (void)installRegistrationSuccessHandler:(NSNotification *)notification
{
    if (self.callbackCommandForRegisterInstall != nil)
    {
        SHInstall *currentInstall = notification.userInfo[SHInstallNotification_kInstall];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:currentInstall.suid];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForRegisterInstall.callbackId];
    }
}

- (void)noneStreetHawkPayloadHandler:(NSNotification *)notification
{
#ifdef SH_FEATURE_NOTIFICATION
    if (self.callbackCommandForNoneStreetHawkPayload != nil)
    {
        NSDictionary *payload = notification.userInfo[SHNMNotification_kPayload];
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:payload];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForNoneStreetHawkPayload.callbackId];
    }
#endif
}

- (void)beaconEnterExitHandler:(NSNotification *)notification
{
#ifdef SH_FEATURE_IBEACON
    if (self.callbackCommandForBeaconEnterExit != nil)
    {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:notification.userInfo];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForBeaconEnterExit.callbackId];
    }
#endif
}

- (void)geofenceEnterExitHandler:(NSNotification *)notification
{
#ifdef SH_FEATURE_GEOFENCE
    if (self.callbackCommandForGeofenceEnterExit != nil)
    {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:notification.userInfo];
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackCommandForGeofenceEnterExit.callbackId];
    }
#endif
}

@end
