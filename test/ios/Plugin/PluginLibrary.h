//
//  PluginLibrary.h
//  TemplateApp
//
//  Created by Srdjan Tubin on August 2018.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#ifndef _PluginLibrary_H__
#define _PluginLibrary_H__

#include <CoronaLua.h>
#include <CoronaMacros.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.testlibrary"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_testlibrary( lua_State *L );

#endif // _PluginLibrary_H__
