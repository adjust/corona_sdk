//
//  AdjustPlugin.h
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 11th September 2017.
//  Copyright (c) 2017-2021 Adjust GmbH. All rights reserved.
//

#ifndef _AdjustPlugin_H__
#define _AdjustPlugin_H__

#include <CoronaLua.h>
#include <CoronaMacros.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library" where the '.' is replaced with '_'.
// Adjust SDK is named "plugin.adjust".
CORONA_EXPORT int luaopen_plugin_adjust(lua_State *L);

#endif // _AdjustPlugin_H__
