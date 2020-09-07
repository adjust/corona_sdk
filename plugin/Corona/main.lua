local adjust = require "plugin.adjust"
local widget = require "widget"
local json = require "json"

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[Adjust]: applicationOpen event. url = " .. event.url)
        -- Capture app event opened from deep link
        adjust.appWillOpenUrl(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[Adjust]: launchArgs.url = (" .. launchArgs.url)
    adjust.appWillOpenUrl(launchArgs.url)
end

-- Setup listeners
-- ------------------------
local function attributionListener(event)
    local json_attribution = json.decode(event.message)
    print("[Adjust]: Attribution changed!")
    print("[Adjust]: Tracker token: " .. json_attribution.trackerToken)
    print("[Adjust]: Tracker name: " .. json_attribution.trackerName)
    print("[Adjust]: Campaign: " .. json_attribution.campaign)
    print("[Adjust]: Network: " .. json_attribution.network)
    print("[Adjust]: Creative: " .. json_attribution.creative)
    print("[Adjust]: Adgroup: " .. json_attribution.adgroup)
    print("[Adjust]: ADID: " .. json_attribution.adid)
end

local function sessionTrackingSuccessListener(event)
    local json_session_success = json.decode(event.message)
    print("[Adjust]: Session tracking success!")
    print("[Adjust]: Message: " .. json_session_success.message)
    print("[Adjust]: Timestamp: " .. json_session_success.timestamp)
    print("[Adjust]: Adid: " .. json_session_success.adid)
    print("[Adjust]: JSON response: " .. json.encode(json_session_success.jsonResponse))
end

local function sessionTrackingFailureListener(event)
    local json_session_failure = json.decode(event.message)
    print("[Adjust]: Session tracking failure!")
    print("[Adjust]: Message: " .. json_session_failure.message)
    print("[Adjust]: Timestamp: " .. json_session_failure.timestamp)
    print("[Adjust]: Adid: " .. json_session_failure.adid)
    print("[Adjust]: Will retry: " .. json_session_failure.adid)
    print("[Adjust]: JSON response: " .. json.encode(json_session_failure.jsonResponse))
end

local function eventTrackingSuccessListener(event)
    local json_event_success = json.decode(event.message)
    print("[Adjust]: Event tracking success!")
    print("[Adjust]: Event token: " .. json_event_success.eventToken)
    print("[Adjust]: Message: " .. json_event_success.message)
    print("[Adjust]: Timestamp: " .. json_event_success.timestamp)
    print("[Adjust]: Adid: " .. json_event_success.adid)
    print("[Adjust]: JSON response: " .. json.encode(json_event_success.jsonResponse))
end

local function eventTrackingFailureListener(event)
    local json_event_failure = json.decode(event.message)
    print("[Adjust]: Event tracking failure!")
    print("[Adjust]: Event token: " .. json_event_failure.eventToken)
    print("[Adjust]: Message: " .. json_event_failure.message)
    print("[Adjust]: Timestamp: " .. json_event_failure.timestamp)
    print("[Adjust]: Adid: " .. json_event_failure.adid)
    print("[Adjust]: Will retry: " .. json_event_failure.willRetry)
    print("[Adjust]: JSON response: " .. json.encode(json_event_failure.jsonResponse))
end

local function deferredDeeplinkListener(event)
    print("[Adjust]: Received event from deferredDeeplinkListener (" .. event.name .. "): ", event.message)
end

adjust.setAttributionListener(attributionListener)
adjust.setEventTrackingSuccessListener(eventTrackingSuccessListener)
adjust.setEventTrackingFailureListener(eventTrackingFailureListener)
adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListener)
adjust.setSessionTrackingFailureListener(sessionTrackingFailureListener)
adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)

-- Init Adjust
-- ------------------------
adjust.addSessionCallbackParameter("scp1", "scp1_value1")
adjust.addSessionCallbackParameter("scp2", "scp2_value2")
adjust.addSessionCallbackParameter("scp3", "scp3_value3")
adjust.removeSessionCallbackParameter("scp2")
adjust.resetSessionCallbackParameters()

adjust.addSessionPartnerParameter("spp1", "spp1_value1")
adjust.addSessionPartnerParameter("spp2", "spp2_value2")
adjust.addSessionPartnerParameter("spp3", "spp3_value3")
adjust.removeSessionPartnerParameter("spp1")
adjust.resetSessionPartnerParameters()

adjust.create({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
    handleSkAdNetwork = false,
    urlStrategy = "india",
    -- shouldLaunchDeeplink = false,
    -- eventBufferingEnabled = true,
    -- delayStart = 6.0,
    -- isDeviceKnown = true,
    -- sendInBackground = true,
    -- defaultTracker = "abc123",
    -- userAgent = "Random User Agent 6.6"
    -- readMobileEquipmentIdentity = true
    -- secretId = aaa,
    -- info1 = bbb,
    -- info2 = ccc,
    -- info3 = ddd,
    -- info4 = eee,
})

adjust.requestTrackingAuthorizationWithCompletionHandler(function(event)
    print("[Adjust]: Authorization status = " .. event.message)
    if     event.message == "0" then print("[Adjust]: ATTrackingManagerAuthorizationStatusNotDetermined")
    elseif event.message == "1" then print("[Adjust]: ATTrackingManagerAuthorizationStatusRestricted")
    elseif event.message == "2" then print("[Adjust]: ATTrackingManagerAuthorizationStatusDenied")
    elseif event.message == "3" then print("[Adjust]: ATTrackingManagerAuthorizationStatusAuthorized")
    end
end)

-- adjust.setPushToken("{YourPushToken}")
-- adjust.sendFirstPackages()

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

-- Track Revenue Event
-- ------------------------
local function handleTrackSimpleEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "g3mfiw"
        })
        adjust.trackAppStoreSubscription({
            price = "6.66",
            currency = "CAD",
            transactionId = "random-transaction-id",
            receipt = "random-receipt",
            transactionDate = "1234567890",
            salesRegion = "CA",
            callbackParameters = {
                {
                    key = "callback_key1",
                    value = "callback_value1",
                },
                {
                    key = "callback_key2",
                    value = "callback_value2",
                },
            },
            partnerParameters = {
                {
                    key = "callback_key3",
                    value = "callback_value3",
                },
                {
                    key = "callback_key6",
                    value = "callback_value6",
                },
            },
        })
        adjust.trackPlayStoreSubscription({
            price = "6",
            currency = "CAD",
            orderId = "random-order-id",
            signature = "random-signature",
            purchaseToken = "random-purchase-token",
            purchaseTime = "1234567890",
            callbackParameters = {
                {
                    key = "callback_key1",
                    value = "callback_value1",
                },
                {
                    key = "callback_key2",
                    value = "callback_value2",
                },
            },
            partnerParameters = {
                {
                    key = "callback_key3",
                    value = "callback_value3",
                },
                {
                    key = "callback_key6",
                    value = "callback_value6",
                },
            },
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (0 * 30),
    id = "button0",
    label = "Track Simple Event",
    onEvent = handleTrackSimpleEvent
})

-- Track Revenue Event
-- ------------------------
local function handleTrackRevenueEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "a4fd35",
            revenue = 0.01,
            currency = "EUR",
            transactionId = "some_transaction_id"
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (1 * 30),
    id = "button1",
    label = "Track Revenue Event",
    onEvent = handleTrackRevenueEvent
})

-- Track Callback Event
-- ------------------------
local function handleTrackCallbackEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "34vgg9",
            callbackParameters = {
                {
                    key = "callback_key1",
                    value = "callback_value1",
                },
                {
                    key = "callback_key2",
                    value = "callback_value2",
                },
            },
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (2 * 30),
    id = "button2",
    label = "Track Callback Event",
    onEvent = handleTrackCallbackEvent
})

-- Track Partner Event
-- ------------------------
local function handleTrackPartnerEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "w788qs",
            partnerParameters = {
                {
                    key = "partner_key1",
                    value = "partner_value2",
                },
                {
                    key = "partner_key2",
                    value = "partner_key2",
                },
            },
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (3 * 30),
    id = "button3",
    label = "Track Partner Event",
    onEvent = handleTrackPartnerEvent
})

-- Enable offline mode
-- ------------------------
local function handleEnableOfflineMode(event)
    if ("ended" == event.phase) then
        adjust.setOfflineMode(true)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (4 * 30),
    id = "button4",
    label = "Enable offline mode",
    onEvent = handleEnableOfflineMode
})

-- Disable offline mode
-- ------------------------
local function handleDisableOfflineMode(event)
    if ("ended" == event.phase) then
        adjust.setOfflineMode(false)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (5 * 30),
    id = "button5",
    label = "Disable offline mode",
    onEvent = handleDisableOfflineMode
})

-- Enable SDK
-- ------------------------
local function handleToggleEnabled(event)
    if ("ended" == event.phase) then
        adjust.setEnabled(true)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (6 * 30),
    id = "button6",
    label = "Enable SDK",
    onEvent = handleToggleEnabled
})

-- Disable SDK
-- ------------------------
local function handleToggleEnabled(event)
    if ("ended" == event.phase) then
        adjust.setEnabled(false)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (7 * 30),
    id = "button7",
    label = "Disnable SDK",
    onEvent = handleToggleEnabled
})

-- is Enabled
-- ------------------------
local function handleIsEnabled(event)
    if ("ended" == event.phase) then
        adjust.isEnabled(function(event)
            print("[Adjust]: isEnabled = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (8 * 30),
    id = "button8",
    label = "Is Enabled",
    onEvent = handleIsEnabled
})

-- Get Adid
-- ------------------------
local function handleGetAdid(event)
    if ("ended" == event.phase) then
        adjust.getAdid(function(event)
            print("[Adjust]: adid = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (9 * 30),
    id = "button9",
    label = "Get Adid",
    onEvent = handleGetAdid
})

-- Get Google Adid
-- ------------------------
local function handleGetAdid(event)
    if ("ended" == event.phase) then
        adjust.getGoogleAdId(function(event)
            print("[Adjust]: googleAdId = " .. event.message)
        end)
        adjust.getAmazonAdId(function(event)
            print("[Adjust]: amazonAdId = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (10 * 30),
    id = "button10",
    label = "Get Google Adid",
    onEvent = handleGetAdid
})

-- Get Idfa
-- ------------------------
local function handleGetIdfa(event)
    if ("ended" == event.phase) then
        adjust.getIdfa(function(event)
            print("[Adjust]: idfa = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (11 * 30),
    id = "button11",
    label = "Get Idfa",
    onEvent = handleGetIdfa
})

-- Get Attribution
-- ------------------------
local function handleGetAttribution(event)
    if ("ended" == event.phase) then
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
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (12 * 30),
    id = "button12",
    label = "Get Attribution",
    onEvent = handleGetAttribution
})
