# Corona SDK v5 migration guide

The [Adjust Corona SDK](https://github.com/adjust/corona_sdk) has been updated to v5. Follow this guide to migrate from v4 to the latest version.

## Before you begin

The minimum supported iOS and Android versions have been updated. If your app targets a lower version, update it first.

- iOS: **12.0**
- Android: **API 21**

### Update the initialization method

In Corona SDK v5, the initialization method name has changed from `start` to `initSdk`.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

### Android permissions

In Corona SDK v4, you needed to declare several permissions to allow your app for Android to access device information via the Adjust SDK for Android.

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE" />
```

In Corona SDK v5, you can delete some or all from your manifest file, depending on your setup.

- `android.permission.INTERNET` is bundled in the Adjust SDK for Android.
- `android.permission.ACCESS_WIFI_STATE` is no longer required.
- `android.permission.ACCESS_NETWORK_STATE` is optional. This allows the SDK to access information about the network a device is connected to, and send this information as part of the callbacks parameters.
- `com.google.android.gms.permission.AD_ID` is bundled in the Adjust SDK for Android. You can remove it with the following snippet:

```xml
<uses-permission android:name="com.google.android.gms.permission.AD_ID" tools:node="remove"/>
```

Learn more about [Adjust's COPPA compliance](https://help.adjust.com/en/article/coppa-compliance).

## Changes and removals

Below is the complete list of changed, renamed, and removed APIs in Corona SDK v5.

Each section includes a reference to the previous and current API implementations, as well as a minimal code snippet that illustrates how to use the latest version.

## Changed APIs

The following APIs have changed in Corona SDK v5.

### Disable and enable the SDK

The `setEnabled` method has been renamed. Corona SDK v5 introduces two separate methods, for clarity:

- Call `disable` to disable the SDK.
- Call `enable` to enable the SDK.

```lua
local adjust = require "plugin.adjust"

adjust.disable(); -- disable SDK
adjust.enable(); -- enable SDK
```

### Offline mode

The `setOfflineMode` method has been renamed. Corona SDK v5 introduces two separate methods, for clarity:

- Call `switchToOfflineMode` to set the SDK to offline mode.
- Call `switchBackToOnlineMode` to set the SDK back to online mode.

```lua
local adjust = require "plugin.adjust"

adjust.switchToOfflineMode(); -- enable offline mode
adjust.switchBackToOnlineMode(); -- disable offline mode
```

### Send from background

The `sendInBackground` initialization map parameter has been renamed to `isSendingInBackgroundEnabled`.

To enable the Corona SDK v5 to attempt sending information to Adjust while your app is running in the background, set the `isSendingInBackgroundEnabled` parameter of your initialization map. This feature is disabled by default.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isSendingInBackgroundEnabled = true
})
```

### Attribution callback

In Corona SDK v5, the `setAttributionListener` method has been renamed to `setAttributionCallback`.

The properties of the `attribution` map have also changed:

- The `adid` is no longer part of the attribution.

Below is a sample snippet that implements these changes:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

adjust.setAttributionCallback(function(event)
    local json_attribution = json.decode(event.message)
    print("Attribution changed!")
    print("Tracker token: " .. (json_attribution.trackerToken or "N/A"))
    print("Tracker name: " .. (json_attribution.trackerName or "N/A"))
    print("Campaign: " .. (json_attribution.campaign or "N/A"))
    print("Network: " .. (json_attribution.network or "N/A"))
    print("Creative: " .. (json_attribution.creative or "N/A"))
    print("Adgroup: " .. (json_attribution.adgroup or "N/A"))
    print("Cost type: " .. (json_attribution.costType or "N/A"))
    print("Cost amount: " .. (json_attribution.costAmount or "N/A"))
    print("Cost currency: " .. (json_attribution.costCurrency or "N/A"))
    print("FB install referrer: " .. (json_attribution.fbInstallReferrer or "N/A"))
end)
```

### Event deduplication

In Corona SDK v5, event deduplication is decoupled from the event `transactionId`. To prevent measuring duplicated events, use the `deduplicationId` ID field.

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    revenue = 1.5,
    currency = "EUR",
    deduplicationId = "deduplucation-id"
})
```

### Session callback parameters

In Corona SDK v5, the session callback parameters have been renamed to global callback parameters together with corresponding methods.

```lua
local adjust = require "plugin.adjust"

adjust.addGlobalCallbackParameter("user_id", "855");
adjust.removeGlobalCallbackParameter("user_id");
adjust.removeGlobalCallbackParameters();
```

### Session partner parameters

In Corona SDK v5, the session partner parameters have been renamed to global partner parameters together with corresponding methods.

```lua
local adjust = require "plugin.adjust"

adjust.addGlobalPartnerParameter("user_id", "855");
adjust.removeGlobalPartnerParameter("user_id");
adjust.removeGlobalPartnerParameters();
```

## Session and event callbacks

### Session success callback

In Corona SDK v5, the `setSessionTrackingSuccessListener` method has been renamed to `setSessionSuccessCallback`.

```lua
local adjust = require "plugin.adjust"

adjust.setSessionSuccessCallback(function(event)
    local json_session_success = json.decode(event.message)
    print("Session tracking success!")
    print("Message: " .. (json_session_success.message or "N/A"))
    print("Timestamp: " .. (json_session_success.timestamp or "N/A"))
    print("Adid: " .. (json_session_success.adid or "N/A"))
    print("JSON response: " .. (json.encode(json_session_success.jsonResponse) or "N/A"))
end)
```

### Session failure callback

In Corona SDK v5, the `setSessionTrackingFailureListener` method has been renamed to `setSessionFailureCallback`.

```lua
local adjust = require "plugin.adjust"

adjust.setSessionFailureCallback(function(event)
    local json_session_failure = json.decode(event.message)
    print("Session tracking failure!")
    print("Message: " .. (json_session_failure.message or "N/A"))
    print("Timestamp: " .. (json_session_failure.timestamp or "N/A"))
    print("Adid: " .. (json_session_failure.adid or "N/A"))
    print("Will retry: " .. (json_session_failure.willRetry or "N/A"))
    print("JSON response: " .. (json.encode(json_session_failure.jsonResponse) or "N/A"))
end)
```

### Event success callback

In Corona SDK v5, the `setEventTrackingSuccessListener` method has been renamed to `setEventSuccessCallback`.

```lua
local adjust = require "plugin.adjust"

adjust.setEventSuccessCallback(function(event)
    local json_event_success = json.decode(event.message)
    print("Event tracking success!")
    print("Event token: " .. (json_event_success.eventToken or "N/A"))
    print("Message: " .. (json_event_success.message or "N/A"))
    print("Timestamp: " .. (json_event_success.timestamp or "N/A"))
    print("Adid: " .. (json_event_success.adid or "N/A"))
    print("JSON response: " .. (json.encode(json_event_success.jsonResponse) or "N/A"))
end)
```

### Event failure callback

In Corona SDK v5, the `setEventTrackingFailureListener` method has been renamed to `setEventFailureCallback`.

```lua
local adjust = require "plugin.adjust"

adjust.setEventFailureCallback(function(event)
    local json_event_failure = json.decode(event.message)
    print("Event tracking failure!")
    print("Event token: " .. (json_event_failure.eventToken or "N/A"))
    print("Message: " .. (json_event_failure.message or "N/A"))
    print("Timestamp: " .. (json_event_failure.timestamp or "N/A"))
    print("Adid: " .. (json_event_failure.adid or "N/A"))
    print("Will retry: " .. (json_event_failure.willRetry or "N/A"))
    print("JSON response: " .. (json.encode(json_event_failure.jsonResponse) or "N/A"))
end)
```

## Deep linking

### Reattribution via deep links

In Corona SDK v5, the `appWillOpenUrl` method has been renamed to `processDeeplink`.

To process a direct deep link, create a deep link map with the `deeplink` parameter, and pass it to the `processDeeplink` method.

```lua
local adjust = require "plugin.adjust"

adjustDeeplink = {}
adjustDeeplink.deeplink = "your-deep-link"

adjust.processDeeplink(adjustDeeplink)
```

### Disable opening deferred deep links

In Corona SDK v5, the `shouldLaunchDeeplink` parameter has been renamed to `isDeferredDeeplinkOpeningEnabled`. Opening deferred deep links is enabled by default.

To disable opening deferred deep links, call the renamed method:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isDeferredDeeplinkOpeningEnabled = false
})
```

### Deferred deep link callback

In Corona SDK v5, the `setDeferredDeeplinkListener` method has been renamed to `setDeferredDeeplinkCallback`.

```lua
local adjust = require "plugin.adjust"

adjust.setDeferredDeeplinkCallback(function(event)
    print("Deferred deep link: " .. event.message)
end)
```

## iOS only API

### SKAdNetwork handling

In Corona SDK v5, the `handleSkAdNetwork` parameter has been renamed to `isSkanAttributionEnabled`. The `SKAdNetwork` API is enabled by default.

To disable the `SKAdNetwork` communication, set the `isSkanAttributionEnabled` parameter of your initialization map.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isSkanAttributionEnabled = false
})
```

### App Tracking Transparency authorization wrapper 

In Corona SDK v5, the `requestTrackingAuthorizationWithCompletionHandler` method has been renamed to `requestAppTrackingAuthorization` for clarity.

The renamed method is invoked like so:

```lua
local adjust = require "plugin.adjust"

adjust.requestAppTrackingAuthorization(function(status)
    if status.message == 0 then
        -- ATTrackingManagerAuthorizationStatusNotDetermined case
    elseif status.message == 1 then
        -- ATTrackingManagerAuthorizationStatusRestricted case
    elseif status.message == 2 then
        -- ATTrackingManagerAuthorizationStatusDenied case
    elseif status.message == 3 then
        -- ATTrackingManagerAuthorizationStatusAuthorized case
    else
        -- error case
    end
end)
```

## Get device information

### Get attribution information

`adid` field is no longer the part of the attribution map which `getAttribution` getter is returning.

```lua
local adjust = require "plugin.adjust"
local json = require "json"

adjust.getAttribution(function(event) 
    local json_attribution = json.decode(event.message)
    print("Tracker token: " .. (json_attribution.trackerToken or "N/A"))
    print("Tracker name: " .. (json_attribution.trackerName or "N/A"))
    print("Campaign: " .. (json_attribution.campaign or "N/A"))
    print("Network: " .. (json_attribution.network or "N/A"))
    print("Creative: " .. (json_attribution.creative or "N/A"))
    print("Adgroup: " .. (json_attribution.adgroup or "N/A"))
    print("Cost type: " .. (json_attribution.costType or "N/A"))
    print("Cost amount: " .. (json_attribution.costAmount or "N/A"))
    print("Cost currency: " .. (json_attribution.costCurrency or "N/A"))
    print("FB install referrer: " .. (json_attribution.fbInstallReferrer or "N/A"))
end)
```

## Removed APIs

The following APIs have been removed from Corona SDK v5.

- The `delayStart` initialization parameter has been removed.
- The `sendFirstPackages` method has been removed.
- The `eventBufferingEnabled` initialization parameter has been removed.
- The `readMobileEquipmentIdentity` initialization parameter has been removed. (non-Google Play Store Android apps only)

### Disable third party sharing globally

The `disableThirdPartySharing` method has been removed.

To disable all third-party sharing in Corona SDK v5, use the `trackThirdPartySharing` method.

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    enabled = false,
})
```

### Huawei referrer API

This feature has been removed. If your Solar2D / Corona app uses the Huawei referrer API, contact your Adjust representative or email support@adjust.com before you upgrade.
