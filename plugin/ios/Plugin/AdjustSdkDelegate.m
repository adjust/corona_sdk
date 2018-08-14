//
//  AdjustSdkDelegate.m
//  Adjust SDK
//
//  Created by Abdullah Obaied (@obaied) on 11th September 2017.
//  Copyright (c) 2017-2018 Adjust GmbH. All rights reserved.
//

#import <objc/runtime.h>
#import "AdjustSdkDelegate.h"

static dispatch_once_t onceToken;
static AdjustSdkDelegate *defaultInstance = nil;

@implementation AdjustSdkDelegate

#pragma mark - Constants

NSString * const KEY_TRACKER_TOKEN = @"trackerToken";
NSString * const KEY_TRACKER_NAME = @"trackerName";
NSString * const KEY_NETWORK = @"network";
NSString * const KEY_CAMPAIGN = @"campaign";
NSString * const KEY_CREATIVE = @"creative";
NSString * const KEY_ADGROUP = @"adgroup";
NSString * const KEY_CLICK_LABEL = @"clickLabel";
NSString * const KEY_ADID = @"adid";
NSString * const KEY_MESSAGE = @"message";
NSString * const KEY_TIMESTAMP = @"timestamp";
NSString * const KEY_EVENT_TOKEN = @"eventToken";
NSString * const KEY_JSON_RESPONSE = @"jsonResponse";
NSString * const KEY_WILL_RETRY = @"willRetry";

#pragma mark - Object lifecycle methods

- (id)init {
    self = [super init];
    if (nil == self) {
        return nil;
    }
    return self;
}

#pragma mark - Public methods

+ (id)getInstanceWithSwizzleOfAttributionChangedCallback:(CoronaLuaRef)attributionCallback
                            eventTrackingSuccessCallback:(CoronaLuaRef)eventTrackingSuccessCallback
                            eventTrackingFailureCallback:(CoronaLuaRef)eventTrackingFailureCallback
                          sessionTrackingSuccessCallback:(CoronaLuaRef)sessionTrackingSuccessCallback
                          sessionTrackingFailureCallback:(CoronaLuaRef)sessionTrackingFailureCallback
                                deferredDeeplinkCallback:(CoronaLuaRef)deferredDeeplinkCallback
                            shouldLaunchDeferredDeeplink:(BOOL)shouldLaunchDeferredDeeplink
                                             andLuaState:(lua_State *)luaState {
    dispatch_once(&onceToken, ^{
        defaultInstance = [[AdjustSdkDelegate alloc] init];

        // Do the swizzling where and if needed.
        if (attributionCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustAttributionChanged:)
                                        withSelector:@selector(adjustAttributionChangedWannabe:)];
        }
        if (eventTrackingSuccessCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustEventTrackingSucceeded:)
                                        withSelector:@selector(adjustEventTrackingSucceededWannabe:)];
        }
        if (eventTrackingFailureCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustEventTrackingFailed:)
                                        withSelector:@selector(adjustEventTrackingFailedWannabe:)];
        }
        if (sessionTrackingSuccessCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustSessionTrackingSucceeded:)
                                        withSelector:@selector(adjustSessionTrackingSucceededWannabe:)];
        }
        if (sessionTrackingFailureCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustSessionTrackingFailed:)
                                        withSelector:@selector(adjustSessionTrackingFailedWannabe:)];
        }
        if (deferredDeeplinkCallback != NULL) {
            [defaultInstance swizzleOriginalSelector:@selector(adjustDeeplinkResponse:)
                                        withSelector:@selector(adjustDeeplinkResponseWannabe:)];
        }

        [defaultInstance setAttributionChangedCallback:attributionCallback];
        [defaultInstance setEventTrackingSuccessCallback:eventTrackingSuccessCallback];
        [defaultInstance setEventTrackingFailureCallback:eventTrackingFailureCallback];
        [defaultInstance setSessionTrackingSuccessCallback:sessionTrackingSuccessCallback];
        [defaultInstance setSessionTrackingFailureCallback:sessionTrackingFailureCallback];
        [defaultInstance setDeferredDeeplinkCallback:deferredDeeplinkCallback];
        [defaultInstance setShouldLaunchDeferredDeeplink:shouldLaunchDeferredDeeplink];
        [defaultInstance setLuaState:luaState];
    });

    return defaultInstance;
}

+ (void)teardown {
    defaultInstance = nil;
    onceToken = 0;
}

+ (void)dispatchEvent:(NSString *)eventName
            withState:(lua_State *)luaState
             callback:(CoronaLuaRef)callback
           andMessage:(NSString *)message {
    // Create event and add message to it.
    CoronaLuaNewEvent(luaState, [eventName UTF8String]);
    lua_pushstring(luaState, [message UTF8String]);
    lua_setfield(luaState, -2, "message");

    // Dispatch event to library's listener
    CoronaLuaDispatchEvent(luaState, callback, 0);
}

+ (void)addKey:(NSString *)key
      andValue:(NSObject *)value
  toDictionary:(NSMutableDictionary *)dictionary {
    if (nil != value) {
        [dictionary setObject:[NSString stringWithFormat:@"%@", value] forKey:key];
    } else {
        [dictionary setObject:@"" forKey:key];
    }
}

#pragma mark - AdjustDelegate swizzle methods

- (void)adjustAttributionChangedWannabe:(ADJAttribution *)attribution {
    if (attribution == nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addKey:KEY_TRACKER_TOKEN andValue:attribution.trackerToken toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_TRACKER_NAME andValue:attribution.trackerName toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_NETWORK andValue:attribution.network toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_CAMPAIGN andValue:attribution.campaign toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_CREATIVE andValue:attribution.creative toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADGROUP andValue:attribution.adgroup toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_CLICK_LABEL andValue:attribution.clickLabel toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADID andValue:attribution.adid toDictionary:dictionary];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"[Adjust][bridge]: Error while trying to convert attribution dictionary to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [AdjustSdkDelegate dispatchEvent:ADJ_ATTRIBUTION_CHANGED
                               withState:_luaState
                                callback:_attributionChangedCallback
                              andMessage:jsonString];
    }
}

- (void)adjustSessionTrackingSucceededWannabe:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (nil == sessionSuccessResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addKey:KEY_MESSAGE andValue:sessionSuccessResponseData.message toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_TIMESTAMP andValue:sessionSuccessResponseData.timeStamp toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADID andValue:sessionSuccessResponseData.adid toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_JSON_RESPONSE andValue:sessionSuccessResponseData.jsonResponse toDictionary:dictionary];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"[Adjust][bridge]: Error while trying to convert session success dictionary to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [AdjustSdkDelegate dispatchEvent:ADJ_SESSION_TRACKING_SUCCESS
                               withState:_luaState
                                callback:_sessionTrackingSuccessCallback
                              andMessage:jsonString];
    }
}

- (void)adjustSessionTrackingFailedWannabe:(ADJSessionFailure *)sessionFailureResponseData {
    if (nil == sessionFailureResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addKey:KEY_MESSAGE andValue:sessionFailureResponseData.message toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_TIMESTAMP andValue:sessionFailureResponseData.timeStamp toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADID andValue:sessionFailureResponseData.adid toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_WILL_RETRY andValue:(sessionFailureResponseData.willRetry ? @"true" : @"false") toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_JSON_RESPONSE andValue:sessionFailureResponseData.jsonResponse toDictionary:dictionary];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"[Adjust][bridge]: Error while trying to convert session failure dictionary to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [AdjustSdkDelegate dispatchEvent:ADJ_SESSION_TRACKING_FAILURE
                               withState:_luaState
                                callback:_sessionTrackingFailureCallback
                              andMessage:jsonString];
    }
}

- (void)adjustEventTrackingSucceededWannabe:(ADJEventSuccess *)eventSuccessResponseData {
    if (nil == eventSuccessResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addKey:KEY_MESSAGE andValue:eventSuccessResponseData.message toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_TIMESTAMP andValue:eventSuccessResponseData.timeStamp toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADID andValue:eventSuccessResponseData.adid toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_EVENT_TOKEN andValue:eventSuccessResponseData.eventToken toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_JSON_RESPONSE andValue:eventSuccessResponseData.jsonResponse toDictionary:dictionary];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"[Adjust][bridge]: Error while trying to convert event success dictionary to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [AdjustSdkDelegate dispatchEvent:ADJ_EVENT_TRACKING_SUCCESS
                               withState:_luaState
                                callback:_eventTrackingSuccessCallback
                              andMessage:jsonString];
    }
}

- (void)adjustEventTrackingFailedWannabe:(ADJEventFailure *)eventFailureResponseData {
    if (nil == eventFailureResponseData) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [AdjustSdkDelegate addKey:KEY_MESSAGE andValue:eventFailureResponseData.message toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_TIMESTAMP andValue:eventFailureResponseData.timeStamp toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_ADID andValue:eventFailureResponseData.adid toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_EVENT_TOKEN andValue:eventFailureResponseData.eventToken toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_WILL_RETRY andValue:(eventFailureResponseData.willRetry ? @"true" : @"false") toDictionary:dictionary];
    [AdjustSdkDelegate addKey:KEY_JSON_RESPONSE andValue:eventFailureResponseData.jsonResponse toDictionary:dictionary];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"[Adjust][bridge]: Error while trying to convert event failure dictionary to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [AdjustSdkDelegate dispatchEvent:ADJ_EVENT_TRACKING_FAILURE
                               withState:_luaState
                                callback:_eventTrackingFailureCallback
                              andMessage:jsonString];
    }
}

- (BOOL)adjustDeeplinkResponseWannabe:(NSURL *)deeplink {
    NSString *strDeeplink = [deeplink absoluteString];
    [AdjustSdkDelegate dispatchEvent:ADJ_DEFERRED_DEEPLINK
                           withState:_luaState
                            callback:_deferredDeeplinkCallback
                          andMessage:strDeeplink];
    return _shouldLaunchDeferredDeeplink;
}

#pragma mark - Private & helper methods

- (void)swizzleOriginalSelector:(SEL)originalSelector
                   withSelector:(SEL)swizzledSelector {
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

@end
