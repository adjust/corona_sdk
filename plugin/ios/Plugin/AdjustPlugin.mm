//
//  PluginLibrary.mm
//  Adjust SDK
//
//  Created by Abdullah Obaied on 11th September 2017.
//  Copyright (c) 2017-Present Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoronaRuntime.h>
#include "CoronaLuaIOS.h"

#import "Adjust.h"
#import "AdjustPlugin.h"
#import "AdjustSdkDelegate.h"
#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJLogger.h"
#import "ADJAttribution.h"
#import "ADJAppStoreSubscription.h"
#import "ADJThirdPartySharing.h"
#import "ADJAdRevenue.h"
#import "ADJAppStorePurchase.h"
#import "ADJPurchaseVerificationResult.h"
#import "ADJDeeplink.h"
#import "ADJStoreInfo.h"

#define EVENT_PROCESS_AND_RESOLVE_DEEPLINK @"adjust_processAndResolveDeeplink"
#define EVENT_IS_ENABLED @"adjust_isEnabled"
#define EVENT_GET_ATTRIBUTION @"adjust_getAttribution"
#define EVENT_GET_ADID @"adjust_getAdid"
#define EVENT_GET_LAST_DEEPLINK @"adjust_getLastDeeplink"
#define EVENT_GET_SDK_VERSION @"adjust_getSdkVersion"

#define EVENT_VERIFY_APP_STORE_PURCHASE_CALLBACK @"adjust_verifyAppStorePurchase"
#define EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE_CALLBACK @"adjust_verifyAndTrackAppStorePurchase"
#define EVENT_REQUEST_APP_TRACKING_AUTHORIZATION @"adjust_requestAppTrackingAuthorization"
#define EVENT_UPDATE_SKAN_CONVERSION_VALUE @"adjust_updateSkanConversionValue"
#define EVENT_GET_IDFA @"adjust_getIdfa"
#define EVENT_GET_IDFV @"adjust_getIdfv"
#define EVENT_GET_APP_TRACKING_AUTHORIZATION_STATUS @"adjust_getAppTrackingAuthorizationStatus"

#define EVENT_VERIFY_PLAY_STORE_PURCHASE_CALLBACK @"adjust_verifyPlayStorePurchase"
#define EVENT_VERIFY_AND_TRACK_PLAY_STORE_PURCHASE_CALLBACK @"adjust_verifyAndTrackPlayStorePurchase"
#define EVENT_GET_GOOGLE_AD_ID @"adjust_getGoogleAdId"
#define EVENT_GET_AMAZON_AD_ID @"adjust_getAmazonAdId"

#define SDK_PREFIX @"corona5.4.0"

// ----------------------------------------------------------------------------

class AdjustPlugin {
public:
    typedef AdjustPlugin Self;

    static const char kName[];
    static const char kEvent[];

    void InitializeAttributionCallback(CoronaLuaRef callback);
    void InitializeEventSuccessCallback(CoronaLuaRef callback);
    void InitializeEventFailureCallback(CoronaLuaRef callback);
    void InitializeSessionSuccessCallback(CoronaLuaRef callback);
    void InitializeSessionFailureCallback(CoronaLuaRef callback);
    void InitializeDeferredDeeplinkCallback(CoronaLuaRef callback);
    void InitializeSkanUpdatedCallback(CoronaLuaRef callback);

    CoronaLuaRef GetAttributionChangedCallback() const { return attributionChangedCallback; }
    CoronaLuaRef GetEventSuccessCallback() const { return eventSuccessCallback; }
    CoronaLuaRef GetEventFailureCallback() const { return eventFailureCallback; }
    CoronaLuaRef GetSessionSuccessCallback() const { return sessionSuccessCallback; }
    CoronaLuaRef GetSessionFailureCallback() const { return sessionFailureCallback; }
    CoronaLuaRef GetDeferredDeeplinkCallback() const { return deferredDeeplinkCallback; }
    CoronaLuaRef GetSkanUpdatedCallback() const { return skanUpdatedCallback; }

    static int Open(lua_State *L);
    static Self *ToLibrary(lua_State *L);

    static int initSdk(lua_State *L);
    static int enable(lua_State *L);
    static int disable(lua_State *L);
    static int switchToOfflineMode(lua_State *L);
    static int switchBackToOnlineMode(lua_State *L);
    static int trackEvent(lua_State *L);
    static int trackAdRevenue(lua_State *L);
    static int trackThirdPartySharing(lua_State *L);
    static int trackMeasurementConsent(lua_State *L);
    static int gdprForgetMe(lua_State *L);
    static int processDeeplink(lua_State *L);
    static int processAndResolveDeeplink(lua_State *L);
    static int setPushToken(lua_State *L);
    static int addGlobalCallbackParameter(lua_State *L);
    static int addGlobalPartnerParameter(lua_State *L);
    static int removeGlobalCallbackParameter(lua_State *L);
    static int removeGlobalPartnerParameter(lua_State *L);
    static int removeGlobalCallbackParameters(lua_State *L);
    static int removeGlobalPartnerParameters(lua_State *L);
    static int isEnabled(lua_State *L);
    static int getAttribution(lua_State *L);
    static int getAdid(lua_State *L);
    static int getLastDeeplink(lua_State *L);
    static int getSdkVersion(lua_State *L);
    static int setAttributionCallback(lua_State *L);
    static int setEventSuccessCallback(lua_State *L);
    static int setEventFailureCallback(lua_State *L);
    static int setSessionSuccessCallback(lua_State *L);
    static int setSessionFailureCallback(lua_State *L);
    static int setDeferredDeeplinkCallback(lua_State *L);
    static int endFirstSessionDelay(lua_State *L);
    static int enableCoppaComplianceInDelay(lua_State *L);
    static int disableCoppaComplianceInDelay(lua_State *L);
    static int setExternalDeviceIdInDelay(lua_State *L);
    // ios only
    static int trackAppStoreSubscription(lua_State *L);
    static int verifyAppStorePurchase(lua_State *L);
    static int verifyAndTrackAppStorePurchase(lua_State *L);
    static int requestAppTrackingAuthorization(lua_State *L);
    static int updateSkanConversionValue(lua_State *L);
    static int getIdfa(lua_State *L);
    static int getIdfv(lua_State *L);
    static int getAppTrackingAuthorizationStatus(lua_State *L);
    static int setSkanUpdatedCallback(lua_State *L);
    // android only
    static int trackPlayStoreSubscription(lua_State *L);
    static int verifyPlayStorePurchase(lua_State *L);
    static int verifyAndTrackPlayStorePurchase(lua_State *L);
    static int enablePlayStoreKidsComplianceInDelay(lua_State *L);
    static int disablePlayStoreKidsComplianceInDelay(lua_State *L);
    static int getGoogleAdId(lua_State *L);
    static int getAmazonAdId(lua_State *L);
    // testing purposes only
    static int setTestOptions(lua_State *L);
    static int onResume(lua_State *L);
    static int onPause(lua_State *L);
    static int teardown(lua_State *L);

protected:
    static int Finalizer(lua_State *L);
    AdjustPlugin();

private:
    CoronaLuaRef attributionChangedCallback;
    CoronaLuaRef eventSuccessCallback;
    CoronaLuaRef eventFailureCallback;
    CoronaLuaRef sessionSuccessCallback;
    CoronaLuaRef sessionFailureCallback;
    CoronaLuaRef deferredDeeplinkCallback;
    CoronaLuaRef skanUpdatedCallback;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library".
// Adjust SDK is named "plugin.adjust".
const char AdjustPlugin::kName[] = "plugin.adjust";

AdjustPlugin::AdjustPlugin()
: attributionChangedCallback(NULL),
eventSuccessCallback(NULL),
eventFailureCallback(NULL),
sessionSuccessCallback(NULL),
sessionFailureCallback(NULL),
deferredDeeplinkCallback(NULL),
skanUpdatedCallback(NULL){}


void AdjustPlugin::InitializeAttributionCallback(CoronaLuaRef callback) {
    attributionChangedCallback = callback;
}

void AdjustPlugin::InitializeEventSuccessCallback(CoronaLuaRef callback) {
    eventSuccessCallback = callback;
}

void AdjustPlugin::InitializeEventFailureCallback(CoronaLuaRef callback) {
    eventFailureCallback = callback;
}

void AdjustPlugin::InitializeSessionSuccessCallback(CoronaLuaRef callback) {
    sessionSuccessCallback = callback;
}

void AdjustPlugin::InitializeSessionFailureCallback(CoronaLuaRef callback) {
    sessionFailureCallback = callback;
}

void AdjustPlugin::InitializeDeferredDeeplinkCallback(CoronaLuaRef callback) {
    deferredDeeplinkCallback = callback;
}

void AdjustPlugin::InitializeSkanUpdatedCallback(CoronaLuaRef callback) {
    skanUpdatedCallback = callback;
}

int
AdjustPlugin::Open(lua_State *L) {
    // Register __gc callback.
    // Globally unique string to prevent collision.
    const char kMetatableName[] = __FILE__;
    CoronaLuaInitializeGCMetatable(L, kMetatableName, Finalizer);

    // Functions in library
    const luaL_Reg kVTable[] = {
        { "initSdk", initSdk },
        { "enable", enable },
        { "disable", disable },
        { "switchToOfflineMode", switchToOfflineMode },
        { "switchBackToOnlineMode", switchBackToOnlineMode },
        { "trackEvent", trackEvent },
        { "trackAdRevenue", trackAdRevenue },
        { "trackThirdPartySharing", trackThirdPartySharing },
        { "trackMeasurementConsent", trackMeasurementConsent },
        { "gdprForgetMe", gdprForgetMe },
        { "processDeeplink", processDeeplink},
        { "processAndResolveDeeplink", processAndResolveDeeplink},
        { "setPushToken", setPushToken },
        { "addGlobalCallbackParameter", addGlobalCallbackParameter },
        { "addGlobalPartnerParameter", addGlobalPartnerParameter },
        { "removeGlobalCallbackParameter", removeGlobalCallbackParameter },
        { "removeGlobalPartnerParameter", removeGlobalPartnerParameter },
        { "removeGlobalCallbackParameters", removeGlobalCallbackParameters },
        { "removeGlobalPartnerParameters", removeGlobalPartnerParameters },
        { "isEnabled", isEnabled },
        { "getAttribution", getAttribution },
        { "getAdid", getAdid },
        { "getLastDeeplink", getLastDeeplink },
        { "getSdkVersion", getSdkVersion },
        { "setAttributionCallback", setAttributionCallback },
        { "setEventSuccessCallback", setEventSuccessCallback },
        { "setEventFailureCallback", setEventFailureCallback },
        { "setSessionSuccessCallback", setSessionSuccessCallback },
        { "setSessionFailureCallback", setSessionFailureCallback },
        { "setDeferredDeeplinkCallback", setDeferredDeeplinkCallback },
        { "endFirstSessionDelay", endFirstSessionDelay },
        { "enableCoppaComplianceInDelay", enableCoppaComplianceInDelay },
        { "disableCoppaComplianceInDelay", disableCoppaComplianceInDelay },
        { "enablePlayStoreKidsComplianceInDelay", enablePlayStoreKidsComplianceInDelay },
        { "disablePlayStoreKidsComplianceInDelay", disablePlayStoreKidsComplianceInDelay },
        { "setExternalDeviceIdInDelay", setExternalDeviceIdInDelay },
        // ios only
        { "trackAppStoreSubscription", trackAppStoreSubscription },
        { "verifyAppStorePurchase", verifyAppStorePurchase },
        { "verifyAndTrackAppStorePurchase", verifyAndTrackAppStorePurchase },
        { "requestAppTrackingAuthorization", requestAppTrackingAuthorization },
        { "updateSkanConversionValue", updateSkanConversionValue },
        { "getIdfa", getIdfa },
        { "getIdfv", getIdfv },
        { "getAppTrackingAuthorizationStatus", getAppTrackingAuthorizationStatus },
        { "setSkanUpdatedCallback", setSkanUpdatedCallback },
        // android only
        { "trackPlayStoreSubscription", trackPlayStoreSubscription },
        { "verifyPlayStorePurchase", verifyPlayStorePurchase },
        { "verifyAndTrackPlayStorePurchase", verifyAndTrackPlayStorePurchase },
        { "getGoogleAdId", getGoogleAdId },
        { "getAmazonAdId", getAmazonAdId },
        // testing purposes only
        { "setTestOptions", setTestOptions },
        { "onResume", onResume },
        { "onPause", onPause },
        { "teardown", teardown },
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
    CoronaLuaDeleteRef(L, library->GetAttributionChangedCallback());
    CoronaLuaDeleteRef(L, library->GetSessionSuccessCallback());
    CoronaLuaDeleteRef(L, library->GetSessionFailureCallback());
    CoronaLuaDeleteRef(L, library->GetEventSuccessCallback());
    CoronaLuaDeleteRef(L, library->GetEventFailureCallback());
    CoronaLuaDeleteRef(L, library->GetDeferredDeeplinkCallback());
    CoronaLuaDeleteRef(L, library->GetSkanUpdatedCallback());

    delete library;
    return 0;
}

AdjustPlugin * AdjustPlugin::ToLibrary(lua_State *L) {
    // Library is pushed as part of the closure.
    Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
    return library;
}

int AdjustPlugin::initSdk(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: initSdk must be supplied with a table");
        return 0;
    }
    
    NSString *appToken = nil;
    NSString *environment = nil;
    NSString *logLevel = nil;
    NSString *defaultTracker = nil;
    NSString *externalDeviceId = nil;
    NSString *storeInfoName = nil;
    NSString *storeInfoAppId = nil;
    
    BOOL isFirstSessionDelayedEnabled = NO;
    BOOL isAppTrackingTransparencyUsageEnabled = YES;
    BOOL isSendingInBackgroundEnabled = NO;
    BOOL isCoppaComplianceEnabled = NO;
    BOOL isDeferredDeeplinkOpeningEnabled = YES;
    BOOL isAdServicesEnabled = YES;
    BOOL isIdfaReadingEnabled = YES;
    BOOL isIdfvReadingEnabled = YES;
    BOOL isSkanAttributionEnabled = YES;
    BOOL isLinkMeEnabled = NO;
    BOOL isCostDataInAttributionEnabled = NO;
    BOOL isDeviceIdsReadingOnceEnabled = NO;
    BOOL isLogLevelSuppress = NO;
    BOOL useSubdomains = NO;
    BOOL isDataResidency = NO;
    NSArray *urlStrategyDomains = nil;
    NSUInteger attConsentWaitingInterval = -1;
    NSInteger eventDeduplicationIdsMaxSize = 0;

    // app token
    lua_getfield(L, 1, "appToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrAppToken = lua_tostring(L, 2);
        if (cstrAppToken != NULL) {
            appToken = [NSString stringWithUTF8String:cstrAppToken];
        }
    }
    lua_pop(L, 1);
    
    // environment
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
    
    // suppress log level
    lua_getfield(L, 1, "logLevel");
    if (!lua_isnil(L, 2)) {
        const char *cstrLogLevel = lua_tostring(L, 2);
        if (cstrLogLevel != NULL) {
            logLevel = [[NSString stringWithUTF8String:cstrLogLevel] lowercaseString];
            if ([logLevel isEqualToString:@"suppress"]) {
                isLogLevelSuppress = YES;
            }
        }
    }
    lua_pop(L, 1);

    ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken
                                                      environment:environment
                                                 suppressLogLevel:isLogLevelSuppress];

    // SDK prefix
    [adjustConfig setSdkPrefix:SDK_PREFIX];

    // log level
    if ([logLevel isEqualToString:@"verbose"]) {
        [adjustConfig setLogLevel:ADJLogLevelVerbose];
    } else if ([logLevel isEqualToString:@"debug"]) {
        [adjustConfig setLogLevel:ADJLogLevelDebug];
    } else if ([logLevel isEqualToString:@"info"]) {
        [adjustConfig setLogLevel:ADJLogLevelInfo];
    } else if ([logLevel isEqualToString:@"warn"]) {
        [adjustConfig setLogLevel:ADJLogLevelWarn];
    } else if ([logLevel isEqualToString:@"error"]) {
        [adjustConfig setLogLevel:ADJLogLevelError];
    } else if ([logLevel isEqualToString:@"assert"]) {
        [adjustConfig setLogLevel:ADJLogLevelAssert];
    } else if ([logLevel isEqualToString:@"suppress"]) {
        [adjustConfig setLogLevel:ADJLogLevelSuppress];
    } else {
        [adjustConfig setLogLevel:ADJLogLevelInfo];
    }
    
    // default tracker
    lua_getfield(L, 1, "defaultTracker");
    if (!lua_isnil(L, 2)) {
        const char *cstrDefaultTracker = lua_tostring(L, 2);
        if (cstrDefaultTracker != NULL) {
            defaultTracker = [NSString stringWithUTF8String:cstrDefaultTracker];
            [adjustConfig setDefaultTracker:defaultTracker];
        }
    }
    lua_pop(L, 1);

    // external device ID
    lua_getfield(L, 1, "externalDeviceId");
    if (!lua_isnil(L, 2)) {
        const char *cstrExternalDeviceId = lua_tostring(L, 2);
        if (cstrExternalDeviceId != NULL) {
            externalDeviceId = [NSString stringWithUTF8String:cstrExternalDeviceId];
            [adjustConfig setExternalDeviceId:externalDeviceId];
        }
    }
    lua_pop(L, 1);
    
    // first session delay
    lua_getfield(L, 1, "isFirstSessionDelayedEnabled");
    if (!lua_isnil(L, 2)) {
        isFirstSessionDelayedEnabled = lua_toboolean(L, 2);
        if (isFirstSessionDelayedEnabled == YES) {
            [adjustConfig enableFirstSessionDelay];
        }
    }
    lua_pop(L, 1);
    
    // App Tracking transparency usage
    lua_getfield(L, 1, "isAppTrackingTransparencyUsageEnabled");
    if (!lua_isnil(L, 2)) {
        isAppTrackingTransparencyUsageEnabled = lua_toboolean(L, 2);
        if (isAppTrackingTransparencyUsageEnabled == NO) {
            [adjustConfig disableAppTrackingTransparencyUsage];
        }
    }
    lua_pop(L, 1);
    
    // sendning from background
    lua_getfield(L, 1, "isSendingInBackgroundEnabled");
    if (!lua_isnil(L, 2)) {
        isSendingInBackgroundEnabled = lua_toboolean(L, 2);
        if (isSendingInBackgroundEnabled == YES) {
            [adjustConfig enableSendingInBackground];
        }
    }
    lua_pop(L, 1);
    
    // COPPA compliance
    lua_getfield(L, 1, "isCoppaComplianceEnabled");
    if (!lua_isnil(L, 2)) {
        isCoppaComplianceEnabled = lua_toboolean(L, 2);
        if (isCoppaComplianceEnabled == YES) {
            [adjustConfig enableCoppaCompliance];
        }
    }
    lua_pop(L, 1);
    
    // should open deferred deeplink
    lua_getfield(L, 1, "isDeferredDeeplinkOpeningEnabled");
    if (!lua_isnil(L, 2)) {
        isDeferredDeeplinkOpeningEnabled = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    // AdServices info reading
    lua_getfield(L, 1, "isAdServicesEnabled");
    if (!lua_isnil(L, 2)) {
        isAdServicesEnabled = lua_toboolean(L, 2);
        if (isAdServicesEnabled == NO) {
            [adjustConfig disableAdServices];
        }
    }
    lua_pop(L, 1);

    // IDFA reading
    lua_getfield(L, 1, "isIdfaReadingEnabled");
    if (!lua_isnil(L, 2)) {
        isIdfaReadingEnabled = lua_toboolean(L, 2);
        if (isIdfaReadingEnabled == NO) {
            [adjustConfig disableIdfaReading];
        }
    }
    lua_pop(L, 1);

    // IDFV reading
    lua_getfield(L, 1, "isIdfvReadingEnabled");
    if (!lua_isnil(L, 2)) {
        isIdfvReadingEnabled = lua_toboolean(L, 2);
        if (isIdfvReadingEnabled == NO) {
            [adjustConfig disableIdfvReading];
        }
    }
    lua_pop(L, 1);

    // SKAdNetwork handling
    lua_getfield(L, 1, "isSkanAttributionEnabled");
    if (!lua_isnil(L, 2)) {
        isSkanAttributionEnabled = lua_toboolean(L, 2);
        if (isSkanAttributionEnabled == NO) {
            [adjustConfig disableSkanAttribution];
        }
    }
    lua_pop(L, 1);
    
    // LinkMe feature
    lua_getfield(L, 1, "isLinkMeEnabled");
    if (!lua_isnil(L, 2)) {
        isLinkMeEnabled = lua_toboolean(L, 2);
        if (isLinkMeEnabled == YES) {
            [adjustConfig enableLinkMe];
        }
    }
    lua_pop(L, 1);

    // cost in data attribution
    lua_getfield(L, 1, "isCostDataInAttributionEnabled");
    if (!lua_isnil(L, 2)) {
        isCostDataInAttributionEnabled = lua_toboolean(L, 2);
        if (isCostDataInAttributionEnabled == YES) {
            [adjustConfig enableCostDataInAttribution];
        }
    }
    lua_pop(L, 1);
    
    // read device IDs just once
    lua_getfield(L, 1, "isDeviceIdsReadingOnceEnabled");
    if (!lua_isnil(L, 2)) {
        isDeviceIdsReadingOnceEnabled = lua_toboolean(L, 2);
        if (isDeviceIdsReadingOnceEnabled == YES) {
            [adjustConfig enableDeviceIdsReadingOnce];
        }
    }
    lua_pop(L, 1);
    
    ADJStoreInfo *adjStoreInfo = nil;
    
    // Store Info name
    lua_getfield(L, 1, "storeInfoName");
    if (!lua_isnil(L, 2)) {
        const char *cstrStoreName = lua_tostring(L, 2);
        if (cstrStoreName != nil) {
            storeInfoName = [NSString stringWithUTF8String:cstrStoreName];
            adjStoreInfo = [[ADJStoreInfo alloc] initWithStoreName:storeInfoName];
        }
    }
    lua_pop(L, 1);
    
    // Store Info app id
    lua_getfield(L, 1, "storeInfoAppId");
    if (!lua_isnil(L, 2)) {
        const char *cstrStoreAppId = lua_tostring(L, 2);
        if (cstrStoreAppId != nil) {
            storeInfoAppId = [NSString stringWithUTF8String:cstrStoreAppId];
            if (adjStoreInfo != nil) {
                [adjStoreInfo setStoreAppId:storeInfoAppId];
            }
        }
    }
    lua_pop(L, 1);
    
    if (adjStoreInfo != nil) {
        [adjustConfig setStoreInfo:adjStoreInfo];
    }
    
    
    // URL strategy domains
    lua_getfield(L, 1, "urlStrategyDomains");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        urlStrategyDomains = [dict allValues];
    }
    lua_pop(L, 1);
    
    // URL strategy data residency
    lua_getfield(L, 1, "isDataResidency");
    if (!lua_isnil(L, 2)) {
        isDataResidency = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);
    
    // URL strategy use subdomains
    lua_getfield(L, 1, "useSubdomains");
    if (!lua_isnil(L, 2)) {
        useSubdomains = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    if ([urlStrategyDomains count] > 0) {
        [adjustConfig setUrlStrategy:urlStrategyDomains
                       useSubdomains:useSubdomains
                     isDataResidency:isDataResidency];
    }
    
    // ATT consent waiting interval
    lua_getfield(L, 1, "attConsentWaitingInterval");
    if (!lua_isnil(L, 2)) {
        attConsentWaitingInterval = lua_tonumber(L, 2);
        [adjustConfig setAttConsentWaitingInterval:attConsentWaitingInterval];
    }
    lua_pop(L, 1);

    // max number of event deduplication IDs
    lua_getfield(L, 1, "eventDeduplicationIdsMaxSize");
    if (!lua_isnil(L, 2)) {
        eventDeduplicationIdsMaxSize = lua_tointeger(L, 2);
        [adjustConfig setEventDeduplicationIdsMaxSize:eventDeduplicationIdsMaxSize];
    }
    lua_pop(L, 1);

    // callbacks
    Self *library = ToLibrary(L);
    BOOL isAttributionChangedCallbackImplemented = library->GetAttributionChangedCallback() != NULL;
    BOOL isEventSuccessCallbackImplemented = library->GetEventSuccessCallback() != NULL;
    BOOL isEventFailureCallbackImplemented = library->GetEventFailureCallback() != NULL;
    BOOL isSessionSuccessCallbackImplemented = library->GetSessionSuccessCallback() != NULL;
    BOOL isSessionFailureCallbackImplemented = library->GetSessionFailureCallback() != NULL;
    BOOL isDeferredDeeplinkCallbackImplemented = library->GetDeferredDeeplinkCallback() != NULL;
    BOOL isSkanUpdatedCallbackImplemented = library->GetSkanUpdatedCallback() != NULL;

    if (isAttributionChangedCallbackImplemented
        || isEventSuccessCallbackImplemented
        || isEventFailureCallbackImplemented
        || isSessionSuccessCallbackImplemented
        || isSessionFailureCallbackImplemented
        || isDeferredDeeplinkCallbackImplemented
        || isSkanUpdatedCallbackImplemented) {
        [adjustConfig setDelegate:
         [AdjustSdkDelegate getInstanceWithSwizzleOfAttributionChangedCallback:library->GetAttributionChangedCallback()
                                                          eventSuccessCallback:library->GetEventSuccessCallback()
                                                          eventFailureCallback:library->GetEventFailureCallback()
                                                        sessionSuccessCallback:library->GetSessionSuccessCallback()
                                                        sessionFailureCallback:library->GetSessionFailureCallback()
                                                      deferredDeeplinkCallback:library->GetDeferredDeeplinkCallback()
                                                           skanUpdatedCallback:library->GetSkanUpdatedCallback()
                                                  shouldLaunchDeferredDeeplink:isDeferredDeeplinkOpeningEnabled
                                                                      luaState:L]];
    }

    [Adjust initSdk:adjustConfig];
    return 0;
}

int AdjustPlugin::enable(lua_State *L) {
    [Adjust enable];
    return 0;
}

int AdjustPlugin::disable(lua_State *L) {
    [Adjust disable];
    return 0;
}

int AdjustPlugin::switchToOfflineMode(lua_State *L) {
    [Adjust switchToOfflineMode];
    return 0;
}

int AdjustPlugin::switchBackToOnlineMode(lua_State *L) {
    [Adjust switchBackToOnlineMode];
    return 0;
}

int AdjustPlugin::trackEvent(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: trackEvent must be supplied with a table");
        return 0;
    }

    double revenue = -1.0;
    NSString *eventToken = nil;
    NSString *currency = nil;
    NSString *deduplicationId = nil;
    NSString *callbackId = nil;
    NSString *productId = nil;
    NSString *transactionId = nil;

    // event token
    lua_getfield(L, 1, "eventToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrEventToken = lua_tostring(L, 2);
        if (cstrEventToken != NULL) {
            eventToken = [NSString stringWithUTF8String:cstrEventToken];
        }
    }
    lua_pop(L, 1);

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:eventToken];

    // revenue
    lua_getfield(L, 1, "revenue");
    if (!lua_isnil(L, 2)) {
        revenue = lua_tonumber(L, 2);
    }
    lua_pop(L, 1);

    // currency
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

    // deduplication ID
    lua_getfield(L, 1, "deduplicationId");
    if (!lua_isnil(L, 2)) {
        const char *cstrDeduplicationId = lua_tostring(L, 2);
        if (cstrDeduplicationId != NULL) {
            deduplicationId = [NSString stringWithUTF8String:cstrDeduplicationId];
            [event setDeduplicationId:deduplicationId];
        }
    }
    lua_pop(L, 1);

    // callback ID
    lua_getfield(L, 1, "callbackId");
    if (!lua_isnil(L, 2)) {
        const char *cstrCallbackId = lua_tostring(L, 2);
        if (cstrCallbackId != NULL) {
            callbackId = [NSString stringWithUTF8String:cstrCallbackId];
            [event setCallbackId:callbackId];
        }
    }
    lua_pop(L, 1);

    // product ID
    lua_getfield(L, 1, "productId");
    if (!lua_isnil(L, 2)) {
        const char *cstrProductId = lua_tostring(L, 2);
        if (cstrProductId != NULL) {
            productId = [NSString stringWithUTF8String:cstrProductId];
            [event setProductId:productId];
        }
    }
    lua_pop(L, 1);
    
    // transaction ID
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 2)) {
        const char *cstrTransactionId = lua_tostring(L, 2);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
            [event setTransactionId:transactionId];
        }
    }
    lua_pop(L, 1);

    // callback parameters
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [event addCallbackParameter:callbackParams[@"key"]
                                  value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    // partner parameters
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [event addPartnerParameter:partnerParams[@"key"]
                                 value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    [Adjust trackEvent:event];
    return 0;
}

int AdjustPlugin::trackAdRevenue(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: trackAdRevenue must be supplied with a table");
        return 0;
    }

    NSString *source = nil;
    double revenue = -1.0;
    NSString *currency = nil;
    
    // source
    lua_getfield(L, 1, "source");
    if (!lua_isnil(L, 2)) {
        const char *cstrSource = lua_tostring(L, 2);
        if (cstrSource != NULL) {
            source = [NSString stringWithUTF8String:cstrSource];
        }
    }
    lua_pop(L, 1);
    
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:source];
    
    // revenue
    lua_getfield(L, 1, "revenue");
    if (!lua_isnil(L, 2)) {
        revenue = lua_tonumber(L, 2);
    }
    lua_pop(L, 1);
    
    // currency
    lua_getfield(L, 1, "currency");
    if (!lua_isnil(L, 2)) {
        const char *cstrCurrency = lua_tostring(L, 2);
        if (cstrCurrency != NULL) {
            currency = [NSString stringWithUTF8String:cstrCurrency];
        }
    }
    lua_pop(L, 1);
    
    if (currency != nil && revenue != -1.0) {
        [adRevenue setRevenue:revenue currency:currency];
    }
    
    // ad impressions count
    lua_getfield(L, 1, "adImpressionsCount");
    if (!lua_isnil(L, 2)) {
        [adRevenue setAdImpressionsCount:(int)lua_tointeger(L, 2)];
    }
    lua_pop(L, 1);
    
    // ad revenue network
    lua_getfield(L, 1, "adRevenueNetwork");
    if (!lua_isnil(L, 2)) {
        const char *cstrAdRevenueNetwork = lua_tostring(L, 2);
        if (cstrAdRevenueNetwork != NULL) {
            [adRevenue setAdRevenueNetwork:[NSString stringWithUTF8String:cstrAdRevenueNetwork]];
        }
    }
    lua_pop(L, 1);
    
    // ad revenue unit
    lua_getfield(L, 1, "adRevenueUnit");
    if (!lua_isnil(L, 2)) {
        const char *cstrAdRevenueUnit = lua_tostring(L, 2);
        if (cstrAdRevenueUnit != NULL) {
            [adRevenue setAdRevenueUnit:[NSString stringWithUTF8String:cstrAdRevenueUnit]];
        }
    }
    lua_pop(L, 1);
    
    // ad revenue placement
    lua_getfield(L, 1, "adRevenuePlacement");
    if (!lua_isnil(L, 2)) {
        const char *cstrAdRevenuePlacement = lua_tostring(L, 2);
        if (cstrAdRevenuePlacement != NULL) {
            [adRevenue setAdRevenuePlacement:[NSString stringWithUTF8String:cstrAdRevenuePlacement]];
        }
    }
    lua_pop(L, 1);
    
    // callback parameters
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [adRevenue addCallbackParameter:callbackParams[@"key"]
                                      value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);
    
    // partner parameters
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [adRevenue addPartnerParameter:partnerParams[@"key"]
                                     value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);
    
    [Adjust trackAdRevenue:adRevenue];
    return 0;
}

int AdjustPlugin::trackThirdPartySharing(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: trackThirdPartySharing must be supplied with a table");
        return 0;
    }

    ADJThirdPartySharing *adjustThirdPartySharing = nil;

    // enable / disable sharing
    lua_getfield(L, 1, "enabled");
    if (!lua_isnil(L, 2)) {
        BOOL enabled = lua_toboolean(L, 2);
        adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:[NSNumber numberWithBool:enabled]];
    } else {
        adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:nil];
    }
    lua_pop(L, 1);

    // granular options
    lua_getfield(L, 1, "granularOptions");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *granularOptions = [dict objectForKey:key];
            for (id keySetting in granularOptions) {
                NSLog(@"key setting is : %@", keySetting);
                if ([keySetting isEqualToString:@"partnerName"]) {
                    NSLog(@"key setting is chosen : %@", keySetting);
                    NSLog(@"key setting is : %@", granularOptions);
                    [adjustThirdPartySharing addGranularOption:granularOptions[@"partnerName"]
                                                           key:granularOptions[@"key"]
                                                         value:granularOptions[@"value"]];
                }
            }
        }
    }
    lua_pop(L, 1);

    // partner sharing settings
    lua_getfield(L, 1, "partnerSharingSettings");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *partnerSharingSettings = [dict objectForKey:key];
            for (id keySetting in partnerSharingSettings) {
                if (![keySetting isEqualToString:@"partnerName"]) {
                    [adjustThirdPartySharing addPartnerSharingSetting:partnerSharingSettings[@"partnerName"]
                                                                  key:partnerSharingSettings[@"key"]
                                                                value:[partnerSharingSettings[@"value"] boolValue]];
                }
            }
        }
    }
    lua_pop(L, 1);

    [Adjust trackThirdPartySharing:adjustThirdPartySharing];
    return 0;
}

int AdjustPlugin::trackMeasurementConsent(lua_State *L) {
    BOOL measurementConsent = lua_toboolean(L, 1);
    [Adjust trackMeasurementConsent:measurementConsent];
    return 0;
}

int AdjustPlugin::gdprForgetMe(lua_State *L) {
    [Adjust gdprForgetMe];
    return 0;
}

int AdjustPlugin::processDeeplink(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: processDeeplink must be supplied with a table");
        return 0;
    }

    NSString *deeplink = nil;
    lua_getfield(L, 1, "deeplink");
    if (!lua_isnil(L, 2)) {
        const char *cstrDeeplink = lua_tostring(L, 2);
        if (cstrDeeplink != NULL) {
            deeplink = [NSString stringWithUTF8String:cstrDeeplink];
        }
    }
    lua_pop(L, 1);

    NSString *referrer = nil;
    lua_getfield(L, 1, "referrer");
    if (!lua_isnil(L, 2)) {
        const char *cstrReferrer = lua_tostring(L, 2);
        if (cstrReferrer != NULL) {
            referrer = [NSString stringWithUTF8String:cstrReferrer];
        }
    }
    lua_pop(L, 1);
    
    if (deeplink != nil) {
        NSURL *deeplinkUrl = [NSURL URLWithString:deeplink];
        ADJDeeplink *adjustDeeplink = [[ADJDeeplink alloc] initWithDeeplink:deeplinkUrl];
        if (referrer != nil) {
            NSURL *referrerUrl = [NSURL URLWithString:referrer];
            [adjustDeeplink setReferrer:referrerUrl];
        }
        [Adjust processDeeplink:adjustDeeplink];
    }
    return 0;
}

int AdjustPlugin::processAndResolveDeeplink(lua_State *L){
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: processAndResolveDeeplink must be supplied with a table");
        return 0;
    }

    NSString *deeplink = nil;
    lua_getfield(L, 1, "deeplink");
    if (!lua_isnil(L, 3)) {
        const char *cstrDeeplink = lua_tostring(L, 3);
        if (cstrDeeplink != NULL) {
            deeplink = [NSString stringWithUTF8String:cstrDeeplink];
        }
    }
    lua_pop(L, 1);
    
   
    NSString *referrer = nil;
    lua_getfield(L, 1, "referrer");
    if (!lua_isnil(L, 2)) {
        const char *cstrReferrer = lua_tostring(L, 2);
        if (cstrReferrer != NULL) {
            referrer = [NSString stringWithUTF8String:cstrReferrer];
        }
    }
    lua_pop(L, 1);
    
    ADJDeeplink *adjustDeeplink = nil;
    if (deeplink != nil) {
        NSURL *deeplinkUrl = [NSURL URLWithString:deeplink];
         adjustDeeplink = [[ADJDeeplink alloc] initWithDeeplink:deeplinkUrl];
        if (referrer != nil) {
            NSURL *referrerUrl = [NSURL URLWithString:referrer];
            [adjustDeeplink setReferrer:referrerUrl];
        }
    }

    int callbackIndex = 2;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        if (deeplink != nil) {
            NSURL *url;
            if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
                url = [NSURL URLWithString:[deeplink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                url = [NSURL URLWithString:[deeplink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#pragma clang diagnostic pop
            }
            [Adjust processAndResolveDeeplink:adjustDeeplink
                        withCompletionHandler:^(NSString * _Nullable resolvedLink) {
                [AdjustSdkDelegate dispatchEvent:EVENT_PROCESS_AND_RESOLVE_DEEPLINK
                                       withState:L
                                        callback:callback
                                         message:resolvedLink];
            }];
        }
    }
    return 0;
}

int AdjustPlugin::setPushToken(lua_State *L) {
    const char *cstrPushToken = lua_tostring(L, 1);
    if (cstrPushToken != NULL) {
        NSString *pushToken =[NSString stringWithUTF8String:cstrPushToken];
        [Adjust setPushTokenAsString:pushToken];
    }
    return 0;
}

int AdjustPlugin::addGlobalCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addGlobalCallbackParameter:[NSString stringWithUTF8String:value]
                                    forKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

int AdjustPlugin::addGlobalPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addGlobalPartnerParameter:[NSString stringWithUTF8String:value]
                                   forKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

int AdjustPlugin::removeGlobalCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeGlobalCallbackParameterForKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

int AdjustPlugin::removeGlobalPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeGlobalPartnerParameterForKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

int AdjustPlugin::removeGlobalCallbackParameters(lua_State *L) {
    [Adjust removeGlobalCallbackParameters];
    return 0;
}

int AdjustPlugin::removeGlobalPartnerParameters(lua_State *L) {
    [Adjust removeGlobalPartnerParameters];
    return 0;
}

int AdjustPlugin::isEnabled(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust isEnabledWithCompletionHandler:^(BOOL isEnabled) {
            NSString *result = isEnabled ? @"true" : @"false";
            [AdjustSdkDelegate dispatchEvent:EVENT_IS_ENABLED
                                   withState:L
                                    callback:callback
                                     message:result];
        }];
    }
    return 0;
}

int AdjustPlugin::getAttribution(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [Adjust attributionWithCompletionHandler:^(ADJAttribution * _Nullable attribution) {
            if (nil != attribution) {
                [AdjustSdkDelegate addKey:@"trackerToken" andValue:attribution.trackerToken toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"trackerName" andValue:attribution.trackerName toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"network" andValue:attribution.network toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"campaign" andValue:attribution.campaign toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"creative" andValue:attribution.creative toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"adgroup" andValue:attribution.adgroup toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"clickLabel" andValue:attribution.clickLabel toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"costType" andValue:attribution.costType toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"costAmount" andValue:attribution.costAmount toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"costCurrency" andValue:attribution.costCurrency toDictionary:dictionary];
                NSLog(@"MAHDI : jsonresponse = is here first ");
                if (attribution.jsonResponse != nil) {
                    NSError *jsonResponseError;
                    NSData *jsonResponseData = [NSJSONSerialization dataWithJSONObject:attribution.jsonResponse
                                                                       options:0
                                                                         error:&jsonResponseError];
                    if (!jsonResponseData) {
                        NSLog(@"[AdjustPlugin]: Error while trying to convert jsonResponse dictionary to JSON string: %@", jsonResponseError);
                    } else {
                        NSString *jsonResponseString = [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding];
                        NSLog(@"[AdjustPlugin]: JSON string: %@", jsonResponseString);
                        [AdjustSdkDelegate addKey:@"jsonResponse" andValue:jsonResponseString toDictionary:dictionary];

                    }
                }
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                   options:0
                                                                     error:&error];
                if (!jsonData) {
                    NSLog(@"[AdjustPlugin]: Error while trying to convert attribution dictionary to JSON string: %@", error);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [AdjustSdkDelegate dispatchEvent:EVENT_GET_ATTRIBUTION
                                           withState:L
                                            callback:callback
                                             message:jsonString];
                }
            }
        }];
    }
    return 0;
}

int AdjustPlugin::getAdid(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust adidWithCompletionHandler:^(NSString * _Nullable adid) {
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_ADID
                                   withState:L
                                    callback:callback
                                     message:adid];
        }];
    }
    return 0;
}

int AdjustPlugin::getLastDeeplink(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust lastDeeplinkWithCompletionHandler:^(NSURL * _Nullable lastDeeplink) {
            NSString *strLastDeeplink = nil != lastDeeplink ? [lastDeeplink absoluteString] : nil;
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_LAST_DEEPLINK
                                   withState:L
                                    callback:callback
                                     message:strLastDeeplink];
        }];
    }
    return 0;
}

int AdjustPlugin::getSdkVersion(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust sdkVersionWithCompletionHandler:^(NSString * _Nullable sdkVersion) {
            NSString *sdkVersionFormatted = nil;
            if (sdkVersion != nil) {
                sdkVersionFormatted = [NSString stringWithFormat:@"%@@%@", SDK_PREFIX, sdkVersion];
            }
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_SDK_VERSION
                                   withState:L
                                    callback:callback
                                     message:sdkVersionFormatted];
        }];
    }
    return 0;
}

int AdjustPlugin::setAttributionCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeAttributionCallback(callback);
    }
    return 0;
}

int AdjustPlugin::setEventSuccessCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeEventSuccessCallback(callback);
    }
    return 0;
}

int AdjustPlugin::setEventFailureCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeEventFailureCallback(callback);
    }
    return 0;
}

int AdjustPlugin::setSessionSuccessCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeSessionSuccessCallback(callback);
    }
    return 0;
}

int AdjustPlugin::setSessionFailureCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeSessionFailureCallback(callback);
    }
    return 0;
}

int AdjustPlugin::setDeferredDeeplinkCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeDeferredDeeplinkCallback(callback);
    }
    return 0;
}

int AdjustPlugin::endFirstSessionDelay(lua_State *L){
    [Adjust endFirstSessionDelay];
    return 0;
}

int AdjustPlugin::enableCoppaComplianceInDelay(lua_State *L){
    [Adjust enableCoppaComplianceInDelay];
    return 0;
}

int AdjustPlugin::disableCoppaComplianceInDelay(lua_State *L){
    [Adjust disableCoppaComplianceInDelay];
    return 0;
}

int AdjustPlugin::setExternalDeviceIdInDelay(lua_State *L){
    const char *cstrExternalDeviceId = lua_tostring(L, 1);
    if (cstrExternalDeviceId != NULL) {
        NSString *externalDeviceId =[NSString stringWithUTF8String:cstrExternalDeviceId];
        [Adjust setExternalDeviceIdInDelay:externalDeviceId];
    }
    return 0;
}

// ios only
int AdjustPlugin::trackAppStoreSubscription(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: trackAppStoreSubscription must be supplied with a table");
        return 0;
    }

    NSString *price = nil;
    NSString *currency = nil;
    NSString *transactionId = nil;
    NSDecimalNumber *priceValue = nil;

    // price
    lua_getfield(L, 1, "price");
    if (!lua_isnil(L, 2)) {
        const char *cstrPrice = lua_tostring(L, 2);
        if (cstrPrice != NULL) {
            price = [NSString stringWithUTF8String:cstrPrice];
            priceValue = [NSDecimalNumber decimalNumberWithString:price];
        }
    }
    lua_pop(L, 1);

    // currency
    lua_getfield(L, 1, "currency");
    if (!lua_isnil(L, 2)) {
        const char *cstrCurrency = lua_tostring(L, 2);
        if (cstrCurrency != NULL) {
            currency = [NSString stringWithUTF8String:cstrCurrency];
        }
    }
    lua_pop(L, 1);

    // transaction ID
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 2)) {
        const char *cstrTransactionId = lua_tostring(L, 2);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
        }
    }
    lua_pop(L, 1);

    ADJAppStoreSubscription *subscription =
    [[ADJAppStoreSubscription alloc] initWithPrice:priceValue
                                          currency:currency
                                     transactionId:transactionId];

    // transaction date
    lua_getfield(L, 1, "transactionDate");
    if (!lua_isnil(L, 2)) {
        const char *cstrTransactionDate = lua_tostring(L, 2);
        if (cstrTransactionDate != NULL) {
            NSString *transactionDate = [NSString stringWithUTF8String:cstrTransactionDate];
            NSTimeInterval transactionDateInterval = [transactionDate doubleValue];
            NSDate *oTransactionDate = [NSDate dateWithTimeIntervalSince1970:transactionDateInterval];
            [subscription setTransactionDate:oTransactionDate];
        }
    }
    lua_pop(L, 1);

    // sales region
    lua_getfield(L, 1, "salesRegion");
    if (!lua_isnil(L, 2)) {
        const char *cstrSalesRegion = lua_tostring(L, 2);
        if (cstrSalesRegion != NULL) {
            NSString *salesRegion = [NSString stringWithUTF8String:cstrSalesRegion];
            [subscription setSalesRegion:salesRegion];
        }
    }
    lua_pop(L, 1);

    // callback parameters
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [subscription addCallbackParameter:callbackParams[@"key"]
                                         value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    // partner parameters
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [subscription addPartnerParameter:partnerParams[@"key"]
                                        value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    [Adjust trackAppStoreSubscription:subscription];
    return 0;
}

// ios only
int AdjustPlugin::verifyAppStorePurchase(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: verifyAppStorePurchase must be supplied with a table");
        return 0;
    }

    NSString *productId = nil;
    NSString *transactionId = nil;

    // product ID
    lua_getfield(L, 1, "productId");
    if (!lua_isnil(L, 3)) {
        const char *cstrProductId = lua_tostring(L, 3);
        if (cstrProductId != NULL) {
            productId = [NSString stringWithUTF8String:cstrProductId];
        }
    }
    lua_pop(L, 1);

    // transaction ID
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 3)) {
        const char *cstrTransactionId = lua_tostring(L, 3);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
        }
    }
    lua_pop(L, 1);

    ADJAppStorePurchase *purchase =
    [[ADJAppStorePurchase alloc] initWithTransactionId:transactionId
                                             productId:productId];

    // verification callback
    int callbackIndex = 2;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust verifyAppStorePurchase:purchase
                 withCompletionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            if (nil != verificationResult) {
                [AdjustSdkDelegate addKey:@"verificationStatus"
                                 andValue:verificationResult.verificationStatus
                             toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"code"
                                 andValue:[NSString stringWithFormat:@"%d", verificationResult.code]
                             toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"message"
                                 andValue:verificationResult.message
                             toDictionary:dictionary];
\
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                   options:0
                                                                     error:&error];
                if (!jsonData) {
                    NSLog(@"[AdjustPlugin]: Error while trying to convert purchase verification response dictionary to JSON string: %@", error);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_APP_STORE_PURCHASE_CALLBACK
                                           withState:L
                                            callback:callback
                                             message:jsonString];
                }
            }
        }];
    }
    return 0;
}

// ios only
int AdjustPlugin::verifyAndTrackAppStorePurchase(lua_State *L) {
    if (!lua_istable(L, 1)) {
        NSLog(@"[AdjustPlugin]: verifyAndTrackAppStorePurchase must be supplied with a table");
        return 0;
    }

    double revenue = -1.0;
    NSString *eventToken = nil;
    NSString *currency = nil;
    NSString *deduplicationId = nil;
    NSString *callbackId = nil;
    NSString *productId = nil;
    NSString *transactionId = nil;

    // event token
    lua_getfield(L, 1, "eventToken");
    if (!lua_isnil(L, 3)) {
        const char *cstrEventToken = lua_tostring(L, 3);
        if (cstrEventToken != NULL) {
            eventToken = [NSString stringWithUTF8String:cstrEventToken];
        }
    }
    lua_pop(L, 1);

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:eventToken];

    // revenue
    lua_getfield(L, 1, "revenue");
    if (!lua_isnil(L, 3)) {
        revenue = lua_tonumber(L, 3);
    }
    lua_pop(L, 1);

    // currency
    lua_getfield(L, 1, "currency");
    if (!lua_isnil(L, 3)) {
        const char *cstrCurrency = lua_tostring(L, 3);
        if (cstrCurrency != NULL) {
            currency = [NSString stringWithUTF8String:cstrCurrency];
        }
    }
    lua_pop(L, 1);

    if (currency != nil && revenue != -1.0) {
        [event setRevenue:revenue currency:currency];
    }

    // deduplication ID
    lua_getfield(L, 1, "deduplicationId");
    if (!lua_isnil(L, 3)) {
        const char *cstrDeduplicationId = lua_tostring(L, 3);
        if (cstrDeduplicationId != NULL) {
            deduplicationId = [NSString stringWithUTF8String:cstrDeduplicationId];
            [event setDeduplicationId:deduplicationId];
        }
    }
    lua_pop(L, 1);

    // callback ID
    lua_getfield(L, 1, "callbackId");
    if (!lua_isnil(L, 3)) {
        const char *cstrCallbackId = lua_tostring(L, 3);
        if (cstrCallbackId != NULL) {
            callbackId = [NSString stringWithUTF8String:cstrCallbackId];
            [event setCallbackId:callbackId];
        }
    }
    lua_pop(L, 1);

    // product ID
    lua_getfield(L, 1, "productId");
    if (!lua_isnil(L, 3)) {
        const char *cstrProductId = lua_tostring(L, 3);
        if (cstrProductId != NULL) {
            productId = [NSString stringWithUTF8String:cstrProductId];
            [event setProductId:productId];
        }
    }
    lua_pop(L, 1);
    
    // transaction ID
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 3)) {
        const char *cstrTransactionId = lua_tostring(L, 3);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
            [event setTransactionId:transactionId];
        }
    }
    lua_pop(L, 1);

    // callback parameters
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 3) && lua_istable(L, 3)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [event addCallbackParameter:callbackParams[@"key"]
                                  value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    // partner parameters
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 3) && lua_istable(L, 3)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [event addPartnerParameter:partnerParams[@"key"]
                                 value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);
    
    int callbackIndex = 2;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust verifyAndTrackAppStorePurchase:event withCompletionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            if (nil != verificationResult) {
                [AdjustSdkDelegate addKey:@"verificationStatus"
                                 andValue:verificationResult.verificationStatus
                             toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"code"
                                 andValue:[NSString stringWithFormat:@"%d", verificationResult.code]
                             toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"message"
                                 andValue:verificationResult.message
                             toDictionary:dictionary];

                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                   options:0
                                                                     error:&error];
                if (!jsonData) {
                    NSLog(@"[AdjustPlugin]: Error while trying to convert purchase verification response dictionary to JSON string: %@", error);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE_CALLBACK
                                           withState:L
                                            callback:callback
                                             message:jsonString];
                }
            }
        }];
    }
    return 0;
}

// ios only
int AdjustPlugin::requestAppTrackingAuthorization(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust requestAppTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
            NSString *strStatus = [NSString stringWithFormat:@"%lu", status];
            [AdjustSdkDelegate dispatchEvent:EVENT_REQUEST_APP_TRACKING_AUTHORIZATION
                                   withState:L
                                    callback:callback
                                     message:strStatus];
        }];
    }
    return 0;
}

// ios only
int AdjustPlugin::updateSkanConversionValue(lua_State *L) {
    NSInteger conversionValue = lua_tointeger(L, 1);
    NSString *coarseValue = nil;
    const char *cstrCoarseValue = lua_tostring(L, 2);
    if (cstrCoarseValue != NULL) {
        coarseValue = [NSString stringWithUTF8String:cstrCoarseValue];
    }
    BOOL lockWindow = lua_toboolean(L, 3);

    int callbackIndex = 4;
    if (coarseValue != NULL) {
        if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
            CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
            [Adjust updateSkanConversionValue:conversionValue
                                  coarseValue:coarseValue
                                   lockWindow:[NSNumber numberWithBool:lockWindow]
                        withCompletionHandler:^(NSError * _Nullable error) {
                [AdjustSdkDelegate dispatchEvent:EVENT_UPDATE_SKAN_CONVERSION_VALUE
                                       withState:L
                                        callback:callback
                                         message:[error localizedDescription]];
            }];
        }
    }
    return 0;
}

// ios only
int AdjustPlugin::getIdfa(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust idfaWithCompletionHandler:^(NSString * _Nullable idfa) {
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_IDFA
                                   withState:L
                                    callback:callback
                                     message:idfa];
        }];
    }
    return 0;
}

// ios only
int AdjustPlugin::getIdfv(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [Adjust idfvWithCompletionHandler:^(NSString * _Nullable idfv) {
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_IDFV
                                   withState:L
                                    callback:callback
                                     message:idfv];
        }];
    }
    return 0;
}

// ios only
int AdjustPlugin::getAppTrackingAuthorizationStatus(lua_State *L) {
    int status = [Adjust appTrackingAuthorizationStatus];
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_APP_TRACKING_AUTHORIZATION_STATUS
                               withState:L
                                callback:callback
                                 message:[NSString stringWithFormat:@"%d", status]];
    }
    return 0;
}

// ios only
int AdjustPlugin::setSkanUpdatedCallback(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        library->InitializeSkanUpdatedCallback(callback);
    }
    return 0;
}

// android only
int AdjustPlugin::trackPlayStoreSubscription(lua_State *L) {
    return 0;
}

// android only
int AdjustPlugin::enablePlayStoreKidsComplianceInDelay(lua_State *L){
    return 0;
}

// android only
int AdjustPlugin::disablePlayStoreKidsComplianceInDelay(lua_State *L){
    return 0;
}

// android only
int AdjustPlugin::verifyPlayStorePurchase(lua_State *L) {
    // verification callback
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionary]
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            NSLog(@"[AdjustPlugin]: Error while trying to convert purchase verification response dictionary to JSON string: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_PLAY_STORE_PURCHASE_CALLBACK
                                   withState:L
                                    callback:callback
                                     message:jsonString];
        }
    }
    return 0;
}

// android only
int AdjustPlugin::verifyAndTrackPlayStorePurchase(lua_State *L) {
    // verification callback
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionary]
                                                           options:0
                                                             error:&error];
        if (!jsonData) {
            NSLog(@"[AdjustPlugin]: Error while trying to convert purchase verification response dictionary to JSON string: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_AND_TRACK_PLAY_STORE_PURCHASE_CALLBACK
                                   withState:L
                                    callback:callback
                                     message:jsonString];
        }
    }
    return 0;
}

// android only
int AdjustPlugin::getGoogleAdId(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_GOOGLE_AD_ID
                               withState:L
                                callback:callback
                                 message:nil];
    }
    return 0;
}

// android only
int AdjustPlugin::getAmazonAdId(lua_State *L) {
    int callbackIndex = 1;
    if (CoronaLuaIsListener(L, callbackIndex, "ADJUST")) {
        CoronaLuaRef callback = CoronaLuaNewRef(L, callbackIndex);
        [AdjustSdkDelegate dispatchEvent:EVENT_GET_AMAZON_AD_ID
                               withState:L
                                callback:callback
                                 message:nil];
    }
    return 0;
}

// testing purposes only
int AdjustPlugin::setTestOptions(lua_State *L) {
    NSMutableDictionary *testOptions = [[NSMutableDictionary alloc] init];

    lua_getfield(L, 1, "baseUrl");
    if (!lua_isnil(L, 2)) {
        const char *baseUrl = lua_tostring(L, 2);
        if (baseUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: baseUrl]
                            forKey:@"baseUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "gdprUrl");
    if (!lua_isnil(L, 2)) {
        const char *gdprUrl = lua_tostring(L, 2);
        if (gdprUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: gdprUrl]
                            forKey:@"gdprUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "subscriptionUrl");
    if (!lua_isnil(L, 2)) {
        const char *subscriptionUrl = lua_tostring(L, 2);
        if (subscriptionUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: subscriptionUrl]
                            forKey:@"subscriptionUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "purchaseVerificationUrl");
    if (!lua_isnil(L, 2)) {
        const char *purchaseVerificationUrl = lua_tostring(L, 2);
        if (purchaseVerificationUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: purchaseVerificationUrl]
                            forKey:@"purchaseVerificationUrl"];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "urlOverwrite");
    if (!lua_isnil(L, 2)) {
        const char *urlOverwrite = lua_tostring(L, 2);
        if (urlOverwrite != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: urlOverwrite]
                            forKey:@"testUrlOverwrite"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "extraPath");
    if (!lua_isnil(L, 2)) {
        const char *extraPath = lua_tostring(L, 2);
        if (extraPath != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: extraPath]
                            forKey:@"extraPath"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "basePath");
    if (!lua_isnil(L, 2)) {
        const char *basePath = lua_tostring(L, 2);
        if (basePath != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: basePath]
                            forKey:@"basePath"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "timerIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:timerIntervalInMilliseconds]
                        forKey:@"timerIntervalInMilliseconds"];
    }
    lua_pop(L, 1);
    
   
    lua_getfield(L, 1, "timerStartInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerStartInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:timerStartInMilliseconds]
                        forKey:@"timerStartInMilliseconds"];
    }
    lua_pop(L, 1);


    lua_getfield(L, 1, "sessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger sessionIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:sessionIntervalInMilliseconds]
                        forKey:@"sessionIntervalInMilliseconds"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "subsessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger subsessionIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:subsessionIntervalInMilliseconds]
                        forKey:@"subsessionIntervalInMilliseconds"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "teardown");
    if (!lua_isnil(L, 2)) {
        BOOL teardown = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:teardown] forKey:@"teardown"];
        if ([testOptions[@"teardown"] isEqualToNumber:@1] == YES) {
           [AdjustSdkDelegate teardown];
       }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "resetSdk");
    if (!lua_isnil(L, 2)) {
        BOOL resetSdk = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:resetSdk] forKey:@"resetSdk"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "deleteState");
    if (!lua_isnil(L, 2)) {
        BOOL deleteState = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:deleteState] forKey:@"deleteState"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "resetTest");
    if (!lua_isnil(L, 2)) {
        BOOL resetTest = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:resetTest] forKey:@"resetTest"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "noBackoffWait");
    if (!lua_isnil(L, 2)) {
        NSInteger noBackoffWait = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:noBackoffWait] forKey:@"noBackoffWaitInt"];
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "adServicesFrameworkEnabled");
    if (!lua_isnil(L, 2)) {
        BOOL adServicesFrameworkEnabled = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:adServicesFrameworkEnabled] forKey:@"adServicesFrameworkEnabled"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "attStatus");
    if (!lua_isnil(L, 2)) {
        NSInteger attStatus = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:attStatus] forKey:@"attStatusInt"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "idfa");
    if (!lua_isnil(L, 2)) {
        const char *cstrIdfa = lua_tostring(L, 2);
        [testOptions setObject:[NSString stringWithUTF8String: cstrIdfa] forKey:@"idfa"];
    }
    lua_pop(L, 1);
    
    [Adjust setTestOptions:testOptions];
    return 0;
}

// testing purposes only
int AdjustPlugin::onResume(lua_State *L) {
    [Adjust trackSubsessionStart];
    return 0;
}

// testing purposes only
int AdjustPlugin::onPause(lua_State *L) {
    [Adjust trackSubsessionEnd];
    return 0;
}

// testing purposes only
int AdjustPlugin::teardown(lua_State *L) {
    Self *library = ToLibrary(L);
    library->attributionChangedCallback = nil;
    library->eventSuccessCallback = nil;
    library->eventFailureCallback = nil;
    library->sessionSuccessCallback = nil;
    library->sessionFailureCallback = nil;
    library->deferredDeeplinkCallback = nil;
    library->skanUpdatedCallback = nil;

    return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_adjust(lua_State *L) {
    return AdjustPlugin::Open(L);
}
