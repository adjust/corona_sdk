//
//  AdjustSdkDelegate.h
//  Adjust
//
//  Created by Abdullah on 2016-11-17
//  Copyright (c) 2012-2016 adjust GmbH. All rights reserved.
//

#import "Adjust.h"

#include <CoronaLua.h>

#define ADJUSTEVENT_ATTRIBUTION_CHANGED @"adjust_attributionChanged"
#define ADJUSTEVENT_EVENT_TRACKING_SUCCEEDED @"adjust_eventTrackingSucceeded"
#define ADJUSTEVENT_EVENT_TRACKING_FAILED @"adjust_eventTrackingFailed"
#define ADJUSTEVENT_SESSION_TRACKING_SUCCEEDED @"adjust_sessionTrackingSucceeded"
#define ADJUSTEVENT_SESSION_TRACKING_FAILED @"adjust_sessionTrackingFailed"
#define ADJUSTEVENT_DEFERRED_DEEPLINK @"adjust_deferredDeeplink"

@interface AdjustSdkDelegate : NSObject<AdjustDelegate>

@property (nonatomic) CoronaLuaRef attributionChangedListener;
@property (nonatomic) CoronaLuaRef eventTrackingSucceededListener;
@property (nonatomic) CoronaLuaRef eventTrackingFailedListener;
@property (nonatomic) CoronaLuaRef sessionTrackingSucceededListener;
@property (nonatomic) CoronaLuaRef sessionTrackingFailedListener;
@property (nonatomic) CoronaLuaRef deferredDeeplinkListener;
@property (nonatomic) BOOL shouldLaunchDeferredDeeplink;
@property (nonatomic) lua_State *luaState;

+ (id)getInstanceWithSwizzleOfAttributionChangedListener:(CoronaLuaRef)attributionChangedListener
						   eventTrackingSucceededListener:(CoronaLuaRef)eventTrackingSucceededListener
							  eventTrackingFailedListener:(CoronaLuaRef)eventTrackingFailedListener
						 sessionTrackingSucceededListener:(CoronaLuaRef)sessionTrackingSucceededListener
						    sessionTrackingFailedListener:(CoronaLuaRef)sessionTrackingFailedListener
					     deferredDeeplinkListener:(CoronaLuaRef)deferredDeeplinkListener
                     shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink
                                       withLuaState:(lua_State *)luaState;

@end
