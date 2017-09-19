//
//  PluginLibrary.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PluginLibrary.h"

#include <CoronaRuntime.h>
#include "CoronaLuaIOS.h"
#import <UIKit/UIKit.h>
#import "Adjust.h"
#import "AdjustSdkDelegate.h"

#define EVENT_IS_ADJUST_ENABLED @"adjust_isEnabled"
#define EVENT_GET_IDFA @"adjust_getAttribution"
#define EVENT_GET_ATTRIBUTION @"adjust_getAttribution"
#define EVENT_GET_ADID @"adjust_getAdid"
#define EVENT_GET_GOOGLEADID @"adjust_getGoogleAdid"
#define EVENT_GET_AMAZONADID @"adjust_getAmazonAdid"

// ----------------------------------------------------------------------------

class PluginLibrary
{
  public:
    typedef PluginLibrary Self;

  public:
    static const char kName[];
    static const char kEvent[];

  protected:
    PluginLibrary();

  public:
    bool InitializeAttributionListener( CoronaLuaRef listener );
    bool InitializeEventTrackingSucceededListener( CoronaLuaRef listener );
    bool InitializeEventTrackingFailedListener( CoronaLuaRef listener );
    bool InitializeSessionTrackingSucceededListener( CoronaLuaRef listener );
    bool InitializeSessionTrackingFailedListener( CoronaLuaRef listener );
    bool InitializeDeferredDeeplinkListener( CoronaLuaRef listener );

    bool InitializeIsEnabledListener( CoronaLuaRef listener );
    bool InitializeGetIdfaListener( CoronaLuaRef listener );
    bool InitializeGetAttributionListener( CoronaLuaRef listener );
    bool InitializeGetAdidListener( CoronaLuaRef listener );
    bool InitializeGetGoogleAdidListener( CoronaLuaRef listener );
    bool InitializeGetAmazonAdidListener( CoronaLuaRef listener );

  public:
    CoronaLuaRef GetAttributionChangedListener() const { return attributionChangedListener; }
    CoronaLuaRef GetEventTrackingSucceededListener() const { return eventTrackingSucceededListener; }
    CoronaLuaRef GetEventTrackingFailedListener() const { return eventTrackingFailedListener; }
    CoronaLuaRef GetSessionTrackingSucceededListener() const { return sessionTrackingSucceededListener; }
    CoronaLuaRef GetSessionTrackingFailedListener() const { return sessionTrackingFailedListener; }
    CoronaLuaRef GetDeferredDeeplinkListener() const { return deferredDeeplinkListener; }

    CoronaLuaRef GetisEnabledListener() const { return isEnabledListener; }
    CoronaLuaRef GetgetIdfaListener() const { return getIdfaListener; }
    CoronaLuaRef GetgetAttributionListener() const { return getAttributionListener; }
    CoronaLuaRef GetgetAdidListener() const { return getAdidListener; }
    CoronaLuaRef GetgetGoogleAdidListener() const { return getGoogleAdidListener; }
    CoronaLuaRef GetgetAmazonAdidListener() const { return getAmazonAdidListener; }

  public:
    static int Open( lua_State *L );

  protected:
    static int Finalizer( lua_State *L );

  public:
    static Self *ToLibrary( lua_State *L );

  public:
    static int create( lua_State *L );
    static int trackEvent( lua_State *L );
    static int setEnabled( lua_State *L );
    static int setPushToken( lua_State *L );
    static int appWillOpenUrl( lua_State *L );
    static int sendFirstPackages( lua_State *L );
    static int addSessionCallbackParameter( lua_State *L );
    static int addSessionPartnerParameter( lua_State *L );
    static int removeSessionCallbackParameter( lua_State *L );
    static int removeSessionPartnerParameter( lua_State *L );
    static int resetSessionCallbackParameters( lua_State *L );
    static int resetSessionPartnerParameters( lua_State *L );
    static int setOfflineMode( lua_State *L );
    static int isEnabled( lua_State *L );
    static int getIdfa( lua_State *L );
    static int getAttribution( lua_State *L );
    static int getAdid( lua_State *L );
    static int getGoogleAdid( lua_State *L );
    static int getAmazonAdid( lua_State *L );

    static int setAttributionListener( lua_State *L );
    static int setEventTrackingSucceededListener( lua_State *L );
    static int setEventTrackingFailedListener( lua_State *L );
    static int setSessionTrackingSucceededListener( lua_State *L );
    static int setSessionTrackingFailedListener( lua_State *L );
    static int setDeferredDeeplinkListener( lua_State *L );

  private:
    CoronaLuaRef attributionChangedListener;
    CoronaLuaRef eventTrackingSucceededListener;
    CoronaLuaRef eventTrackingFailedListener;
    CoronaLuaRef sessionTrackingSucceededListener;
    CoronaLuaRef sessionTrackingFailedListener;
    CoronaLuaRef deferredDeeplinkListener;

    CoronaLuaRef isEnabledListener;
    CoronaLuaRef getIdfaListener;
    CoronaLuaRef getAttributionListener;
    CoronaLuaRef getAdidListener;
    CoronaLuaRef getGoogleAdidListener;
    CoronaLuaRef getAmazonAdidListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginLibrary::kName[] = "plugin.adjust";

PluginLibrary::PluginLibrary()
  :	attributionChangedListener( NULL ),
  eventTrackingSucceededListener( NULL ),
  eventTrackingFailedListener( NULL ),
  sessionTrackingSucceededListener( NULL ),
  sessionTrackingFailedListener( NULL ),
  deferredDeeplinkListener( NULL ),
  isEnabledListener( NULL ),
  getIdfaListener( NULL ),
  getAttributionListener( NULL ),
  getAdidListener( NULL ),
  getGoogleAdidListener( NULL ),
  getAmazonAdidListener( NULL )
{
}

  bool
PluginLibrary::InitializeAttributionListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == attributionChangedListener );

  if ( result )
  {
    attributionChangedListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeEventTrackingSucceededListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == eventTrackingSucceededListener );

  if ( result )
  {
    eventTrackingSucceededListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeEventTrackingFailedListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == eventTrackingFailedListener );

  if ( result )
  {
    eventTrackingFailedListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeSessionTrackingSucceededListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == sessionTrackingSucceededListener );

  if ( result )
  {
    sessionTrackingSucceededListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeSessionTrackingFailedListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == sessionTrackingFailedListener );

  if ( result )
  {
    sessionTrackingFailedListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeDeferredDeeplinkListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == deferredDeeplinkListener );

  if ( result )
  {
    deferredDeeplinkListener = listener;
  }

  return result;
}


  bool
PluginLibrary::InitializeIsEnabledListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == isEnabledListener );

  if ( result )
  {
    isEnabledListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeGetIdfaListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == getIdfaListener );

  if ( result )
  {
    getIdfaListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeGetAttributionListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == getAttributionListener );

  if ( result )
  {
    getAttributionListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeGetAdidListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == getAdidListener );

  if ( result )
  {
    getAdidListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeGetGoogleAdidListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == getGoogleAdidListener );

  if ( result )
  {
    getGoogleAdidListener = listener;
  }

  return result;
}

  bool
PluginLibrary::InitializeGetAmazonAdidListener( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == getAmazonAdidListener );

  if ( result )
  {
    getAmazonAdidListener = listener;
  }

  return result;
}

  int
PluginLibrary::Open( lua_State *L )
{
  // Register __gc callback
  const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
  CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );

  // Functions in library
  const luaL_Reg kVTable[] =
  {
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
    { "setEventTrackingSucceededListener", setEventTrackingSucceededListener },
    { "setEventTrackingFailedListener", setEventTrackingFailedListener },
    { "setSessionTrackingSucceededListener", setSessionTrackingSucceededListener },
    { "setSessionTrackingFailedListener", setSessionTrackingFailedListener },
    { "setDeferredDeeplinkListener", setDeferredDeeplinkListener },
    { "isEnabled", isEnabled },
    { "getIdfa", getIdfa },
    { "getAttribution", getAttribution },
    { "getAdid", getAdid },
    { "getGoogleAdid", getGoogleAdid },
    { "getAmazonAdid", getAmazonAdid },

    { NULL, NULL }
  };

  // Set library as upvalue for each library function
  Self *library = new Self;
  CoronaLuaPushUserdata( L, library, kMetatableName );

  luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack

  return 1;
}

  int
PluginLibrary::Finalizer( lua_State *L )
{
  Self *library = (Self *)CoronaLuaToUserdata( L, 1 );

  CoronaLuaDeleteRef( L, library->GetAttributionChangedListener() );

  delete library;

  return 0;
}

  PluginLibrary *
PluginLibrary::ToLibrary( lua_State *L )
{
  // library is pushed as part of the closure
  Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
  return library;
}

  int
PluginLibrary::create( lua_State *L )
{
  ADJLogLevel logLevel = ADJLogLevelInfo;
  NSString *appToken = nil;
  NSString *environment = nil;
  NSString * defaultTracker = nil;
  NSString * sdkPrefix = nil;
  BOOL eventBufferingEnabled = NO;
  NSString * userAgent = nil;
  BOOL sendInBackground = NO;
  double delayStart = 0.0;

  if(!lua_istable(L, 1)) {
    return 0;
  }
  //log level
  lua_getfield(L, 1, "logLevel");
  if(!lua_isnil(L, 2)) {
    const char *logLevel_char = lua_tostring(L, 2);
    logLevel = [ADJLogger logLevelFromString:[NSString stringWithUTF8String:logLevel_char]];
  }
  lua_pop(L, 1);

  //AppToken
  lua_getfield(L, 1, "appToken");
  if(!lua_isnil(L, 2)) {
    const char *appToken_char = lua_tostring(L, 2);
    appToken = [NSString stringWithUTF8String:appToken_char];
  }
  lua_pop(L, 1);

  //Environment
  lua_getfield(L, 1, "environment");
  if(!lua_isnil(L, 2)) {
    const char *environment_char = lua_tostring(L, 2);
    environment = [NSString stringWithUTF8String:environment_char];

    if([[environment uppercaseString] isEqualToString:@"SANDBOX"]) {
      environment = ADJEnvironmentSandbox;
    } else if([[environment uppercaseString] isEqualToString:@"PRODUCTION"]) {
      environment = ADJEnvironmentProduction;
    }
  }

  lua_pop(L, 1);

  ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
    environment:environment
    allowSuppressLogLevel:logLevel == ADJLogLevelSuppress];

  if(![adjustConfig isValid]) {
    return 0;
  }

  // Log level
  [adjustConfig setLogLevel:logLevel];

  //Event Buffering Enabled
  lua_getfield(L, 1, "eventBufferingEnabled");
  if (!lua_isnil(L, 2)) {
    eventBufferingEnabled = lua_toboolean(L, 2);
    [adjustConfig setEventBufferingEnabled:eventBufferingEnabled];
  }
  lua_pop(L, 1);

  //Sdk prefix
  lua_getfield(L, 1, "sdkPrefix");
  if (!lua_isnil(L, 2)) {
    const char *sdkPrefix_char = lua_tostring(L, 2);
    sdkPrefix = [NSString stringWithUTF8String:sdkPrefix_char];
    [adjustConfig setSdkPrefix:sdkPrefix];
  }
  lua_pop(L, 1);

  // Default tracker
  lua_getfield(L, 1, "defaultTracker");
  if (!lua_isnil(L, 2)) {
    const char *defaultTracker_char = lua_tostring(L, 2);
    defaultTracker = [NSString stringWithUTF8String:defaultTracker_char];
    [adjustConfig setDefaultTracker:defaultTracker];
  }
  lua_pop(L, 1);

  // User agent
  lua_getfield(L, 1, "userAgent");
  if (!lua_isnil(L, 2)) {
    const char *userAgent_char = lua_tostring(L, 2);
    userAgent = [NSString stringWithUTF8String:userAgent_char];
    [adjustConfig setUserAgent:userAgent];
  }
  lua_pop(L, 1);

  //Send in background
  lua_getfield(L, 1, "sendInBackground");
  if (!lua_isnil(L, 2)) {
    sendInBackground = lua_toboolean(L, 2);
    [adjustConfig setSendInBackground:sendInBackground];
  }
  lua_pop(L, 1);

  // Launching deferred deep link
  lua_getfield(L, 1, "shouldLaunchDeeplink");
  BOOL shouldLaunchDeferredDeeplink = NO;
  if (!lua_isnil(L, 2)) {
    shouldLaunchDeferredDeeplink = lua_toboolean(L, 2);
  }
  lua_pop(L, 1);

  // Delay start
  lua_getfield(L, 1, "delayStart");
  if (!lua_isnil(L, 2)) {
    delayStart = lua_tonumber(L, 2);
    [adjustConfig setDelayStart:delayStart];
  }
  lua_pop(L, 1);

  Self *library = ToLibrary( L );
  BOOL isAttributionChangedListenerImplmented = library->GetAttributionChangedListener() != NULL;
  BOOL isEventTrackingSucceededListenerImplmented = library->GetEventTrackingSucceededListener() != NULL;
  BOOL isEventTrackingFailedListenerImplmented = library->GetEventTrackingFailedListener() != NULL;
  BOOL isSessionTrackingSucceededListenerImplmented = library->GetSessionTrackingSucceededListener() != NULL;
  BOOL isSessionTrackingFailedListenerImplmented = library->GetSessionTrackingFailedListener() != NULL;
  BOOL isDeferredDeeplinkListenerImplemented = library->GetDeferredDeeplinkListener() != NULL;

  if(
      isAttributionChangedListenerImplmented ||
      isEventTrackingSucceededListenerImplmented ||
      isEventTrackingFailedListenerImplmented || 
      isSessionTrackingSucceededListenerImplmented || 
      isSessionTrackingFailedListenerImplmented || 
      isDeferredDeeplinkListenerImplemented
    ) {
    [adjustConfig setDelegate:
      [AdjustSdkDelegate getInstanceWithSwizzleOfAttributionChangedListener:library->GetAttributionChangedListener()
        eventTrackingSucceededListener:library->GetEventTrackingSucceededListener()
          eventTrackingFailedListener:library->GetEventTrackingFailedListener()
          sessionTrackingSucceededListener:library->GetSessionTrackingSucceededListener()
          sessionTrackingFailedListener:library->GetSessionTrackingFailedListener()
          deferredDeeplinkListener:library->GetDeferredDeeplinkListener()
          shouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink
          withLuaState:L]];
  }

  [Adjust appDidLaunch:adjustConfig];
  [Adjust trackSubsessionStart];

  return 0;
}

  int
PluginLibrary::trackEvent( lua_State *L )
{
  if(!lua_istable(L, 1)) {
    return 0;
  }

  NSString *eventToken = nil;
  NSString *currency = nil;
  double revenue = 0.0;
  NSString *transactionId = nil;

  //Event Token
  lua_getfield(L, 1, "eventToken");
  if(!lua_isnil(L, 2)) {
    const char *eventToken_char = lua_tostring(L, 2);
    eventToken = [NSString stringWithUTF8String:eventToken_char];
  }
  lua_pop(L, 1);

  ADJEvent *event = [ADJEvent eventWithEventToken:eventToken];

  if(![event isValid]) {
    return 0;
  }

  // Revenue
  lua_getfield(L, 1, "revenue");
  if (!lua_isnil(L, 2)) {
    revenue = lua_tonumber(L, 2);
  }
  lua_pop(L, 1);

  // Currency
  lua_getfield(L, 1, "currency");
  if(!lua_isnil(L, 2)) {
    const char *currency_char = lua_tostring(L, 2);
    currency = [NSString stringWithUTF8String:currency_char];
  }
  lua_pop(L, 1);

  //set revenue and currency if any
  if(currency != nil) {
    [event setRevenue:revenue currency:currency];
  }

  // Transaction ID
  lua_getfield(L, 1, "transactionId");
  if(!lua_isnil(L, 2)) {
    const char *transactionId_char = lua_tostring(L, 2);
    transactionId = [NSString stringWithUTF8String:transactionId_char];
    [event setTransactionId:transactionId];
  }
  lua_pop(L, 1);

  // Callback Parameters
  lua_getfield(L, 1, "callbackParameters");
  if(!lua_isnil(L, 2) && lua_istable(L, 2)) {
    NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
    for(id key in dict) {
      NSDictionary *callbackParams = [dict objectForKey:key];
      [event addCallbackParameter:callbackParams[@"key"] value:callbackParams[@"value"]];
    }
  }

  // Partner Parameters
  lua_getfield(L, 1, "partnerParameters");
  if(!lua_isnil(L, 2) && lua_istable(L, 2)) {
    NSDictionary *dict = CoronaLuaCreateDictionary(L, 2);
    for(id key in dict) {
      NSDictionary *partnerParams = [dict objectForKey:key];
      [event addPartnerParameter:partnerParams[@"key"] value:partnerParams[@"value"]];
    }
  }

  [Adjust trackEvent:event];

  return 0;
}

  int
PluginLibrary::setAttributionListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeAttributionListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setEventTrackingSucceededListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeEventTrackingSucceededListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setEventTrackingFailedListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeEventTrackingFailedListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setSessionTrackingSucceededListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeSessionTrackingSucceededListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setSessionTrackingFailedListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeSessionTrackingFailedListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setDeferredDeeplinkListener( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeDeferredDeeplinkListener( listener );
  }

  return 0;
}

  int
PluginLibrary::setEnabled( lua_State *L )
{
  BOOL enabled = lua_toboolean(L, 1);
  [Adjust setEnabled:enabled];
  return 0;
}

  int
PluginLibrary::setPushToken( lua_State *L )
{
  const char *pushToken = lua_tostring(L, 1);
  NSString *pushToken_ns =[NSString stringWithUTF8String:pushToken];
  [Adjust setDeviceToken:[pushToken_ns dataUsingEncoding:NSUTF8StringEncoding]];
  return 0;
}

  int
PluginLibrary::appWillOpenUrl( lua_State *L )
{
  const char *urlStr = lua_tostring(L, 1);
  NSURL *url = [NSURL URLWithString:[NSString stringWithUTF8String:urlStr]];
  [Adjust appWillOpenUrl:url];
  return 0;
}

  int
PluginLibrary::sendFirstPackages( lua_State *L )
{
  [Adjust sendFirstPackages];
  return 0;
}

  int
PluginLibrary::addSessionCallbackParameter( lua_State *L )
{
  const char *key = lua_tostring(L, 1);
  const char *value = lua_tostring(L, 2);
  [Adjust addSessionCallbackParameter:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
  return 0;
}

  int
PluginLibrary::addSessionPartnerParameter( lua_State *L )
{
  const char *key = lua_tostring(L, 1);
  const char *value = lua_tostring(L, 2);
  [Adjust addSessionPartnerParameter:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
  return 0;
}

  int
PluginLibrary::removeSessionCallbackParameter( lua_State *L )
{
  const char *key = lua_tostring(L, 1);
  [Adjust removeSessionCallbackParameter:[NSString stringWithUTF8String:key]];
  return 0;
}

  int
PluginLibrary::removeSessionPartnerParameter( lua_State *L )
{
  const char *key = lua_tostring(L, 1);
  [Adjust removeSessionPartnerParameter:[NSString stringWithUTF8String:key]];
  return 0;
}

  int
PluginLibrary::resetSessionCallbackParameters( lua_State *L )
{
  [Adjust resetSessionCallbackParameters];
  return 0;
}

  int
PluginLibrary::resetSessionPartnerParameters( lua_State *L )
{
  [Adjust resetSessionPartnerParameters];
  return 0;
}

  int
PluginLibrary::setOfflineMode( lua_State *L )
{
  BOOL enabled = lua_toboolean(L, 1);
  [Adjust setOfflineMode:enabled];
  return 0;
}

  int
PluginLibrary::isEnabled( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeIsEnabledListener( listener );

    BOOL isEnabled = [Adjust isEnabled];
    NSString *result = isEnabled ? @"true" : @"false";
    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetisEnabledListener() withEventName:EVENT_IS_ADJUST_ENABLED withMessage:result];
  }

  return 0;
}

  int
PluginLibrary::getIdfa( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeGetIdfaListener( listener );

    NSString *idfa = [Adjust idfa];
    if (nil == idfa) {
      idfa = @"";
    }

    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetgetIdfaListener() withEventName:EVENT_GET_IDFA withMessage:idfa];
  }

  return 0;
}

  int
PluginLibrary::getAttribution( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeGetAttributionListener( listener );

    //TODO: send JSON
    ADJAttribution *attribution = [Adjust attribution];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (nil != attribution) {
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"trackerToken" value:attribution.trackerToken];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"trackerName" value:attribution.trackerName];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"network" value:attribution.network];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"campaign" value:attribution.campaign];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"creative" value:attribution.creative];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adgroup" value:attribution.adgroup];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"clickLabel" value:attribution.clickLabel];
      [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:attribution.adid];
    }

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetgetAttributionListener() withEventName:EVENT_GET_ATTRIBUTION withMessage:strDict];
  }

  return 0;
}

  int
PluginLibrary::getAdid( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeGetAdidListener( listener );

    NSString *adid = [Adjust adid];
    if (nil == adid) {
      adid = @"";
    }

    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetgetAdidListener() withEventName:EVENT_GET_ADID withMessage:adid];
  }

  return 0;
}

  int
PluginLibrary::getGoogleAdid( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeGetGoogleAdidListener( listener );

    NSString *googleAdid = @"";

    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetgetGoogleAdidListener() withEventName:EVENT_GET_GOOGLEADID withMessage:googleAdid];
  }

  return 0;
}

  int
PluginLibrary::getAmazonAdid( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, "ADJUST" ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->InitializeGetAmazonAdidListener( listener );

    NSString *amazonAdid = @"";

    [AdjustSdkDelegate dispatchEvent:L withListener:library->GetgetAmazonAdidListener() withEventName:EVENT_GET_AMAZONADID withMessage:amazonAdid];
  }

  return 0;
}

// ----------------------------------------------------------------------------
CORONA_EXPORT int luaopen_plugin_adjust( lua_State *L )
{
  return PluginLibrary::Open( L );
}

