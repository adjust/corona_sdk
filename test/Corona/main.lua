--local adjust = require "plugin.adjust"
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

-- Setting up assets
-- ------------------------
display.setDefault("background", 1, 1, 1)

local baseUrl = "https://192.168.8.103:8443"

local function executeCommand(event)
    local command = json.decode(event.message)
    print("  >>>>> Executing command: " .. command.className .. "." .. command.methodName .. " <<<<<")
    -- TODO: create and use AdjustCommandExecutor
    
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
    top = 40 + (0 * 30),
    id = "button0",
    label = "Start Test Session",
    onEvent = handleStartTestSession
})

-- START TEST SESSION AUTIMATICALLY
testLib.startTestSession("corona4.14.0@android4.14.0")