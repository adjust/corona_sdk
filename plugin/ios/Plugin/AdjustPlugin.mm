//
//  PluginLibrary.mm
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 11th September 2017.
//  Copyright (c) 2017-2022 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CoronaRuntime.h>
#include "CoronaLuaIOS.h"
#import "Adjust.h"
#import "AdjustPlugin.h"
#import "AdjustSdkDelegate.h"
#import "ADJLogger.h"
#import "ADJSubscription.h"
#import "ADJAttribution.h"
#import "ADJPurchaseVerificationResult.h"
#import "ADJAppStorePurchase.h"

#define EVENT_IS_ENABLED @"adjust_isEnabled"
#define EVENT_GET_IDFA @"adjust_getIdfa"
#define EVENT_GET_ATTRIBUTION @"adjust_getAttribution"
#define EVENT_GET_ADID @"adjust_getAdid"
#define EVENT_GET_GOOGLE_AD_ID @"adjust_getGoogleAdId"
#define EVENT_GET_AMAZON_AD_ID @"adjust_getAmazonAdId"
#define EVENT_GET_SDK_VERSION @"adjust_getSdkVersion"
#define EVENT_GET_AUTHORIZATION_STATUS @"adjust_requestAppTrackingAuthorization"
#define EVENT_GET_LAST_DEEPLINK @"adjust_getLastDeeplink"
#define EVENT_PROCESS_AND_RESOLVE_DEEPLINK @"adjust_processAndResolveDeeplink"
#define EVENT_VERIFY_APP_STORE_PURCHASE_CALLBACK @"adjust_verifyAppStorePurchase"
#define EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE_CALLBACK @"adjust_verifyAndTrackAppStorePurchase"
#define EVENT_UPDATE_SKAN_CONVERSION_VALUE @"adjust_updateSkanConversionValue"

#define SDK_PREFIX @"corona5.0.0"

// ----------------------------------------------------------------------------

class AdjustPlugin {
public:
    typedef AdjustPlugin Self;

    static const char kName[];
    static const char kEvent[];

    void InitializeAttributionListener(CoronaLuaRef listener);
    void InitializeEventSuccessListener(CoronaLuaRef listener);
    void InitializeEventFailureListener(CoronaLuaRef listener);
    void InitializeSessionSuccessListener(CoronaLuaRef listener);
    void InitializeSessionFailureListener(CoronaLuaRef listener);
    void InitializeDeferredDeeplinkListener(CoronaLuaRef listener);
    void InitializeUpdateSkanListener(CoronaLuaRef listener);

    CoronaLuaRef GetAttributionChangedListener() const { return attributionChangedListener; }
    CoronaLuaRef GetEventSuccessListener() const { return eventSuccessListener; }
    CoronaLuaRef GetEventFailureListener() const { return eventFailureListener; }
    CoronaLuaRef GetSessionSuccessListener() const { return sessionSuccessListener; }
    CoronaLuaRef GetSessionFailureListener() const { return sessionFailureListener; }
    CoronaLuaRef GetDeferredDeeplinkListener() const { return deferredDeeplinkListener; }
    CoronaLuaRef GetUpdateSkanListener() const { return updateSkanListener; }

    static int Open(lua_State *L);
    static Self *ToLibrary(lua_State *L);

    static int initSdk(lua_State *L);
    static int trackEvent(lua_State *L);
    static int enable(lua_State *L);
    static int disable(lua_State *L);
    static int setPushToken(lua_State *L);
    static int processDeeplink(lua_State *L);
    static int processAndResolveDeeplink(lua_State *L);
    static int addGlobalCallbackParameter(lua_State *L);
    static int addGlobalPartnerParameter(lua_State *L);
    static int removeGlobalCallbackParameter(lua_State *L);
    static int removeGlobalPartnerParameter(lua_State *L);
    static int removeGlobalCallbackParameters(lua_State *L);
    static int removeGlobalPartnerParameters(lua_State *L);
    static int switchToOfflineMode(lua_State *L);
    static int switchBackToOnlineMode(lua_State *L);
    static int isEnabled(lua_State *L);
    static int getIdfa(lua_State *L);
    static int getSdkVersion(lua_State *L);
    static int getAttribution(lua_State *L);
    static int getAdid(lua_State *L);
    static int gdprForgetMe(lua_State *L);
    static int trackAdRevenue(lua_State *L);
    static int trackAppStoreSubscription(lua_State *L);
    static int requestAppTrackingAuthorization(lua_State *L);
    static int getAppTrackingAuthorizationStatus(lua_State *L);
    static int updateSkanConversionValue(lua_State *L);
    static int trackThirdPartySharing(lua_State *L);
    static int trackMeasurementConsent(lua_State *L);
    static int setAttributionListener(lua_State *L);
    static int setEventSuccessListener(lua_State *L);
    static int setEventFailureListener(lua_State *L);
    static int setSessionSuccessListener(lua_State *L);
    static int setSessionFailureListener(lua_State *L);
    static int setDeferredDeeplinkListener(lua_State *L);
    static int setUpdateSkanListener(lua_State *L);
    static int checkForNewAttStatus(lua_State *L);
    static int getLastDeeplink(lua_State *L);
    static int verifyAppStorePurchase(lua_State *L);
    static int verifyAndTrackAppStorePurchase(lua_State *L);

    // Android specific.
    static int getGoogleAdId(lua_State *L);
    static int getAmazonAdId(lua_State *L);
    static int setReferrer(lua_State *L);
    static int trackPlayStoreSubscription(lua_State *L);
    static int verifyPlayStorePurchase(lua_State *L);
    static int verifyAndTrackPlayStorePurchase(lua_State *L);

    // For testing purposes only.
    static int setTestOptions(lua_State *L);
    static int onResume(lua_State *L);
    static int onPause(lua_State *L);

protected:
    static int Finalizer(lua_State *L);
    AdjustPlugin();

private:
    CoronaLuaRef attributionChangedListener;
    CoronaLuaRef eventSuccessListener;
    CoronaLuaRef eventFailureListener;
    CoronaLuaRef sessionSuccessListener;
    CoronaLuaRef sessionFailureListener;
    CoronaLuaRef deferredDeeplinkListener;
    CoronaLuaRef updateSkanListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library".
// Adjust SDK is named "plugin.adjust".
const char AdjustPlugin::kName[] = "plugin.adjust";

AdjustPlugin::AdjustPlugin()
: attributionChangedListener(NULL),
eventSuccessListener(NULL),
eventFailureListener(NULL),
sessionSuccessListener(NULL),
sessionFailureListener(NULL),
deferredDeeplinkListener(NULL),
updateSkanListener(NULL){}


void AdjustPlugin::InitializeAttributionListener(CoronaLuaRef listener) {
    attributionChangedListener = listener;
}

void AdjustPlugin::InitializeEventSuccessListener(CoronaLuaRef listener) {
    eventSuccessListener = listener;
}

void AdjustPlugin::InitializeEventFailureListener(CoronaLuaRef listener) {
    eventFailureListener = listener;
}

void AdjustPlugin::InitializeSessionSuccessListener(CoronaLuaRef listener) {
    sessionSuccessListener = listener;
}

void AdjustPlugin::InitializeSessionFailureListener(CoronaLuaRef listener) {
    sessionFailureListener = listener;
}

void AdjustPlugin::InitializeDeferredDeeplinkListener(CoronaLuaRef listener) {
    deferredDeeplinkListener = listener;
}

void AdjustPlugin::InitializeUpdateSkanListener(CoronaLuaRef listener) {
    updateSkanListener = listener;
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
        { "trackEvent", trackEvent },
        { "enable", enable },
        { "disable", disable },
        { "setPushToken", setPushToken },
        { "processDeeplink", processDeeplink},
        { "processAndResolveDeeplink", processAndResolveDeeplink},
        { "trackAdRevenue", trackAdRevenue },
        { "addGlobalCallbackParameter", addGlobalCallbackParameter },
        { "addGlobalPartnerParameter", addGlobalPartnerParameter },
        { "removeGlobalCallbackParameter", removeGlobalCallbackParameter },
        { "removeGlobalPartnerParameter", removeGlobalPartnerParameter },
        { "removeGlobalCallbackParameters", removeGlobalCallbackParameters },
        { "removeGlobalPartnerParameters", removeGlobalPartnerParameters },
        { "switchToOfflineMode", switchToOfflineMode },
        { "switchBackToOnlineMode", switchBackToOnlineMode },
        { "setAttributionListener", setAttributionListener },
        { "setEventSuccessListener", setEventSuccessListener },
        { "setEventFailureListener", setEventFailureListener },
        { "setSessionSuccessListener", setSessionSuccessListener },
        { "setSessionFailureListener", setSessionFailureListener },
        { "setDeferredDeeplinkListener", setDeferredDeeplinkListener },
        { "isEnabled", isEnabled },
        { "getSdkVersion", getSdkVersion },
        { "getAttribution", getAttribution },
        { "getAdid", getAdid },
        { "gdprForgetMe", gdprForgetMe },
        { "getLastDeeplink", getLastDeeplink },
        { "trackThirdPartySharing", trackThirdPartySharing },
        { "trackMeasurementConsent", trackMeasurementConsent },
        { "trackPlayStoreSubscription", trackPlayStoreSubscription }, // Android Only.
        { "verifyPlayStorePurchase", verifyPlayStorePurchase },
        { "verifyAndTrackPlayStorePurchase", verifyAndTrackPlayStorePurchase },
        { "getGoogleAdId", getGoogleAdId },
        { "getAmazonAdId", getAmazonAdId },
        { "setReferrer", setReferrer },
        { "getIdfa", getIdfa }, // IOS only.
        { "getAppTrackingAuthorizationStatus", getAppTrackingAuthorizationStatus },
        { "requestAppTrackingAuthorization", requestAppTrackingAuthorization },
        { "setUpdateSkanListener", setUpdateSkanListener },
        { "checkForNewAttStatus", checkForNewAttStatus },
        { "updateSkanConversionValue", updateSkanConversionValue },
        { "trackAppStoreSubscription", trackAppStoreSubscription },
        { "verifyAppStorePurchase", verifyAppStorePurchase },
        { "verifyAndTrackAppStorePurchase", verifyAndTrackAppStorePurchase },
        { "onResume", onResume }, // Test only.
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
    CoronaLuaDeleteRef(L, library->GetSessionSuccessListener());
    CoronaLuaDeleteRef(L, library->GetSessionFailureListener());
    CoronaLuaDeleteRef(L, library->GetEventSuccessListener());
    CoronaLuaDeleteRef(L, library->GetEventFailureListener());
    CoronaLuaDeleteRef(L, library->GetDeferredDeeplinkListener());
    CoronaLuaDeleteRef(L, library->GetUpdateSkanListener());

    delete library;
    return 0;
}

AdjustPlugin * AdjustPlugin::ToLibrary(lua_State *L) {
    // Library is pushed as part of the closure.
    Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
    return library;
}

// Public API.
int AdjustPlugin::initSdk(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }
    
    NSString *appToken = nil;
    NSString *environment = nil;
    BOOL isSendingInBackgroundEnabled = NO;
    BOOL isAdServicesEnabled = YES;
    BOOL isIdfaReadingEnabled = YES;
    BOOL isIdfvReadingEnabled = YES;
    BOOL isSkanAttributionEnabled = YES;
    BOOL isCostDataInAttributionEnabled = NO;
    BOOL linkMeEnabled = NO;
    BOOL isDeviceIdsReadingOnceEnabled = NO;
    NSArray *urlStrategyDomains = nil;
    BOOL useSubdomains = NO;
    BOOL isDataResidency = NO;
    BOOL isCoppaComplianceEnabled = NO;
    ADJLogLevel logLevel = ADJLogLevelInfo;
    NSString *defaultTracker = nil;
    NSString *externalDeviceId = nil;
    NSUInteger attConsentWaitingSeconds = -1;
    NSInteger eventDeduplicationIdsMaxSize = 0;
    BOOL shouldLaunchDeferredDeeplink = YES;
    
    

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

    ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken
                                                      environment:environment
                                                 suppressLogLevel:YES];

    // SDK prefix.
    [adjustConfig setSdkPrefix:@"corona5.0.0"];

    // Log level.
    [adjustConfig setLogLevel:logLevel];


    // AdServices info reading.
    lua_getfield(L, 1, "allowAdServicesInfoReading");
    if (!lua_isnil(L, 2)) {
        isAdServicesEnabled = lua_toboolean(L, 2);
        if (isAdServicesEnabled == NO) {
            [adjustConfig disableAdServices];
        }
    }
    lua_pop(L, 1);

    // IDFA reading.
    lua_getfield(L, 1, "allowIdfaReading");
    if (!lua_isnil(L, 2)) {
        isIdfaReadingEnabled = lua_toboolean(L, 2);
        if (isIdfaReadingEnabled == NO) {
            [adjustConfig disableIdfaReading];
        }
    }
    lua_pop(L, 1);

    // IDFV reading.
    lua_getfield(L, 1, "allowIdfvReading");
    if (!lua_isnil(L, 2)) {
        isIdfvReadingEnabled = lua_toboolean(L, 2);
        if (isIdfvReadingEnabled == NO) {
            [adjustConfig disableIdfvReading];
        }
    }
    lua_pop(L, 1);

    // SKAdNetwork handling.
    lua_getfield(L, 1, "isSkanAttributionEnabled");
    if (!lua_isnil(L, 2)) {
        isSkanAttributionEnabled = lua_toboolean(L, 2);
        if (isSkanAttributionEnabled == NO) {
            [adjustConfig disableSkanAttribution];
        }
    }
    lua_pop(L, 1);

    // cost in data attribution handling.
    lua_getfield(L, 1, "isCostDataInAttributionEnabled");
    if (!lua_isnil(L, 2)) {
        isCostDataInAttributionEnabled = lua_toboolean(L, 2);
        if (isCostDataInAttributionEnabled == YES) {
            [adjustConfig enableCostDataInAttribution];
        }
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

    // External device ID.
    lua_getfield(L, 1, "externalDeviceId");
    if (!lua_isnil(L, 2)) {
        const char *cstrExternalDeviceId = lua_tostring(L, 2);
        if (cstrExternalDeviceId != NULL) {
            externalDeviceId = [NSString stringWithUTF8String:cstrExternalDeviceId];
        }
        [adjustConfig setExternalDeviceId:externalDeviceId];
    }
    lua_pop(L, 1);
    
    // URL strategy.
    lua_getfield(L, 1, "urlStrategyDomains");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        urlStrategyDomains = [dict allValues];
    }
    lua_pop(L, 1);
    
    // Is Data Residency.
    lua_getfield(L, 1, "isDataResidency");
    if (!lua_isnil(L, 2)) {
        isDataResidency = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);
    
    // UseSubdomains.
    lua_getfield(L, 1, "useSubdomains");
    if (!lua_isnil(L, 2)) {
        useSubdomains = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    if ([urlStrategyDomains count] > 0){
        [adjustConfig setUrlStrategy:urlStrategyDomains useSubdomains:useSubdomains isDataResidency:isDataResidency];
    }

    // Send in background.
    lua_getfield(L, 1, "isSendingInBackgroundEnabled");
    if (!lua_isnil(L, 2)) {
        isSendingInBackgroundEnabled = lua_toboolean(L, 2);
        if (isSendingInBackgroundEnabled == YES) {
            [adjustConfig enableSendingInBackground];
        }
    }
    lua_pop(L, 1);

    // Launching deferred deep link.
    lua_getfield(L, 1, "shouldLaunchDeeplink");
    if (!lua_isnil(L, 2)) {
        shouldLaunchDeferredDeeplink = lua_toboolean(L, 2);
    }
    lua_pop(L, 1);

    // Consent Waiting Time.
    lua_getfield(L, 1, "attConsentWaitingSeconds");
    if (!lua_isnil(L, 2)) {
        attConsentWaitingSeconds = lua_tonumber(L, 2);
        [adjustConfig setAttConsentWaitingInterval:attConsentWaitingSeconds];
    }
    lua_pop(L, 1);

    // Event deduplication Id max size.
    lua_getfield(L, 1, "eventDeduplicationIdsMaxSize");
    if (!lua_isnil(L, 2)) {
        eventDeduplicationIdsMaxSize = lua_tointeger(L, 2);
        [adjustConfig setEventDeduplicationIdsMaxSize:eventDeduplicationIdsMaxSize];
    }
    lua_pop(L, 1);

//    // Device known.
//    lua_getfield(L, 1, "isDeviceKnown");
//    if (!lua_isnil(L, 2)) {
//        isDeviceKnown = lua_toboolean(L, 2);
//        [adjustConfig setIsDeviceKnown:isDeviceKnown];
//    }
//    lua_pop(L, 1);


    // COPPA compliance.
    lua_getfield(L, 1, "coppaCompliant");
    if (!lua_isnil(L, 2)) {
        isCoppaComplianceEnabled = lua_toboolean(L, 2);
        if (isCoppaComplianceEnabled == YES) {
            [adjustConfig enableCoppaCompliance];
        }
    }
    lua_pop(L, 1);

    // LinkMe feature.
    lua_getfield(L, 1, "linkMeEnabled");
    if (!lua_isnil(L, 2)) {
        linkMeEnabled = lua_toboolean(L, 2);
        if (linkMeEnabled == YES) {
            [adjustConfig enableLinkMe];
        }
    }
    lua_pop(L, 1);

    // Device Ids read once.
    lua_getfield(L, 1, "isDeviceIdsReadingOnceEnabled");
    if (!lua_isnil(L, 2)) {
        isDeviceIdsReadingOnceEnabled = lua_toboolean(L, 2);
        if (isDeviceIdsReadingOnceEnabled == YES) {
            [adjustConfig enableDeviceIdsReadingOnce];
        }
    }
    lua_pop(L, 1);

    // Callbacks.
    Self *library = ToLibrary(L);
    BOOL isAttributionChangedListenerImplmented = library->GetAttributionChangedListener() != NULL;
    BOOL isEventSuccessListenerImplmented = library->GetEventSuccessListener() != NULL;
    BOOL isEventFailureListenerImplmented = library->GetEventFailureListener() != NULL;
    BOOL isSessionSuccessListenerImplmented = library->GetSessionSuccessListener() != NULL;
    BOOL isSessionFailureListenerImplmented = library->GetSessionFailureListener() != NULL;
    BOOL isDeferredDeeplinkListenerImplemented = library->GetDeferredDeeplinkListener() != NULL;
    BOOL isUpdateSkanListenerImplemented = library->GetUpdateSkanListener() != NULL;

    if (isAttributionChangedListenerImplmented
        || isEventSuccessListenerImplmented
        || isEventFailureListenerImplmented
        || isSessionSuccessListenerImplmented
        || isSessionFailureListenerImplmented
        || isDeferredDeeplinkListenerImplemented
        || isUpdateSkanListenerImplemented) {
        [adjustConfig setDelegate:
         [AdjustSdkDelegate getInstanceWithSwizzleOfAttributionChangedCallback:library->GetAttributionChangedListener()
                                                  eventSuccessCallback:library->GetEventSuccessListener()
                                                  eventFailureCallback:library->GetEventFailureListener()
                                                sessionSuccessCallback:library->GetSessionSuccessListener()
                                                sessionFailureCallback:library->GetSessionFailureListener()
                                                      deferredDeeplinkCallback:library->GetDeferredDeeplinkListener()
                                                            updateSkanCallback:library->GetUpdateSkanListener()
                                                  shouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink
                                                                   andLuaState:L]];
    }

    [Adjust initSdk:adjustConfig];
    NSLog(@"sdk init finished");
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
    NSString *deduplicationId = nil;
    NSString *productId = nil;
    NSString *callbackId = nil;

    // Event token.
    lua_getfield(L, 1, "eventToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrEventToken = lua_tostring(L, 2);
        if (cstrEventToken != NULL) {
            eventToken = [NSString stringWithUTF8String:cstrEventToken];
        }
    }
    lua_pop(L, 1);

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:eventToken];

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

    // Callback ID.
    lua_getfield(L, 1, "callbackId");
    if (!lua_isnil(L, 2)) {
        const char *cstrCallbackId = lua_tostring(L, 2);
        if (cstrCallbackId != NULL) {
            callbackId = [NSString stringWithUTF8String:cstrCallbackId];
        }
        [event setCallbackId:callbackId];
    }
    lua_pop(L, 1);

    // Deduplication ID.
    lua_getfield(L, 1, "deduplicationId");
    if (!lua_isnil(L, 2)) {
        const char *cstrDeduplicationId = lua_tostring(L, 2);
        if (cstrDeduplicationId != NULL) {
            deduplicationId = [NSString stringWithUTF8String:cstrDeduplicationId];
        }
        [event setDeduplicationId:deduplicationId];
    }
    lua_pop(L, 1);

    // Prdouction ID.
    lua_getfield(L, 1, "productId");
    if (!lua_isnil(L, 2)) {
        const char *cstrProductId = lua_tostring(L, 2);
        if (cstrProductId != NULL) {
            productId = [NSString stringWithUTF8String:cstrProductId];
        }
        [event setProductId:productId];
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
int AdjustPlugin::trackAppStoreSubscription(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }

    NSString *price = nil;
    NSString *currency = nil;
    NSString *transactionId = nil;

    NSDecimalNumber *priceValue = nil;

    // Price.
    lua_getfield(L, 1, "price");
    if (!lua_isnil(L, 2)) {
        const char *cstrPrice = lua_tostring(L, 2);
        if (cstrPrice != NULL) {
            price = [NSString stringWithUTF8String:cstrPrice];
            priceValue = [NSDecimalNumber decimalNumberWithString:price];
        }
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

    // Transaction ID.
    lua_getfield(L, 1, "transactionId");
    if (!lua_isnil(L, 2)) {
        const char *cstrTransactionId = lua_tostring(L, 2);
        if (cstrTransactionId != NULL) {
            transactionId = [NSString stringWithUTF8String:cstrTransactionId];
        }
    }
    lua_pop(L, 1);

    ADJAppStoreSubscription *subscription = [[ADJAppStoreSubscription alloc] initWithPrice:priceValue
                                                                  currency:currency
                                                             transactionId:transactionId];

    // Transaction date.
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

    // Sales region.
    lua_getfield(L, 1, "salesRegion");
    if (!lua_isnil(L, 2)) {
        const char *cstrSalesRegion = lua_tostring(L, 2);
        if (cstrSalesRegion != NULL) {
            NSString *salesRegion = [NSString stringWithUTF8String:cstrSalesRegion];
            [subscription setSalesRegion:salesRegion];
        }
    }
    lua_pop(L, 1);

    // Callback parameters.
    lua_getfield(L, 1, "callbackParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *callbackParams = [dict objectForKey:key];
            [subscription addCallbackParameter:callbackParams[@"key"] value:callbackParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    // Partner parameters.
    lua_getfield(L, 1, "partnerParameters");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for(id key in dict) {
            NSDictionary *partnerParams = [dict objectForKey:key];
            [subscription addPartnerParameter:partnerParams[@"key"] value:partnerParams[@"value"]];
        }
    }
    lua_pop(L, 1);

    [Adjust trackAppStoreSubscription:subscription];
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
int AdjustPlugin::setEventSuccessListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeEventSuccessListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setEventFailureListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeEventFailureListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setSessionSuccessListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeSessionSuccessListener(listener);
    }
    return 0;
}

// Public API.
int AdjustPlugin::setSessionFailureListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeSessionFailureListener(listener);
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
int AdjustPlugin::setUpdateSkanListener(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        library->InitializeUpdateSkanListener(listener);
    }
    return 0;
}


// Public API.
int AdjustPlugin::enable(lua_State *L) {
//    BOOL enabled = lua_toboolean(L, 1);
    [Adjust enable];
    return 0;
}

// Public API.
int AdjustPlugin::disable(lua_State *L) {
    [Adjust disable];
    return 0;
}

// Public API.
int AdjustPlugin::setPushToken(lua_State *L) {
    const char *cstrPushToken = lua_tostring(L, 1);
    if (cstrPushToken != NULL) {
        NSString *pushToken =[NSString stringWithUTF8String:cstrPushToken];
        [Adjust setPushTokenAsString:pushToken];
    }
    return 0;
}

// Public API.
int AdjustPlugin::processDeeplink(lua_State *L) {
    const char *urlChar = lua_tostring(L, 1);
    if (urlChar != NULL) {
        NSString *urlString = [NSString stringWithUTF8String:urlChar];
        NSURL *url;
        if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
            url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        } else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }
        #pragma clang diagnostic pop
        ADJDeeplink *deeplink = [[ADJDeeplink alloc] initWithDeeplink:url];
        [Adjust processDeeplink:deeplink];
    }
    return 0;
}

// Public API
int AdjustPlugin::processAndResolveDeeplink(lua_State *L){
    const char *urlChar = lua_tostring(L, 1);
    int listenerIndex = 2;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        if (urlChar != NULL) {
            NSString *urlString = [NSString stringWithUTF8String:urlChar];
            NSURL *url;
            if ([NSString instancesRespondToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
                url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
            } else {
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
                #pragma clang diagnostic pop
                ADJDeeplink *deeplink = [[ADJDeeplink alloc] initWithDeeplink:url];
                [Adjust processAndResolveDeeplink:deeplink
                            withCompletionHandler:^(NSString * _Nullable resolvedLink) {
                    [AdjustSdkDelegate dispatchEvent:EVENT_PROCESS_AND_RESOLVE_DEEPLINK withState:L callback:listener andMessage:resolvedLink];
                }];
        }
    }
}

// Public API.
int AdjustPlugin::trackAdRevenue(lua_State *L) {
        // New API
        NSString *source = nil;
        double revenue = -1.0;
        NSString *currency = nil;

        // Source.
        lua_getfield(L, 1, "source");
        if (!lua_isnil(L, 2)) {
            const char *cstrSource = lua_tostring(L, 2);
            if (cstrSource != NULL) {
                source = [NSString stringWithUTF8String:cstrSource];
            }
        }
        lua_pop(L, 1);

        ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:source];

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
            [adRevenue setRevenue:revenue currency:currency];
        }

        // Ad impressions count.
        lua_getfield(L, 1, "adImpressionsCount");
        if (!lua_isnil(L, 2)) {
            [adRevenue setAdImpressionsCount:lua_tointeger(L, 2)];
        }
        lua_pop(L, 1);

        // Ad revenue network.
        lua_getfield(L, 1, "adRevenueNetwork");
        if (!lua_isnil(L, 2)) {
            const char *cstrAdRevenueNetwork = lua_tostring(L, 2);
            if (cstrAdRevenueNetwork != NULL) {
                [adRevenue setAdRevenueNetwork:[NSString stringWithUTF8String:cstrAdRevenueNetwork]];
            }
        }
        lua_pop(L, 1);

        // Ad revenue unit.
        lua_getfield(L, 1, "adRevenueUnit");
        if (!lua_isnil(L, 2)) {
            const char *cstrAdRevenueUnit = lua_tostring(L, 2);
            if (cstrAdRevenueUnit != NULL) {
                [adRevenue setAdRevenueUnit:[NSString stringWithUTF8String:cstrAdRevenueUnit]];
            }
        }
        lua_pop(L, 1);

        // Ad revenue placement.
        lua_getfield(L, 1, "adRevenuePlacement");
        if (!lua_isnil(L, 2)) {
            const char *cstrAdRevenuePlacement = lua_tostring(L, 2);
            if (cstrAdRevenuePlacement != NULL) {
                [adRevenue setAdRevenuePlacement:[NSString stringWithUTF8String:cstrAdRevenuePlacement]];
            }
        }
        lua_pop(L, 1);

        // Callback parameters.
        lua_getfield(L, 1, "callbackParameters");
        if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
            NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
            for (id key in dict) {
                NSDictionary *callbackParams = [dict objectForKey:key];
                [adRevenue addCallbackParameter:callbackParams[@"key"] value:callbackParams[@"value"]];
            }
        }
        lua_pop(L, 1);

        // Partner parameters.
        lua_getfield(L, 1, "partnerParameters");
        if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
            NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
            for(id key in dict) {
                NSDictionary *partnerParams = [dict objectForKey:key];
                [adRevenue addPartnerParameter:partnerParams[@"key"] value:partnerParams[@"value"]];
            }
        }
        lua_pop(L, 1);

        [Adjust trackAdRevenue:adRevenue];
    return 0;
}

// Public API.
int AdjustPlugin::addGlobalCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addGlobalCallbackParameter:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::addGlobalPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    if (key != NULL && value != NULL) {
        [Adjust addGlobalPartnerParameter:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::removeGlobalCallbackParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeGlobalCallbackParameterForKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::removeGlobalPartnerParameter(lua_State *L) {
    const char *key = lua_tostring(L, 1);
    if (key != NULL) {
        [Adjust removeGlobalPartnerParameterForKey:[NSString stringWithUTF8String:key]];
    }
    return 0;
}

// Public API.
int AdjustPlugin::removeGlobalCallbackParameters(lua_State *L) {
    [Adjust removeGlobalCallbackParameters];
    return 0;
}

// Public API.
int AdjustPlugin::removeGlobalPartnerParameters(lua_State *L) {
    [Adjust removeGlobalPartnerParameters];
    return 0;
}

// Public API.
int AdjustPlugin::switchToOfflineMode(lua_State *L) {
    [Adjust switchToOfflineMode];
    return 0;
}

// Public API.
int AdjustPlugin::switchBackToOnlineMode(lua_State *L) {
    [Adjust switchBackToOnlineMode];
    return 0;
}

// Public API.
int AdjustPlugin::isEnabled(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust isEnabledWithCompletionHandler:^(BOOL isEnabled) {
            NSString *result = isEnabled ? @"true" : @"false";
            [AdjustSdkDelegate dispatchEvent:EVENT_IS_ENABLED withState:L callback:listener andMessage:result];
        }];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getIdfa(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust idfaWithCompletionHandler:^(NSString * _Nullable idfa) {
            if (nil == idfa) {
                idfa = @"";
            }
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_IDFA withState:L callback:listener andMessage:idfa];
        }];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getSdkVersion(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust sdkVersionWithCompletionHandler:^(NSString * _Nullable sdkVersion) {
            if (sdkVersion == nil) {
                sdkVersion = @"";
            }
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_SDK_VERSION withState:L callback:listener andMessage:[NSString stringWithFormat:@"%@@%@", SDK_PREFIX, sdkVersion]];
        }];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAttribution(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
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
                [AdjustSdkDelegate addKey:@"costAmount" andValue:[attribution.costAmount stringValue] toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"costCurrency" andValue:attribution.costCurrency toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"fbInstallReferrer" andValue:nil toDictionary:dictionary];
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
        }];
        

        
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAdid(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust adidWithCompletionHandler:^(NSString * _Nullable adid) {
            if (nil == adid) {
                adid = @"";
            }
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_ADID withState:L callback:listener andMessage:adid];
        }];
    }
    return 0;
}

// Public API.
int AdjustPlugin::gdprForgetMe(lua_State *L) {
    [Adjust gdprForgetMe];
    return 0;
}


// Public API.
int AdjustPlugin::requestAppTrackingAuthorization(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
            NSString *strStatus = [NSString stringWithFormat:@"%zd", status];
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_AUTHORIZATION_STATUS withState:L callback:listener andMessage:strStatus];
        }];
    }
    return 0;
}

// Public API.
int AdjustPlugin::getAppTrackingAuthorizationStatus(lua_State *L) {
    int status = [Adjust appTrackingAuthorizationStatus];
    lua_pushinteger(L, status);
    return 1;
}

// Public API.
int AdjustPlugin::updateSkanConversionValue(lua_State *L) {
        NSInteger conversionValue = lua_tointeger(L, 1);
        const char* coarseValue = lua_tostring(L, 2);
        BOOL lockWindow = lua_toboolean(L, 3);
        int listenerIndex = 4;
        if (coarseValue != NULL) {
            if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
                CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
                [Adjust updatePostbackConversionValue:conversionValue
                                          coarseValue:[NSString stringWithUTF8String:coarseValue]
                                           lockWindow:lockWindow
                                    completionHandler:^(NSError * _Nullable error) {
                    [AdjustSdkDelegate dispatchEvent:EVENT_UPDATE_SKAN_CONVERSION_VALUE
                                           withState:L
                                            callback:listener
                                          andMessage:[error localizedDescription]];
                }];
            }
        }
        return 0;
}

// Public API.
int AdjustPlugin::verifyAppStorePurchase(lua_State *L) {
    const char* receipt = lua_tostring(L, 1);
    const char* transactionId = lua_tostring(L, 2);
    const char* productId = lua_tostring(L, 3);
    
    // create purchase instance
    ADJAppStorePurchase *purchase = [[ADJAppStorePurchase alloc] initWithTransactionId:[NSString stringWithUTF8String:transactionId]
                                                                             productId:[NSString stringWithUTF8String:productId]];
    int listenerIndex = 4;
    if (purchase != NULL) {
        if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
            CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
            
            [Adjust verifyAppStorePurchase:purchase
                     withCompletionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                if (nil != verificationResult) {
                    [AdjustSdkDelegate addKey:@"verificationStatus" andValue:verificationResult.verificationStatus toDictionary:dictionary];
                    [AdjustSdkDelegate addKey:@"code" andValue:[NSString stringWithFormat:@"%d", verificationResult.code] toDictionary:dictionary];
                    [AdjustSdkDelegate addKey:@"message" andValue:verificationResult.message toDictionary:dictionary];
\
                    NSError *error;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                       options:NSJSONWritingPrettyPrinted
                                                                         error:&error];
                    if (!jsonData) {
                        NSLog(@"[Adjust][bridge]: Error while trying to convert attribution dictionary to JSON string: %@", error);
                    } else {
                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_APP_STORE_PURCHASE_CALLBACK withState:L callback:listener andMessage:jsonString];
                    }
                }
            }];
        }
    }
    return 0;
}

// Verify and track AppStore purchase
int AdjustPlugin::verifyAndTrackAppStorePurchase(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }

    double revenue = -1.0;
    NSString *currency = nil;
    NSString *eventToken = nil;
    NSString *transactionId = nil;
    NSString *deduplicationId = nil;
    NSString *productId = nil;
    NSString *callbackId = nil;

    // Event token.
    lua_getfield(L, 1, "eventToken");
    if (!lua_isnil(L, 2)) {
        const char *cstrEventToken = lua_tostring(L, 2);
        if (cstrEventToken != NULL) {
            eventToken = [NSString stringWithUTF8String:cstrEventToken];
        }
    }
    lua_pop(L, 1);

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:eventToken];

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

    // Callback ID.
    lua_getfield(L, 1, "callbackId");
    if (!lua_isnil(L, 2)) {
        const char *cstrCallbackId = lua_tostring(L, 2);
        if (cstrCallbackId != NULL) {
            callbackId = [NSString stringWithUTF8String:cstrCallbackId];
        }
        [event setCallbackId:callbackId];
    }
    lua_pop(L, 1);

    // Deduplication ID.
    lua_getfield(L, 1, "deduplicationId");
    if (!lua_isnil(L, 2)) {
        const char *cstrDeduplicationId = lua_tostring(L, 2);
        if (cstrDeduplicationId != NULL) {
            deduplicationId = [NSString stringWithUTF8String:cstrDeduplicationId];
        }
        [event setDeduplicationId:deduplicationId];
    }
    lua_pop(L, 1);

    // Prdouction ID.
    lua_getfield(L, 1, "productId");
    if (!lua_isnil(L, 2)) {
        const char *cstrProductId = lua_tostring(L, 2);
        if (cstrProductId != NULL) {
            productId = [NSString stringWithUTF8String:cstrProductId];
        }
        [event setProductId:productId];
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
    
    lua_getfield(L, 1, "listener");
    int listenerIndex = 2;
    
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        
        
        [Adjust verifyAndTrackAppStorePurchase:event withCompletionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
            
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            if (nil != verificationResult) {
                [AdjustSdkDelegate addKey:@"verificationStatus" andValue:verificationResult.verificationStatus toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"code" andValue:[NSString stringWithFormat:@"%d", verificationResult.code] toDictionary:dictionary];
                [AdjustSdkDelegate addKey:@"message" andValue:verificationResult.message toDictionary:dictionary];
                
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:&error];
                if (!jsonData) {
                    NSLog(@"[Adjust][bridge]: Error while trying to convert attribution dictionary to JSON string: %@", error);
                } else {
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSLog(@"ADJUSTVERIFY %@", jsonString);
                    [AdjustSdkDelegate dispatchEvent:EVENT_VERIFY_AND_TRACK_APP_STORE_PURCHASE_CALLBACK withState:L callback:listener andMessage:jsonString];
                }
            }
        }];
    }
    return 0;
}

    

// Public API.
int AdjustPlugin::trackThirdPartySharing(lua_State *L) {
    if (!lua_istable(L, 1)) {
        return 0;
    }

    ADJThirdPartySharing *adjustThirdPartySharing = nil;

    // Enabled.
    lua_getfield(L, 1, "enabled");
    if (!lua_isnil(L, 2)) {
        BOOL enabled = lua_toboolean(L, 2);
        adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:[NSNumber numberWithBool:enabled]];
    } else {
        adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:nil];
    }
    lua_pop(L, 1);

    // Granular options.
    lua_getfield(L, 1, "granularOptions");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *granularOptions = [dict objectForKey:key];
            for (id keySetting in granularOptions) {
                if (![keySetting isEqualToString:@"partnerName"]) {
                    NSLog(@"%@ -- %@ -- %@",granularOptions[@"partnerName"],granularOptions[@"key"],granularOptions[@"value"]);
                    [adjustThirdPartySharing addGranularOption:granularOptions[@"partnerName"]
                                                           key:granularOptions[@"key"]
                                                         value:granularOptions[@"value"]];
                }
            }
        }
    }
    lua_pop(L, 1);

    // Partner sharing settings.
    lua_getfield(L, 1, "partnerSharingSettings");
    if (!lua_isnil(L, 2) && lua_istable(L, 2)) {
        NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
        for (id key in dict) {
            NSDictionary *partnerSharingSettings = [dict objectForKey:key];
            // partnerSharingSettings dictionary contains one KVP whose key is for sure partnerName
            // we need to extract the remaining KVPs and attach them to that partner sharing settings
            for (id keySetting in partnerSharingSettings) {
                if (![keySetting isEqualToString:@"partnerName"]) {
                    [adjustThirdPartySharing addPartnerSharingSetting:partnerSharingSettings[@"partnerName"]
                                                                  key:partnerSharingSettings[@"key"]
                                                                value:[[partnerSharingSettings objectForKey:keySetting] boolValue]];
                }
            }
        }
    }
    lua_pop(L, 1);

    [Adjust trackThirdPartySharing:adjustThirdPartySharing];

    return 0;
}

// Public API.
int AdjustPlugin::trackMeasurementConsent(lua_State *L) {
    BOOL measurementConsent = lua_toboolean(L, 1);
    [Adjust trackMeasurementConsent:measurementConsent];
    return 0;
}

// Public API.
int AdjustPlugin::checkForNewAttStatus(lua_State *L) {
    [Adjust checkForNewAttStatus];
    return 0;
}

// Public API.
int AdjustPlugin::getLastDeeplink(lua_State *L) {
    int listenerIndex = 1;
    if (CoronaLuaIsListener(L, listenerIndex, "ADJUST")) {
        CoronaLuaRef listener = CoronaLuaNewRef(L, listenerIndex);
        [Adjust lastDeeplinkWithCompletionHandler:^(NSURL * _Nullable lastDeeplink) {
            NSString *lastDeeplinkString;
            if (nil != lastDeeplink) {
                lastDeeplinkString = [lastDeeplink absoluteString];
                if (nil == lastDeeplinkString) {
                    lastDeeplinkString = @"";
                }
            } else {
                lastDeeplinkString = @"";
            }
            [AdjustSdkDelegate dispatchEvent:EVENT_GET_LAST_DEEPLINK withState:L callback:listener andMessage:lastDeeplinkString];
        }];
    }
    return 0;
}

// Android specific.
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

// Android specific.
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

// Android specific.
// Public API.
int AdjustPlugin::trackPlayStoreSubscription(lua_State *L) {
    return 0;
}

// Public API.
int AdjustPlugin::setReferrer(lua_State *L) {
    return 0;
}

// Public API.
int AdjustPlugin::verifyPlayStorePurchase(lua_State *L) {
    return 0;
}

// Public API.
int AdjustPlugin::verifyAndTrackPlayStorePurchase(lua_State *L) {
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
    NSMutableDictionary *testOptions = [[NSMutableDictionary alloc] init];

    lua_getfield(L, 1, "baseUrl");
    if (!lua_isnil(L, 2)) {
        const char *baseUrl = lua_tostring(L, 2);
        if (baseUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: baseUrl] forKey:@"baseUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "gdprUrl");
    if (!lua_isnil(L, 2)) {
        const char *gdprUrl = lua_tostring(L, 2);
        if (gdprUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: gdprUrl] forKey:@"gdprUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "subscriptionUrl");
    if (!lua_isnil(L, 2)) {
        const char *subscriptionUrl = lua_tostring(L, 2);
        if (subscriptionUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: subscriptionUrl] forKey:@"subscriptionUrl"];
        }
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "purchaseVerificationUrl");
    if (!lua_isnil(L, 2)) {
        const char *purchaseVerificationUrl = lua_tostring(L, 2);
        if (purchaseVerificationUrl != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: purchaseVerificationUrl] forKey:@"purchaseVerificationUrl"];
        }
    }
    lua_pop(L, 1);
    
    lua_getfield(L, 1, "urlOverwrite");
    if (!lua_isnil(L, 2)) {
        const char *urlOverwrite = lua_tostring(L, 2);
        if (urlOverwrite != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: urlOverwrite] forKey:@"testUrlOverwrite"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "extraPath");
    if (!lua_isnil(L, 2)) {
        const char *extraPath = lua_tostring(L, 2);
        if (extraPath != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: extraPath] forKey:@"extraPath"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "basePath");
    if (!lua_isnil(L, 2)) {
        const char *basePath = lua_tostring(L, 2);
        if (basePath != NULL) {
            [testOptions setObject:[NSString stringWithUTF8String: basePath] forKey:@"basePath"];
        }
    }
    lua_pop(L, 1);
   
    lua_getfield(L, 1, "timerIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:timerIntervalInMilliseconds] forKey:@"timerIntervalInMilliseconds"];
    }
    lua_pop(L, 1);
    
   
    lua_getfield(L, 1, "timerStartInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger timerStartInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:timerStartInMilliseconds] forKey:@"timerStartInMilliseconds"];
    }
    lua_pop(L, 1);


    lua_getfield(L, 1, "sessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger sessionIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:sessionIntervalInMilliseconds] forKey:@"sessionIntervalInMilliseconds"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "subsessionIntervalInMilliseconds");
    if (!lua_isnil(L, 2)) {
        NSUInteger subsessionIntervalInMilliseconds = lua_tointeger(L, 2);
        [testOptions setObject:[NSNumber numberWithInteger:subsessionIntervalInMilliseconds] forKey:@"subsessionIntervalInMilliseconds"];
    }
    lua_pop(L, 1);

    lua_getfield(L, 1, "teardown");
    if (!lua_isnil(L, 2)) {
        BOOL teardown = lua_toboolean(L, 2);
        [testOptions setObject:[NSNumber numberWithBool:teardown] forKey:@"teardown"];
        if([testOptions[@"teardown"] isEqualToNumber:@1] == YES) {
           NSLog(@"[Adjust][bridge]: AdjustSdkDelegate callbacks teardown.");
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

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_adjust(lua_State *L) {
    return AdjustPlugin::Open(L);
}
