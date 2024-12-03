local testLib = require ("plugin.adjust.test") 
local adjust = require ("plugin.adjust")
local widget = require ("widget")
local json = require ("json")
local command = require ("command")
local command_executor = require ("command_executor")

print("------------------------------------------------------------")
local platformInfo = system.getInfo("platform")
print("[TestApp]: Running on [" .. platformInfo .. "]--")
print("------------------------------------------------------------")

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[TestApp]: applicationOpen event. url = " .. event.url)
        -- Capture app event opened from deep link
        -- adjust.appWillOpenUrl(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[TestApp]: launchArgs.url = (" .. launchArgs.url .. ")")
    -- adjust.appWillOpenUrl(launchArgs.url)
end

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

local protocol
local port
if platformInfo == "ios" then
    protocol = "http"
    port = "8080"
else
    protocol = "https"
    port = "8443"
end
local baseIp = "192.168.8.16"
local overwriteUrl = protocol .. "://" .. baseIp .. ":" .. port
local controlUrl = "ws://" .. baseIp .. ":1987";
print("[TestApp]: Using BaseUrl: [" .. overwriteUrl .. "]--")
local commandExecutor = command_executor.CommandExecutor:new(nil, overwriteUrl)

local function executeCommand(event)
    local rawCommand = json.decode(event.message)
    local commandObj
    if platformInfo == "ios" then
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.functionName, json.encode(rawCommand.params))
    else
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.methodName, rawCommand.parameters)
    end
    --commandObj:printCommand()
    print("[TestApp]: Executing command: " .. commandObj.className .. "." .. commandObj.methodName .. " <<<<<")
    commandExecutor:executeCommand(commandObj)
end

print("[TestApp]: Create and init test lib....")
testLib.initTestLibrary(overwriteUrl, controlUrl, executeCommand)
command_executor.setTestLib(testLib)
command_executor.setPlatform(platformInfo)

print("[TestApp]: Setting test lib tests....")

--testLib.addTest("Test_GdprForgetMe_inbetween_multiple_events")

--testLib.addTestDirectory("deeplink-getter")
--testLib.addTestDirectory("global-parameters")
--testLib.addTestDirectory("ad-revenue")
--testLib.addTestDirectory("tracking-domain")
--testLib.addTestDirectory("disable-enable")
--testLib.addTestDirectory("subscription")
--testLib.addTestDirectory("link-shortener")
--testLib.addTestDirectory("parameters")
--testLib.addTestDirectory("coppa")
--testLib.addTestDirectory("attribution-initiated-by")
--testLib.addTestDirectory("push-token")
--testLib.addTestDirectory("retry-in")
--testLib.addTestDirectory("attribution-getter")
--testLib.addTestDirectory("session-count")
testLib.addTestDirectory("default-tracker")
--testLib.addTestDirectory("error-responses")
--testLib.addTestDirectory("third-party-sharing")
--testLib.addTestDirectory("pasteboard")
--testLib.addTestDirectory("event-tracking")
--testLib.addTestDirectory("measurement-consent")
--testLib.addTestDirectory("session-callbacks")
--testLib.addTestDirectory("init-malformed")
--testLib.addTestDirectory("sdk-prefix")
--testLib.addTestDirectory("continue-in")
--testLib.addTestDirectory("queue-size")
--testLib.addTestDirectory("purchase-verification")
--testLib.addTestDirectory("deeplink")
--testLib.addTestDirectory("google-kids")
--testLib.addTestDirectory("send-in-background")
--testLib.addTestDirectory("offline-mode")
--testLib.addTestDirectory("verify-track")
--testLib.addTestDirectory("skan")
--testLib.addTestDirectory("gdpr")
--testLib.addTestDirectory("deeplink-deferred")
--testLib.addTestDirectory("lifecycle")
--testLib.addTestDirectory("ad-services")
--testLib.addTestDirectory("external-device-id")
--testLib.addTestDirectory("attribution-callback")
--testLib.addTestDirectory("event-callbacks")


testLib.startTestSession("corona5.0.0@ios5.0.1")

-- Start Test Session
-- ------------------------
local function handleStartTestSession(event)
    if ("ended" == event.phase) then
        print("start test")
        adjust.getSdkVersion(function(event)
            print("[TestApp]: starting test session with sdk version = " .. event.message)
            testLib.startTestSession(event.message)
        end)
    end
end

widget.newButton({
    left = display.contentCenterX - 85,
    top = 40 + (0 * 30),
    id = "button0",
    label = "Start Test Session",
    onEvent = handleStartTestSession
})

-- START TEST SESSION AUTIMATICALLY
-- adjust.getSdkVersion(function(event)
--     print("[TestApp]: starting test session with sdk version = " .. event.message)
--     testLib.startTestSession(event.message)
-- end)
