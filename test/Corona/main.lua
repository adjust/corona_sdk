local testLib = require "plugin.testlibrary"
local adjust = require "plugin.adjust"
local widget = require "widget"
local json = require "json"
local command = require "command"
local adjustCommandExecutor = require "adjustCommandExecutor"

print("------------------------------------------------------------")
local platformInfo = system.getInfo("platform")
print("--Running on [" .. platformInfo .. "]--")
print("------------------------------------------------------------")

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[TestApp]: applicationOpen event. url = " .. event.url)
        -- Capture app event opened from deep link
        adjust.appWillOpenUrl(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[TestApp]: launchArgs.url = (" .. launchArgs.url .. ")")
    adjust.appWillOpenUrl(launchArgs.url)
end

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

local clientSdkInfo
local protocol
local port
if platformInfo == "ios" then
    protocol = "http"
    port = "8080"
    clientSdkInfo = "corona4.14.0@ios4.14.1"
else
    protocol = "https"
    port = "8443"
    clientSdkInfo = "corona4.14.0@android4.14.0"
end
local baseIp = "192.168.8.200"    
local baseUrl = protocol .. "://" .. baseIp .. ":" .. port
local gdprUrl = protocol .. "://" .. baseIp .. ":" .. port
print("--Using BaseUrl: [" .. baseUrl .. "]--")
local commandExecutor = adjustCommandExecutor.AdjustCommandExecutor:new(nil, baseUrl, gdprUrl)

local function executeCommand(event)
    local rawCommand = json.decode(event.message)
    local commandObj
    if platformInfo == "ios" then
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.functionName, json.encode(rawCommand.params))
    else
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.methodName, rawCommand.parameters)
    end
    --commandObj:printCommand()
    print("  >>>>> Executing command: " .. commandObj.className .. "." .. commandObj.methodName .. " <<<<<")
    commandExecutor:executeCommand(commandObj)
end

print("Create and init test lib....")
testLib.initTestLibrary(baseUrl, executeCommand)
adjustCommandExecutor.setTestLib(testLib)

print("Setting test lib tests....")
--testLib.addTest("current/session-event-callbacks/Test_EventCallback_success")
--testLib.addTest("current/session-event-callbacks/Test_EventCallback_failure")
--testLib.addTest("current/session-event-callbacks/Test_SessionCallback_success")
--testLib.addTest("current/session-event-callbacks/Test_SessionCallback_failure")
--testLib.addTest("current/attribution-callback/Test_AttributionCallback_ask_in_once")
--testLib.addTestDirectory("current/attribution-callback")
--testLib.addTestDirectory("current/session-event-callbacks")
--testLib.addTestDirectory("current/deeplink-deferred")
--testLib.addTest("current/deeplink-deferred/Test_DeferredDeeplink")
testLib.addTestDirectory("current/user-agent")

-- Start Test Session
-- ------------------------
local function handleStartTestSession(event)
    if ("ended" == event.phase) then
        testLib.startTestSession(clientSdkInfo)
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
testLib.startTestSession(clientSdkInfo)
