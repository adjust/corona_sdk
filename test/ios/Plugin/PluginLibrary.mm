//
//  PluginLibrary.mm
//  TemplateApp
//
//  Created by Srdjan Tubin on August 2018.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import "PluginLibrary.h"
#import "ATLTestLibrary.h"
#import "TestLibCommandExecutor.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>

// ----------------------------------------------------------------------------

class PluginLibrary {
public:
    typedef PluginLibrary Self;
    
public:
    static const char kName[];
    static const char kEvent[];
    
protected:
    PluginLibrary();
    
public:
    bool InitExecuteCommandListener(CoronaLuaRef listener);
    
public:
    CoronaLuaRef GetExecuteCommandListener() const { return executeCommandListener; }
    
public:
    static int Open(lua_State *L);
    
protected:
    static int Finalizer(lua_State *L);
    
public:
    static Self *ToLibrary(lua_State *L);
    
public:
    static int init(lua_State *L);
    static int show(lua_State *L);
    static int initTestLibrary(lua_State *L);
    static int addTest(lua_State *L);
    static int addTestDirectory(lua_State *L);
    static int startTestSession(lua_State *L);
    static int addInfoToSend(lua_State *L);
    static int sendInfoToServer(lua_State *L);
    
private:
    CoronaLuaRef executeCommandListener;
    ATLTestLibrary *testLibrary;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.testlibrary"
const char PluginLibrary::kName[] = "plugin.testlibrary";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginLibrary::kEvent[] = "pluginlibraryevent";

PluginLibrary::PluginLibrary() : executeCommandListener(NULL) { }

bool PluginLibrary::InitExecuteCommandListener( CoronaLuaRef listener )
{
    // Can only initialize listener once
    bool result = ( NULL == executeCommandListener );
    if (result) {
        executeCommandListener = listener;
    }
    
    return result;
}

int PluginLibrary::Open( lua_State *L )
{
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
    
    // Functions in library
    const luaL_Reg kVTable[] = {
        { "init", init },
        { "show", show },
        { "initTestLibrary", initTestLibrary },
        { "addTest", addTest },
        { "addTestDirectory", addTestDirectory },
        { "startTestSession", startTestSession },
        { "addInfoToSend", addInfoToSend },
        { "sendInfoToServer", sendInfoToServer },
        
        { NULL, NULL }
    };
    
    // Set library as upvalue for each library function
    Self *library = new Self;
    CoronaLuaPushUserdata( L, library, kMetatableName );
    
    luaL_openlib( L, kName, kVTable, 1 ); // leave "library" on top of stack
    
    return 1;
}

int PluginLibrary::Finalizer( lua_State *L )
{
    Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
    
    CoronaLuaDeleteRef( L, library->GetExecuteCommandListener() );
    
    delete library;
    
    return 0;
}

PluginLibrary * PluginLibrary::ToLibrary( lua_State *L )
{
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
    return library;
}

// [Lua] library.init( listener )
int PluginLibrary::init( lua_State *L )
{
    int listenerIndex = 1;
    
    if ( CoronaLuaIsListener( L, listenerIndex, kEvent ) )
    {
        Self *library = ToLibrary( L );
        
        CoronaLuaRef listener = CoronaLuaNewRef( L, listenerIndex );
        library->InitExecuteCommandListener( listener );
    }
    
    return 0;
}

int PluginLibrary::initTestLibrary(lua_State *L) {
    NSLog(@"[TestLibrary][bridge]: Init test library started...");
    Self *library = ToLibrary(L);
    
    const char *baseUrlCStr = lua_tostring(L, 1);
    NSString *baseUrl = [NSString stringWithUTF8String:baseUrlCStr];
    
    NSLog(@"[TestLibrary][bridge]: Init test library with base URL: %@", baseUrl);
    
    if (CoronaLuaIsListener(L, 2, kEvent))
    {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, 2);
        library->InitExecuteCommandListener(listener);
    }
    
    TestLibCommandExecutor *commandExecutor = [[TestLibCommandExecutor alloc] init];
    library->testLibrary = [ATLTestLibrary testLibraryWithBaseUrl:baseUrl andCommandDelegate:commandExecutor];
    
    NSLog(@"[TestLibrary][bridge]: Test library initialization completed.");
    return 0;
}

int PluginLibrary::addTest(lua_State *L) {
    Self *library = ToLibrary(L);
    const char *testName = lua_tostring(L, 1);
    [library->testLibrary addTest:[NSString stringWithUTF8String:testName]];
    return 0;
}

int PluginLibrary::addTestDirectory(lua_State *L) {
    Self *library = ToLibrary(L);
    const char *testDir = lua_tostring(L, 1);
    [library->testLibrary addTestDirectory:[NSString stringWithUTF8String:testDir]];
    return 0;
}

int PluginLibrary::startTestSession(lua_State *L) {
    Self *library = ToLibrary(L);
    const char *clientSdk = lua_tostring(L, 1);
    [library->testLibrary startTestSession:[NSString stringWithUTF8String:clientSdk]];
    return 0;
}

int PluginLibrary::addInfoToSend(lua_State *L) {
    Self *library = ToLibrary(L);
    const char *key = lua_tostring(L, 1);
    const char *value = lua_tostring(L, 2);
    [library->testLibrary addInfoToSend:[NSString stringWithUTF8String:key] value:[NSString stringWithUTF8String:value]];
    return 0;
}

int PluginLibrary::sendInfoToServer(lua_State *L) {
    Self *library = ToLibrary(L);
    const char *basePath = lua_tostring(L, 1);
    [library->testLibrary sendInfoToServer:[NSString stringWithUTF8String:basePath]];
    return 0;
}

// [Lua] library.show( word )
int PluginLibrary::show( lua_State *L )
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
    CoronaLuaDispatchEvent( L, library->GetExecuteCommandListener(), 0 );
    
    return 0;
}

// ----------------------------------------------------------------------------
CORONA_EXPORT int luaopen_plugin_testlibrary( lua_State *L )
{
    return PluginLibrary::Open( L );
}
