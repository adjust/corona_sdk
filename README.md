## Summary

This is the Adjust™ plugin for Solar2D (ex Corona). You can read more about Adjust™ at [adjust.com](https://adjust.com).

## Table of contents

* [Example app](#example-app)
* [Integration guide](#integration-guide)
   * [Simulator integration](#integration-simulator)
   * [Get the SDK](#sdk-get)
   * [Add the SDK to your Android project](#sdk-add-android)
   * [Add the SDK to your iOS project](#sdk-add-ios)
   * [Integrate the SDK into your app](#sdk-integrate)
   * [Adjust logging](#sdk-logging)
   * [Android permissions](#android-permissions)
   * [iOS frameworks](#ios-frameworks)
   * [SDK signature](#sdk-signature)
* [Additional features](#additional-features)
   * [Send event information](#event-sending)
      * [Event revenue](#event-revenue)
      * [Event deduplication](#event-deduplication)
      * [Event callback identifier](#event-callback-id)
      * [Event callback parameters](#event-callback-params)
      * [Event partner parameters](#event-partner-params)
   * [User attribution](#user-attribution)
      * [Attribution callback](#attribution-callback)
      * [Get user attribution](#attribution-getter)
   * [Preinstalled apps](#preinstalled-apps)
      * [Default link token](#preinstall-default-link)
   * [Global parameters](#global-params)
      * [Global callback parameters](#global-callback-params)
      * [Global partner parameters](#global-partner-params)
   * [Privacy features](#privacy-features)
      * [GDPR right to be forgotten](#gdpr-forget-me)
      * [Third party sharing](#third-party-sharing)
      * [Disable third-party sharing for specific users](#disable-third-party-sharing)
      * [Enable or re-enable third-party sharing for specific users](#enable-third-party-sharing)
      * [Send granular options](#send-granular-options)
      * [Manage Facebook Limited Data Use](#facebook-limited-data-use)
      * [Provide consent data to Google (Digital Markets Act compliance)](#digital-markets-act)
      * [Update partner sharing settings](#partner-sharing-settings)
      * [Consent measurement for specific users](#measurement-consent)
      * [COPPA compliance](#coppa-compliance)
      * [Play Store kids apps](#play-store-kids-apps)
      * [URL strategies](#url-strategies)
   * [Deep linking](#deeplinking)
      * [Deferred deep linking scenario](#deeplinking-deferred)
      * [Reattribution via deep links](#deeplinking-reattribution)
      * [Resolve Adjust short links](#short-links-resolution)
      * [Get last processed deep link](#last-deeplink-getter)
   * [App Tracking Transparency](#app-tracking-transparency)
      * [ATT authorization wrapper](#att-wrapper)
      * [Get current authorization status](#att-status-getter)
      * [ATT prompt waiting interval](#att-waiting-interval)
   * [SKAdNetwork and conversion values](#skan-framework)
      * [Disable SKAdNetwork communication](#skan-disable)
      * [Listen for changes to conversion values](#skan-update-callback)
      * [Set up direct install postbacks](#skan-postbacks)
   * [Record ad revenue information](#adrevenue-recording)
      * [Ad revenue amount](#adrevenue-amount)
      * [Ad revenue network](#adrevenue-network)
      * [Ad revenue unit](#adrevenue-unit)
      * [Ad revenue placement](#adrevenue-placement)
      * [Ad impressions count](#adrevenue-impressions)
      * [Ad revenue callback parameters](#adrevenue-callback-params)
      * [Ad revenue partner parameters](#adrevenue-partner-params)
   * [Purchase verification](#purchase-verification)
      * [Verify purchase and record event](#verify-and-record)
      * [Verify purchase only](#verify-only)
   * [Send subscription information](#subscription-sending)
      * [Subscription purchase date](#subscription-purchase-date)
      * [Subscription region](#subscription-region)
      * [Subscription callback parameters](#subscription-callback-params)
      * [Subscription partner parameters](#subscription-partner-params)
   * [Device IDs](#device-ids)
      * [iOS advertising identifier](#idfa)
      * [iOS identifier for vendors](#idfv)
      * [Google Play Services advertising identifier](#gps-adid)
      * [Amazon advertising identifier](#fire-adid)
      * [Adjust device identifier](#adid)
   * [Session and event callbacks](#session-event-callbacks)
   * [Disable the SDK](#disable-sdk)
   * [Offline mode](#offline-mode)
   * [Sending from background](#background-sending)
   * [External device ID](#external-device-id)
   * [Push token](#push-token)
   * [Disable AdServices information reading](#disable-ad-services)
* [License](#license)

## <a id="example-app"></a>Example app

An example app is included in the [`plugin` directory](./plugin). You can use the example app to see how the Adjust SDK can be integrated.

## <a id="integration-guide"></a>Integration guide

The Adjust Corona SDK enables you to record attribution, events, and more in your Solar2D / Corona app. Follow the steps in this guide to set up your app to work with the Adjust SDK.

> Before you begin: The Adjust SDK supports iOS 12 or later and Android API level 21 (Lollipop) or later.

### <a id="integration-simulator"></a>Simulator integration

Easiest way to add Adjust SDK to your Simulator project is to add `build.settings` entry:

```lua
settings = 
{
    iphone =
    {
        plist =
        {
            NSUserTrackingUsageDescription = "Reason for asking access to IDFA identifier",
        },
    },
    plugins =
    {
        ['plugin.adjust'] = { publisherId = 'com.adjust' },
    }
}

```

### <a id="sdk-get"></a>Get the SDK

You can also get the latest version of the Adjust SDK from our [releases page][releases]. Please, download both the `plugin.adjust.jar` and `libplugin_adjust.a` files, since you will need to add them to your app's projects. In addition to that, you will also need to download the latest version of the Adjust signature library for each of the platforms from [here](https://github.com/adjust/adjust_signature_sdk/releases) and add them to your app's projects.

#### <a id="sdk-add-android"></a>Add the SDK to your Android project

Inside your Android Studio app project, create a `libs` folder inside of your app folder and add the `plugin.adjust.jar` to it. After that, please update your app's `build.gradle` file and add the following lines to your `dependencies` section to add the dependency to the native Adjust Android SDK:

```
compile 'com.adjust.sdk:adjust-android:5.0.2'
compile 'com.android.installreferrer:installreferrer:2.2'
```

#### <a id="sdk-add-ios"></a>Add the SDK to your iOS project

Inside your Xcode app project, select your app's target, go to `General -> Linked Frameworks and Libraries` section, press the `+` button and add the `libplugin_adjust.a` and `AdjustSigSdk.a` library into the list.

### <a id="sdk-integrate"></a>Integrate the SDK into your app

In order to start the Adjust SDK, initialize your config object with your app token and the environment you want to run your application in.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

Replace `{YourAppToken}` with your app token. You can find this in your [dashboard](https://dash.adjust.com).

Depending on whether you build your app for testing or for production, you must set `environment` with one of these values:

```lua
SANDBOX
PRODUCTION
```

**Important:** This value should be set to `SANDBOX` if and only if you or someone else is testing your app. Make sure to set the environment to `PRODUCTION` just before you publish the app. Set it back to `SANDBOX` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is very important that you keep this value meaningful at all times!

### <a id="sdk-logging"></a>Adjust logging

You can increase or decrease the amount of logs you see in tests by setting the `logLevel` parameter value when calling the `initSdk` method and assign one of the following string values to it:

```lua
"VERBOSE"   // enable all logging
"DEBUG"     // enable more logging
"INFO"      // default
"WARN"      // disable info logging
"ERROR"     // disable warnings as well
"ASSERT"    // disable errors as well
"SUPPRESS"  // suppress all logging
```

Example:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

### <a id="android-permissions"></a>Android permissions

The Adjust SDK includes the `com.google.android.gms.AD_ID` and `android.permission.INTERNET` permissions by default. You can remove the `com.google.android.gms.AD_ID` permission by adding a remove directive to your app's manifest file if you need to make your app COPPA-compliant or if you don't target the Google Play Store.

```xml
<manifest>
    <uses-permission android:name="com.google.android.gms.AD_ID" tools:node="remove" />
</manifest>
```

See Google's [AdvertisingIdClient.Info](https://developers.google.com/android/reference/com/google/android/gms/ads/identifier/AdvertisingIdClient.Info#public-string-getid) documentation for more information about this permission.

### <a id="ios-frameworks"></a>iOS frameworks

You can add following iOS frameworks to your generated Xcode project to take advantage of additional features:

* `AdServices.framework` - needed for Apple Search Ads tracking
* `AdSupport.framework` - needed for reading iOS Advertising Id (IDFA)
* `StoreKit.framework` - needed for communication with `SKAdNetwork` framework
* `AppTrackingTransparency.framework` - needed to ask for user's consent to be tracked and obtain status of that consent

### <a id="sdk-signature"></a>SDK signature

By following the Adjust SDK integration guide, you will be adding signature library for iOS by manually linking it and the signature library for Android will be automatically added to your app once you specify the dependency to native Adjust Android SDK inside of your `build.gradle` file. After this, all the setup for signing of the SDK traffic has been completed. However, enforcing signing checks is not a feature that is enabled by default. If you want to take the advantage of this feature to secure communications between the Adjust SDK and Adjust's servers, follow the instructions in the [SDK signature guide on the Adjust Help Center](https://help.adjust.com/en/article/sdk-signature).

## <a id="additional-features"></a>Additional features

You can take advantage of the following features once the Adjust SDK is integrated into your project.

### <a id="event-sending"></a>Send event information

You can tell Adjust about every event you want to record. Let's say that event token is `abc123`. You can record that event like this:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123"
})
```

### <a id="event-revenue"></a>Event revenue

If your users can generate revenue by tapping on advertisements or making in-app purchases, then you can record those revenues with events. Let's say a tap is worth €1.50. You could record the revenue event like this:

```lua
local adjust = require "plugin.adjust"

adjust.trackEvent({
    eventToken = "abc123",
    revenue = 1.5,
    currency = "EUR"
})
```

### <a id="event-deduplication"></a>Event deduplication

You can also add an optional deduplication ID to avoid recording duplicate events. The last ten transaction IDs are remembered by default, and events with duplicate deduplication IDs are skipped. If you would like to make the Adjust SDK to remember more than last 10 transaction IDs, you can do that by passing the new limit to `eventDeduplicationIdsMaxSize` parameter of the initialization map:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    eventDeduplicationIdsMaxSize = 20
})

-- ...

adjust.trackEvent({
    eventToken = "abc123",
    revenue = 1.5,
    currency = "EUR",
    deduplicationId = "deduplucation-id"
})
```

### <a id="event-callback-id"></a>Event callback identifier

You can also add custom string identifier to each event you want to record. This identifier will later be reported in event success and/or event failure callbacks to enable you to keep track on which event was successfully recorded or not. You can set this identifier by setting the `callbackId` parameter of the `trackEvent` parameter map:

```lua
adjust.trackEvent({
    eventToken = "abc123",
    callbackId = "callback-id"
})
```

### <a id="event-callback-params"></a>Event callback parameters

You can also register a callback URL for that event in your [dashboard](https://dash.adjust.com), and we will send a GET request to that URL whenever the event gets recorded. In that case, you can also put some key-value pairs in an object and pass it to the `trackEvent` method. We will then append these named parameters to your callback URL.

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

In this case we would record the event and send a request to:

```
http://www.adjust.com/callback?key=value&foo=bar
```

It should be mentioned that we support a variety of placeholders like `{idfa}` for iOS or `{gps_adid}` for Android that can be used as parameter values. In the resulting callback, the `{idfa}` placeholder would be replaced with the ID for Advertisers of the current device for iOS and the `{gps_adid}` would be replaced with the Google Advertising ID of the current device for Android. Also note that we don't store any of your custom parameters, but only append them to your callbacks. If you haven't registered a callback for an event, these parameters won't even be read.

### <a id="event-partner-params"></a>Event partner parameters

You can also add parameters for integrations that have been activated in your Adjust dashboard that can be transmitted to network partners.

This works similarly to the callback parameters mentioned above but parameter name used for them is `partnerParameters`:

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

### <a id="user-attribution"></a>User attribution

Each recorded install is getting certain attribution assigned and also, during the app lifetime, the attribution can change.

### <a id="attribution-callback"></a>Attribution callback

You can register a callback to be notified of attribution changes. Due to the different sources considered for attribution, this information can not be provided synchronously. You can implement attribution callback like this:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- attribution callback needs to be set before calling initSdk method
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

-- ...

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

The callback function will get called when the SDK receives final attribution data. Within the callback function you have access to the `attribution` parameter. Here is a quick summary of its properties:

- `trackerToken`        the tracker token of the current attribution
- `trackerName`         the tracker name of the current attribution
- `network`             the network grouping level of the current attribution
- `campaign`            the campaign grouping level of the current attribution
- `adgroup`             the ad group grouping level of the current attribution
- `creative`            the creative grouping level of the current attribution
- `clickLabel`          the click label of the current attribution
- `costType`            the cost type, use `isCostDataInAttributionEnabled` to request this value
- `costAmount`          the price, use `isCostDataInAttributionEnabled` to request this value
- `costCurrency`        the currency used, use `isCostDataInAttributionEnabled` to request this value
- `fbInstallReferrer`   the Facebook install referrer information

### <a id="attribution-getter"></a>Get user attribution

If you want to access information about a user's current attribution whenever you need it, you can make a call to the `getAttribution` method:

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

**Note**: Information about current attribution is available after app installation has been recorded by the Adjust backend and the attribution callback has been initially triggered. From that moment on, the Adjust SDK has information about a user's attribution and you can access it with this method. So, **it is not possible** to access a user's attribution value before the SDK has been initialised and an attribution callback has been triggered.

### <a id="preinstalled-apps"></a>Preinstalled apps

You can use the Adjust SDK to record activity from apps that came preinstalled on a user’s device. This enables you to attribute these users to a custom defined campaign link instead to an organic one.

### <a id="preinstall-default-link"></a>Default link token

Configuring a default link token enables you to attribute all preinstalls to a predefined Adjust link. Adjust records all information against this token until the attribution source changes. To set this up, first you need to [create a new campaign link in Campaign Lab](https://help.adjust.com/en/article/links). After doing this, you need to set `defaultTracker` parameter of the initialization map and pass a token you got generated for your campign link:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    defaultTracker = "abc123"
})
```

In case this approach is not applicable to your preinstall use case, please reach out to support@adjust.com to explore other ways of how the attribution for preinstalled apps can be handled.

### <a id="global-params"></a>Global parameters

Some parameters are saved to be sent in every session, event, ad revenue and subscription request of the Adjust SDK. Once you have added any of these parameters, you don't need to add them every time, since they will be saved locally. If you add the same parameter twice, there will be no effect. These global parameters can be set before the Adjust SDK is launched to make sure they are sent even on install.

### <a id="global-callback-params"></a>Global callback parameters

The global callback parameters have a similar interface to the event callback parameters. Instead of adding the key and its value to an event, it's added through a call to `addGlobalCallbackParameter` method:

```lua
local adjust = require "plugin.adjust"

adjust.addGlobalCallbackParameter("foo", "bar")
```

The global callback parameters will be merged with the callback parameters added to an event / ad revenue / subscription. The callback parameters added to any of these packages take precedence over the global callback parameters. Meaning that, when adding a callback parameter to any of these packages with the same key to one added globaly, the value that prevails is the callback parameter added any of these particular packages.

It's possible to remove a specific global callback parameter by passing the desired key to the `removeGlobalCallbackParameter` method:

```lua
local adjust = require "plugin.adjust"

adjust.removeGlobalCallbackParameter("foo")
```

If you wish to remove all keys and values from the global callback parameters, you can remove them with the `removeGlobalCallbackParameters` method:

```lua
local adjust = require "plugin.adjust"

adjust.removeGlobalCallbackParameters()
```

### <a id="global-partner-params"></a>Global partner parameters

In the same way that there are [global callback parameters](#session-callback-params) that are sent for every event or session of the Adjust SDK, there are also global partner parameters.

These will be transmitted to network partners, for the integrations that have been activated in your Adjust [dashboard](https://dash.adjust.com).

The global partner parameters have a similar interface to the event / ad revenue / subscription partner parameters. Instead of adding the key and its value to an event, it's added through a call to the `addGlobalPartnerParameter` method:

```lua
local adjust = require "plugin.adjust"

adjust.addGlobalPartnerParameter("foo", "bar")
```

The global partner parameters will be merged with the partner parameters added to an event / ad revenue / subscription. The partner parameters added to any of thes packages take precedence over the global partner parameters. Meaning that, when adding a partner parameter to any of these packages with the same key to one added globally, the value that prevails is the partner parameter added to any of these particular packages.

It's possible to remove a specific global partner parameter by passing the desired key to the `removeGlobalPartnerParameter` method:

```lua
local adjust = require "plugin.adjust"

adjust.removeGlobalPartnerParameter("foo")
```

If you wish to remove all keys and values from the global partner parameters, you can remove them with the `removeGlobalPartnerParameters` method:

```lua
local adjust = require "plugin.adjust"

adjust.removeGlobalPartnerParameters()
```

### <a id="privacy-features"></a>Privacy features

The Adjust SDK contains features that you can use to handle user privacy in your app.

### <a id="gdpr-forget-me"></a>GDPR right to be forgotten

In accordance with article 17 of the EU's General Data Protection Regulation (GDPR), you can notify Adjust when a user has exercised their right to be forgotten. Calling the following method will instruct the Adjust SDK to communicate the user's choice to be forgotten to the Adjust backend:

```lua
local adjust = require "plugin.adjust"

adjust.gdprForgetMe()
```

Upon receiving this information, Adjust will erase the user's data and no requests from this device will be sent to Adjust in the future.

### <a id="third-party-sharing"></a>Third-party sharing for specific users

You can notify Adjust when a user disables, enables, and re-enables data sharing with third-party partners.

### <a id="disable-third-party-sharing"></a>Disable third-party sharing for specific users

Call the following method to instruct the Adjust SDK to communicate the user's choice to disable data sharing to the Adjust backend:

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    enabled = false,
})
```

Upon receiving this information, Adjust will block the sharing of that specific user's data to partners and the Adjust SDK will continue to work as usual.

### <a id="enable-third-party-sharing">Enable or re-enable third-party sharing for specific users</a>

Call the following method to instruct the Adjust SDK to communicate the user's choice to share data or change data sharing, to the Adjust backend:

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    enabled = true,
})
```

Upon receiving this information, Adjust changes sharing the specific user's data to partners. The Adjust SDK will continue to work as expected.

### <a id="send-granular-options">Send granular options</a>

You can attach granular information when a user updates their third-party sharing preferences. Use this information to communicate more detail about a user’s decision. To do this, set the `granularOptions` parameter like this:

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    granularOptions = {
        {
            partnerName = "PartnerName",
            key = "key",
            value = "value",
        },
    },
})
```

The following partners are available:

| Partner name              | String value                  |
|---------------------------|-------------------------------|
| AppleAds                  | `apple_ads`                   |
| Facebook                  | `facebook`                    |
| GoogleAds                 | `adwords`                     |
| GoogleMarketingPlatform   | `google_marketing_platform`   |
| Snapchat                  | `snapchat`                    |
| Tencent                   | `tencent`                     |
| TikTokSan                 | `tiktok_san`                  |
| X (formerly Twitter)      | `twitter`                     |
| YahooGemini               | `yahoo_gemini`                |
| YahooJapanSearch          | `yahoo_japan_search`          |

### <a id="facebook-limited-data-use">Manage Facebook Limited Data Use</a>

Facebook provides a feature called Limited Data Use (LDU) to comply with the California Consumer Privacy Act (CCPA). This feature enables you to notify Facebook when a California-based user is opted out of the sale of data. You can also use it if you want to opt all users out by default.

You can update the Facebook LDU status by passing arguments to the `granularOptions` parameter.

| Parameter                        | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| `partner_name`                   | Use `facebook` to toggle LDU.                                              |
| `data_processing_options_country`| The country in which the user is located.                                  |
|                                  | - `0`: Request that Facebook use geolocation.                              |
|                                  | - `1`: United States of America.                                           |
| `data_processing_options_state`  | Notifies Facebook in which state the user is located.                      |
|                                  | - `0`: Request that Facebook use geolocation.                              |
|                                  | - `1000`: California.                                                      |
|                                  | - `1001`: Colorado.                                                        |
|                                  | - `1002`: Connecticut.                                                     |

> Note: If you call this method with a 0 value for **either** `data_processing_options_country` or `data_processing_options_state`, the Adjust SDK passes **both** fields back as 0.

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    granularOptions = {
        {
            partnerName = "facebook",
            key = "data_processing_options_country",
            value = "1",
        },
        {
            partnerName = "facebook",
            key = "data_processing_options_state",
            value = "1000",
        },
    },
})
```

### <a id="digital-markets-act">Provide consent data to Google (Digital Markets Act compliance)</a>

> Important: Passing these options is required if you use Google Ads or Google Marketing Platform and have users located in the European Economic Area (EEA).

To comply with the EU’s Digital Markets Act (DMA), Google Ads and the Google Marketing Platform require explicit consent to receive Adjust’s attribution requests to their APIs. To communicate this consent, you need to add the following granular options to your third party sharing instance for the partner `google_dma`.

| Key                 | Value               | Description                                                                                                      |
|---------------------|---------------------|------------------------------------------------------------------------------------------------------------------|
| `eea`               | `1` (positive) \| `0` (negative) | Informs Adjust whether users installing the app are within the European Economic Area. Includes EU member states, Switzerland, Norway, Iceland, and Slovenia. |
| `ad_personalization`| `1` (positive) \| `0` (negative) | Informs Adjust whether users consented with being served personalized ads via Google Ads and/or Google Marketing Platform. This parameter also informs the `npa` parameter reserved for Google Marketing Platform. |
| `ad_user_data`      | `1` (positive) \| `0` (negative) | Informs Adjust whether users consented with their advertiser ID being leveraged for attribution purposes.         |

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    granularOptions = {
        {
            partnerName = "google_dma",
            key = "eea",
            value = "1",
        },
        {
            partnerName = "google_dma",
            key = "ad_personalization",
            value = "1",
        },
        {
            partnerName = "google_dma",
            key = "ad_user_data",
            value = "1",
        },
    },
})
```

### <a id="partner-sharing-settings">Update partner sharing settings</a>

By default, Adjust shares all metrics with any partners you’ve configured in your app settings. You can use the Adjust SDK to update your third party sharing settings on a per-partner basis. To do this, set the `partnerSharingSettings` parameter with the following arguments:

| Argument     | Data type | Description                                                |
|--------------|-----------|------------------------------------------------------------|
| `partnerName`| string    | The name of the partner. [Download the full list of available partners](https://assets.ctfassets.net/5s247im0esyq/5WvsJ7J7fGFUlfsFeGdalj/643651619adc3256acac7885ec60624d/modules.csv). |
| `key`        | string    | The metric to share with the partner.                      |
| `value`      | bool   | The user’s decision.                                       |

You can use the `key` to specify which metrics you want to disable or re-enable. If you want to enable/disable sharing all metrics, you can use the `all` key. The full list of available metrics is available below:

- `ad_revenue`
- `all`
- `attribution`
- `update`
- `att_update`
- `cost_update`
- `event`
- `install`
- `reattribution`
- `reattribution_reinstall`
- `reinstall`
- `rejected_install`
- `rejected_reattribution`
- `sdk_click`
- `sdk_info`
- `session`
- `subscription`
- `uninstall`

When you set a `false` value against a metric for a partner, Adjust stops sharing the metric with the partner.

> Tip: If you only want to share a few metrics with a partner, you can pass the `all` key with a `false` value to disable all sharing and then pass individual metrics with a `true` value to limit what you share.

Examples:

If you want to stop sharing all metrics with a specific partner, pass the `all` key with a `false` value.

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    partnerSharingSettings = {
        {
            partnerName = "PartnerA",
            key = "all",
            value = false
        },
    },
})
```

To re-enable sharing, pass the `all` key with a `true` value.

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    partnerSharingSettings = {
        {
            partnerName = "PartnerA",
            key = "all",
            value = true
        },
    },
})
```

You can stop or start sharing specific metrics by calling the `addPartnerSharingSetting` method multiple times with different keys. For example, if you only want to share event information with a partner, you can pass:

- `all` with a `false` value to disable sharing all information
- `event` with a `true` value to enable event sharing

> Note: Specific keys always take priority over `all`. If you pass `all` with other keys, the individual key values override the `all` setting.

```lua
local adjust = require "plugin.adjust"

adjust.trackThirdPartySharing({
    partnerSharingSettings = {
        {
            partnerName = "PartnerA",
            key = "all",
            value = false
        },
        {
            partnerName = "PartnerA",
            key = "event",
            value = true
        },
    },
})
```

### <a id="measurement-consent"></a>Consent measurement for specific users

If you’re using [Data Privacy settings](https://help.adjust.com/en/article/manage-data-collection-and-retention) in your Adjust dashboard, you need to set up the Adjust SDK to work with them. This includes settings such as consent expiry period and user data retention period.

To toggle this feature, call the `trackMeasurementConsent` method with the boolean parameter indicating whether consent measurement is enabled (`true`) or not (`false`).

When enabled, the SDK communicates the data privacy settings to Adjust’s servers. Adjust’s servers then applies your data privacy rules to the user. The Adjust SDK continues to work as expected.

```lua
local adjust = require "plugin.adjust"

adjust.trackMeasurementConsent(true)
-- or
adjust.trackMeasurementConsent(false)
```

### <a id="coppa-compliance"></a>COPPA compliance

f you need your app to be compliant with the Children’s Online Privacy Protection Act (COPPA), set the `isCoppaComplianceEnabled` parameter on your initialization map. This performs the following actions:

1. Disables third-party sharing **before** the user launches their first `session`.
2. Prevents the SDK from reading device and advertising IDs (for example: `gps_adid`, `idfa`, and `android_id`).

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isCoppaComplianceEnabled = true
})
```

### <a id="play-store-kids-apps"></a>Play Store kids apps

If your app targets users under the age of 13, and the install region **isn’t** the USA, you need to mark it as a Kids App. This prevents the SDK from reading device and advertising IDs (for example: `idfa`, `gps_adid` and `android_id`).

To mark your app as a Play Store Kids App, set the `isPlayStoreKidsComplianceEnabled` parameter on your initialization map.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isPlayStoreKidsComplianceEnabled = true
})
```

### <a id="url-strategies"></a>URL strategies

The URL strategy feature allows you to set either:

- The country in which Adjust stores your data (data residency).
- The endpoint to which the Adjust SDK sends traffic (URL strategy).

This is useful if you’re operating in a country with strict privacy requirements. When you set your URL strategy, Adjust stores data in the selected data residency region or sends traffic to the chosen domain.

To set your country of data residency, set the URL strategy parameters in your initialization map:

- `urlStrategyDomains` (`list`): The country or countries of data residence, or the endpoints to which you want to send SDK traffic.
- `useSubdomains` (`bool`): Whether the source should prefix a subdomain.
- `isDataResidency` (`bool`): Whether the domain should be used for data residency.

| URL strategy                | Main and fallback domain                           | Use sub domains | Is Data Residency |
|-----------------------------|----------------------------------------------------|-----------------|-------------------|
| EU data residency           | `{"eu.adjust.com"}`                                  | `true`          | `true`            |
| Turkish data residency      | `{"tr.adjust.com"}`                                  | `true`          | `true`            |
| US data residency           | `{"us.adjust.com"}`                                  | `true`          | `true`            |
| China global URL strategy   | `{"adjust.world"`, `"adjust.com"}`                   | `true`          | `false`           |
| China only URL strategy     | `{"adjust.cn"}`                                      | `true`          | `false`           |
| India URL strategy          | `{"adjust.net.in"`, `"adjust.com"}`                  | `true`          | `false`           |

Examples:

```lua
-- India URL strategy
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "adjust.net.in", "adjust.com" },
    useSubdomains = true,
    isDataResidency = false
})
```

```lua
-- China global URL strategy
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "adjust.world", "adjust.com" },
    useSubdomains = true,
    isDataResidency = false
})
```

```lua
-- China only URL strategy
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "adjust.cn" },
    useSubdomains = true,
    isDataResidency = false
})
```

```lua
-- EU data residency
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "eu.adjust.com" },
    useSubdomains = true,
    isDataResidency = true
})
```

```lua
-- US data residency
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "us.adjust.com" },
    useSubdomains = true,
    isDataResidency = true
})
```

```lua
-- Turkey data residency
local adjust = require "plugin.adjust"
adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    -- URL strategy parameters below
    urlStrategyDomains = { "us.adjust.com" },
    useSubdomains = true,
    isDataResidency = true
})
```

### <a id="deeplinking"></a>Deep linking

If you are using the Adjust campaign link URL with an option to deep link into your app from the URL, there is the possibility to get information about the deep link URL and its content. Hitting the URL can happen when the user has your app already installed (standard deep linking scenario) or if they don't have the app on their device (deferred deep linking scenario).

### <a id="deeplinking-deferred"></a>Deferred deep linking scenario

While deferred deep linking is not supported out of the box on Android and iOS, our Adjust SDK makes it possible.

In order to get information about the URL content in a deferred deep linking scenario, you should set a callback method, which will receive one `string` parameter where the content of the URL will be delivered. You should set this method on the config object by calling the method `setDeferredDeeplinkCallback`:

```lua
local adjust = require "plugin.adjust"

-- make sure to set the callback before calling initSdk
adjust.setDeferredDeeplinkCallback(function(event)
    print("Deferred deep link: " .. event.message)
end)

-- ...

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

In a deferred deep linking scenario, there is one additional setting which can be set in the initialization map. Once the Adjust SDK gets the deferred deep link information, you have the possibility to choose whether our SDK should open this URL or not. You can choose to set this option by setting the `isDeferredDeeplinkOpeningEnabled` parameter in the initialization map:

```lua
local adjust = require "plugin.adjust"

-- make sure to set the callback before calling initSdk
adjust.setDeferredDeeplinkCallback(function(event)
    print("Deferred deep link: " .. event.message)
end)

-- ...

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isDeferredDeeplinkOpeningEnabled = false
})
```

If nothing is set, **the Adjust SDK will always try to launch the URL by default**.

To enable your app to support deep linking, you should do some additional set up for each supported platform.

### <a id="deeplinking-reattribution"></a>Reattribution via deep links

Adjust enables you to run re-engagement campaigns through deep links.

If you are using this feature, in order for your user to be properly reattributed, you need to make one additional call to the Adjust SDK in your app.

Once you have received deep link content information in your app, add a call to the `processDeeplink` method. By making this call, the Adjust SDK will try to find if there is any new attribution information inside of the deep link. If there is any, it will be sent to the Adjust backend. If your user should be reattributed due to a click on the Adjust campaign link URL with deep link content, you will see the [attribution callback](#attribution-callback) in your app being triggered with new attribution info for this user.

```lua
local adjust = require "plugin.adjust"

adjustDeeplink = {}
adjustDeeplink.deeplink = "your-deep-link"

adjust.processDeeplink(adjustDeeplink)
```

### <a id="short-links-resolution"></a>Resolve Adjust short links

To resolve an Adjust shortened deep link, invoke the `processAndResolveDeeplink` method with a callback function. The callback function receives the resolved deep link as a `string`.

```lua
local adjust = require "plugin.adjust"

adjustDeeplink = {}
adjustDeeplink.deeplink = "your-deep-link"

adjust.processAndResolveDeeplink(adjustDeeplink, function(resolvedLink)
    print("Resolved link: " .. resolvedLink.message)
end)
```

> Note: If the link passed to the `processAndResolveDeeplink` method was shortened, the callback function receives the extended original link. Otherwise, the callback function receives the link you passed.

### <a id="last-deeplink-getter"></a>Get last processed deep link

You can get the last deep link URL processed by the `processDeeplink` or `processAndResolveDeepLink` method by calling the `getLastDeeplink` method. This method returns the last processed deep link as a string.

```lua
local adjust = require "plugin.adjust"

adjust.getLastDeeplink(function(lastDeeplink)
    print("Last deep link = " .. lastDeeplink.message)
end)
```

### <a id="app-tracking-transparency"></a>App Tracking Transparency

> Note: This feature exists only in iOS platform.

If you want to record the device’s ID for Advertisers (IDFA), you must display a prompt to get your user’s authorization. To do this, you need to include Apple’s App Tracking Transparency (ATT) framework in your app. The Adjust SDK stores the user’s authorization status and sends it to Adjust’s servers with each request.

Below, you can find the list of possible ATT status values:

| Status                                    | Code | Description                                                          |
|-------------------------------------------|------|----------------------------------------------------------------------|
| `ATTrackingManagerAuthorizationStatusNotDetermined` | `0`  | The user hasn’t responded to the access prompt yet                   |
| `ATTrackingManagerAuthorizationStatusRestricted`   | `1`  | Access to app-related data is blocked at the device level            |
| `ATTrackingManagerAuthorizationStatusDenied`       | `2`  | The user has denied access to app-related data for device measurement |
| `ATTrackingManagerAuthorizationStatusAuthorized`   | `3`  | The user has approved access to app-related data for device measurement |

> Note: You might receive a status code of -1 if the SDK is unable to retrieve the ATT (App Tracking Transparency) status.

### <a id="att-wrapper"></a>ATT authorization wrapper

**Note**: This feature exists only in iOS platform.

The Adjust SDK contains a wrapper around [Apple’s requestTrackingAuthorizationWithCompletionHandler: method](https://developer.apple.com/documentation/apptrackingtransparency/attrackingmanager/3547037-requesttrackingauthorizationwith). You can use this wrapper if you don’t want to use the ATT prompt.

The callback method triggers when your user responds to the consent dialog. This method sends the user’s consent status code to Adjust’s servers. You can define responses to each status code within the callback function.

You must specify text content for the ATT. To do this, add your text to the `NSUserTrackingUsageDescription` key in your `Info.plist` file.


You can trigger ATT prompt via Adjust SDK wrapper method like this:

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

### <a id="att-status-getter"></a>Get current authorization status

You can retrieve a user’s current authorization status at any time. Call the `getAppTrackingAuthorizationStatus` method to return the authorization status code as an `integer`.

```lua
local adjust = require "plugin.adjust"

adjust.getAppTrackingAuthorizationStatus(function(status)
    print("Authorization status: " .. status.message)
end)
```

### <a id="att-waiting-interval"></a>ATT prompt waiting interval

If your app includes an onboarding process or a tutorial, you may want to delay sending your user’s ATT consent status until after the user has completed this process. To do this, you can set the `attConsentWaitingInterval` parameter of your initialization map to delay the sending of data for up to **360 seconds** to give the user time to complete the initial onboarding. After the timeout ends or the user sets their consent status, the SDK sends all information it has recorded during the delay to Adjust’s servers along with the user’s consent status.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    attConsentWaitingInterval = 30
})
```

### <a id="skan-framework"></a>SKAdNetwork and conversion values

> Important: This feature is only available on devices running iOS 14 and above.

SKAdNetwork is Apple’s attribution framework for app install and reinstall attribution. The SKAdNetwork workflow goes like this:

1. Apple gathers attribution information and notifies the relevant ad network.
2. The network sends a postback with this information to Adjust.
3. Adjust displays SKAdNetwork data in [Datascape](https://help.adjust.com/en/suite/article/datascape).

### <a id="skan-disable"></a>Disable SKAdNetwork communication

The Adjust SDK communicates with SKAdNetwork by default. The SDK registers for SKAdNetwork attribution upon initialization.

You can control this behavior by setting `isSkanAttributionEnabled` parameter of your initialization map:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isSkanAttributionEnabled = false
})
```

### <a id="skan-update-callback"></a>Listen for changes to conversion values

If you use Adjust to manage conversion values, the Adjust’s servers send conversion value updates to the SDK. You can set up a callback function to listen for these changes assigning a callback method for this on before you initialize the SDK:

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- callback needs to be set before calling initSdk method
adjust.setSkanUpdatedCallback(function(event)
    local json_skan_updated = json.decode(event.message)
    print("SKAN conversion value updated!")
    print("Conversion value: " .. (json_skan_updated.conversionValue or "N/A"))
    print("Coarse value: " .. (json_skan_updated.coarseValue or "N/A"))
    print("Lock window: " .. (json_skan_updated.lockWindow or "N/A"))
    print("Error: " .. (json_skan_updated.error or "N/A"))
end)

-- ...

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE"
})
```

The callback function receives a postback from SKAdNetwork with the following properties:

| Arguments      | Description                                                                                                                       |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `conversionValue`   | The conversion value sent by Adjust’s servers                                                                                    |
| `coarseValue` | The coarse conversion value. This value is used if your app doesn’t have sufficient installs to reach the privacy threshold.      |
|                | - `none`                                                                                                                         |
|                | - `low`                                                                                                                          |
|                | - `medium`                                                                                                                       |
|                | - `high`                                                                                                                         |
|                | Apple sends `none` whenever none of the conditions that are set for `low`, `medium`, and `high` were met.                        |
| `lockWindow`  | Whether to send the postback before the conversion window ends. `true` indicates the postback will be sent before the window ends.   |
|                | Defaults to `false` in SKAdNetwork 4.0 postbacks and `null` in older SKAdNetwork versions.                                             |
| `error`        | Contains the error message if an error occurred.                                                                                 |

### <a id="skan-postbacks"></a>Set up direct install postbacks

> Note: Direct install postbacks contain only SKAdNetwork information. Information such as campaign data isn’t included in these postbacks.

You can configure your app to send a copy of winning SKAdNetwork callbacks to Adjust. This enables you to use SKAdNetwork information in your analytics.

To set up direct install postbacks, you need to add the Adjust callback URL to your `Info.plist` file:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://adjust-skadnetwork.com</string>
```

> See also: See Apple’s guide on [Configuring an Advertised App](https://developer.apple.com/documentation/storekit/skadnetwork/configuring_an_advertised_app) for more information.

### <a id="adrevenue-recording"></a>Record ad revenue information

You can record ad revenue for [supported network partners](https://help.adjust.com/en/article/ad-revenue) using the Adjust SDK.

> Important: You need to perform some extra setup steps in your Adjust dashboard to measure ad revenue. Contact your Technical Account Manager or support@adjust.com to get started.

To send ad revenue information with the Adjust SDK, you need to instantiate an ad revenue map. This map contains variables that are sent to Adjust when ad revenue is recorded in your app.

To instantiate an ad revenue map, pass the following parameters:

- source (`string`): The source of the ad revenue. See the table below for available sources.

| Argument                     | Ad revenue Source       |
|------------------------------|-------------------------|
| `"applovin_max_sdk"`         | AppLovin MAX            |
| `"admob_sdk"`                | AdMob                   |
| `"ironsource_sdk"`           | ironSource              |
| `"admost_sdk"`               | AdMost                  |
| `"unity_sdk"`                | Unity                   |
| `"helium_chartboost_sdk"`    | Helium Chartboost       |
| `"adx_sdk"`                  | Ad(X)                   |
| `"tradplus_sdk"`             | TradPlus                |
| `"topon_sdk"`                | TopOn                   |
| `"publisher_sdk"`            | Generic source          |

### <a id="adrevenue-amount"></a>Ad revenue amount

To send the ad revenue amount, call the `setRevenue` method of your `AdjustAdRevenue` instance and pass the following arguments:

- revenue (`integer`): The amount of revenue
- currency (`string`): The 3 character [ISO 4217 code](https://www.iban.com/currency-codes) of your reporting currency

> See also: Check the [guide to recording purchases in different currencies](https://help.adjust.com/en/article/currency-conversion) for more information.

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR"
})
```

### <a id="adrevenue-network"></a>Ad revenue network

To record the network associated with the ad revenue, assign `adRevenueNetwork` parameter in your ad revenue map with the network name.

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
    adRevenueNetwork = "network1"
})
```

### <a id="adrevenue-unit"></a>Ad revenue unit

To send the ad revenue unit, assign `adRevenueUnit` parameter of your ad revenue map with the unit value.

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
    adRevenueUnit = "unit1"
})
```

### <a id="adrevenue-placement"></a>Ad revenue placement

To send the ad revenue placement, assign `adRevenuePlacement` parameter of your ad revenue map with the placement value.

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
    adRevenuePlacement = "banner"
})
```

### <a id="adrevenue-impressions"></a>Ad impressions count

To send the number of recorded ad impressions, assign `adImpressionsCount` parameter of your ad revenue map with the number of ad impressions.

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
    adImpressionsCount = 6
})
```

### <a id="adrevenue-callback-params"></a>Ad revenue callback parameters

Similar to how one can set [event callback parameters](#event-callback-params), the same can be done for ad revenue:

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
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

### <a id="adrevenue-partner-params"></a>Ad revenue partner parameters

Similar to how one can set [event partner parameters](#event-partner-params), the same can be done for ad revenue:

```lua
local adjust = require "plugin.adjust"

adjust.trackAdRevenue({
    source = "applovin_max_sdk",
    revenue = 1.0,
    currency = "EUR",
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

### <a id="purchase-verification"></a>Purchase verification

If you’ve enabled [purchase verification](https://help.adjust.com/en/article/purchase-verification), you can use the Adjust SDK to request App Store or Google Play Store purchase verification. There are two ways to verify purchases with the Adjust SDK.

### <a id="verify-and-record"></a>Verify purchase and record event

With this approach, you will be performing verification of your purchase and having an event recorded for that verification. This will give you an overview later in the dashboard on the events (and assigned revenue) based on whether verification was successful or not.

In order to do this, you need to complete your in-app purchase and then pass parameters that Adjust SDK needs out of that purchase in order to be able to try to verify the purchase. Once you have obtained the verification parameters the SDK needs, you can perform verification and recording of an event by calling `verifyAndTrackAppStorePurchase` or `verifyAndTrackPlayStorePurchase` methods.

Next to revenue and currency of the purchase, you need to obtain the following parameters as well:

- Product ID (for both, App Store and Play Store purchases)
- Transaction ID (for App Store purchases)
- Purchase token (for Play Store purchases)

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- perform App Store in-app purchase

-- create an event with purchase parameters attached
adjustEvent = {}
adjustEvent.eventToken = "abc123"
adjustEvent.revenue = 6.0
adjustEvent.currency = "EUR"
adjustEvent.transactionId = "transaction-id"
adjustEvent.productId = "product-id"

-- call verifyAndTrackAppStorePurchase method
adjust.verifyAndTrackAppStorePurchase(adjustEvent, function(result)
    local json_verification_result = json.decode(result.message)
    print("Verification status: " .. json_verification_result.verificationStatus)
    print("Code: " .. json_verification_result.code)
    print("Message: " .. json_verification_result.message)
end)
```

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- perform Play Store in-app purchase

-- create an event with purchase parameters attached
adjustEvent = {}
adjustEvent.eventToken = "abc123"
adjustEvent.revenue = 6.0
adjustEvent.currency = "EUR"
adjustEvent.productId = "product-id"
adjustEvent.purchaseToken = "purchase-token"

-- call verifyAndTrackPlayStorePurchase method
adjust.verifyAndTrackPlayStorePurchase(adjustEvent, function(result)
    local json_verification_result = json.decode(result.message)
    print("Verification status: " .. json_verification_result.verificationStatus)
    print("Code: " .. json_verification_result.code)
    print("Message: " .. json_verification_result.message)
end)
```

### <a id="verify-only"></a>Verify purchase only

In case you don't want to see revenue events being automatically recorded once you verify the purchase, but you are instead interested in just getting the information on the validity of the purchase, you can also perform only the verification of the purchase. For this, you need to invoke `verifyAppStorePurchase` and `verifyPlayStorePurchase` methods.

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- perform App Store in-app purchase

-- create a purchase map with purchase parameters attached
adjustPurchase = {}
adjustPurchase.transactionId = "transaction-id"
adjustPurchase.productId = "product-id"

-- call verifyAppStorePurchase method
adjust.verifyAppStorePurchase(adjustPurchase, function(result)
    local json_verification_result = json.decode(result.message)
    print("Verification status: " .. json_verification_result.verificationStatus)
    print("Code: " .. json_verification_result.code)
    print("Message: " .. json_verification_result.message)
end)
```

```lua
local adjust = require "plugin.adjust"
local json = require "json"

-- perform Play Store in-app purchase

-- create a purchase map with purchase parameters attached
adjustPurchase = {}
adjustPurchase.productId = "product-id"
adjustPurchase.purchaseToken = "purchase-token"

-- call verifyPlayStorePurchase method
adjust.verifyPlayStorePurchase(adjustPurchase, function(result)
    local json_verification_result = json.decode(result.message)
    print("Verification status: " .. json_verification_result.verificationStatus)
    print("Code: " .. json_verification_result.code)
    print("Message: " .. json_verification_result.message)
end)
```

### <a id="subscription-sending"></a>Send subscription information

> Important: The following steps only set up subscription measurement within the Adjust SDK. To enable the feature, follow the steps at [Set up subscriptions for your app](https://help.adjust.com/en/article/set-up-subscriptions-for-your-app).

You can record App Store and Play Store subscriptions and verify their validity with the Adjust SDK. After the user purchases a subscription, create a subscription map containing the purchase details.

```lua
-- App Store subscription
local adjust = require "plugin.adjust"

adjust.trackAppStoreSubscription({
    price = "just-price-numeric-value-as-string", -- for example "0.99" or "6.00"
    currency = "EUR",
    transactionId = "transaction-id"
})
```

```lua
-- Play Store subscription
local adjust = require "plugin.adjust"

adjust.trackPlayStoreSubscription({
    price = "price-numeric-value-in-micros-as-string", -- for example "0.99" should be "990000"
    currency = "EUR",
    sku = "product-sku",
    orderId = "order-id",
    signature = "signature",
    purchaseToken = "purchase-token"
})
```

Subscription parameters for App Store subscription:

- [price](https://developer.apple.com/documentation/storekit/product/price)
- currency (you need to pass [currencyCode](https://developer.apple.com/documentation/foundation/nslocale/1642836-currencycode?language=objc))
- [transactionId](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411288-transactionidentifier?language=objc)
- [transactionDate](https://developer.apple.com/documentation/storekit/skpaymenttransaction/1411273-transactiondate?language=objc)
- salesRegion (you need to pass [countryCode](https://developer.apple.com/documentation/foundation/nslocale/1643060-countrycode?language=objc) of the [priceLocale](https://developer.apple.com/documentation/storekit/skproduct/1506145-pricelocale?language=objc) object)

Subscription parameters for Play Store subscription:

- [price](https://developer.android.com/reference/com/android/billingclient/api/SkuDetails#getpriceamountmicros)
- [currency](https://developer.android.com/reference/com/android/billingclient/api/SkuDetails#getpricecurrencycode)
- [sku](https://developer.android.com/reference/com/android/billingclient/api/Purchase#getsku)
- [orderId](https://developer.android.com/reference/com/android/billingclient/api/Purchase#getorderid)
- [signature](https://developer.android.com/reference/com/android/billingclient/api/Purchase#getsignature)
- [purchaseToken](https://developer.android.com/reference/com/android/billingclient/api/Purchase#getpurchasetoken)
- [purchaseTime](https://developer.android.com/reference/com/android/billingclient/api/Purchase#getpurchasetime)

> Note: All the links behind the parameters are pointing to fields one needs to obtain from native iOS and Android in-app purchases API. In-app purchases on Solar2D / Corona platform are being done with usage of some plugins which are wrapping the native API and can therefore have these fields exposed under different names or, in bad case scenario, not provide some of these fields at all. In case you are having issues in understanding how to properly pass these fields based on what your Solar2D / Corona plugin is sending you back, feel free contact us about it.

### <a id="subscription-purchase-date"></a>Subscription purchase date

You can record the date on which the user purchased a subscription. The SDK returns this data for you to report on.

```lua
-- App Store subscription
local adjust = require "plugin.adjust"

adjust.trackAppStoreSubscription({
    price = "just-price-numeric-value-as-string", -- for example "0.99" or "6.00"
    currency = "EUR",
    transactionId = "transaction-id",
    transactionDate = "unix-timestamp"
})
```

```lua
-- Play Store subscription
local adjust = require "plugin.adjust"

adjust.trackPlayStoreSubscription({
    price = "price-numeric-value-in-micros-as-string", -- for example "0.99" should be "990000"
    currency = "EUR",
    sku = "product-sku",
    orderId = "order-id",
    signature = "signature",
    purchaseToken = "purchase-token",
    purchaseDate = "unix-timestamp"
})
```

### <a id="subscription-region"></a>Subscription region

> Note: This is feature is iOS only.

You can record the region in which the user purchased a subscription. To do this, set the `salesRegion` method of your Apple App Store subscription map to the country code as a string. This needs to be formatted as the [countryCode](https://developer.apple.com/documentation/storekit/storefront/3792000-countrycode) of the [Storefront](https://developer.apple.com/documentation/storekit/storefront) object.

```lua
-- App Store subscription
local adjust = require "plugin.adjust"

adjust.trackAppStoreSubscription({
    price = "just-price-numeric-value-as-string", -- for example "0.99" or "6.00"
    currency = "EUR",
    transactionId = "transaction-id",
    salesRegion = "sales-region"
})
```

### <a id="subscription-callback-params"></a>Subscription callback parameters

Similar to how one can set [event callback parameters](#event-callback-params), the same can be done for subscriptions:

```lua
-- App Store subscription
local adjust = require "plugin.adjust"

adjust.trackAppStoreSubscription({
    price = "just-price-numeric-value-as-string", -- for example "0.99" or "6.00"
    currency = "EUR",
    transactionId = "transaction-id",
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

### <a id="subscription-partner-params"></a>Subscription partner parameters

Similar to how one can set [event partner parameters](#event-partner-params), the same can be done for subscriptions:

```lua
-- App Store subscription
local adjust = require "plugin.adjust"

adjust.trackAppStoreSubscription({
    price = "just-price-numeric-value-as-string", -- for example "0.99" or "6.00"
    currency = "EUR",
    transactionId = "transaction-id",
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

### <a id="device-ids"></a>Device IDs

The Adjust SDK contains helper methods that return device information. Use these methods to add details to your callbacks and improve your reporting.

### <a id="idfa"></a>IDFA

To obtain the IDFA, call the `getIdfa` method:

```lua
local adjust = require "plugin.adjust"

adjust.getIdfa(function(event)
    print("IDFA: " .. (event.message or "N/A"))
end)
```

### <a id="idfv"></a>IDFV

To obtain the IDFV, call the `getIdfv` method:

```lua
local adjust = require "plugin.adjust"

adjust.getIdfv(function(event)
    print("IDFV: " .. (event.message or "N/A"))
end)
```

### <a id="gps-adid"></a>Google advertising identifier

To obtain Google advertising ID, call the `getGoogleAdId` method:

```lua
local adjust = require "plugin.adjust"

adjust.getGoogleAdId(function(event)
    print("Google Advertising ID: " .. (event.message or "N/A"))
end)
```

### <a id="fire-adid"></a>Amazon advertising identifier

If you need to obtain the Amazon advertising ID, you can call the `getAmazonAdId` method:

```lua
local adjust = require "plugin.adjust"

adjust.getAmazonAdId(function(event)
    print("Amazon Advertising ID: " .. (event.message or "N/A"))
end)
```

### <a id="adid"></a>Adjust device identifier

For every device with your app installed on it, the Adjust backend generates a unique **Adjust device identifier** (**adid**). In order to obtain this identifier, you can make a call to `getAdid` method:

```lua
local adjust = require "plugin.adjust"

adjust.getAdid(function(event)
    print("Adjust ID: " .. (event.message or "N/A"))
end)
```

**Note**: Information about the **adid** is available after app installation has been recorded by the Adjust backend. From that moment on, the Adjust SDK has information about the device **adid** and you can access it with this method. So, **it is not possible** to access the **adid** value before the SDK has been initialised and installation of your app has been successfully recorded.

### <a id="session-event-callbacks"></a>Session and event callbacks

You can register a callback to be notified of successful and failed recorded events and/or sessions.

Follow the same steps to implement the callback for successfully recorded events:

```lua
local adjust = require "plugin.adjust"

-- make sure to set callback before calling initSdk method
adjust.setEventSuccessCallback(function(event)
    local json_event_success = json.decode(event.message)
    print("Event tracking success!")
    print("Event token: " .. (json_event_success.eventToken or "N/A"))
    print("Message: " .. (json_event_success.message or "N/A"))
    print("Timestamp: " .. (json_event_success.timestamp or "N/A"))
    print("Adid: " .. (json_event_success.adid or "N/A"))
    print("JSON response: " .. (json.encode(json_event_success.jsonResponse) or "N/A"))
end)

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

The callback function for failed recorded events:

```lua
local adjust = require "plugin.adjust"

-- make sure to set callback before calling initSdk method
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

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

For successfully recorded sessions:

```lua
local adjust = require "plugin.adjust"

-- make sure to set callback before calling initSdk method
adjust.setSessionSuccessCallback(function(event)
    local json_session_success = json.decode(event.message)
    print("Session tracking success!")
    print("Message: " .. (json_session_success.message or "N/A"))
    print("Timestamp: " .. (json_session_success.timestamp or "N/A"))
    print("Adid: " .. (json_session_success.adid or "N/A"))
    print("JSON response: " .. (json.encode(json_session_success.jsonResponse) or "N/A"))
end)

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

And for failed recorded sessions:

```lua
local adjust = require "plugin.adjust"

-- make sure to set callback before calling initSdk method
adjust.setSessionFailureCallback(function(event)
    local json_session_failure = json.decode(event.message)
    print("Session tracking failure!")
    print("Message: " .. (json_session_failure.message or "N/A"))
    print("Timestamp: " .. (json_session_failure.timestamp or "N/A"))
    print("Adid: " .. (json_session_failure.adid or "N/A"))
    print("Will retry: " .. (json_session_failure.willRetry or "N/A"))
    print("JSON response: " .. (json.encode(json_session_failure.jsonResponse) or "N/A"))
end)

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX"
})
```

The callback functions will be called after the SDK tries to send a package to the server. Within the callback, you have access to a response data object specifically for the callback. Here is a quick summary of the session response data properties:

- `message` the message from the server or the error logged by the SDK.
- `timestamp` timestamp from the server.
- `adid` a unique device identifier provided by Adjust.
- `jsonResponse` the JSON string with the response from the server.

Both event response data objects contain:

- `eventToken` the event token, if the package recorded was an event.
- `callbackId` the custom defined callback ID set on event object.

And both event and session failed objects also contain:

- `willRetry` indicates there will be an attempt to resend the package at a later time.

### <a id="disable-sdk"></a>Disable the SDK

You can disable the Adjust SDK from recording any activity by invoking the `disable` method. This setting is **remembered between sessions**.

```lua
local adjust = require "plugin.adjust"

adjust.disable()
```

You can verify if the Adjust SDK is currently active with the `isEnabled` method. It is always possible to activate the Adjust SDK by invoking `enable` method.

```lua
local adjust = require "plugin.adjust"

adjust.enable()
```

### <a id="offline-mode"></a>Offline mode

You can put the Adjust SDK in offline mode to suspend transmission to our servers, while still retaining recorded data to be sent later. While in offline mode, all information is saved in a file, so be careful not to trigger too many events while in offline mode.

You can activate offline mode by calling the `switchToOfflineMode` method.

```lua
local adjust = require "plugin.adjust"

adjust.switchToOfflineMode()
```

Conversely, you can deactivate the offline mode by calling `switchBackToOnlineMode` method. When the Adjust SDK is put back in online mode, all saved information is sent to our servers with the correct timestamps.

Unlike disabling the SDK, this setting is **not remembered between sessions**. This means that the SDK is in online mode whenever it is started, even if the app was terminated in offline mode.

### <a id="background-sending"></a>Sending from background 

The default behaviour of the Adjust SDK is to **pause sending HTTP requests while the app is in the background**. You can change this in your initialization map by assigning the `isSendingInBackgroundEnabled` parameter:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isSendingInBackgroundEnabled = true
})
```

If nothing is set, sending in background is **disabled by default**.

### <a id="external-device-id"></a>Set external device ID

> **Note** If you want to use external device IDs, please contact your Adjust representative. They will talk you through the best approach for your use case.

An external device identifier is a custom value that you can assign to a device or user. They can help you to recognize users across sessions and platforms. They can also help you to deduplicate installs by user so that a user isn't counted as multiple new installs.

You can also use an external device ID as a custom identifier for a device. This can be useful if you use these identifiers elsewhere and want to keep continuity.

Check out our [external device identifiers article](https://help.adjust.com/en/article/external-device-identifiers) for more information.

To set an external device ID, assign the identifier to the `externalDeviceId` parameter of your initialization map.

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    externalDeviceId = "unique-id-for-each-user"
})
```

> **Important**: You need to make sure this ID is **unique to the user or device** depending on your use-case. Using the same ID across different users or devices could lead to duplicated data. Talk to your Adjust representative for more information.

If you want to use the external device ID in your business analytics, you can pass it as a session callback parameter. See the section on [session callback parameters](#session-callback-params) for more information.

You can import existing external device IDs into Adjust. This ensures that the backend matches future data to your existing device records. If you want to do this, please contact your Adjust representative.

### <a id="push-token"></a>Push token

To send us the push notification token, add the following call to Adjust **whenever you get your token in the app or when it gets updated**:

```lua
local adjust = require "plugin.adjust"

adjust.setPushToken("push-notifications-token")
```

Push tokens are used for Audience Builder and client callbacks, and they are required for the uninstall detection feature.

### <a id="disable-ad-services"></a>Disable AdServices information reading

> Note: This is iOS only feature.

The SDK is enabled by default to try to communicate with `AdServices.framework` on iOS in order to try to obtain attribution token which is later being used for handling Apple Search Ads attribution. In case you would not like Adjust to show information from Apple Search Ads campaigns, you can disable this in the SDK by assigning `isSkanAttributionEnabled` parameter of your initialization map:

```lua
local adjust = require "plugin.adjust"

adjust.initSdk({
    appToken = "{YourAppToken}",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    isSkanAttributionEnabled = false
})
```

## <a id="license"></a>License

The Adjust SDK is licensed under the MIT License.

Copyright (c) 2017-Present Adjust GmbH, http://www.adjust.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
