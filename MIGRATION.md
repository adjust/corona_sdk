
# Corona SDK v4 to v5 Migration Guide

The migration guide has been made by following the current README and outlining what has changed from what we had currently documented (and also some things that weren't documented).

---

## Add the SDK to Your iOS App

In addition to the steps mentioned in this chapter, go to the signature releases page, download the latest `AdjustSigSdk-iOS-Static-3.X.Y.a.zip`, and link that static library in the same way as the `libplugin_adjust.a` library.

---

## Integrate the SDK into Your App

### Initialization Method

- **V4**:
  ```lua
  local adjust = require "plugin.adjust"

  adjust.create({
      appToken = "{YourAppToken}",
      environment = "SANDBOX"
  })
  ```

- **V5**:
  ```lua
  local adjust = require "plugin.adjust"

  adjust.initSdk({
      appToken = "{YourAppToken}",
      environment = "SANDBOX"
  })
  ```

---

## Android Permissions

Since the native Android SDK dependency is being pulled from Maven as an AAR, all the permissions required by the SDK are added automatically. For example:
- `ACCESS_NETWORK_STATE` is optional.
- The `AD_ID` permission can be removed if not required.

---

## ProGuard Settings

Since the native Android SDK dependency is being pulled from Maven as an AAR, ProGuard rules are bundled inside it and are no longer needed to be added by clients. This chapter can be removed.

---

## Install Referrer

The chapter about adding install referrer dependency is unnecessary as the ProGuard rules for it are bundled into the SDK. Everything is handled automatically.

---

## Google Play Store Intent

Refer to the documentation for details on integrating Google Play Store intent:
[Google Play Store Intent Documentation](https://docs.google.com/document/d/1u1htdrZiERgGobz3NzlxK1eGWVmjToMY5k7Y8hInc38/edit?tab=t.0#heading=h.nssk6aqssj7p).

---

## Huawei Install Referrer

This feature has been removed from being automatically supported in the SDK. However, in Corona, you can add the dependency to a native plugin for Huawei install referrer and make it work. Refer to the documentation for detailed steps.

---

## App-Tracking Authorization Wrapper

### Method Renamed

- **V4**:
  ```lua
  adjust.requestTrackingAuthorizationWithCompletionHandler(function(event)
      print("[Adjust]: Authorization status = " .. event.message)
      if     event.message == "0" then print("[Adjust]: ATTrackingManagerAuthorizationStatusNotDetermined")
      elseif event.message == "1" then print("[Adjust]: ATTrackingManagerAuthorizationStatusRestricted")
      elseif event.message == "2" then print("[Adjust]: ATTrackingManagerAuthorizationStatusDenied")
      elseif event.message == "3" then print("[Adjust]: ATTrackingManagerAuthorizationStatusAuthorized")
      end
  end)
  ```

- **V5**:
  ```lua
  adjust.requestAppTrackingAuthorization(function(event)
      print("[Adjust]: Authorization status = " .. event.message)
      if     event.message == "0" then print("[Adjust]: ATTrackingManagerAuthorizationStatusNotDetermined")
      elseif event.message == "1" then print("[Adjust]: ATTrackingManagerAuthorizationStatusRestricted")
      elseif event.message == "2" then print("[Adjust]: ATTrackingManagerAuthorizationStatusDenied")
      elseif event.message == "3" then print("[Adjust]: ATTrackingManagerAuthorizationStatusAuthorized")
      end
  end)
  ```

---

## Get Current Authorization Status

### Method Renamed

- **V4**:
  ```lua
  local status = adjust.appTrackingAuthorizationStatus()
  print("[Adjust]: Authorization status = " .. status)
  if     status == "0" then print("[Adjust]: ATTrackingManagerAuthorizationStatusNotDetermined")
  elseif status == "1" then print("[Adjust]: ATTrackingManagerAuthorizationStatusRestricted")
  elseif status == "2" then print("[Adjust]: ATTrackingManagerAuthorizationStatusDenied")
  elseif status == "3" then print("[Adjust]: ATTrackingManagerAuthorizationStatusAuthorized")
  end
  ```

- **V5**:
  ```lua
  local status = adjust.getAppTrackingAuthorizationStatus()
  print("[Adjust]: Authorization status = " .. status)
  if     status == "0" then print("[Adjust]: ATTrackingManagerAuthorizationStatusNotDetermined")
  elseif status == "1" then print("[Adjust]: ATTrackingManagerAuthorizationStatusRestricted")
  elseif status == "2" then print("[Adjust]: ATTrackingManagerAuthorizationStatusDenied")
  elseif status == "3" then print("[Adjust]: ATTrackingManagerAuthorizationStatusAuthorized")
  end
  ```

---

## SKAdNetwork

### Configuration Parameter Renamed

- **V4**:
  ```lua
  local adjust = require "plugin.adjust"

  adjust.create({
      appToken = "{YourAppToken}",
      environment = "SANDBOX",
      logLevel = "VERBOSE",
      handleSkAdNetwork = false
  })
  ```

- **V5**:
  ```lua
  local adjust = require "plugin.adjust"

  adjust.initSdk({
      appToken = "{YourAppToken}",
      environment = "SANDBOX",
      logLevel = "VERBOSE",
      isSkanAttributionEnabled = false
  })
  ```

---

## Event Deduplication

### Deduplication Field Changed

- **V4**:
  ```lua
  adjust.trackEvent({
      eventToken = "abc123",
      transactionId = "YourDeduplicationId"
  })
  ```

- **V5**:
  ```lua
  adjust.trackEvent({
      eventToken = "abc123",
      deduplicationId = "YourDeduplicationId"
  })
  ```

---

## Subscription Tracking

For App Store subscription tracking, it’s no longer necessary to pass the `receipt` field.

- **V4**:
  ```lua
  adjust.trackAppStoreSubscription({
      price = "6.66",
      currency = "EUR",
      transactionId = "your-transaction-id",
      receipt = "your-receipt",
      transactionDate = "unix-timestamp",
      salesRegion = "your-sales-region",
  })
  ```

- **V5**:
  ```lua
  adjust.trackAppStoreSubscription({
      price = "6.66",
      currency = "EUR",
      transactionId = "your-transaction-id",
      transactionDate = "unix-timestamp",
      salesRegion = "your-sales-region",
  })
  ```

---

## Additional Changes

### Session Callback Parameters Renamed
- **V4**:
  ```lua
  adjust.addSessionCallbackParameter("foo", "bar")
  adjust.removeSessionCallbackParameter("foo")
  adjust.resetSessionCallbackParameters()
  ```
- **V5**:
  ```lua
  adjust.addGlobalCallbackParameter("foo", "bar")
  adjust.removeGlobalCallbackParameter("foo")
  adjust.removeGlobalCallbackParameters()
  ```

---

Final note: Corona SDK v5 aligns closely with non-native SDKs. Refer to the official documentation for remaining parts.
