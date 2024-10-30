local testLib = require "plugin.adjust.test"
local adjust = require "plugin.adjust"
local widget = require "widget"
local json = require "json"
local command = require "command"
local command_executor = require "command_executor"

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
local baseIp = "192.168.2.32"
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
 --testLib.addTest("Test_Event_token_malformed")
 --testLib.addTest("Test_Lifecycle_StartsForeground")
 --testLib.addTest("Test_VerifyTrack_delayed")
 --testLib.addTest("Test_VerifyTrack_multiple_events")


 --testLib.addTestDirectory("current/session-event-callbacks")

-- Start Test Session
-- ------------------------
local function handleStartTestSession(event)
    if ("ended" == event.phase) then
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
