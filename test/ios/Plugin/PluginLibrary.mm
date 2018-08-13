//
//  PluginLibrary.mm
//  TemplateApp
//
//  Created by Srdjan Tubin on August 2018.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import "PluginLibrary.h"
#import "TestLibCommandExecutor.h"

#include <CoronaRuntime.h>
#import <UIKit/UIKit.h>

static lua_State *initialLuaState;

// This corresponds to the name of the library, e.g. [Lua] require "plugin.testlibrary"
const char PluginLibrary::kName[] = "plugin.testlibrary";

// This corresponds to the event name, e.g. [Lua] event.name
const char PluginLibrary::kEvent[] = "pluginlibraryevent";

PluginLibrary::PluginLibrary() : executeCommandListener(NULL) { }

void PluginLibrary::InitExecuteCommandListener(CoronaLuaRef listener) {
    // Can only initialize listener once
    if (executeCommandListener == NULL) {
        executeCommandListener = listener;
    }
}

int PluginLibrary::Open(lua_State *L) {
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
    
    // Functions in library
    const luaL_Reg kVTable[] = {
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
    CoronaLuaPushUserdata(L, library, kMetatableName);
    
    luaL_openlib(L, kName, kVTable, 1); // leave "library" on top of stack
    
    return 1;
}

int PluginLibrary::Finalizer(lua_State *L) {
    Self *library = (Self *)CoronaLuaToUserdata(L, 1);
    CoronaLuaDeleteRef(L, library->GetExecuteCommandListener());
    delete library;
    return 0;
}

PluginLibrary * PluginLibrary::ToLibrary(lua_State *L) {
    // library is pushed as part of the closure
    Self *library = (Self *)CoronaLuaToUserdata(L, lua_upvalueindex(1));
    return library;
}

int PluginLibrary::initTestLibrary(lua_State *L) {
    NSLog(@"[TestLibrary][bridge]: Init test library started...");
    Self *library = ToLibrary(L);
    initialLuaState = L;
    
    const char *baseUrlCStr = lua_tostring(L, 1);
    NSString *baseUrl = [NSString stringWithUTF8String:baseUrlCStr];
    
    NSLog(@"[TestLibrary][bridge]: Init test library with base URL: %@", baseUrl);
    
    if (CoronaLuaIsListener(L, 2, kEvent))
    {
        Self *library = ToLibrary(L);
        CoronaLuaRef listener = CoronaLuaNewRef(L, 2);
        library->InitExecuteCommandListener(listener);
    }
    
    TestLibCommandExecutor *commandExecutor = [[TestLibCommandExecutor alloc] initWithPluginLibrary:library];
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
    NSString *key = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSString *value = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    NSLog(@"[TestLibrary][bridge]: Adding info to send to server: [%@, %@]", key, value);
    [library->testLibrary addInfoToSend:key value:value];
    return 0;
}

int PluginLibrary::sendInfoToServer(lua_State *L) {
    Self *library = ToLibrary(L);
    NSString *basePath = [NSString stringWithUTF8String:lua_tostring(L, 1)];
    NSLog(@"[TestLibrary][bridge]: Sending info to server, basePath: %@", basePath);
    [library->testLibrary sendInfoToServer:basePath];
    return 0;
}

void PluginLibrary::dispachExecuteCommand(NSString *commandJson) {
    lua_State *L = initialLuaState;
    
    // Create event and add message to it
    CoronaLuaNewEvent(L, kEvent);
    lua_pushstring(L, [commandJson UTF8String]);
    lua_setfield(L, -2, "message");
    
    // Dispatch event to library's listener
    CoronaLuaDispatchEvent(L, this->GetExecuteCommandListener(), 0);
}

// ----------------------------------------------------------------------------
CORONA_EXPORT int luaopen_plugin_testlibrary(lua_State *L) {
    return PluginLibrary::Open( L );
}
