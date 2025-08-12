local testLib = require ("plugin.adjust.test") 
local adjust = require ("plugin.adjust")
local widget = require ("widget")
local json = require ("json")
local command = require ("command")
local command_executor = require ("command_executor")

-- setting up a system event listener for deeplink support
local function onSystemEvent(event)
    if event.type == "applicationOpen" and event.url then
        print("[TestApp]: applicationOpen event.url = " .. event.url)
        -- Capture app event opened from deep link
        -- adjust.processDeeplink(event.url)
    end
end

Runtime:addEventListener("system", onSystemEvent)

local launchArgs = ...
if launchArgs and launchArgs.url then
    print("[TestApp]: launchArgs.url = " .. launchArgs.url .. "")
    -- adjust.processDeeplink(launchArgs.url)
end

-- screen setup
local screenW = display.contentWidth
local screenH = display.contentHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Dark blue background (same as original design)
local background = display.newRect(centerX, centerY, screenW, screenH)
background:setFillColor(0.16, 0.25, 0.45)

-- App title at top
local titleText = display.newText({
    text = "Adjust Test App",
    x = centerX,
    y = 50,
    font = native.systemFontBold,
    fontSize = 18
})
titleText:setFillColor(1, 1, 1)

-- test session title
local testSessionTitle = display.newText({
    text = "Test Session",
    x = centerX,
    y = centerY - 80,
    font = native.systemFontBold,
    fontSize = 15
})
testSessionTitle:setFillColor(1, 1, 1)

-- subtitle text
local subtitleText = display.newText({
    text = "Tap the button below to start testing\nthe Adjust SDK functionality",
    x = centerX,
    y = centerY - 30,
    font = native.systemFont,
    fontSize = 10,
    align = "center"
})
subtitleText:setFillColor(0.8, 0.85, 0.9)

-- network configuration
local platformInfo = system.getInfo("platform")
local protocol = platformInfo == "ios" and "http" or "https"
local port = platformInfo == "ios" and "8080" or "8443"
local baseIp = "192.168.86.211"
local overwriteUrl = protocol .. "://" .. baseIp .. ":" .. port
local controlUrl = "ws://" .. baseIp .. ":1987"

-- command executor setup
local commandExecutor = command_executor.CommandExecutor:new(nil, overwriteUrl)

local function executeCommand(event)
    local rawCommand = json.decode(event.message)
    local commandObj
    if platformInfo == "ios" then
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.functionName, json.encode(rawCommand.params))
    else
        commandObj = command.Command:new(nil, rawCommand.className, rawCommand.methodName, rawCommand.parameters)
    end
    print("[TestApp]: Executing command: " .. commandObj.className .. "." .. commandObj.methodName .. " <<<<<")
    commandExecutor:executeCommand(commandObj)
end

-- initialize test library
testLib.initTestLibrary(overwriteUrl, controlUrl, executeCommand)
command_executor.setTestLib(testLib)
command_executor.setPlatform(platformInfo)

-- testLib.addTestDirectory("ad-revenue")
-- testLib.addTest("Test_ThirdPartySharing_after_install")

-- button functionality
local function startTestSession()
    adjust.getSdkVersion(function(event)
        print("[TestApp]: Starting test session with SDK version = " .. event.message)
        testLib.startTestSession(event.message)
    end)
end

-- simple start button
local startButton = widget.newButton({
    x = centerX,
    y = centerY + 50,
    width = 150,
    height = 35,
    label = "Start Test Session",
    fontSize = 10,
    fillColor = { default = {1,1,1}, over = {0.9,0.9,0.9} },
    labelColor = { default = {0.16,0.25,0.45}, over = {0.12,0.2,0.4} },
    shape = "roundedRect",
    cornerRadius = 12,
    onRelease = startTestSession
})
