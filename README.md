## Summary

This is the Corona SDK of Adjust™. You can read more about Adjust™ at [adjust.com].

## Table of contents

* [Example app](#example-app)
* [Basic integration](#basic-integration)
   * [Get the SDK](#sdk-get)
   * [Add the SDK to your app](#sdk-add)
      * [Add the SDK to your Android project](#sdk-add-android)
      * [Add the SDK to your iOS project](#sdk-add-ios)
   * [Integrate the SDK into your app](#sdk-integrate)
   * [Adjust logging](#sdk-logging)
   * [Adjust project settings](#sdk-project-settings)
      * [Android permissions](#android-permissions)
      * [Google Play Services](#android-gps)
      * [Proguard settings](#android-proguard)
      * [Install referrer](#android-referrer)
         * [Google Play Referrer API](#android-referrer-gpr-api)
         * [Google Play Store intent](#android-referrer-gps-intent)
      * [iOS frameworks](#ios-frameworks)
* [Additional features](#additional-features)
   * [Event tracking](#event-tracking)
      * [Revenue tracking](#revenue-tracking)
      * [Revenue deduplication](#revenue-deduplication)
      * [Callback parameters](#callback-parameters)
      * [Partner parameters](#partner-parameters)
      * [Callback identifier](#callback-id)
   * [Session parameters](#session-parameters)
      * [Session callback parameters](#session-callback-parameters)
      * [Session partner parameters](#session-partner-parameters)
      * [Delay start](#delay-start)
   * [Attribution callback](#attribution-callback)
   * [Session and event callbacks](#session-event-callbacks)
   * [Disable tracking](#disable-tracking)
   * [Offline mode](#offline-mode)
   * [Event buffering](#event-buffering)
   * [GDPR right to be forgotten](#gdpr-forget-me)
   * [Disable third-party sharing](#disable-third-party-sharing)
   * [SDK signature](#sdk-signature)
   * [Background tracking](#background-tracking)
   * [Device IDs](#device-ids)
      * [iOS advertising identifier](#di-idfa)
      * [Google Play Services advertising identifier](#di-gps-adid)
      * [Amazon advertising identifier](#di-fire-adid)
      * [Adjust device identifier](#di-adid)
   * [User attribution](#user-attribution)
   * [Push token](#push-token)
   * [Track additional device identifiers](#track-additional-ids)
   * [Pre-installed trackers](#pre-installed-trackers)
   * [Deeplinking](#deeplinking)
      * [Standard deeplinking scenario](#deeplinking-standard)
      * [Deeplinking on iOS 8 and earlier](#deeplinking-ios-old)
      * [Deeplinking on iOS 9 and later](#deeplinking-ios-new)
      * [Deeplinking on Android](#deeplinking-android)
      * [Deferred deeplinking scenario](#deeplinking-deferred)
      * [Reattribution via deeplinks](#deeplinking-reattribution)
* [License](#license)


## <a id="example-app"></a>Example app

There is example inside the [`plugin` directory][plugin]. In there in you can check how to integrate the Adjust SDK into your app.

## <a id="basic-integration"></a>Basic integration

These are the essential steps required to integrate the Adjust SDK into your Corona app project.

### <a id="sdk-get"></a>Get the SDK

You can get the latest version of the Adjust SDK from our [releases page][releases]. Please, download both the `plugin.adjust.jar` and `libplugin_adjust.a` files, since you will need to add them to your app's projects.

### <a id="sdk-add"></a>Add the SDK to your app

You can now add the Adjust SDK to your Corona Enterprise app project. The Adjust SDK will soon be published to the Corona plugin marketplace. Once this happens, this chapter will be updated with integration instructions for users working from the plugin marketplace.

#### <a id="sdk-add-android"></a>Add the SDK to your Android project

Inside your Android Studio app project, create a `libs` folder inside of your app folder and add the `plugin.adjust.jar` file to it. After that, please update your app's `build.gradle` file and add the following lines to your `dependencies` section:

```
compile 'com.adjust.sdk:adjust-android:4.13.0'
compile 'com.android.installreferrer:installreferrer:1.0'
```

#### <a id="sdk-add-ios"></a>Add the SDK to your iOS project

Inside your Xcode app project, select your app's target, go to `General -> Linked Frameworks and Libraries` section, press the `+` button and add the `libplugin_adjust.a` library into the list.

### <a id="sdk-integrate"></a>Integrate the SDK into your app

You should initialize the Adjust SDK **as soon as possible** within your application, pretty much upon app launch. Run the initialization code once per app launch: there's no need to place this code where it will be executed multiple times per app life cycle, since the Adjust SDK exists in your app as a static instance. In order to initialize the Adjust SDK in your app, please do the following:

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

Replace `{YourAppToken}` with your app token. You can find this in your [dashboard].

Depending on whether you are building your app for testing or for production, you need to set `environment` with one of these string values:

```lua
SANDBOX
PRODUCTION
```

**Important:** This value should be set to `SANDBOX` if and only if you or someone else is testing your app. Make sure to set the environment to `PRODUCTION` before you publish the app. Set it back to `SANDBOX` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is imperative that you keep this value meaningful at all times.

### <a id="sdk-logging">Adjust logging

You can increase or decrease the amount of logs you see in tests by setting the `logLevel` parameter value when calling the `adjust.create` method and assign one of the following string values to it:

```lua
"VERBOSE"   // enable all logging
"DEBUG"     // enable more logging
"INFO"      // default
"WARN"      // disable info logging
"ERROR"     // disable warnings as well
"ASSERT"    // disable errors as well
"SUPPRESS"  // disable all logging
```

### <a id="sdk-project-settings">Adjust project settings

Once the Adjust SDK has been added to your app, certain tweaks need to be performed so that the Adjust SDK can work properly. Below you can find a description of every additional thing that you need to do after you've added the Adjust SDK into to your app.

### <a id="android-permissions">Android permissions

Please add the following permissions, which the Adjust SDK needs, if they are not already present in your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

If you are **not targeting the Google Play Store**, please also add the following permission:

```xml
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
```

The Adjust SDK might need the `INTERNET` permission at any point in time. The Adjust SDK needs the `ACCESS_WIFI_STATE` permission in case your app is not targeting the Google Play Store and doesn't use Google Play Services. If you are targeting the Google Play Store and you are using Google Play Services, the Adjust SDK doesn't need the `ACCESS_WIFI_STATE` permission and, if you don't need it anywhere else in your app, you can remove it.

### <a id="android-gps"></a>Google Play Services

Since August 1, 2014, apps in the Google Play Store must use the [Google advertising ID][google-ad-id] to uniquely identify each device. To allow the Adjust SDK to use the Google advertising ID, you must integrate [Google Play Services][google-play-services].

Open the `build.gradle` file of your app and find the `dependencies` block. Add the following line:

```
compile 'com.google.android.gms:play-services-analytics:11.8.0'
```

To check whether the analytics part of the Google Play Services library has been successfully added to your app, you should start your app by configuring the SDK to run in `SANDBOX` mode and set the log level to `VERBOSE`. After that, track a session or some events in your app and observe the list of parameters in the verbose logs which are being read once the session or event has been tracked. If you see a parameter called `gps_adid` in there, you have successfully added the analytics part of the Google Play Services library to your app and our SDK is reading the necessary information from it.

### <a id="android-proguard"></a>Proguard settings

If you are using Proguard, add these lines to your Proguard file:

```
-keep public class com.adjust.sdk.** { *; }
-keep class com.google.android.gms.common.ConnectionResult {
    int SUCCESS;
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient {
    com.google.android.gms.ads.identifier.AdvertisingIdClient$Info getAdvertisingIdInfo(android.content.Context);
}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info {
    java.lang.String getId();
    boolean isLimitAdTrackingEnabled();
}
-keep public class com.android.installreferrer.** { *; }
```

### <a id="android-referrer"></a>Install referrer

In order to correctly attribute an install of your Android app to its source, Adjust needs information about the **install referrer**. This can be obtained by using the **Google Play Referrer API** or by catching the **Google Play Store intent** with a broadcast receiver.

**Important**: The Google Play Referrer API is newly introduced by Google with the express purpose of providing a more reliable and secure way of obtaining install referrer information and to aid attribution providers in the fight against click injection. It is **strongly advised** that you support this in your application. The Google Play Store intent is a less secure way of obtaining install referrer information. It will continue to exist in parallel with the new Google Play Referrer API temporarily, but it is set to be deprecated in future.

#### <a id="android-referrer-gpr-api"></a>Google Play Referrer API

In order to support this in your app, please make sure that you have followed the [Add the SDK to your Android project](#sdk-add-android) chapter properly and that you have following line added to your `build.gradle` file:

```
compile 'com.android.installreferrer:installreferrer:1.0'
```

Also, make sure that you have paid attention to the [Proguard settings](#android-proguard) chapter and that you have added all the rules mentioned in it, especially the one needed for this feature:

```
-keep public class com.android.installreferrer.** { *; }
```

This feature is supported if you are using the **Adjust SDK v4.12.0 or above**.

#### <a id="android-referrer-gps-intent"></a>Google Play Store intent

The Google Play Store `INSTALL_REFERRER` intent should be captured with a broadcast receiver. If you are **not using your own broadcast receiver** to receive the `INSTALL_REFERRER` intent, add the following `receiver` tag inside the `application` tag in your `AndroidManifest.xml`.

```xml
<receiver
    android:name="com.adjust.sdk.AdjustReferrerReceiver"
    android:exported="true" >
    <intent-filter>
        <action android:name="com.android.vending.INSTALL_REFERRER" />
    </intent-filter>
</receiver>
```

We use this broadcast receiver to retrieve the install referrer and pass it to our backend.

Please bear in mind that, if you are using your own broadcast receiver which handles the `INSTALL_REFERRER` intent, you don't need the Adjust broadcast receiver to be added to your manifest file. You can remove it, but, inside your own receiver, add the call to the Adjust broadcast receiver as described in our [Android guide][broadcast-receiver-custom].

### <a id="ios-frameworks"></a>iOS frameworks

The Adjust SDK iOS module adds three iOS frameworks to your generated Xcode project:

* `iAd.framework` - in case you are running iAd campaigns
* `AdSupport.framework` - for reading the iOS advertising ID (IDFA)
* `CoreTelephony.framework` - for reading MCC and MNC information

If you are not running any iAd campaigns, feel free to remove the `iAd.framework` dependency.

## <a id="additional-features"></a>Additional features

You can take advantage of the following features once you have integrated the Adjust SDK into your project.

### <a id="event-tracking"></a>Event tracking

You can use Adjust to track all kinds of events. Let's say you want to track every tap on a button. If you create a new event token in your [dashboard] - let's say that event token is `abc123` - you can add the following line in your button’s click handler method to track the click:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123"
})
```

### <a id="revenue-tracking"></a>Revenue tracking

If your users can generate revenue by tapping on advertisements or making in-app purchases, then you can track that revenue with events. Let's say a tap is worth €0.01. You could track the revenue event like this:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    revenue = 0.01,
    currency = "EUR"
})
```

When you set a currency token, Adjust will automatically convert the incoming revenue into a reporting revenue of your choice. Read more about [currency conversion here][currency-conversion].

### <a id="revenue-deduplication"></a>Revenue deduplication

You can also add an optional transaction ID to avoid tracking duplicate revenue. The last ten transaction IDs are remembered, and revenue events with duplicate transaction IDs are skipped. This is especially useful for in-app purchase tracking. You can see an example below.

If you want to track in-app purchases, please make sure to call `trackEvent` only when the transaction is completed and an item is purchased. That way you can avoid tracking revenue that is not actually being generated.

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    revenue = 0.01,
    currency = "EUR",
    transactionId = "YourTransactionId"
})
```

**Note**: Transaction ID is the iOS term. The unique identifier for completed Android in-app purchases is **Order ID**.

### <a id="callback-parameters"></a>Callback parameters

You can register a callback URL for an event in your [dashboard][dashboard], and we will send a GET request to that URL whenever the event is tracked. You can also put some key-value pairs in an object and pass them to the `trackEvent` method. We will then append these named parameters to your callback URL.

For example, suppose you have registered the URL `http://www.adjust.com/callback` for your event with event token `abc123` and execute the following lines:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    callbackParameters = {
        {
            key = "key",
            value = "value",
        },
        {
            key = "foo",
            value = "bar",
        }
    }
})
```

In that case, we would track the event and send a request to:

```
http://www.adjust.com/callback?key=value&foo=bar
```

It should be mentioned that we support a variety of placeholders, like `{idfa}` for iOS or `{gps_adid}` for Android, that can be used as parameter values.  In the resulting callback, the `{idfa}` placeholder would be replaced with the ID for advertisers of the current device for iOS and the `{gps_adid}` would be replaced with the Google advertising ID of the current device for Android. Also note that we don't store any of your custom parameters, but only append them to your callbacks. If you haven't registered a callback for an event, these parameters won't even be read.

You can read more about using URL callbacks, including a full list of available values, in our [callbacks guide][callbacks-guide].

### <a id="partner-parameters"></a>Partner parameters

Similarly to the callback parameters mentioned above, you can also add parameters that Adjust will transmit to network partners of your choice. You can activate these networks in your Adjust Dashboard.

These work similarly to the callback parameters mentioned above but parameter name used for them is `partnerParameters`:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    partnerParameters = {
        {
            key = "key",
            value = "value",
        },
        {
            key = "foo",
            value = "bar",
        }
    }
})
```

You can read more about special partners and networks in our [guide to special partners][special-partners].

### <a id="callback-id"></a>Callback identifier

You can also add custom string identifier to each event you want to track. This identifier will later be reported in event success and/or event failure callbacks to enable you to keep track on which event was successfully tracked or not. You can set this identifier by passing the `callbackId` field when tracking event:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    callbackId = "Your-Custom-Id"
})
```

### <a id="session-parameters"></a>Session parameters

Some parameters are saved to be sent with every event and session of the Adjust SDK. Once you have added any of these parameters, you don't need to add them every time, since they will be saved locally. If you add the same parameter twice, there will be no effect.

These session parameters can be called before the Adjust SDK is launched to make sure they are sent even on install. If you need to send them with an install but can only obtain the needed values after launch, it's possible to [delay](#delay-start) the first launch of the Adjust SDK to allow for this behavior.

### <a id="session-callback-parameters"></a>Session callback parameters

The same callback parameters that are registered for [events](#callback-parameters) can also be saved to be sent with every event or session of the Adjust SDK.

Session callback parameters have a similar interface to event callback parameters, except that, instead of adding the key and its value to an event, they are added through a call to the `addSessionCallbackParameter` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.addSessionCallbackParameter("foo", "bar")
```

Session callback parameters will be merged with the callback parameters added to an event. The callback parameters added to an event take precedence over the session callback parameters. This means that, when adding a callback parameter to an event with the same key as one added from the session, the callback parameter added to the event will prevail.

It's possible to remove a specific session callback parameter by passing the desired key to the `removeSessionCallbackParameter` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.removeSessionCallbackParameter("foo")
```

If you wish to remove all keys and values from the session callback parameters, you can reset them with the `resetSessionCallbackParameters` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.resetSessionCallbackParameters()
```

### <a id="session-partner-parameters"></a>Session partner parameters

In the same way that there are [session callback parameters](#session-callback-parameters) that are sent with every event or session of the Adjust SDK, there are also session partner parameters.

These will be transmitted to network partners that you have integrated and activated in your Adjust [dashboard].

Session partner parameters have a similar interface to event partner parameters. Except that, instead of adding the key and its value to an event, they are added through a call to the `addSessionPartnerParameter` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.addSessionPartnerParameter("foo", "bar")
```

The session partner parameters will be merged with the partner parameters added to an event. The partner parameters added to an event take precedence over the session partner parameters. This means that, when adding a partner parameter to an event with the same key as one added from the session, the partner parameter added to the event will prevail.

It's possible to remove a specific session partner parameter by passing the desired key to the `removeSessionPartnerParameter` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.removeSessionPartnerParameter("foo")
```

If you wish to remove all keys and values from the session partner parameters, you can reset them with the `resetSessionPartnerParameters` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.resetSessionPartnerParameters()
```

### <a id="delay-start"></a>Delay start

Delaying the start of the Adjust SDK allows your app some time to obtain session parameters, such as unique identifiers, to be sent on install.

Set the initial delay time, in seconds, with the `delayStart` parameter of the `adjust.create` method:

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    delayStart = 5.5
})
```

In this case, the Adjust SDK not send the initial install session and any events created for 5.5 seconds. Once this time has elapsed, or if you call `sendFirstPackages()` of the `adjust` instance in the meantime, every session parameter will be added to the delayed install session and events and the Adjust SDK will resume as usual.

**The maximum start time delay of the Adjust SDK is 10 seconds**.

### <a id="attribution-callback"></a>Attribution callback

You can register a listener to be notified of tracker attribution changes. Due to the different sources considered for attribution, this information cannot be provided synchronously. The simplest way to achieve this is to create a single anonymous listener which is going to be called **each time a user's attribution value changes**. Use the `setAttributionListener` method of the `adjust` instance to set the listener before starting the SDK:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function attributionListener(event)
    local json_attribution = json.decode(event.message)
    print("Attribution changed!")
    print("Tracker token: " .. json_attribution.trackerToken)
    print("Tracker name: " .. json_attribution.trackerName)
    print("Campaign: " .. json_attribution.campaign)
    print("Network: " .. json_attribution.network)
    print("Creative: " .. json_attribution.creative)
    print("Adgroup: " .. json_attribution.adgroup)
    print("Click label: " .. json_attribution.clickLabel)
    print("ADID: " .. json_attribution.adid)
end

-- ...

adjust.setAttributionListener(attributionListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

Within the listener function you have access to the `attribution` parameters. Here is a quick summary of their properties:

- `trackerToken`    the tracker token of the current attribution
- `trackerName`     the tracker name of the current attribution
- `network`         the network grouping level of the current attribution
- `campaign`        the campaign grouping level of the current attribution
- `adgroup`         the ad group grouping level of the current attribution
- `creative`        the creative grouping level of the current attribution
- `clickLabel`      the click label of the current attribution
- `adid`            the Adjust device identifier

Please make sure to consider our [applicable attribution data policies][attribution-data].

### <a id="session-event-callbacks">Session and event callbacks

You can register a callback to be notified of successfully tracked and failed events and/or sessions.

Follow the same steps as for attribution callbacks to implement the following callback function for successfully tracked events:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function eventTrackingSuccessListener(event)
    local json_event_success = json.decode(event.message)
    print("Event tracking success!")
    print("Event token: " .. json_event_success.eventToken)
    print("Message: " .. json_event_success.message)
    print("Timestamp: " .. json_event_success.timestamp)
    print("Callback Id: " .. json_event_success.callbackId)
    print("Adid: " .. json_event_success.adid)
    print("JSON response: " .. json_event_success.jsonResponse)
end

-- ...

adjust.setEventTrackingSuccessListener(eventTrackingSuccessListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

The following callback function for failed events:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function eventTrackingFailureListener(event)
    local json_event_failure = json.decode(event.message)
    print("Event tracking failure!")
    print("Event token: " .. json_event_failure.eventToken)
    print("Message: " .. json_event_failure.message)
    print("Timestamp: " .. json_event_failure.timestamp)
    print("Callback Id: " .. json_event_failure.callbackId)
    print("Adid: " .. json_event_failure.adid)
    print("Will retry: " .. json_event_failure.willRetry)
    print("JSON response: " .. json_event_failure.jsonResponse)
end

-- ...

adjust.setEventTrackingFailureListener(eventTrackingFailureListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

For successfully tracked sessions:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function sessionTrackingSuccessListener(event)
    local json_session_success = json.decode(event.message)
    print("Session tracking success!")
    print("Message: " .. json_session_success.message)
    print("Timestamp: " .. json_session_success.timestamp)
    print("Adid: " .. json_session_success.adid)
    print("JSON response: " .. json_session_success.jsonResponse)
end

-- ...

adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

And for failed sessions:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function sessionTrackingFailureListener(event)
    local json_session_failure = json.decode(event.message)
    print("Session tracking failure!")
    print("Message: " .. json_session_failure.message)
    print("Timestamp: " .. json_session_failure.timestamp)
    print("Adid: " .. json_session_failure.adid)
    print("Will retry: " .. json_session_failure.adid)
    print("JSON response: " .. json_session_failure.jsonResponse)
end

-- ...

adjust.setSessionTrackingFailureListener(sessionTrackingFailureListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

The callback functions will be called after the SDK tries to send a package to the server. Within the callback you have access to a response data object specifically for the callback. Here is a quick summary of the session response data properties:

- `var message` the message from the server or the error logged by the SDK
- `var timestamp` timestamp from the server
- `var adid` a unique device identifier provided by Adjust
- `var jsonResponse` the JSON object with the response from the server

Both event response data objects contain:

- `var eventToken` the event token, if the package tracked was an event
- `var callbackId` the custom defined callback ID set on event object

And both event and session failed objects also contain:

- `var willRetry` indicates there will be an attempt to resend the package at a later time

### <a id="disable-tracking"></a>Disable tracking

You can disable the Adjust SDK from tracking by invoking the `setEnabled` method of the `adjust` instance with the enabled parameter set to `false`. This setting is **remembered between sessions**, but it can only be activated after the first session.

```lua
local adjust = require "plugin.adjust"

adjust.setEnabled(false)
```

You can verify if the Adjust SDK is currently active with the `isEnabled` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.isEnabled(function(event) 
    print("isEnabled = " .. event.message) 
end)
```

It is always possible to activate the Adjust SDK by invoking `setEnabled` with the parameter set to `true`.

### <a id="offline-mode"></a>Offline mode

You can put the Adjust SDK in offline mode to suspend transmissions to our servers while retaining tracked data to be sent later. When in offline mode, all information is saved in a file, so it is best not to trigger too many events.

You can activate offline mode by calling the `setOfflineMode` method of the `adjust` instance with `true`.

```lua
local adjust = require "plugin.adjust"

adjust.setOfflineMode(true)
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with`false`. When the Adjust SDK is put back in online mode, all saved information is sent to our servers with the correct time information.

Unlike disabling tracking, **this setting is not remembered** between sessions. This means that the SDK is in online mode whenever it is started, even if the app was terminated in offline mode.

### <a id="event-buffering"></a>Event buffering

If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch every minute. You can enable event buffering by passing the `eventBufferingEnabled` parameter into the `adjust.create` method call:

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    eventBufferingEnabled = true
})
```


### <a id="gdpr-forget-me"></a>GDPR right to be forgotten

In accordance with article 17 of the EU's General Data Protection Regulation (GDPR), you can notify Adjust when a user has exercised their right to be forgotten. Calling the following method will instruct the Adjust SDK to communicate the user's choice to be forgotten to the Adjust backend:

```lua
local adjust = require "plugin.adjust"

adjust.gdprForgetMe();
```

Upon receiving this information, Adjust will erase the user's data and the Adjust SDK will stop tracking the user. No requests from this device will be sent to Adjust in the future.


### <a id="disable-third-party-sharing"></a>Disable third-party sharing for specific users

You can now notify Adjust when a user has exercised their right to stop sharing their data with partners for marketing purposes, but has allowed it to be shared for statistics purposes. 

Call the following method to instruct the Adjust SDK to communicate the user's choice to disable data sharing to the Adjust backend:

```lua
local adjust = require "plugin.adjust"

adjust.disableThirdPartySharing();
```

Upon receiving this information, Adjust will block the sharing of that specific user's data to partners and the Adjust SDK will continue to work as usual.

### <a id="sdk-signature"></a>SDK signature

An account manager must activate the Adjust SDK signature. Contact Adjust support (support@adjust.com) if you are interested in using this feature.

If the SDK signature has already been enabled on your account and you have access to App Secrets in your Adjust Dashboard, please use the method below to integrate the SDK signature into your app.

An App Secret is set by passing all secret parameters (`secretId`, `info1`, `info2`, `info3`, `info4`) when making the `adjust.create` method call:

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    secretId = aaa,
    info1 = bbb,
    info2 = ccc,
    info3 = ddd,
    info4 = eee
})
```

### <a id="background-tracking"></a>Background tracking

The default behavior of the Adjust SDK is to **pause sending HTTP requests while the app is in the background**. You can change this by passing the `sendInBackground` parameter into the `adjust.create` method call:

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    sendInBackground = true
})
```

If nothing is set here, sending in background is **disabled by default**.

### <a id="device-ids"></a>Device IDs

Certain services (such as Google Analytics) require you to coordinate device and client IDs in order to prevent duplicate reporting.

### <a id="di-idfa"></a>iOS Advertising Identifier

To obtain the IDFA, call the `getIdfa` method of the `adjust` instance. You need to pass a callback to that method in order to obtain the value:

```lua
local adjust = require "plugin.adjust"

adjust.getIdfa(function(event) 
    print("idfa = " .. event.message) 
end)
```

### <a id="di-gps-adid"></a>Google Play Services advertising identifier

If you need to obtain the Google advertising ID, you can call the `getGoogleAdId` method of the `adjust` instance. You need to pass a callback to that method in order to obtain the value:

```lua
local adjust = require "plugin.adjust"

adjust.getGoogleAdId(function(event) 
    print("googleAdId = " .. event.message) 
end)
```

### <a id="di-fire-adid"></a>Amazon advertising identifier

If you need to obtain the Amazon advertising ID, you can call the `getAmazonAdId` method on `adjust` instance:

```lua
local adjust = require "plugin.adjust"

adjust.getAmazonAdId(function(event) 
    print("amazonAdId = " .. event.message) 
end)
```

### <a id="di-adid"></a>Adjust device identifier

For every device with your app installed on it, the Adjust backend generates a unique **Adjust device identifier** (**adid**). In order to obtain this identifier, call the `getAdid` method of the `adjust` instance. You need to pass a callback to that method in order to obtain the value:

```lua
local adjust = require "plugin.adjust"

adjust.getAdid(function(event) 
    print("adid = " .. event.message) 
end)
```

**Note**: Information about the **adid** is only available after an app installation has been tracked by the Adjust backend. From that moment on, the Adjust SDK has information about the device **adid** and you can access it with this method. So, **it is not possible** to access the **adid** value before the SDK has been initialized and installation of your app has been successfully tracked.

### <a id="user-attribution"></a>User attribution

As described in the [attribution callback section](#attribution-callback), this callback is triggered to provide you with information about a new attribution whenever it changes. If you want to access information about a user's current attribution at any other time, you can make a call to the `getAttribution` method of the `adjust` instance:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

adjust.getAttribution(function(event) 
    local json_attribution = json.decode(event.message)
    print("Tracker token: " .. json_attribution.trackerToken)
    print("Tracker name: " .. json_attribution.trackerName)
    print("Campaign: " .. json_attribution.campaign)
    print("Network: " .. json_attribution.network)
    print("Creative: " .. json_attribution.creative)
    print("Adgroup: " .. json_attribution.adgroup)
    print("Click label: " .. json_attribution.clickLabel)
    print("ADID: " .. json_attribution.adid)
end)
```

**Note**: Information about current attribution is only available after an app installation has been tracked by the Adjust backend and the attribution callback has been triggered. From that moment on, the Adjust SDK has information about a user's attribution and you can access it with this method. So, **it is not possible** to access a user's attribution value before the SDK has been initialized and an attribution callback has been triggered.

### <a id="push-token"></a>Push token

To send us the push notification token, add the following call to Adjust **whenever you get your token in the app or when it gets updated**:

```js
local adjust = require "plugin.adjust"

adjust.setPushToken("YourPushNotificationToken");
```

Push tokens are used for Audience Builder and client callbacks, and they are required for the upcoming uninstall tracking feature.

### <a id="track-additional-ids"></a>Track additional device identifiers

If you are distributing your Android app **outside of the Google Play Store** and would like to track additional device identifiers (IMEI and MEID), you need to explicitly instruct the Adjust SDK to do so. You can do that by passing the `readMobileEquipmentIdentity` parameter when making the call to `adjust.create` method. **The Adjust SDK does not collect these identifiers by default**.

```lua
local adjust = require "plugin.adjust"

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    readMobileEquipmentIdentity = true
})
```

You will also need to add the `READ_PHONE_STATE` permission to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

In order to use this feature, additional steps are required within your Adjust Dashboard. For more information, please contact your dedicated account manager or write an email to support@adjust.com.

### <a id="pre-installed-trackers"></a>Pre-installed trackers

If you want to use the Adjust SDK to recognize users whose devices came with your app pre-installed, follow these steps.

1. Create a new tracker in your [dashboard].
2. Open your app delegate and set the default tracker by passing the `defaultTracker` parameter to the `adjust.create` method call:

    ```lua
    local adjust = require "plugin.adjust"

    adjust.create({
        appToken = "{YourAppToken}",
        environment = "SANDBOX",
        logLevel = "VERBOSE",
        defaultTracker = "abc123"
    })
    ```

  Replace `abc123` with the tracker token you created in step 1. Please note that the dashboard displays a tracker URL (including `http://app.adjust.com/`). In your source code, you should specify only the six-character token and not the entire URL.

3. Build and run your app. You should see a line like the following in the app's log output:

    ```
    Default tracker: 'abc123'
    ```

### <a id="deeplinking"></a>Deep linking

If you are using the Adjust tracker URL with an option to deep link into your app from the URL, there is the possibility to get information about the deeplink URL and its content. There are two scenarios when it comes to deeplinking: standard and deferred:

- Standard deeplinking is when a user already has your app installed.
- Deferred deeplinking is when a user does not have your app installed.

**Note**: At this moment, due to Corona framework limitations, standard deeplinking is currently fully supported **only on the Android platform**. Deferred deeplinking works well on both the iOS and Android platforms.

### <a id="deeplinking-standard"></a>Standard deeplinking

Standard deeplinking is a platform-specific feature and, in order to support it, you need to add some additional settings to your app. If your user already has the app installed and hits a tracker URL with deeplink information in it, your application will be opened and the content of the deep link will be sent to your app so that you can parse it and decide what to do next. 

**Note for iOS**: With the introduction of iOS 9, Apple has changed the way deeplinking is handled in apps. Depending on which deeplinking scenario you want to use for your app (or if you want to use them both to support a wide range of devices), you need to set up your app to handle one or both of the following scenarios. 

Like mentioned above, standard deeplinking is currently not supported due to Corona platform limitations, but, nevertheless, setting it up in your Xcode project as described in the chapters below is still required for deferred deep linking.

### <a id="deeplinking-ios-old"></a>Deeplinking on iOS 8 and earlier

To support deeplink handling in your app for iOS 8 and earlier versions, you need to set a `Custom URL Scheme` setting for your iOS app. In order to do this, please follow our [official iOS SDK README instructions][deeplinking-ios8-lower]. There is **no need** to override methods inside of `AppDelegate.m` (in Corona's case: `AppCoronaDelegate.mm`), just follow the Xcode project setting part of the instructions.

### <a id="deeplinking-ios-new"></a>Deeplinking on iOS 9 and later

Starting from **iOS 9**, Apple introduced suppressed support for the old style deeplinking with custom URL schemes, as described above, in favor of `universal links`. If you want to support deeplinking in your app for iOS 9 and higher, you need to add support for universal link handling. In order to do this, please follow our [official iOS SDK README instructions][deeplinking-ios9-higher]. There is **no need** to override methods inside of `AppDelegate.m` (in Corona's case: `AppCoronaDelegate.mm`), just follow the Xcode project setting part of the instructions.

### <a id="deeplinking-android"></a>Deeplinking on Android

In order to support deeplinking in your Android app, you need to add support for handling the custom URL scheme that you want to use to open your Android app. In order to do this, please follow our [official Android SDK README instructions][deeplinking-android].

In order to obtain information about the link that caused your app to open, you need to add some additional code to your `main.lua` file:

```lua
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("url = " .. event.url)
    end
end
```

The value of the `event.url` variable in the above example (if available) represents the actual link that opened your Android app.

By completing this, you should be able to handle direct deeplinking on **Android**.

### <a id="deeplinking-deferred"></a>Deferred deeplinking

While deferred deeplinking is not supported out of the box on Android or iOS, the Adjust SDK makes it possible.
 
In order to get information about the URL content through deferred deeplinking, you should set a callback method on the the `adjust` instance which will receive one parameter where the content of the URL will be delivered. You should set this method on the config object by calling the `setDeferredDeeplinkListener` method:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function deferredDeeplinkListener(event)
    print("deeplink = " .. event.message)
end

-- ...

adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

In deferred deeplinking, there is one additional setting available to pass to the `adjust.create` method call. Once the Adjust SDK gets the deferred deeplink information, you can choose whether our SDK opens this URL or not. You can choose to set this option by passing the `shouldLaunchDeeplink` parameter to the `adjust.create` method call:


```lua
local adjust = require "plugin.adjust"
local json = require "json"

local function deferredDeeplinkListener(event)
    print("deeplink = " .. event.message)
end

-- ...

adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)

-- ...

adjust.create({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    shouldLaunchDeeplink = false
})
```

If nothing is set here, **the Adjust SDK will always try to launch the URL by default**.

### <a id="deeplinking-reattribution"></a>Reattribution via deeplinks

Adjust enables you to run re-engagement campaigns by using deeplinks. For more information on this, please check our [official docs][reattribution-with-deeplinks].

If you are using this feature, in order for your users to be properly reattributed, you need to make one additional call to the Adjust SDK in your app.

Once you have received information about the deeplink content in your app, add a call to the `appWillOpenUrl` method of the `adjust` instance. By making this call, the Adjust SDK will try to find if there is any new attribution information inside of the deeplink, and, if there is any, it will be sent to the Adjust backend. If a user should be reattributed through a click on an Adjust tracker URL with deeplink content in it, you will see the [attribution callback](#attribution-callback) in your app being triggered with new attribution information for this user.

In the code examples described above, a call to the `appWillOpenUrl` method should be done like this:


```lua
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("url = " .. event.url)
        
        adjust.appWillOpenUrl(event.url)
    end
end
```

Having added these calls, if the deeplink that opened your app contains any reattribution parameters, our SDK will pass that information to the backend, which will decide whether the user is going to be reattributed or not. As already mentioned, if a user gets reattributed, an attribution callback (if implemented) will be triggered with the new attribution value, and you will have this information in your app, as well.

## <a id="license"></a>License

The Adjust SDK is licensed under the MIT License.

Copyright (c) 2012-2019 Adjust GmbH, http://www.adjust.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


[dashboard]:    http://adjust.com
[adjust.com]:   http://adjust.com

[plugin]:      ./plugin
[releases]:     https://github.com/adjust/corona_sdk/releases

[google-ad-id]:         https://developer.android.com/google/play-services/id.html
[enable-ulinks]:        https://github.com/adjust/ios_sdk#deeplinking-setup-new
[event-tracking]:       https://docs.adjust.com/en/event-tracking
[callbacks-guide]:      https://docs.adjust.com/en/callbacks
[attribution-data]:     https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[special-partners]:     https://docs.adjust.com/en/special-partners
[broadcast-receiver]:   https://github.com/adjust/android_sdk#sdk-broadcast-receiver

[deeplinking-android]:    https://github.com/adjust/android_sdk/blob/master/README.md#deeplinking
[google-launch-modes]:    http://developer.android.com/guide/topics/manifest/activity-element.html#lmode
[currency-conversion]:    https://docs.adjust.com/en/event-tracking/#tracking-purchases-in-different-currencies
[google-play-services]:   http://developer.android.com/google/play-services/index.html
[deeplinking-ios8-lower]: https://github.com/adjust/ios_sdk#deeplinking-setup-old

[deeplinking-ios9-higher]:      https://github.com/adjust/ios_sdk#deeplinking-setup-new
[bencooding-android-tools]: 	  https://github.com/benbahrenburg/benCoding.Android.Tools
[broadcast-receiver-custom]:    https://github.com/adjust/android_sdk/blob/master/doc/english/referrer.md
[reattribution-with-deeplinks]: https://docs.adjust.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link
