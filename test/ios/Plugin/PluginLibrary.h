//
//  PluginLibrary.h
//  Adjust Test Library Plugin
//
//  Created by Srdjan Tubin (@2beens) on August 2018.
//  Copyright (c) 2018-2019 Adjust GmbH. All rights reserved.
//

#ifndef _PluginLibrary_H__
#define _PluginLibrary_H__

#import "ATLTestLibrary.h"

#include <CoronaLua.h>
#include <CoronaMacros.h>
#include <CoronaRuntime.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.testlibrary" where the '.' is replaced with '_'
// Adjust SDK test library is named "plugin.adjust.test".
CORONA_EXPORT int luaopen_plugin_adjust_test(lua_State *L);

class PluginLibrary {
public:
    typedef PluginLibrary Self;
    static Self *ToLibrary(lua_State *L);
    
    static const char kName[];
    static const char kEvent[];
    
    void InitExecuteCommandListener(CoronaLuaRef listener);
    CoronaLuaRef GetExecuteCommandListener() const { return executeCommandListener; }
    void dispachExecuteCommand(NSString *commandJson);
    
    static int Open(lua_State *L);
    
    static int initTestLibrary(lua_State *L);
    static int addTest(lua_State *L);
    static int addTestDirectory(lua_State *L);
    static int startTestSession(lua_State *L);
    static int addInfoToSend(lua_State *L);
    static int sendInfoToServer(lua_State *L);
    
protected:
    PluginLibrary();
    static int Finalizer(lua_State *L);
    
private:
    CoronaLuaRef executeCommandListener;
    ATLTestLibrary *testLibrary;
};

#endif // _PluginLibrary_H__
