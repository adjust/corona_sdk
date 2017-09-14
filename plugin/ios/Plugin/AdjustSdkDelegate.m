//
//  AdjustSdkDelegate.m
//  Adjust
//
//  Created by Abdullah Obaied on 2016-11-18.
//  Copyright (c) 2012-2016 adjust GmbH. All rights reserved.
//

#import <objc/runtime.h>

#import "AdjustSdkDelegate.h"

@implementation AdjustSdkDelegate

+ (id)getInstanceWithSwizzleOfAttributionChangedListener:(CoronaLuaRef)attributionChangedListener
						   eventTrackingSucceededListener:(CoronaLuaRef)eventTrackingSucceededListener
							  eventTrackingFailedListener:(CoronaLuaRef)eventTrackingFailedListener
						 sessionTrackingSucceededListener:(CoronaLuaRef)sessionTrackingSucceededListener
						    sessionTrackingFailedListener:(CoronaLuaRef)sessionTrackingFailedListener
					     deferredDeeplinkListener:(CoronaLuaRef)deferredDeeplinkListener
                     shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink
                                       withLuaState:(lua_State *)luaState {
    static dispatch_once_t onceToken;
    static AdjustSdkDelegate *defaultInstance = nil;
    
    dispatch_once(&onceToken, ^{
        defaultInstance = [[AdjustSdkDelegate alloc] init];
        
        // Do the swizzling where and if needed.
        if (attributionChangedListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustAttributionChanged:)
                                  swizzledSelector:@selector(adjustAttributionChangedWannabe:)];
        }
        
        if (eventTrackingSucceededListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustEventTrackingSucceeded:)
                                  swizzledSelector:@selector(adjustEventTrackingSucceededWannabe:)];
        }
        
        if (eventTrackingFailedListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustEventTrackingFailed:)
                                  swizzledSelector:@selector(adjustEventTrackingFailedWannabe:)];
        }
        
        if (sessionTrackingSucceededListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustSessionTrackingSucceeded:)
                                  swizzledSelector:@selector(adjustSessionTrackingSucceededWannabe:)];
        }
        
        if (sessionTrackingFailedListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustSessionTrackingFailed:)
                                  swizzledSelector:@selector(adjustSessionTrackingFailedWananbe:)];
        }
        
        if (deferredDeeplinkListener != NULL) {
            [defaultInstance swizzleCallbackMethod:@selector(adjustDeeplinkResponse:)
                                  swizzledSelector:@selector(adjustDeeplinkResponseWannabe:)];
        }
        
        [defaultInstance setAttributionChangedListener:attributionChangedListener];
        [defaultInstance setEventTrackingSucceededListener:eventTrackingSucceededListener];
        [defaultInstance setEventTrackingFailedListener:eventTrackingFailedListener];
        [defaultInstance setSessionTrackingSucceededListener:sessionTrackingSucceededListener];
        [defaultInstance setSessionTrackingFailedListener:sessionTrackingFailedListener];
        [defaultInstance setDeferredDeeplinkListener:deferredDeeplinkListener];
        [defaultInstance setShouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink];
        [defaultInstance setLuaState:luaState];
    });
    
    return defaultInstance;
}

- (id)init {
    self = [super init];
    
    if (nil == self) {
        return nil;
    }
    
    return self;
}

- (void)adjustAttributionChangedWannabe:(ADJAttribution *)attribution {
    if (attribution == nil) {
        return;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"trackerToken" value:attribution.trackerToken];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"trackerName" value:attribution.trackerName];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"network" value:attribution.network];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"campaign" value:attribution.campaign];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"creative" value:attribution.creative];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adgroup" value:attribution.adgroup];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"clickLabel" value:attribution.clickLabel];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:attribution.adid];

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_attributionChangedListener withEventName:EVENT_ATTRIBUTION_CHANGED withMessage:strDict];
}

- (void)adjustEventTrackingSucceededWannabe:(ADJEventSuccess *)eventSuccessResponseData {
    if (nil == eventSuccessResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"message" value:eventSuccessResponseData.message];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"timestamp" value:eventSuccessResponseData.timeStamp];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:eventSuccessResponseData.adid];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"eventToken" value:eventSuccessResponseData.eventToken];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"jsonResponse" value:eventSuccessResponseData.jsonResponse];

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_eventTrackingSucceededListener withEventName:EVENT_EVENT_TRACKING_SUCCEEDED withMessage:strDict];
}

- (void)adjustEventTrackingFailedWannabe:(ADJEventFailure *)eventFailureResponseData {
    if (nil == eventFailureResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"message" value:eventFailureResponseData.message];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"timestamp" value:eventFailureResponseData.timeStamp];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:eventFailureResponseData.adid];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"eventToken" value:eventFailureResponseData.eventToken];
    [dictionary setObject:(eventFailureResponseData.willRetry ? @"true" : @"false") forKey:@"willRetry"];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"jsonResponse" value:eventFailureResponseData.jsonResponse];

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_eventTrackingFailedListener withEventName:EVENT_EVENT_TRACKING_FAILED withMessage:strDict];
}


- (void)adjustSessionTrackingSucceededWannabe:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (nil == sessionSuccessResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"message" value:sessionSuccessResponseData.message];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"timestamp" value:sessionSuccessResponseData.timeStamp];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:sessionSuccessResponseData.adid];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"jsonResponse" value:sessionSuccessResponseData.jsonResponse];

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_sessionTrackingSucceededListener withEventName:EVENT_SESSION_TRACKING_SUCCEEDED withMessage:strDict];
}

- (void)adjustSessionTrackingFailedWananbe:(ADJSessionFailure *)sessionFailureResponseData {
    if (nil == sessionFailureResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"message" value:sessionFailureResponseData.message];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"timestamp" value:sessionFailureResponseData.timeStamp];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"adid" value:sessionFailureResponseData.adid];
    [dictionary setObject:(sessionFailureResponseData.willRetry ? @"true" : @"false") forKey:@"willRetry"];
    [AdjustSdkDelegate addValueOrEmpty:dictionary key:@"jsonResponse" value:sessionFailureResponseData.jsonResponse];

    NSString *strDict = [NSString stringWithFormat:@"%@", dictionary];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_sessionTrackingFailedListener withEventName:EVENT_SESSION_TRACKING_FAILED withMessage:strDict];
}

- (BOOL)adjustDeeplinkResponseWannabe:(NSURL *)deeplink {
    NSString *path = [deeplink absoluteString];
    [AdjustSdkDelegate dispatchEvent:_luaState withListener:_deferredDeeplinkListener withEventName:EVENT_DEFERRED_DEEPLINK withMessage:path];
    
    return _shouldLaunchDeferredDeeplink;
}

- (void)swizzleCallbackMethod:(SEL)originalSelector
             swizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)addValueOrEmpty:(NSMutableDictionary *)dictionary
                    key:(NSString *)key
                  value:(NSObject *)value {
    if (nil != value) {
        [dictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    } else {
        [dictionary setObject:@"" forKey:key];
    }
}

+ (void)dispatchEvent:(lua_State *)luaState
         withListener:(CoronaLuaRef)listener
        withEventName:(NSString*)eventName
          withMessage:(NSString*)message {
    
    // Create event and add message to it
    CoronaLuaNewEvent(luaState, [eventName UTF8String]);
    lua_pushstring(luaState, [message UTF8String] );
    lua_setfield(luaState, -2, "message" );
    
    // Dispatch event to library's listener
    CoronaLuaDispatchEvent(luaState, listener, 0);
}

@end
