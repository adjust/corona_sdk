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

adjust.create({
  appToken = "2fm9gkqubvpc",
  environment = "SANDBOX",
  logLevel = "VERBOSE",
  eventBufferingEnabled = true,
})

--timer.performWithDelay( 1000, function()
	--library.foo( "bunny foo foo" )
--end )

