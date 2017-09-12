local adjust = require "plugin.adjust"

-- This event is dispatched to the global Runtime object
-- by `didLoadMain:` in MyCoronaDelegate.mm
--local function delegateListener( event )
	--native.showAlert(
		--"Event dispatched from `didLoadMain:`",
		--"of type: " .. tostring( event.name ),
		--{ "OK" } )
--end
--Runtime:addEventListener( "delegate", delegateListener )

-- This event is dispatched to the following Lua function
-- by PluginLibrary::show() in PluginLibrary.mm
--local function listener( event )
	--print( "Received event from Library plugin (" .. event.name .. "): ", event.message )
--end

--library.init( listener )

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

adjust.create({
  appToken = "2fm9gkqubvpc",
  environment = "SANDBOX",
  logLevel = "VERBOSE",
  eventBufferingEnabled = true,
  sdkPrefix = "sdkPrefix1",
  defaultTracker = "myDefaultTracker",
  userAgent = "myUserAgent",
  sendInBackground = true,
  shouldLaunchDeeplink = false,
  delayStart = 20.0,
})

--timer.performWithDelay( 1000, function()
	--library.foo( "bunny foo foo" )
--end )

