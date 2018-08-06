local adjust = require "plugin.adjust"
local testLib = require "plugin.testlibrary"
local widget = require "widget"
local json = require "json"

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[TestApp]: applicationOpen event. url = " .. event.url)
        -- Capture app event opened from deep link
        --adjust.appWillOpenUrl(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[Adjust]: launchArgs.url = (" .. launchArgs.url)
    --adjust.appWillOpenUrl(launchArgs.url)
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
    print("[Adjust]: JSON response: " .. json_session_success.jsonResponse)
end

local function sessionTrackingFailureListener(event)
    local json_session_failure = json.decode(event.message)
    print("[Adjust]: Session tracking failure!")
    print("[Adjust]: Message: " .. json_session_failure.message)
    print("[Adjust]: Timestamp: " .. json_session_failure.timestamp)
    print("[Adjust]: Adid: " .. json_session_failure.adid)
    print("[Adjust]: Will retry: " .. json_session_failure.adid)
    print("[Adjust]: JSON response: " .. json_session_failure.jsonResponse)
end

local function eventTrackingSuccessListener(event)
    local json_event_success = json.decode(event.message)
    print("[Adjust]: Event tracking success!")
    print("[Adjust]: Event token: " .. json_event_success.eventToken)
    print("[Adjust]: Message: " .. json_event_success.message)
    print("[Adjust]: Timestamp: " .. json_event_success.timestamp)
    print("[Adjust]: Adid: " .. json_event_success.adid)
    print("[Adjust]: JSON response: " .. json_event_success.jsonResponse)
end

local function eventTrackingFailureListener(event)
    local json_event_failure = json.decode(event.message)
    print("[Adjust]: Event tracking failure!")
    print("[Adjust]: Event token: " .. json_event_failure.eventToken)
    print("[Adjust]: Message: " .. json_event_failure.message)
    print("[Adjust]: Timestamp: " .. json_event_failure.timestamp)
    print("[Adjust]: Adid: " .. json_event_failure.adid)
    print("[Adjust]: Will retry: " .. json_event_failure.willRetry)
    print("[Adjust]: JSON response: " .. json_event_failure.jsonResponse)
end

local function deferredDeeplinkListener(event)
    print("[Adjust]: Received event from deferredDeeplinkListener (" .. event.name .. "): ", event.message)
end

--adjust.setAttributionListener(attributionListener)
--adjust.setEventTrackingSuccessListener(eventTrackingSuccessListener)
--adjust.setEventTrackingFailureListener(eventTrackingFailureListener)
--adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListener)
--adjust.setSessionTrackingFailureListener(sessionTrackingFailureListener)
--adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)

-- Init Adjust
-- ------------------------
--adjust.addSessionCallbackParameter("scp1", "scp1_value1")
--adjust.addSessionCallbackParameter("scp2", "scp2_value2")
--adjust.addSessionCallbackParameter("scp3", "scp3_value3")
--
--adjust.removeSessionCallbackParameter("scp2")
--
--adjust.resetSessionCallbackParameters()
--
--adjust.addSessionPartnerParameter("spp1", "spp1_value1")
--adjust.addSessionPartnerParameter("spp2", "spp2_value2")
--adjust.addSessionPartnerParameter("spp3", "spp3_value3")
--
--adjust.removeSessionPartnerParameter("spp1")
--
--adjust.resetSessionPartnerParameters()

--adjust.create({
--    appToken = "2fm9gkqubvpc",
--    environment = "SANDBOX",
--    logLevel = "VERBOSE",
--    -- shouldLaunchDeeplink = false,
--    -- eventBufferingEnabled = true,
--    -- delayStart = 6.0,
--    -- isDeviceKnown = true,
--    -- sendInBackground = true,
--    -- defaultTracker = "abc123",
--    -- userAgent = "Random User Agent 6.6"
--    -- readMobileEquipmentIdentity = true
--    -- secretId = aaa,
--    -- info1 = bbb,
--    -- info2 = ccc,
--    -- info3 = ddd,
--    -- info4 = eee,
--})

-- adjust.setPushToken("{YourPushToken}")
-- adjust.sendFirstPackages()

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

local baseUrl = "https://192.168.8.103:8443"

local function executeCommand(event)
    local command = json.decode(event.message)
    print("  >>>>> Executing command: " .. command.className .. "." .. command.methodName .. " <<<<<")
    
    
end

print("Create and init test lib....")
testLib.initTestLibrary(baseUrl, executeCommand)
print("Setting test lib tests....")
testLib.addTest("current/event-tracking/Test_Event_Count_6events")

-- Start Test Session
-- ------------------------
local function handleStartTestSession(event)
    if ("ended" == event.phase) then
        testLib.startTestSession("corona4.14.0@android4.14.0")
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (3 * 30),
    id = "button2",
    label = "Start Test Session",
    onEvent = handleStartTestSession
})

-- Test Func
-- ------------------------
local function handleTestFunc(event)
    if ("ended" == event.phase) then
        testLib.testFunc()
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (5 * 30),
    id = "button3",
    label = "Test Func",
    onEvent = handleTestFunc
})

-- Track Revenue Event
-- ------------------------
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
