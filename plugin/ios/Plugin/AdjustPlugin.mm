//
//  PluginLibrary.mm
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 11th September 2017.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoronaRuntime.h>
#include "CoronaLuaIOS.h"
#import "Adjust.h"
#import "AdjustPlugin.h"
#import "AdjustSdkDelegate.h"

#define EVENT_IS_ENABLED @"adjust_isEnabled"
#define EVENT_GET_IDFA @"adjust_getIdfa"
#define EVENT_GET_ATTRIBUTION @"adjust_getAttribution"
#define EVENT_GET_ADID @"adjust_getAdid"
#define EVENT_GET_GOOGLE_AD_ID @"adjust_getGoogleAdId"
#define EVENT_GET_AMAZON_AD_ID @"adjust_getAmazonAdId"

// ----------------------------------------------------------------------------

class AdjustPlugin {
public:
    typedef AdjustPlugin Self;

    static const char kName[];
    static const char kEvent[];

    void InitializeAttributionListener(CoronaLuaRef listener);
    void InitializeEventTrackingSuccessListener(CoronaLuaRef listener);
    void InitializeEventTrackingFailureListener(CoronaLuaRef listener);
    void InitializeSessionTrackingSuccessListener(CoronaLuaRef listener);
    void InitializeSessionTrackingFailureListener(CoronaLuaRef listener);
    void InitializeDeferredDeeplinkListener(CoronaLuaRef listener);

    CoronaLuaRef GetAttributionChangedListener() const { return attributionChangedListener; }
    CoronaLuaRef GetEventTrackingSuccessListener() const { return eventTrackingSuccessListener; }
    CoronaLuaRef GetEventTrackingFailureListener() const { return eventTrackingFailureListener; }
    CoronaLuaRef GetSessionTrackingSuccessListener() const { return sessionTrackingSuccessListener; }
    CoronaLuaRef GetSessionTrackingFailureListener() const { return sessionTrackingFailureListener; }
    CoronaLuaRef GetDeferredDeeplinkListener() const { return deferredDeeplinkListener; }

    static int Open(lua_State *L);
    static Self *ToLibrary(lua_State *L);

    static int create(lua_State *L);
    static int trackEvent(lua_State *L);
    static int setEnabled(lua_State *L);
    static int setPushToken(lua_State *L);
    static int appWillOpenUrl(lua_State *L);
    static int sendFirstPackages(lua_State *L);
    static int addSessionCallbackParameter(lua_State *L);
    static int addSessionPartnerParameter(lua_State *L);
    static int removeSessionCallbackParameter(lua_State *L);
    static int removeSessionPartnerParameter(lua_State *L);
    static int resetSessionCallbackParameters(lua_State *L);
    static int resetSessionPartnerParameters(lua_State *L);
    static int setOfflineMode(lua_State *L);
    static int isEnabled(lua_State *L);
    static int getIdfa(lua_State *L);
    static int getAttribution(lua_State *L);
    static int getAdid(lua_State *L);
    static int getGoogleAdId(lua_State *L);
    static int getAmazonAdId(lua_State *L);
    static int gdprForgetMe(lua_State *L);
    static int setAttributionListener(lua_State *L);
    static int setEventTrackingSuccessListener(lua_State *L);
    static int setEventTrackingFailureListener(lua_State *L);
    static int setSessionTrackingSuccessListener(lua_State *L);
    static int setSessionTrackingFailureListener(lua_State *L);
    static int setDeferredDeeplinkListener(lua_State *L);

    // For testing purposes only.
    static int setTestOptions(lua_State *L);
    static int onResume(lua_State *L);
    static int onPause(lua_State *L);

protected:
    static int Finalizer(lua_State *L);
    AdjustPlugin();

private:
    CoronaLuaRef attributionChangedListener;
    CoronaLuaRef eventTrackingSuccessListener;
    CoronaLuaRef eventTrackingFailureListener;
    CoronaLuaRef sessionTrackingSuccessListener;
    CoronaLuaRef sessionTrackingFailureListener;
    CoronaLuaRef deferredDeeplinkListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library".
// Adjust SDK is named "plugin.adjust".
const char AdjustPlugin::kName[] = "plugin.adjust";

AdjustPlugin::AdjustPlugin()
: attributionChangedListener(NULL),
eventTrackingSuccessListener(NULL),
eventTrackingFailureListener(NULL),
sessionTrackingSuccessListener(NULL),
sessionTrackingFailureListener(NULL),
deferredDeeplinkListener(NULL) {}

void AdjustPlugin::InitializeAttributionListener(CoronaLuaRef listener) {
    attributionChangedListener = listener;
}

void AdjustPlugin::InitializeEventTrackingSuccessListener(CoronaLuaRef listener) {
    eventTrackingSuccessListener = listener;
}

void AdjustPlugin::InitializeEventTrackingFailureListener(CoronaLuaRef listener) {
    eventTrackingFailureListener = listener;
}

void AdjustPlugin::InitializeSessionTrackingSuccessListener(CoronaLuaRef listener) {
    sessionTrackingSuccessListener = listener;
}

void AdjustPlugin::InitializeSessionTrackingFailureListener(CoronaLuaRef listener) {
    sessionTrackingFailureListener = listener;
}

void AdjustPlugin::InitializeDeferredDeeplinkListener(CoronaLuaRef listener) {
    deferredDeeplinkListener = listener;
}

int
AdjustPlugin::Open(lua_State *L) {
    // Register __gc callback.
    // Globally unique string to prevent collision.
    const char kMetatableName[] = __FILE__;
    CoronaLuaInitializeGCMetatable(L, kMetatableName, Finalizer);

    // Functions in library
    const luaL_Reg kVTable[] = {
        { "create", create },
        { "trackEvent", trackEvent },
        { "setEnabled", setEnabled },
        { "setPushToken", setPushToken },
        { "appWillOpenUrl", appWillOpenUrl },
        { "sendFirstPackages", sendFirstPackages },
        { "addSessionCallbackParameter", addSessionCallbackParameter },
        { "addSessionPartnerParameter", addSessionPartnerParameter },
        { "removeSessionCallbackParameter", removeSessionCallbackParameter },
        { "removeSessionPartnerParameter", removeSessionPartnerParameter },
        { "resetSessionCallbackParameters", resetSessionCallbackParameters },
        { "resetSessionPartnerParameters", resetSessionPartnerParameters },
        { "setOfflineMode", setOfflineMode },
        { "setAttributionListener", setAttributionListener },
        { "setEventTrackingSuccessListener", setEventTrackingSuccessListener },
        { "setEventTrackingFailureListener", setEventTrackingFailureListener },
        { "setSessionTrackingSuccessListener", setSessionTrackingSuccessListener },
        { "setSessionTrackingFailureListener", setSessionTrackingFailureListener },
        { "setDeferredDeeplinkListener", setDeferredDeeplinkListener },
        { "isEnabled", isEnabled },
        { "getIdfa", getIdfa },
        { "getAttribution", getAttribution },
        { "getAdid", getAdid },
        { "getGoogleAdId", getGoogleAdId },
        { "getAmazonAdId", getAmazonAdId },
        { "gdprForgetMe", gdprForgetMe },
        { "onResume", onResume },
        { "onPause", onPause },
        { "setTestOptions", setTestOptions },

        { NULL, NULL }
    };

    // Set library as upvalue for each library function.
    Self *library = new Self;
    CoronaLuaPushUserdata(L, library, kMetatableName);

    // Leave "library" on top of stack.
    luaL_openlib(L, kName, kVTable, 1);

    return 1;
}

int AdjustPlugin::Finalizer(lua_State *L) {
    Self *library = (Self *)CoronaLuaToUserdata(L, 1);
    CoronaLuaDeleteRef(L, library->GetAttributionChangedListener());
    CoronaLuaDeleteRef(L, library->GetSessionTrackingSuccessListener());
    CoronaLuaDeleteRef(L, library->GetSessionTrackingFailureListener());
    CoronaLuaDeleteRef(L, library->GetEventTrackingSuccessListener());
    CoronaLuaDeleteRef(L, library->GetEventTrackingFailureListener());
    CoronaLuaDeleteRef(L, library->GetDeferredDeeplinkListener());

    delete library;
    return 0;
}

AdjustPlugin * AdjustPlugin::ToLibrary(lua_State *L) {
    // Library is pushed as part of the closure.
    Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
    return library;
}

// Public API.
int AdjustPlugin::create(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }

    double delayStart = 0.0;
    NSUInteger secretId = -1;
    NSUInteger info1 = -1;
    NSUInteger info2 = -1;
    NSUInteger info3 = -1;
    NSUInteger info4 = -1;
    BOOL isDeviceKnown = NO;
    BOOL sendInBackground = NO;
    BOOL eventBufferingEnabled = NO;
    BOOL shouldLaunchDeferredDeeplink = YES;
    NSString *appToken = nil;
    NSString *userAgent = nil;
    NSString *environment = nil;
    NSString *defaultTracker = nil;
    ADJLogLevel logLevel = ADJLogLevelInfo;

    // Log level.
    lua_getfield(L, 1, "logLevel");
    if (!lua_isnil(L, 2)) {
        const char *cstrLogLevel = lua_tostring(L, 2);
        if (cstrLogLevel != NULL) {
            logLevel = [ADJLogger logLevelFromString:[[NSString stringWithUTF8String:cstrLogLevel] lowercaseString]];
        }
    }
    lua_pop(L, 1);

    // App token.
    lua_getfield(L, 1, "appToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrAppToken = lua_tostring(L, 2);
        if (cstrAppToken != NULL) {
            appToken = [NSString stringWithUTF8String:cstrAppToken];
        }
    }
    lua_pop(L, 1);

    // Environment.
    lua_getfield(L, 1, "environment");
    if (!lua_isnil(L, 2)) {
        const char *cstrEnvironment = lua_tostring(L, 2);
        if (cstrEnvironment != NULL) {
            environment = [NSString stringWithUTF8String:cstrEnvironment];
        }
        if ([[environment lowercaseString] isEqualToString:@"sandbox"]) {
            environment = ADJEnvironmentSandbox;
        } else if ([[environment lowercaseString] isEqualToString:@"production"]) {
            environment = ADJEnvironmentProduction;
        }
    }
    lua_pop(L, 1);

    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
                                                environment:environment
                                      allowSuppressLogLevel:(logLevel == ADJLogLevelSuppress)];

    // Sdk prefix.
    [adjustConfig setSdkPrefix:@"corona4.17.0"];

    // Log level.
    [adjustConfig setLogLevel:logLevel];

    // Event buffering.
    lua_getfield(L, 1, "eventBufferingEnabled");
    if (!lua_isnil(L, 2)) {
        eventBufferingEnabled = lua_toboolean(L, 2);
        [adjustConfig setEventBufferingEnabled:eventBufferingEnabled];
    }
    lua_pop(L, 1);

    // Default tracker.
    lua_getfield(L, 1, "defaultTracker");
    if (!lua_isnil(L, 2)) {
        const char *cstrDefaultTracker = lua_tostring(L, 2);
        if (cstrDefaultTracker != NULL) {
            defaultTracker = [NSString stringWithUTF8String:cstrDefaultTracker];
        }
        [adjustConfig setDefaultTracker:defaultTracker];
    }
    lua_pop(L, 1);

    // User agent.
    lua_getfield(L, 1, "userAgent");
    if (!lua_isnil(L, 2)) {
        const char *cstrUserAgent = lua_tostring(L, 2);
        if (cstrUserAgent != NULL) {
            userAgent = [NSString stringWithUTF8String:cstrUserAgent];
        }
        [adjustConfig setUserAgent:userAgent];
    }
    lua_pop(L, 1);

    // Send in background.
    lua_getfield(L, 1, "sendInBackground");
    if (!lua_isnil(L, 2)) {
        sendInBackground = lua_toboolean(L, 2);
        [adjustConfig setSendInBackground:sendInBackground];
    }
    lua_pop(L, 1);

    // Launching deferred deep link.
    lua_getfield(L, 1, "shouldLaunchDeeplink");
    if (!lua_isnil(L, 2)) {
        shouldLaunchDeferredDeeplink = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    // Delay start.
    lua_getfield(L, 1, "delayStart");
    if (!lua_isnil(L, 2)) {
        delayStart = lua_tonumber(L, 2);
        [adjustConfig setDelayStart:delayStart];
    }
    lua_pop(L, 1);

    // Device known.
    lua_getfield(L, 1, "isDeviceKnown");
    if (!lua_isnil(L, 2)) {
        isDeviceKnown = lua_toboolean(L, 2);
        [adjustConfig setIsDeviceKnown:isDeviceKnown];
    }
    lua_pop(L, 1);

    // App secret.
    lua_getfield(L, 1, "secretId");
    if (!lua_isnil(L, 2)) {
        secretId = lua_tointeger(L, 2);
    }
    lua_pop(L, 1);
    lua_getfield(L, 1, "info1");
    if (!lua_isnil(L, 2)) {
        info1 = lua_tointeger(L, 2);
    }
    lua_pop(L, 1);
    lua_getfield(L, 1, "info2");
    if (!lua_isnil(L, 2)) {
        info2 = lua_tointeger(L, 2);
    }
    lua_pop(L, 1);
    lua_getfield(L, 1, "info3");
    if (!lua_isnil(L, 2)) {
        info3 = lua_tointeger(L, 2);
    }
    lua_pop(L, 1);
    lua_getfield(L, 1, "info4");
    if (!lua_isnil(L, 2)) {
        info4 = lua_tointeger(L, 2);
    }
    lua_pop(L, 1);

    if (secretId != -1 && info1 != -1 && info2 != -1 && info3 != -1 && info4 != -1) {
        [adjustConfig setAppSecret:secretId info1:info1 info2:info2 info3:info3 info4:info4];
    }

    // Callbacks.
    Self *library = ToLibrary(L);
    BOOL isAttributionChangedListenerImplmented = library->GetAttributionChangedListener() != NULL;
    BOOL isEventTrackingSuccessListenerImplmented = library->GetEventTrackingSuccessListener() != NULL;
    BOOL isEventTrackingFailureListenerImplmented = library->GetEventTrackingFailureListener() != NULL;
    BOOL isSessionTrackingSuccessListenerImplmented = library->GetSessionTrackingSuccessListener() != NULL;
    BOOL isSessionTrackingFailureListenerImplmented = library->GetSessionTrackingFailureListener() != NULL;
    BOOL isDeferredDeeplinkListenerImplemented = library->GetDeferredDeeplinkListener() != NULL;

    if (isAttributionChangedListenerImplmented
        || isEventTrackingSuccessListenerImplmented
        || isEventTrackingFailureListenerImplmented
        || isSessionTrackingSuccessListenerImplmented
        || isSessionTrackingFailureListenerImplmented
        || isDeferredDeeplinkListenerImplemented) {
        [adjustConfig setDelegate:
         [AdjustSdkDelegate getInstanceWithSwizzleOfAttributionChangedCallback:library->GetAttributionChangedListener()
                                                  eventTrackingSuccessCallback:library->GetEventTrackingSuccessListener()
                                                  eventTrackingFailureCallback:library->GetEventTrackingFailureListener()
                                                sessionTrackingSuccessCallback:library->GetSessionTrackingSuccessListener()
                                                sessionTrackingFailureCallback:library->GetSessionTrackingFailureListener()
                                                      deferredDeeplinkCallback:library->GetDeferredDeeplinkListener()
                                                  shouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink andLuaState:L]];
    }

    [Adjust appDidLaunch:adjustConfig];
    [Adjust trackSubsessionStart];
    return 0;
}

// Public API.
int AdjustPlugin::trackEvent(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }

    double revenue = -1.0;
    NSString *currency = nil;
    NSString *eventToken = nil;
    NSString *transactionId = nil;

    // Event token.
    lua_getfield(L, 1, "eventToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrEventToken = lua_tostring(L, 2);
        if (cstrEventToken != NULL) {
            eventToken = [NSString stringWithUTF8String:cstrEventToken];
        }
    }
    lua_pop(L, 1);

    ADJEvent *event = [ADJEvent eventWithEventToken:eventToken];

    // Revenue.
    lua_getfield(L, 1, "revenue");
    if (!lua_isnil(L, 2)) {
        revenue = lua_tonumber(L, 2);
    }
    lua_pop(L, 1);

    // Currency.
    lua_getfield(L, 1, "currency");
    if (!lua_isnil(L, 2)) {
        const char *cstrCurrency = lua_tostring(L, 2);
        if (cstrCurrency != NULL) {
            currency = [NSString stringWithUTF8String:cstrCurrency];
        }
    }
    lua_pop(L, 1);

    if (currency != nil && revenue != -1.0) {
        [event setRevenue:revenue currency:currency];
    }

    // Transaction ID.
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 2)) {
        const char *cstrTransactionId = lua_tostring(L, 2);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
        }
        [event setTransactionId:transactionId];
    }
    lua_pop(L, 1);

    // Callback parameters.
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [event addCallbackParameter:callbackParams[@"key"] value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    // Partner parameters.
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [event addPartnerParameter:partnerParams[@"key"] value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    [Adjust trackEvent:event];
    return 0;
}

// Public API.
int AdjustPlugin::setAttributionListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeAttributionListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setEventTrackingSuccessListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeEventTrackingSuccessListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setEventTrackingFailureListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeEventTrackingFailureListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setSessionTrackingSuccessListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeSessionTrackingSuccessListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setSessionTrackingFailureListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeSessionTrackingFailureListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setDeferredDeeplinkListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeDeferredDeeplinkListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setEnabled(lua_State *L) {
    BOOL enabled = lua_toboolean(L, 1);
    [Adjust setEnabled:enabled];
    return 0;
}

// Public API.
int AdjustPlugin::setPushToken(lua_State *L) {
    const char *cstrPushToken = lua_tostring(L, 1);
    if (cstrPushToken != NULL) {
        NSString *pushToken =[NSString stringWithUTF8String:cstrPushToken];
        [Adjust setPushToken:pushToken];
    }
    return 0;
}

// Public API.
int AdjustPlugin::appWillOpenUrl(lua_State *L) {
    const char *cstrUrl = lua_tostring(L, 1);
    if (cstrUrl != NULL) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:cstrUrl]];
        [Adjust appWillOpenUrl:url];
    }
    return 0;
}

// Public API.
int AdjustPlugin::sendFirstPackages(lua_State *L) {
    [Adjust sendFirstPackages];
    return 0;
}

// Public API.
int AdjustPlugin::addSessionCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addSessionCallbackParameter:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::addSessionPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addSessionPartnerParameter:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::removeSessionCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeSessionCallbackParameter:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::removeSessionPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeSessionPartnerParameter:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::resetSessionCallbackParameters(lua_State *L) {
    [Adjust resetSessionCallbackParameters];
    return 0;
}

// Public API.
int AdjustPlugin::resetSessionPartnerParameters(lua_State *L) {
    [Adjust resetSessionPartnerParameters];
    return 0;
}

// Public API.
int AdjustPlugin::setOfflineMode(lua_State *L) {
    BOOL enabled = lua_toboolean(L, 1);
    [Adjust setOfflineMode:enabled];
    return 0;
}

// Public API.
int AdjustPlugin::isEnabled(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        BOOL isEnabled = [Adjust isEnabled];
        NSString *result = isEnabled ? @"true" : @"false";
        [AdjustSdkDelegate dispatchEvent:EVENT_IS_ENABLED withState:L callback:listener andMessage:result];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getIdfa(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        NSString *idfa = [Adjust idfa];
        if (nil == idfa) {
            idfa = @"";
        }
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_IDFA withState:L callback:listener andMessage:idfa];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAttribution(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        ADJAttribution *attribution = [Adjust attribution];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (nil != attribution) {
            [AdjustSdkDelegate addKey:@"trackerToken" andValue:attribution.trackerToken toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"trackerName" andValue:attribution.trackerName toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"network" andValue:attribution.network toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"campaign" andValue:attribution.campaign toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"creative" andValue:attribution.creative toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"adgroup" andValue:attribution.adgroup toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"clickLabel" andValue:attribution.clickLabel toDictionary:dictionary];
            [AdjustSdkDelegate addKey:@"adid" andValue:attribution.adid toDictionary:dictionary];
        }

        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (!jsonData) {
            NSLog(@"[Adjust][bridge]: Error while trying to convert attribution dictionary to JSON string: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_ATTRIBUTION withState:L callback:listener andMessage:jsonString];
        }
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAdid(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        NSString *adid = [Adjust adid];
        if (nil == adid) {
            adid = @"";
        }
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_ADID withState:L callback:listener andMessage:adid];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getGoogleAdId(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        NSString *googleAdId = @"";
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_GOOGLE_AD_ID withState:L callback:listener andMessage:googleAdId];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAmazonAdId(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        NSString *amazonAdId = @"";
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_AMAZON_AD_ID withState:L callback:listener andMessage:amazonAdId];
    }
    return 0;
}

// Public API.
int AdjustPlugin::gdprForgetMe(lua_State *L) {
    [Adjust gdprForgetMe];
    return 0;
}

// For testing purposes only.
int AdjustPlugin::onResume(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL && [[NSString stringWithUTF8String:key] isEqualToString:@"test"]) {
        [Adjust trackSubsessionStart];
    }
    return 0;
}

// For testing purposes only.
int AdjustPlugin::onPause(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL && [[NSString stringWithUTF8String:key] isEqualToString:@"test"]) {
        [Adjust trackSubsessionEnd];
    }
    return 0;
}

// For testing purposes only.
int AdjustPlugin::setTestOptions(lua_State *L) {
    AdjustTestOptions *testOptions = [[AdjustTestOptions alloc] init];
    
    lua_getfield(L, 1, "baseUrl");
    if (!lua_isnil(L, 2)) {
        const char *baseUrl = lua_tostring(L, 2);
        if (baseUrl != NULL) {
            testOptions.baseUrl = [NSString stringWithUTF8String:baseUrl];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "gdprUrl");
    if (!lua_isnil(L, 2)) {
        const char *gdprUrl = lua_tostring(L, 2);
        if (gdprUrl != NULL) {
            testOptions.gdprUrl = [NSString stringWithUTF8String:gdprUrl];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "basePath");
    if (!lua_isnil(L, 2)) {
        const char *basePath = lua_tostring(L, 2);
        if (basePath != NULL) {
            testOptions.basePath = [NSString stringWithUTF8String:basePath];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "gdprPath");
    if (!lua_isnil(L, 2)) {
        const char *gdprPath = lua_tostring(L, 2);
        if (gdprPath != NULL) {
            testOptions.gdprPath = [NSString stringWithUTF8String:gdprPath];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "timerIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerIntervalInMilliseconds = lua_tointeger(L, 2);
        testOptions.timerIntervalInMilliseconds = [NSNumber numberWithInteger:timerIntervalInMilliseconds];
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "timerStartInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerStartInMilliseconds = lua_tointeger(L, 2);
        testOptions.timerStartInMilliseconds = [NSNumber numberWithInteger:timerStartInMilliseconds];
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "sessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger sessionIntervalInMilliseconds = lua_tointeger(L, 2);
        testOptions.sessionIntervalInMilliseconds = [NSNumber numberWithInteger:sessionIntervalInMilliseconds];
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "subsessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger subsessionIntervalInMilliseconds = lua_tointeger(L, 2);
        testOptions.subsessionIntervalInMilliseconds = [NSNumber numberWithInteger:subsessionIntervalInMilliseconds];
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "teardown");
    if (!lua_isnil(L, 2)) {
        testOptions.teardown = lua_toboolean(L, 2);
        if(testOptions.teardown) {
            NSLog(@"[Adjust][bridge]: AdjustSdkDelegate callbacks teardown.");
            [AdjustSdkDelegate teardown];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "deleteState");
    if (!lua_isnil(L, 2)) {
        testOptions.deleteState = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "noBackoffWait");
    if (!lua_isnil(L, 2)) {
        testOptions.noBackoffWait = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "iAdFrameworkEnabled");
    if (!lua_isnil(L, 2)) {
        testOptions.iAdFrameworkEnabled = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    [Adjust setTestOptions:testOptions];
    return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_adjust(lua_State *L) {
    return AdjustPlugin::Open(L);
}
