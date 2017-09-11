//
//  PluginLibrary.mm
//  TemplateApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PluginLibrary.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>
#import <AdjustSdk/Adjust.h>


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
    bool Initialize( CoronaLuaRef listener );

  public:
    CoronaLuaRef GetListener() const { return fListener; }

  public:
    static int Open( lua_State *L );

  protected:
    static int Finalizer( lua_State *L );

  public:
    static Self *ToLibrary( lua_State *L );

  public:
    static int init( lua_State *L );
    static int show( lua_State *L );
    static int create( lua_State *L );

  private:
    CoronaLuaRef fListener;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char PluginLibrary::kName[] = "plugin.adjust";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginLibrary::kEvent[] = "AdjustListener";

PluginLibrary::PluginLibrary()
  :	fListener( NULL )
{
}

  bool
PluginLibrary::Initialize( CoronaLuaRef listener )
{
  // Can only initialize listener once
  bool result = ( NULL == fListener );

  if ( result )
  {
    fListener = listener;
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
    { "init", init },
    { "show", show },
    { "create", create },

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

  CoronaLuaDeleteRef( L, library->GetListener() );

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
  int
PluginLibrary::init( lua_State *L )
{
  int listenerIndex = 1;

  if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
  {
    Self *library = ToLibrary( L );

    CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
    library->Initialize( listener );
  }

  return 0;
}

// [Lua] library.show( word )
  int
PluginLibrary::show( lua_State *L )
{
  NSString *message = @"Error: Could not display UIReferenceLibraryViewController. This feature requires iOS 5 or later.";

  if ( [UIReferenceLibraryViewController class] )
  {
    id<CoronaRuntime> runtime = (id<CoronaRuntime>)CoronaLuaGetContext( L );

    const char kDefaultWord[] = "corona";
    const char *word = lua_tostring( L, 1 );
    if ( ! word )
    {
      word = kDefaultWord;
    }

    UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:[NSString stringWithUTF8String:word]] autorelease];

    // Present the controller modally.
    [runtime.appViewController presentViewController:controller animated:YES completion:nil];

    message = @"Success. Displaying UIReferenceLibraryViewController for 'corona'.";
  }

  Self *library = ToLibrary( L );

  // Create event and add message to it
  CoronaLuaNewEvent( L, kEvent );
  lua_pushstring( L, [message UTF8String] );
  lua_setfield( L, -2, "message" );

  // Dispatch event to library's listener
  CoronaLuaDispatchEvent( L, library->GetListener(), 0 );

  return 0;
}

  int
PluginLibrary::create( lua_State *L )
{
  NSString *logLevel = nil;
  BOOL allowSuppressLogLevel = NO;
  NSString *appToken = nil;
  NSString *environment = nil;
  NSString * defaultTracker = nil;
  NSString * processName = nil;
  NSString * sdkPrefix = nil;
  BOOL eventBufferingEnabled = NO;
  NSString * userAgent = nil;
  BOOL sendInBackground = NO;
  NSNumber* delayStart;

  if(lua_istable(L, 1)) {
    //log level
    lua_getfield(L, 1, "logLevel");
    if(!lua_isnil(L, 2)) {
      const char *logLevel_char = luaL_checkstring(L, 2);
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
      const char *appToken_char = luaL_checkstring(L, 2);
      appToken = [NSString stringWithUTF8String:appToken_char];
    }
    lua_pop(L, 1);
    NSLog(@"appToken: %@", appToken);

    //Environment
    lua_getfield(L, 1, "environment");
    if(!lua_isnil(L, 2)) {
      const char *environment_char = luaL_checkstring(L, 2);
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
        [adjustConfig setLogLevel:[ADJLogger LogLevelFromString:[logLevel lowercaseString]]];
      } else {
        [adjustConfig setLogLevel:ADJLogLevelSuppress];
      }
    }

    //AppToken
    //lua_getfield(L, 1, "appToken");
    //if (!lua_isnil(L, 2)) {
      //const char *appToken_char = luaL_checkstring(L, 2);
      //appToken = [NSString stringWithUTF8String:appToken_char];
    //}
    //lua_pop(L, 1);

    //Event Buffering Enabled
    lua_getfield(L, 1, "eventBufferingEnabled");
    if (!lua_isnil(L, 2)) {
      eventBufferingEnabled = lua_toboolean(L, 2);
      [adjustConfig setEventBufferingEnabled:eventBufferingEnabled];
    }
    lua_pop(L, 1);
    NSLog(@"eventBuffering: %d", eventBufferingEnabled);

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
  //  CoronaLuaDispatchEvent( L, library->GetListener(), 0 );

  return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_plugin_adjust( lua_State *L )
{
  return PluginLibrary::Open( L );
}
