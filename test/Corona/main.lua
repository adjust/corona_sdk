local testLib = require "plugin.testlibrary"
local widget = require "widget"
local json = require "json"
local command = require "command"
local adjustCommandExecutor = require "adjustCommandExecutor"

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

local baseIp = "192.168.8.159"
local baseUrl = "https://" .. baseIp .. ":8443"
local gdprUrl = "https://" .. baseIp .. ":8443"
local commandExecutor = adjustCommandExecutor.AdjustCommandExecutor:new(nil, baseUrl, gdprUrl)

local function executeCommand(event)
    local rawCommand = json.decode(event.message)
    local command = command.Command:new(nil, rawCommand.className, rawCommand.methodName, rawCommand.parameters)
    --command:printCommand()
    print("  >>>>> Executing command: " .. command.className .. "." .. command.methodName .. " <<<<<")
    commandExecutor:executeCommand(command)
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
--testLib.addTestDirectory("current/session-event-callbacks")
--testLib.addTestDirectory("current/attribution-callback")

-- Start Test Session
-- ------------------------
local function handleStartTestSession(event)
    if ("ended" == event.phase) then
        testLib.startTestSession("corona4.14.0@android4.14.0")
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
testLib.startTestSession("corona4.14.0@android4.14.0")
