local adjust = require "plugin.adjust"
local widget = require("widget")

local isAdjustEnabled = false -- flag to indicate if Adjust SDK is enabled

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[*] Lua: applicationOpen. Event url is (" .. event.url .. ")")
        -- Capture app event opened from deep link
        adjust.appWillOpenUrl(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[*] Lua: launchArgs url is (" .. launchArgs.url .. ")")
    adjust.appWillOpenUrl(launchArgs.url)
end

-- Setup listeners
-- ------------------------
local function attributionListener(event)
    print("[*] Lua: Received event from Attribution listener (" .. event.name .. "): ", event.message)
end

local function sessionTrackingSuccessListener(event)
    print("[*] Lua: Received event from sessionTrackingSuccessListener (" .. event.name .. "): ", event.message)
end

local function sessionTrackingFailureListener(event)
    print("[*] Lua: Received event from sessionTrackingFailureListener (" .. event.name .. "): ", event.message)
end

local function eventTrackingSuccessListener(event)
    print("[*] Lua: Received event from eventTrackingSuccessListener (" .. event.name .. "): ", event.message)
end

local function eventTrackingFailureListener(event)
    print("[*] Lua: Received event from eventTrackingFailureListener (" .. event.name .. "): ", event.message)
end

local function deferredDeeplinkListener(event)
    print("[*] Lua: Received event from deferredDeeplinkListener (" .. event.name .. "): ", event.message)
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
    -- shouldLaunchDeeplink = false,
    -- eventBufferingEnabled = true,
    -- delayStart = 6.0,
    -- isDeviceKnown = true,
    -- sendInBackground = true,
    -- defaultTracker = "abc123",
    -- userAgent = "Crappy User Agent 6.6"
    -- readMobileEquipmentIdentity = true
    -- secretId = 1,
    -- info1 = 552143313,
    -- info2 = 465657129,
    -- info3 = 437714723,
    -- info4 = 1932667013,
})

adjust.setPushToken("crappy_omg_token")

isAdjustEnabled = true

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
        adjust.setPushToken("le_crappy_token_le")
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (0 * 30),
    id = "button1",
    label = "Track Simple Event",
    onEvent = handleTrackSimpleEvent
})

-- Track Revenue Event
-- ------------------------
local function handleTrackRevenueEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "g3mfiw",
            revenue = 0.01,
            currency = "EUR",
            transactionId = "some_transaction_id"
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (1 * 30),
    id = "button2",
    label = "Track Revenue Event",
    onEvent = handleTrackRevenueEvent
})

-- Track Callback Event
-- ------------------------
local function handleTrackCallbackEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "g3mfiw",
            callbackParameters = {
                {
                    key = "bunny1",
                    value = "foofoo1",
                },
                {
                    key = "bunny2",
                    value = "foofoo2",
                },
            },
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (2 * 30),
    id = "button3",
    label = "Track Callback Event",
    onEvent = handleTrackCallbackEvent
})

-- Track Partner Event
-- ------------------------
local function handleTrackPartnerEvent(event)
    if ("ended" == event.phase) then
        adjust.trackEvent({
            eventToken = "g3mfiw",
            partnerParameters = {
                {
                    key = "bunny1",
                    value = "foofoo1",
                },
                {
                    key = "bunny2",
                    value = "foofoo2",
                },
            },
        })
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (3 * 30),
    id = "button4",
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
    id = "button5",
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
    id = "button6",
    label = "Disable offline mode",
    onEvent = handleDisableOfflineMode
})

-- Toggle enabled mode
-- ------------------------
local function handleToggleEnabled(event)
    if ("ended" == event.phase) then
        isAdjustEnabled = not isAdjustEnabled
        adjust.setEnabled(isAdjustEnabled)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (6 * 30),
    id = "button7",
    label = "Toggle Enabled",
    onEvent = handleToggleEnabled
})

-- is Enabled
-- ------------------------
local function handleIsEnabled(event)
    if ("ended" == event.phase) then
        adjust.isEnabled(function(event) print("[*] Lua: isEnabled (" .. event.message .. ")") end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (7 * 30),
    id = "button8",
    label = "Is Enabled",
    onEvent = handleIsEnabled
})

-- Get Adid
-- ------------------------
local function handleGetAdid(event)
    if ("ended" == event.phase) then
        adjust.getAdid(function(event) print("[*] Lua: getAdid (" .. event.message .. ")") end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (8 * 30),
    id = "button9",
    label = "Get Adid",
    onEvent = handleGetAdid
})

-- Get Google Adid
-- ------------------------
local function handleGetAdid(event)
    if ("ended" == event.phase) then
        adjust.getGoogleAdId(function(event) print("[*] Lua: getGoogleAdId (" .. event.message .. ")") end)
        adjust.getAmazonAdId(function(event) print("[*] Lua: amazonAdId (" .. event.message .. ")") end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (9 * 30),
    id = "button10",
    label = "Get Google Adid",
    onEvent = handleGetAdid
})

-- Get Idfa
-- ------------------------
local function handleGetIdfa(event)
    if ("ended" == event.phase) then
        adjust.getIdfa(function(event) print("[*] Lua: getIdfa (" .. event.message .. ")") end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (10 * 30),
    id = "button11",
    label = "Get Idfa",
    onEvent = handleGetIdfa
})

-- Get Attribution
-- ------------------------
local function handleGetAttribution(event)
    if ("ended" == event.phase) then
        adjust.getAttribution(function(event) print("[*] Lua: getAttribution (" .. event.message .. ")") end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (11 * 30),
    id = "button12",
    label = "Get Attribution",
    onEvent = handleGetAttribution
})
