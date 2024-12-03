//
//  AdjustSdkDelegate.h
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 11th September 2017.
//  Copyright (c) 2017-2022 Adjust GmbH. All rights reserved.
//

#include <CoronaLua.h>
#import "Adjust.h"
#import "ADJConfig.h"

#define ADJ_ATTRIBUTION_CHANGED @"adjust_attributionChanged"
#define ADJ_EVENT_TRACKING_SUCCESS @"adjust_eventTrackingSuccess"
#define ADJ_EVENT_TRACKING_FAILURE @"adjust_eventTrackingFailure"
#define ADJ_SESSION_TRACKING_SUCCESS @"adjust_sessionTrackingSuccess"
#define ADJ_SESSION_TRACKING_FAILURE @"adjust_sessionTrackingFailure"
#define ADJ_DEFERRED_DEEPLINK @"adjust_deferredDeeplink"
#define ADJ_UPDATE_SKAN @"adjust_updateSkan"

/**
 * @brief Adjust delegate singleton which takes care of bridging between native SDK and Lua callbacks.
 */
@interface AdjustSdkDelegate : NSObject<AdjustDelegate>

/**
 * @brief Lua state object.
 */
@property (nonatomic) lua_State *luaState;

/**
 * @brief Attribution callback reference.
 */
@property (nonatomic) CoronaLuaRef attributionChangedCallback;

/**
 * @brief Event success callback reference.
 */
@property (nonatomic) CoronaLuaRef eventSuccessCallback;

/**
 * @brief Event failure callback reference.
 */
@property (nonatomic) CoronaLuaRef eventFailureCallback;

/**
 * @brief Session success callback reference.
 */
@property (nonatomic) CoronaLuaRef sessionSuccessCallback;

/**
 * @brief Session failure callback reference.
 */
@property (nonatomic) CoronaLuaRef sessionFailureCallback;

/**
 * @brief Deferred deep link callback reference.
 */
@property (nonatomic) CoronaLuaRef deferredDeeplinkCallback;
/**
 * @brief Deferred deep link callback reference.
 */
@property (nonatomic) CoronaLuaRef updateSkanCallback;

/**
 * @brief Should deferred deep link be opened or not.
 */
@property (nonatomic) BOOL shouldLaunchDeferredDeeplink;

/**
 * @brief Obtain static instance of AdjustSdkDelegate.
 *
 * @param attributionCallback                   Attribution callback reference.
 * @param eventSuccessCallback          Event success callback reference.
 * @param eventFailureCallback          Event failure callback reference.
 * @param sessionSuccessCallback        Session success callback reference.
 * @param sessionFailureCallback        Session failure callback reference.
 * @param deferredDeeplinkCallback              Deferred deep link callback reference.
 * @param updateSkanCallback              skan update callback reference.
 * @param conversionValueUpdatedCallback        Conversion value updated callback reference.
 * @param skan4conversionValueUpdatedCallback   Conversion value updated callback reference.
 * @param shouldLaunchDeferredDeeplink          Should deferred deep link be opened or not.
 * @param luaState                              Lua state object.
 *
 * @returns Static instance of AdjustSdkDelegate.
 */
+ (id)getInstanceWithSwizzleOfAttributionChangedCallback:(CoronaLuaRef)attributionCallback
                            eventSuccessCallback:(CoronaLuaRef)eventSuccessCallback
                            eventFailureCallback:(CoronaLuaRef)eventFailureCallback
                          sessionSuccessCallback:(CoronaLuaRef)sessionSuccessCallback
                          sessionFailureCallback:(CoronaLuaRef)sessionFailureCallback
                                deferredDeeplinkCallback:(CoronaLuaRef)deferredDeeplinkCallback
                                      updateSkanCallback:(CoronaLuaRef)updateSkanCallback
                            shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink
                                             andLuaState:(lua_State *)luaState;

/**
 * @brief Dispatch event from native bridge to Lua world.
 *
 * @param eventName String identifier of the event being launched.
 * @param luaState  Lua state object.
 * @param callback  Lua callback method to get triggered.
 * @param message   String message being sent from native bridge to Lua.
 */
+ (void)dispatchEvent:(NSString *)eventName
            withState:(lua_State *)luaState
             callback:(CoronaLuaRef)callback
           andMessage:(NSString *)message;

/**
 * @brief Add key-value pair to dictionary. If value is nil, add empty string value.
 *
 * @param key           Key to be added.
 * @param value         Value to be added.
 * @param dictionary    Destination dictionary.
 */
+ (void)addKey:(NSString *)key
      andValue:(NSObject *)value
  toDictionary:(NSMutableDictionary *)dictionary;

+ (void)teardown;

@end
