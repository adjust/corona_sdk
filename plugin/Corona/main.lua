local adjust = require "plugin.adjust"
local widget = require("widget")

local isAdjustEnabled = false -- flag to indicate if Adjust SDK is enabled

-- Setting up a system event listener for deeplink support
-- ---------------------------------------------------------
local function onSystemEvent(event)
  if event.type == "applicationOpen" and event.url then
    -- Capture app event opened from deep link
    adjust.appWillOpenUrl(event.url)
  end
end

Runtime:addEventListener("system", onSystemEvent)

-- Setup listeners
-- ------------------------
local function attributionListener( event )
  print("[*] Lua: Received event from Attribution listener (" .. event.name .. "): ", event.message )
end

local function sessionTrackingSucceededListener(event)
  print("[*] Lua: Received event from sessionTrackingSucceededListener (" .. event.name .. "): ", event.message )
end

local function sessionTrackingFailedListener(event)
  print("[*] Lua: Received event from sessionTrackingFailedListener (" .. event.name .. "): ", event.message )
end

local function eventTrackingSucceededListener(event)
  print("[*] Lua: Received event from eventTrackingSucceededListener (" .. event.name .. "): ", event.message )
end

local function eventTrackingFailedListener(event)
  print("[*] Lua: Received event from eventTrackingFailedListener (" .. event.name .. "): ", event.message )
end

local function deferredDeeplinkListener(event)
  print("[*] Lua: Received event from deferredDeeplinkListener (" .. event.name .. "): ", event.message )
end

adjust.setAttributionListener(attributionListener)
adjust.setEventTrackingSucceededListener(eventTrackingSucceededListener)
adjust.setEventTrackingFailedListener(eventTrackingFailedListener)
adjust.setSessionTrackingSucceededListener(sessionTrackingSucceededListener)
adjust.setSessionTrackingFailedListener(sessionTrackingFailedListener)
adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)

-- Init Adjust
-- ------------------------
adjust.create({
  appToken = "2fm9gkqubvpc",
  environment = "SANDBOX",
  logLevel = "VERBOSE",
})

isAdjustEnabled = true

-- Setting up assets
-- ------------------------
local background = display.newImageRect("background.png", 360, 570)
background.x = display.contentCenterX
background.y = display.contentCenterY

local platform = display.newImageRect("platform.png", 300, 50)
platform.x = display.contentCenterX
platform.y = display.contentHeight
platform.yScale = 0.5

local balloon = display.newImageRect( "balloon.png", 112, 112 )
balloon.x = display.contentCenterX
balloon.y = display.contentCenterY
balloon.alpha = 0.8

-- Setting up physics
-- ------------------------
local physics = require( "physics" )
physics.start()

physics.addBody( platform, "static" )
physics.addBody( balloon, "dynamic", { radius=50, bounce=0.3 } )

-- Balloon event listener
-- ------------------------
local function handleBalloonTap()
  balloon:applyLinearImpulse( 0, -0.75, balloon.x, balloon.y )

  adjust.trackEvent({
    eventToken = "g3mfiw",
  })
end

balloon:addEventListener("tap", handleBalloonTap)

-- Track Revenue Event
-- ------------------------
local function handleTrackRevenueEvent(event)
  if("ended" == event.phase) then
    adjust.trackEvent({
      eventToken = "g3mfiw",
      revenue = 0.01,
      currency = "EUR"
    })
  end
end

widget.newButton({
  left = display.contentCenterX - 50,
  top = 75 + (0*40),
  id = "button1",
  label = "Track Revenue Event",
  onEvent = handleTrackRevenueEvent
}
)

-- Track Callback Event
-- ------------------------
local function handleTrackCallbackEvent(event)
  if("ended" == event.phase) then
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
  left = display.contentCenterX - 50,
  top = 75 + (1*40),
  id = "button1",
  label = "Track Callback Event",
  onEvent = handleTrackCallbackEvent
}
)

-- Track Partner Event
-- ------------------------
local function handleTrackPartnerEvent(event)
  if("ended" == event.phase) then
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
  left = display.contentCenterX - 50,
  top = 75 + (2*40),
  id = "button1",
  label = "Track Partner Event",
  onEvent = handleTrackPartnerEvent
}
)

-- Enable offline mode
-- ------------------------
local function handleEnableOfflineMode(event)
  if("ended" == event.phase) then
    adjust.setOfflineMode(true)
  end
end

widget.newButton({
  left = display.contentCenterX - 50,
  top = 75 + (3*40),
  id = "button1",
  label = "Enable offline mode",
  onEvent = handleEnableOfflineMode
}
)

-- Disable offline mode
-- ------------------------
local function handleDisableOfflineMode(event)
  if("ended" == event.phase) then
    adjust.setOfflineMode(false)
  end
end

widget.newButton({
  left = display.contentCenterX - 50,
  top = 75 + (4*40),
  id = "button1",
  label = "Disable offline mode",
  onEvent = handleDisableOfflineMode
}
)

-- Toggle enabled mode
-- ------------------------
local function handleToggleEnabled(event)
  if("ended" == event.phase) then
    isAdjustEnabled = not isAdjustEnabled
    adjust.setEnabled(isAdjustEnabled)
  end
end

local setEnabledBtn = widget.newButton({
  left = display.contentCenterX - 50,
  top = 225,
  top = 75 + (5*40),
  id = "button1",
  label = "Toggle Enabled",
  onEvent = handleToggleEnabled
}
)
