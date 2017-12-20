//
//  AdjustSdkDelegate.h
//  Adjust SDK
//
//  Created by Abdullah Obaied on 17th November 2016.
//  Copyright (c) 2017 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#include <CoronaLua.h>

#define EVENT_ATTRIBUTION_CHANGED @"adjust_attributionChanged"
#define EVENT_EVENT_TRACKING_SUCCESS @"adjust_eventTrackingSuccess"
#define EVENT_EVENT_TRACKING_FAILURE @"adjust_eventTrackingFailure"
#define EVENT_SESSION_TRACKING_SUCCESS @"adjust_sessionTrackingSuccess"
#define EVENT_SESSION_TRACKING_FAILURE @"adjust_sessionTrackingFailure"
#define EVENT_DEFERRED_DEEPLINK @"adjust_deferredDeeplink"

@interface AdjustSdkDelegate : NSObject<AdjustDelegate>

@property (nonatomic) lua_State *luaState;
@property (nonatomic) CoronaLuaRef attributionChangedCallback;
@property (nonatomic) CoronaLuaRef eventTrackingSuccessCallback;
@property (nonatomic) CoronaLuaRef eventTrackingFailureCallback;
@property (nonatomic) CoronaLuaRef sessionTrackingSuccessCallback;
@property (nonatomic) CoronaLuaRef sessionTrackingFailureCallback;
@property (nonatomic) CoronaLuaRef deferredDeeplinkCallback;
@property (nonatomic) BOOL shouldLaunchDeferredDeeplink;

+ (id)getInstanceWithSwizzleOfAttributionChangedCallback:(CoronaLuaRef)attributionCallback
                            eventTrackingSuccessCallback:(CoronaLuaRef)eventTrackingSuccessCallback
                            eventTrackingFailureCallback:(CoronaLuaRef)eventTrackingFailureCallback
                          sessionTrackingSuccessCallback:(CoronaLuaRef)sessionTrackingSuccessCallback
                          sessionTrackingFailureCallback:(CoronaLuaRef)sessionTrackingFailureCallback
                                deferredDeeplinkCallback:(CoronaLuaRef)deferredDeeplinkCallback
                            shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink
                                             andLuaState:(lua_State *)luaState;

+ (void)dispatchEvent:(lua_State *)luaState
         withListener:(CoronaLuaRef)listener
            eventName:(NSString *)eventName
           andMessage:(NSString *)message;

+ (void)addKey:(NSString *)key
      andValue:(NSObject *)value
  toDictionary:(NSMutableDictionary *)dictionary;

@end
