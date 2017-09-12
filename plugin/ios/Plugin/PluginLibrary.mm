
//
//  PluginLibrary.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PluginLibrary.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
#import "Adjust.h"
#import "AdjustSdkDelegate.h"


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

  public:
    CoronaLuaRef GetAttributionChangedListener() const { return attributionChangedListener; }
    CoronaLuaRef GetEventTrackingSucceededListener() const { return eventTrackingSucceededListener; }
    CoronaLuaRef GetEventTrackingFailedListener() const { return eventTrackingFailedListener; }
    CoronaLuaRef GetSessionTrackingSucceededListener() const { return sessionTrackingSucceededListener; }
    CoronaLuaRef GetSessionTrackingFailedListener() const { return sessionTrackingFailedListener; }
    CoronaLuaRef GetDeferredDeeplinkListener() const { return deferredDeeplinkListener; }

  public:
    static int Open( lua_State *L );

  protected:
    static int Finalizer( lua_State *L );

  public:
    static Self *ToLibrary( lua_State *L );

  public:
    static int create( lua_State *L );
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
  deferredDeeplinkListener( NULL )
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
    { "setAttributionListener", setAttributionListener },
    { "setEventTrackingSucceededListener", setEventTrackingSucceededListener },
    { "setEventTrackingFailedListener", setEventTrackingFailedListener },
    { "setSessionTrackingSucceededListener", setSessionTrackingSucceededListener },
    { "setSessionTrackingFailedListener", setSessionTrackingFailedListener },
    { "setDeferredDeeplinkListener", setDeferredDeeplinkListener },

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

// [Lua] library.init( listener )
//  int
//PluginLibrary::init( lua_State *L )
//{
//  int listenerIndex = 1;
//
//  if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
//  {
//    Self *library = ToLibrary( L );
//
//    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
//    library->InitializeAttributionListener( listener );
//  }
//
//  return 0;
//}

// [Lua] library.show( word )
//  int
//PluginLibrary::show( lua_State *L )
//{
//  NSString *message = @"Error: Could not display UIReferenceLibraryViewController. This feature requires iOS 5 or later.";
//
//  if ( [UIReferenceLibraryViewController class] )
//  {
//    id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
//
//    const char kDefaultWord[] = "corona";
//    const char *word = lua_tostring( L, 1 );
//    if ( ! word )
//    {
//      word = kDefaultWord;
//    }
//
//    UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:[NSString stringWithUTF8String:word]] autorelease];
//
//    // Present the controller modally.
//    [runtime.appViewController presentViewController:controller animated:YES completion:nil];
//
//    message = @"Success. Displaying UIReferenceLibraryViewController for 'corona'.";
//  }
//
//  Self *library = ToLibrary( L );
//
//  // Create event and add message to it
//  CoronaLuaNewEvent( L, kEvent );
//  lua_pushstring( L, [message UTF8String] );
//  lua_setfield( L, -2, "message" );
//
//  // Dispatch event to library's listener
//  CoronaLuaDispatchEvent( L, library->GetAttributionChangedListener(), 0 );
//
//  return 0;
//}

  int
PluginLibrary::create( lua_State *L )
{
  NSString *logLevel = nil;
  BOOL allowSuppressLogLevel = NO;
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
    logLevel = [NSString stringWithUTF8String:logLevel_char];
    if([[logLevel uppercaseString] isEqualToString:@"SUPPRESS"]) {
      allowSuppressLogLevel = YES;
    }
  }
  lua_pop(L, 1);
  NSLog(@"logLevel: %@", logLevel);
  NSLog(@"logLevel: %d", allowSuppressLogLevel);

  //AppToken
  lua_getfield(L, 1, "appToken");
  if(!lua_isnil(L, 2)) {
    const char *appToken_char = lua_tostring(L, 2);
    appToken = [NSString stringWithUTF8String:appToken_char];
  }
  lua_pop(L, 1);
  NSLog(@"appToken: %@", appToken);

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

  NSLog(@"environment: %@", environment);

  lua_pop(L, 1);

  ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
    environment:environment
    allowSuppressLogLevel:allowSuppressLogLevel];

  if(![adjustConfig isValid]) {
    NSLog(@"adjust config is not working");
    return 0;
  }

  // Log level
  if (nil != logLevel) {
    if (NO == allowSuppressLogLevel) {
      [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
    } else {
      [adjustConfig setLogLevel:ADJLogLevelSuppress];
    }
  }

  //Event Buffering Enabled
  lua_getfield(L, 1, "eventBufferingEnabled");
  if (!lua_isnil(L, 2)) {
    eventBufferingEnabled = lua_toboolean(L, 2);
    [adjustConfig setEventBufferingEnabled:eventBufferingEnabled];
  }
  lua_pop(L, 1);
  NSLog(@"eventBuffering: %d", eventBufferingEnabled);

  //Sdk prefix
  lua_getfield(L, 1, "sdkPrefix");
  if (!lua_isnil(L, 2)) {
    const char *sdkPrefix_char = lua_tostring(L, 2);
    sdkPrefix = [NSString stringWithUTF8String:sdkPrefix_char];
    [adjustConfig setSdkPrefix:sdkPrefix];
  }
  lua_pop(L, 1);
  NSLog(@"sdkPRefix: %@", sdkPrefix);

  // Default tracker
  lua_getfield(L, 1, "defaultTracker");
  if (!lua_isnil(L, 2)) {
    const char *defaultTracker_char = lua_tostring(L, 2);
    defaultTracker = [NSString stringWithUTF8String:defaultTracker_char];
    [adjustConfig setDefaultTracker:defaultTracker];
  }
  lua_pop(L, 1);
  NSLog(@"defaultTracker: %@", defaultTracker);

  // User agent
  lua_getfield(L, 1, "userAgent");
  if (!lua_isnil(L, 2)) {
    const char *userAgent_char = lua_tostring(L, 2);
    userAgent = [NSString stringWithUTF8String:userAgent_char];
    [adjustConfig setUserAgent:userAgent];
  }
  lua_pop(L, 1);
  NSLog(@"userAgent: %@", userAgent);

  //Send in background
  lua_getfield(L, 1, "sendInBackground");
  if (!lua_isnil(L, 2)) {
    sendInBackground = lua_toboolean(L, 2);
    [adjustConfig setSendInBackground:sendInBackground];
  }
  lua_pop(L, 1);
  NSLog(@"sendInBackground: %d", sendInBackground);

  // Launching deferred deep link
  lua_getfield(L, 1, "shouldLaunchDeeplink");
  BOOL shouldLaunchDeferredDeeplink = NO;
  if (!lua_isnil(L, 2)) {
    shouldLaunchDeferredDeeplink = lua_toboolean(L, 2);
  }
  lua_pop(L, 1);
  NSLog(@"shouldLaunchDeeplink: %d", shouldLaunchDeferredDeeplink);

  // Delay start
  lua_getfield(L, 1, "delayStart");
  if (!lua_isnil(L, 2)) {
    delayStart = lua_tonumber(L, 2);
    [adjustConfig setDelayStart:delayStart];
  }
  lua_pop(L, 1);
  NSLog(@"delayStart: %f", delayStart);

  Self *library = ToLibrary( L );
  BOOL isAttributionChangedListenerImplmented = library->GetAttributionChangedListener() != NULL;
  BOOL isEventTrackingSucceededListenerImplmented = library->GetEventTrackingSucceededListener() != NULL;
  BOOL isEventTrackingFailedListenerImplmented = library->GetEventTrackingFailedListener() != NULL;
  BOOL isSessionTrackingSucceededListenerImplmented = library->GetSessionTrackingSucceededListener() != NULL;
  BOOL isSessionTrackingFailedListenerImplmented = library->GetSessionTrackingFailedListener() != NULL;
  BOOL isDeferredDeeplinkListenerImplemented = library->GetDeferredDeeplinkListener() != NULL;
  NSLog(@"isAttributionImplemented: %d", isAttributionChangedListenerImplmented);
  NSLog(@"isEventTrackingSucceededListenerImplmented: %d", isEventTrackingSucceededListenerImplmented);
  NSLog(@"isEventTrackingFailedListenerImplmented: %d", isEventTrackingFailedListenerImplmented);
  NSLog(@"isSessionTrackingSucceededListenerImplmented: %d", isSessionTrackingSucceededListenerImplmented);
  NSLog(@"isSessionTrackingFailedListenerImplmented: %d", isSessionTrackingFailedListenerImplmented);
  NSLog(@"isDeferredDeeplink: %d", isDeferredDeeplinkListenerImplemented);

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

  //  if ( [UIReferenceLibraryViewController class] )
  //  {
  //    id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );
  //
  //    const char kDefaultWord[] = "corona";
  //    const char *word = lua_tostring( L, 1 );
  //    if ( ! word )
  //    {
  //      word = kDefaultWord;
  //    }
  //
  //    UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:[NSString stringWithUTF8String:word]] autorelease];
  //
  //    // Present the controller modally.
  //    [runtime.appViewController presentViewController:controller animated:YES completion:nil];
  //
  //    message = @"Success. Displaying UIReferenceLibraryViewController for 'corona'.";
  //  }
  //
  //  Self *library = ToLibrary( L );
  //
  //  // Create event and add message to it
  //  CoronaLuaNewEvent( L, kEvent );
  //  lua_pushstring( L, [message UTF8String] );
  //  lua_setfield( L, -2, "message" );
  //
  //  // Dispatch event to library's listener
  //  CoronaLuaDispatchEvent( L, library->GetAttributionChangedListener(), 0 );

  return 0;
}

  int
PluginLibrary::setAttributionListener( lua_State *L )
{
  NSLog(@"setAttronitionListener");
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

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_adjust( lua_State *L )
{
  return PluginLibrary::Open( L );
}
