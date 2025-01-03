local adjust = require "plugin.adjust"
local widget = require "widget"
local json = require "json"

-- setting up a system event listener for deeplink support
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[Adjust]: applicationOpen event.url = " .. event.url)
        adjustDeeplink = {}
        adjustDeeplink.deeplink = event.url
        adjust.processDeeplink(adjustDeeplink)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[Adjust]: launchArgs.url = (" .. launchArgs.url)
    adjustDeeplink = {}
    adjustDeeplink.deeplink = launchArgs.url
    adjust.processDeeplink(adjustDeeplink)
end

-- initialize the SDK
adjust.setAttributionCallback(function(event)
    local json_attribution = json.decode(event.message)
    print("[Adjust]: Attribution changed!")
    print("[Adjust]: Tracker token: " .. (json_attribution.trackerToken or "N/A"))
    print("[Adjust]: Tracker name: " .. (json_attribution.trackerName or "N/A"))
    print("[Adjust]: Campaign: " .. (json_attribution.campaign or "N/A"))
    print("[Adjust]: Network: " .. (json_attribution.network or "N/A"))
    print("[Adjust]: Creative: " .. (json_attribution.creative or "N/A"))
    print("[Adjust]: Adgroup: " .. (json_attribution.adgroup or "N/A"))
    print("[Adjust]: Cost type: " .. (json_attribution.costType or "N/A"))
    print("[Adjust]: Cost amount: " .. (json_attribution.costAmount or "N/A"))
    print("[Adjust]: Cost currency: " .. (json_attribution.costCurrency or "N/A"))
    print("[Adjust]: FB install referrer: " .. (json_attribution.fbInstallReferrer or "N/A"))
end)
adjust.setEventSuccessCallback(function(event)
    local json_event_success = json.decode(event.message)
    print("[Adjust]: Event tracking success!")
    print("[Adjust]: Event token: " .. (json_event_success.eventToken or "N/A"))
    print("[Adjust]: Message: " .. (json_event_success.message or "N/A"))
    print("[Adjust]: Timestamp: " .. (json_event_success.timestamp or "N/A"))
    print("[Adjust]: Adid: " .. (json_event_success.adid or "N/A"))
    print("[Adjust]: JSON response: " .. (json.encode(json_event_success.jsonResponse) or "N/A"))
end)
adjust.setEventFailureCallback(function(event)
    local json_event_failure = json.decode(event.message)
    print("[Adjust]: Event tracking failure!")
    print("[Adjust]: Event token: " .. (json_event_failure.eventToken or "N/A"))
    print("[Adjust]: Message: " .. (json_event_failure.message or "N/A"))
    print("[Adjust]: Timestamp: " .. (json_event_failure.timestamp or "N/A"))
    print("[Adjust]: Adid: " .. (json_event_failure.adid or "N/A"))
    print("[Adjust]: Will retry: " .. (json_event_failure.willRetry or "N/A"))
    print("[Adjust]: JSON response: " .. (json.encode(json_event_failure.jsonResponse) or "N/A"))
end)
adjust.setSessionSuccessCallback(function(event)
    local json_session_success = json.decode(event.message)
    print("[Adjust]: Session tracking success!")
    print("[Adjust]: Message: " .. (json_session_success.message or "N/A"))
    print("[Adjust]: Timestamp: " .. (json_session_success.timestamp or "N/A"))
    print("[Adjust]: Adid: " .. (json_session_success.adid or "N/A"))
    print("[Adjust]: JSON response: " .. (json.encode(json_session_success.jsonResponse) or "N/A"))
end)
adjust.setSessionFailureCallback(function(event)
    local json_session_failure = json.decode(event.message)
    print("[Adjust]: Session tracking failure!")
    print("[Adjust]: Message: " .. (json_session_failure.message or "N/A"))
    print("[Adjust]: Timestamp: " .. (json_session_failure.timestamp or "N/A"))
    print("[Adjust]: Adid: " .. (json_session_failure.adid or "N/A"))
    print("[Adjust]: Will retry: " .. (json_session_failure.willRetry or "N/A"))
    print("[Adjust]: JSON response: " .. (json.encode(json_session_failure.jsonResponse) or "N/A"))
end)
adjust.setDeferredDeeplinkCallback(function(event)
    print("[Adjust]: Deferred deep link received!")
    print("[Adjust]: Deferred deep link = " .. event.message)
end)
adjust.setSkanUpdatedCallback(function(event)
    local json_skan_updated = json.decode(event.message)
    print("[Adjust]: SKAN updated!");
    print("[Adjust]: Conversion value: " .. (json_skan_updated.conversionValue or "N/A"))
    print("[Adjust]: Coarse value: " .. (json_skan_updated.coarseValue or "N/A"))
    print("[Adjust]: Lock window: " .. (json_skan_updated.lockWindow or "N/A"))
    print("[Adjust]: Error: " .. (json_skan_updated.error or "N/A"))
end)

adjust.addGlobalCallbackParameter("scp1", "scp1_value1")
adjust.addGlobalCallbackParameter("scp2", "scp2_value2")
adjust.addGlobalCallbackParameter("scp3", "scp3_value3")
adjust.removeGlobalCallbackParameter("scp2")
adjust.removeGlobalCallbackParameters()

adjust.addGlobalPartnerParameter("spp1", "spp1_value1")
adjust.addGlobalPartnerParameter("spp2", "spp2_value2")
adjust.addGlobalPartnerParameter("spp3", "spp3_value3")
adjust.removeGlobalPartnerParameter("spp1")
adjust.removeGlobalPartnerParameters()

adjust.initSdk({
    appToken = "2fm9gkqubvpc",
    environment = "SANDBOX",
    logLevel = "VERBOSE",
})

-- setting up assets
display.setDefault("background", 229,255,204)

-- track standard event
local function handleTrackSimpleEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "g3mfiw"
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

-- track revenue event
local function handleTrackRevenueEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "a4fd35",
            revenue = 6.0,
            currency = "EUR",
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

-- track callback event
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

-- track partner event
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

-- enable offline mode
local function handleEnableOfflineMode(event)
    if ("ended" == event.phase) then
        adjust.switchToOfflineMode()
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (4 * 30),
    id = "button4",
    label = "Enable offline mode",
    onEvent = handleEnableOfflineMode
})

-- disable offline mode
local function handleDisableOfflineMode(event)
    if ("ended" == event.phase) then
        adjust.switchBackToOnlineMode()
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (5 * 30),
    id = "button5",
    label = "Disable offline mode",
    onEvent = handleDisableOfflineMode
})

-- enable SDK
local function handleEnableSdk(event)
    if ("ended" == event.phase) then
        adjust.enable()
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (6 * 30),
    id = "button6",
    label = "Enable SDK",
    onEvent = handleEnableSdk
})

-- disable SDK
local function handleDisableSdk(event)
    if ("ended" == event.phase) then
        adjust.disable()
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (7 * 30),
    id = "button7",
    label = "Disable SDK",
    onEvent = handleDisableSdk
})

-- is SDK enabled?
local function handleIsEnabled(event)
    if ("ended" == event.phase) then
        adjust.isEnabled(function(event)
            print("[Adjust]: Is SDK enabled = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (8 * 30),
    id = "button8",
    label = "Is SDK Enabled",
    onEvent = handleIsEnabled
})

-- get adid
local function handleGetAdid(event)
    if ("ended" == event.phase) then
        adjust.getAdid(function(event)
            print("[Adjust]: Adjust ID = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (9 * 30),
    id = "button9",
    label = "Get Adjust ID",
    onEvent = handleGetAdid
})

-- get Google advertising ID
local function handleGetGoogleAdid(event)
    if ("ended" == event.phase) then
        adjust.getGoogleAdId(function(event)
            print("[Adjust]: Google advertising ID = " .. event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (10 * 30),
    id = "button10",
    label = "Get Google Advertising ID",
    onEvent = handleGetGoogleAdid
})

-- get idfa
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
    label = "Get IDFA",
    onEvent = handleGetIdfa
})

-- get attribution
local function handleGetAttribution(event)
    if ("ended" == event.phase) then
        adjust.getAttribution(function(event)
            local json_attribution = json.decode(event.message)
            print("Tracker token: " .. (json_attribution.trackerToken or "N/A"))
            print("Tracker name: " .. (json_attribution.trackerName or "N/A"))
            print("Campaign: " .. (json_attribution.campaign or "N/A"))
            print("Network: " .. (json_attribution.network or "N/A"))
            print("Creative: " .. (json_attribution.creative or "N/A"))
            print("Adgroup: " .. (json_attribution.adgroup or "N/A"))
            print("Click label: " .. (json_attribution.clickLabel or "N/A"))
            print("Cost type: " .. (json_attribution.costType or "N/A"))
            print("Cost amount: " .. (json_attribution.costAmount or "N/A"))
            print("Cost currency: " .. (json_attribution.costCurrency or "N/A"))
            print("FB install referrer: " .. (json_attribution.fbInstallReferrer or "N/A"))
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (12 * 30),
    id = "button12",
    label = "Get attribution",
    onEvent = handleGetAttribution
})
