local adjust = require "plugin.adjust"
local json = require "json"

local module = {}
local platformInfo = system.getInfo("platform")

platform = ""
testLib = nil
localBasePath = ""

CommandExecutor = {
    baseUrl = "",
    gdprUrl = "",
    subscriptionUrl = "",
    extraPath = "",
    basePath = "",
    gdprPath = "",
    subscriptionPath = "",
    extraPath = "",
    savedEvents = {},
    savedConfigs = {},
    command = nil
}

function CommandExecutor:new (o, baseUrl, gdprUrl, subscriptionUrl)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.baseUrl = baseUrl
    self.gdprUrl = gdprUrl
    self.subscriptionUrl = subscriptionUrl
    return o
end

function module.setTestLib(tl)
    testLib = tl
end

function module.setPlatform(p)
    platform = p
end

function CommandExecutor:executeCommand(command)
    self.command = command
    local method = command.methodName
    
    if method == "testOptions" then self:testOptions()
    elseif method == "config" then self:config()
    elseif method == "start" then self:start()
    elseif method == "event" then self:event()
    elseif method == "trackEvent" then self:trackEvent()
    elseif method == "resume" then self:resume()
    elseif method == "pause" then self:pause()
    elseif method == "setEnabled" then self:setEnabled()
    elseif method == "setReferrer" then self:setReferrer()
    elseif method == "setOfflineMode" then self:setOfflineMode()
    elseif method == "sendFirstPackages" then self:sendFirstPackages()
    elseif method == "addSessionCallbackParameter" then self:addSessionCallbackParameter()
    elseif method == "addSessionPartnerParameter" then self:addSessionPartnerParameter()
    elseif method == "removeSessionCallbackParameter" then self:removeSessionCallbackParameter()
    elseif method == "removeSessionPartnerParameter" then self:removeSessionPartnerParameter()
    elseif method == "resetSessionCallbackParameters" then self:resetSessionCallbackParameters()
    elseif method == "resetSessionPartnerParameters" then self:resetSessionPartnerParameters()    
    elseif method == "setPushToken" then self:setPushToken()
    elseif method == "openDeeplink" then self:openDeeplink()
    elseif method == "sendReferrer" then self:sendReferrer()
    elseif method == "gdprForgetMe" then self:gdprForgetMe()
    elseif method == "trackAdRevenue" then self:trackAdRevenue()
    elseif method == "disableThirdPartySharing" then self:disableThirdPartySharing()
    elseif method == "trackSubscription" then self:trackSubscription()
        
    else print("CommandExecutor: unknown method name: " .. method)
    end
end

function CommandExecutor:testOptions()
    local testOptions = {}
    testOptions.baseUrl = self.baseUrl
    testOptions.gdprUrl = self.gdprUrl
    testOptions.subscriptionUrl = self.subscriptionUrl
    
    if self.command:containsParameter("basePath") then
        self.basePath = self.command:getFirstParameterValue("basePath")
        self.gdprPath = self.command:getFirstParameterValue("basePath")
        self.subscriptionPath = self.command:getFirstParameterValue("basePath")
        self.extraPath = self.command:getFirstParameterValue("basePath")
    end
    
    if self.command:containsParameter("timerInterval") then
        local timerInterval = tonumber(self.command:getFirstParameterValue("timerInterval"))
        testOptions.timerIntervalInMilliseconds = timerInterval
    end
    
    if self.command:containsParameter("timerStart") then
        local timerStart = tonumber(self.command:getFirstParameterValue("timerStart"))
        testOptions.timerStartInMilliseconds = timerStart
    end
    
    if self.command:containsParameter("sessionInterval") then
        local sessionInterval = tonumber(self.command:getFirstParameterValue("sessionInterval"))
        testOptions.sessionIntervalInMilliseconds = sessionInterval
    end
    
    if self.command:containsParameter("subsessionInterval") then
        local subsessionInterval = tonumber(self.command:getFirstParameterValue("subsessionInterval"))
        testOptions.subsessionIntervalInMilliseconds = subsessionInterval
    end
    
    if self.command:containsParameter("tryInstallReferrer") then
        local tryInstallReferrer = self.command:getFirstParameterValue("tryInstallReferrer")
        if tryInstallReferrer == "true" then
            testOptions.tryInstallReferrer = true
        else
            testOptions.tryInstallReferrer = false
        end
    end
    
    if self.command:containsParameter("noBackoffWait") then
        local noBackoffWait = self.command:getFirstParameterValue("noBackoffWait")
        if noBackoffWait == "true" then
            testOptions.noBackoffWait = true
        else
            testOptions.noBackoffWait = false
        end
    end
    
    if self.command:containsParameter("iAdFrameworkEnabled") then
        local iAdFrameworkEnabled = self.command:getFirstParameterValue("iAdFrameworkEnabled")
        if iAdFrameworkEnabled == "true" then
            testOptions.iAdFrameworkEnabled = true
        else
            testOptions.iAdFrameworkEnabled = false
        end
    end
    
    if self.command:containsParameter("teardown") then
        local teardownOptions = self.command.parameters["teardown"]
        for k in pairs(teardownOptions) do
            local option = teardownOptions[k]
            if option == "resetSdk" then
                testOptions.teardown = true
                testOptions.basePath = self.basePath
                testOptions.gdprPath = self.gdprPath
                testOptions.subscriptionPath = self.subscriptionPath
                testOptions.extraPath = self.extraPath
                testOptions.useTestConnectionOptions = true
                testOptions.tryInstallReferrer = false
            elseif option == "deleteState" then 
                testOptions.setContext = true
                testOptions.deleteState = true
            elseif option == "resetTest" then 
                self:clearSavedConfigsAndEvents()
                testOptions.timerIntervalInMilliseconds = -1
                testOptions.timerStartInMilliseconds = -1
                testOptions.sessionIntervalInMilliseconds = -1
                testOptions.subsessionIntervalInMilliseconds = -1
            elseif option == "sdk" then 
                testOptions.teardown = true
                testOptions.basePath = nil
                testOptions.gdprPath = nil
                testOptions.subscriptionPath = nil
                testOptions.extraPath = nil
                testOptions.useTestConnectionOptions = false
            elseif option == "test" then 
                self:clearSavedConfigsAndEvents()
                testOptions.timerIntervalInMilliseconds = -1
                testOptions.timerStartInMilliseconds = -1
                testOptions.sessionIntervalInMilliseconds = -1
                testOptions.subsessionIntervalInMilliseconds = -1
            end
        end
    end
    
    adjust.setTestOptions(testOptions)
end

function CommandExecutor:config()
    local configNumber = 0
    if self.command:containsParameter("configName") then
        local configName = self.command:getFirstParameterValue("configName")
        local configNumberStr = string.sub(configName, string.len(configName) - 1)
        configNumber = tonumber(configNumberStr)
    end
    
    local adjustConfig = {}
    if self.savedConfigs[configNumber] ~= nil then
        adjustConfig = self.savedConfigs[configNumber]
    else
        adjustConfig.environment = self.command:getFirstParameterValue("environment")
        adjustConfig.appToken = self.command:getFirstParameterValue("appToken")
        adjustConfig.logLevel = "VERBOSE"
        
        self.savedConfigs[configNumber] = adjustConfig
    end
    
    if self.command:containsParameter("logLevel") then
        adjustConfig.logLevel = self.command:getFirstParameterValue("logLevel")
    end
    
    if self.command:containsParameter("sdkPrefix") then
        -- not needed
    end
    
    if self.command:containsParameter("defaultTracker") then
        adjustConfig.defaultTracker = self.command:getFirstParameterValue("defaultTracker")
    end

    if self.command:containsParameter("externalDeviceId") then
        adjustConfig.externalDeviceId = self.command:getFirstParameterValue("externalDeviceId")
    end
    
    if self.command:containsParameter("appSecret") then
        local appSecretArray = self.command.parameters["appSecret"]
        adjustConfig.secretId = tonumber(appSecretArray[1])
        adjustConfig.info1 = tonumber(appSecretArray[2])
        adjustConfig.info2 = tonumber(appSecretArray[3])
        adjustConfig.info3 = tonumber(appSecretArray[4])
        adjustConfig.info4 = tonumber(appSecretArray[5])
    end
    
    if self.command:containsParameter("delayStart") then
        adjustConfig.delayStart = tonumber(self.command:getFirstParameterValue("delayStart"))
    end
    
    if self.command:containsParameter("deviceKnown") then
        adjustConfig.isDeviceKnown = (self.command:getFirstParameterValue("deviceKnown") == "true")
    end
    
    if self.command:containsParameter("eventBufferingEnabled") then
        adjustConfig.eventBufferingEnabled = (self.command:getFirstParameterValue("eventBufferingEnabled") == "true")
    end

    if self.command:containsParameter("allowiAdInfoReading") then
        adjustConfig.allowiAdInfoReading = (self.command:getFirstParameterValue("allowiAdInfoReading") == "true")
    end

    if self.command:containsParameter("allowIdfaReading") then
        adjustConfig.allowIdfaReading = (self.command:getFirstParameterValue("allowIdfaReading") == "true")
    end
    
    if self.command:containsParameter("sendInBackground") then
        adjustConfig.sendInBackground = (self.command:getFirstParameterValue("sendInBackground") == "true")
    end
    
    if self.command:containsParameter("userAgent") then
        adjustConfig.userAgent = self.command:getFirstParameterValue("userAgent")
    end
    
    -- first, clear all callback
    adjust.setDeferredDeeplinkListener(deferredDeeplinkListenerEmpty)
    adjust.setAttributionListener(attributionListenerEmpty)
    adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListenerEmpty)
    adjust.setSessionTrackingFailureListener(sessionTrackingFailureListenerEmpty)
    adjust.setEventTrackingSuccessListener(eventTrackingSuccessListenerEmpty)
    adjust.setEventTrackingFailureListener(eventTrackingFailureListenerEmpty)
    
    if self.command:containsParameter("deferredDeeplinkCallback") then
        localBasePath = self.basePath
        adjustConfig.shouldLaunchDeeplink = (self.command:getFirstParameterValue("deferredDeeplinkCallback") == "true")
        print("[CommandExecutor]: Setting deferred deeplink callback... adjustConfig.shouldLaunchDeeplink=" .. tostring(adjustConfig.shouldLaunchDeeplink))
        adjust.setDeferredDeeplinkListener(deferredDeeplinkListener)
    end
    
    if self.command:containsParameter("attributionCallbackSendAll") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting attribution callback... lbp=" .. localBasePath)
        adjust.setAttributionListener(attributionListener)
    end
    
    if self.command:containsParameter("sessionCallbackSendSuccess") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting session send success callback... local-base-path=" .. localBasePath)
        adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListener)
    end
    
    if self.command:containsParameter("sessionCallbackSendFailure") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting session send failure callback... local-base-path=" .. localBasePath)
        adjust.setSessionTrackingFailureListener(sessionTrackingFailureListener)
    end
    
    if self.command:containsParameter("eventCallbackSendSuccess") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting event tracking success callback... local-base-path=" .. localBasePath)
        adjust.setEventTrackingSuccessListener(eventTrackingSuccessListener)
    end
    
    if self.command:containsParameter("eventCallbackSendFailure") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting event tracking failed callback... local-base-path=" .. localBasePath)
        adjust.setEventTrackingFailureListener(eventTrackingFailureListener)
    end
end

function deferredDeeplinkListenerEmpty(event)
end
function attributionListenerEmpty(event)
end
function sessionTrackingSuccessListenerEmpty(event)
end
function sessionTrackingFailureListenerEmpty(event)
end
function eventTrackingSuccessListenerEmpty(event)
end
function eventTrackingFailureListenerEmpty(event)
end

function deferredDeeplinkListener(event)
    print("[CommandExecutor]: Deferred deeplink received!")
    
    if event == nil then
        print("[CommandExecutor]: Deeplink response, uri = nil")
        return false
    end
    
    local deeplink
    if platform == "ios" then
        deeplink = event.message
    else
        deeplink = json.decode(event.message).uri
    end
    
    print("[CommandExecutor]: deferred deeplink: " .. deeplink)
    testLib.addInfoToSend("deeplink", deeplink)
    testLib.sendInfoToServer(localBasePath)
end

function attributionListener(event)
    print("[CommandExecutor]: Attribution received!")
    local json_attribution = json.decode(event.message)
    testLib.addInfoToSend("trackerToken", json_attribution.trackerToken)
    testLib.addInfoToSend("trackerName", json_attribution.trackerName)
    testLib.addInfoToSend("network", json_attribution.network)
    testLib.addInfoToSend("campaign", json_attribution.campaign)
    testLib.addInfoToSend("adgroup", json_attribution.adgroup)
    testLib.addInfoToSend("creative", json_attribution.creative)
    testLib.addInfoToSend("clickLabel", json_attribution.clickLabel)
    testLib.addInfoToSend("adid", json_attribution.adid)
    testLib.sendInfoToServer(localBasePath)
end

function sessionTrackingSuccessListener(event)
    print("[CommandExecutor]: Session tracking success event received!")
    local json_session_success = json.decode(event.message)
    testLib.addInfoToSend("message", json_session_success.message)
    testLib.addInfoToSend("timestamp", json_session_success.timestamp)
    testLib.addInfoToSend("adid", json_session_success.adid)
    if json_session_success.jsonResponse ~= nil then
        if platformInfo == "ios" then
            testLib.addInfoToSend("jsonResponse", json.encode(json_session_success.jsonResponse))
        else
            testLib.addInfoToSend("jsonResponse", json_session_success.jsonResponse)
        end
    end
    testLib.sendInfoToServer(localBasePath)
end

function sessionTrackingFailureListener(event)
    print("[CommandExecutor]: Session tracking failure event received!")
    local json_session_failure = json.decode(event.message)
    testLib.addInfoToSend("message", json_session_failure.message)
    testLib.addInfoToSend("timestamp", json_session_failure.timestamp)
    testLib.addInfoToSend("adid", json_session_failure.adid)
    testLib.addInfoToSend("willRetry", tostring(json_session_failure.willRetry))
    if json_session_failure.jsonResponse ~= nil then
        if platformInfo == "ios" then
            testLib.addInfoToSend("jsonResponse", json.encode(json_session_failure.jsonResponse))
        else
            testLib.addInfoToSend("jsonResponse", json_session_failure.jsonResponse)
        end
    end
    testLib.sendInfoToServer(localBasePath)
end

function eventTrackingSuccessListener(event)
    print("[CommandExecutor]: Event tracking success event received!")
    local json_event_success = json.decode(event.message)
    testLib.addInfoToSend("message", json_event_success.message)
    testLib.addInfoToSend("timestamp", json_event_success.timestamp)
    testLib.addInfoToSend("adid", json_event_success.adid)
    testLib.addInfoToSend("eventToken", json_event_success.eventToken)
    testLib.addInfoToSend("callbackId", json_event_success.callbackId)
    if json_event_success.jsonResponse ~= nil then
        if platformInfo == "ios" then
            testLib.addInfoToSend("jsonResponse", json.encode(json_event_success.jsonResponse))
        else
            testLib.addInfoToSend("jsonResponse", json_event_success.jsonResponse)
        end
    end
    testLib.sendInfoToServer(localBasePath)
end

function eventTrackingFailureListener(event)
    print("[CommandExecutor]: Event tracking failed event received!")
    local json_event_failure = json.decode(event.message)
    testLib.addInfoToSend("message", json_event_failure.message)
    testLib.addInfoToSend("timestamp", json_event_failure.timestamp)
    testLib.addInfoToSend("adid", json_event_failure.adid)
    testLib.addInfoToSend("eventToken", json_event_failure.eventToken)
    testLib.addInfoToSend("callbackId", json_event_failure.callbackId)
    testLib.addInfoToSend("willRetry", tostring(json_event_failure.willRetry))
    if json_event_failure.jsonResponse ~= nil then
        if platformInfo == "ios" then
            testLib.addInfoToSend("jsonResponse", json.encode(json_event_failure.jsonResponse))
        else
            testLib.addInfoToSend("jsonResponse", json_event_failure.jsonResponse)
        end
    end
    testLib.sendInfoToServer(localBasePath)
end

function CommandExecutor:start()
    self:config()
    
    local configNumber = 0
    if self.command:containsParameter("configName") then
        local configName = self.command:getFirstParameterValue("configName")
        local configNumberStr = string.sub(configName, string.len(configName) - 1)
        configNumber = tonumber(configNumberStr)
    end
   
    local adjustConfig = self.savedConfigs[configNumber]
    print("[CommandExecutor]: Sending adjust config to adjust.create: " .. json.encode(adjustConfig))
    adjust.create(adjustConfig)
    
    self.savedConfigs[configNumber] = nil
end

function CommandExecutor:event()
    local eventNumber = 0
    if self.command:containsParameter("eventName") then
        local eventName = self.command:getFirstParameterValue("eventName")
        local eventNumberStr = string.sub(eventName, string.len(eventName) - 1)
        eventNumber = tonumber(eventNumberStr)
    end
    
    local adjustEvent = {}
    if self.savedEvents[eventNumber] ~= nil then
        adjustEvent = self.savedEvents[eventNumber]
    else
        adjustEvent.eventToken = self.command:getFirstParameterValue("eventToken")
        self.savedEvents[eventNumber] = adjustEvent
    end
    
    if self.command:containsParameter("revenue") then
        local revenueParams = self.command.parameters["revenue"]
        adjustEvent.currency = revenueParams[1]
        adjustEvent.revenue = tonumber(revenueParams[2])
    end

    if self.command:containsParameter("callbackId") then
        adjustEvent.callbackId = self.command:getFirstParameterValue("callbackId")
    end
    
    if self.command:containsParameter("callbackParams") then
        local callbackParams = self.command.parameters["callbackParams"]
        adjustEvent.callbackParameters = {}
        local k = 1
        for i=1, #callbackParams, 2 do
            adjustEvent.callbackParameters[k] = { 
                key = callbackParams[i], 
                value = callbackParams[i + 1] 
            }
            k = k + 1
        end
    end
    
    if self.command:containsParameter("partnerParams") then
        local partnerParams = self.command.parameters["partnerParams"]
        adjustEvent.partnerParameters = {}
        local k = 1
        for i=1, #partnerParams, 2 do
            adjustEvent.partnerParameters[k] = { 
                key = partnerParams[i], 
                value = partnerParams[i + 1] 
            }
            k = k + 1
        end
    end
    
    if self.command:containsParameter("orderId") then
        adjustEvent.transactionId = self.command:getFirstParameterValue("orderId")
    end
end

function CommandExecutor:trackEvent()
    self:event()
    
    local eventNumber = 0
    if self.command:containsParameter("eventName") then
        local eventName = self.command:getFirstParameterValue("eventName")
        local eventNumberStr = string.sub(eventName, string.len(eventName) - 1)
        eventNumber = tonumber(eventNumberStr)
    end
    
    local adjustEvent = self.savedEvents[eventNumber]
    adjust.trackEvent(adjustEvent)
    
    self.savedEvents[eventNumber] = nil
end

function CommandExecutor:resume()
    adjust.onResume("test")
end

function CommandExecutor:pause()
    adjust.onPause("test")
end

function CommandExecutor:setEnabled()
    local enabled = (self.command:getFirstParameterValue("enabled") == "true")
    adjust.setEnabled(enabled)
end

function CommandExecutor:setReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function CommandExecutor:setOfflineMode()
    local enabled = (self.command:getFirstParameterValue("enabled") == "true")
    adjust.setOfflineMode(enabled)
end

function CommandExecutor:sendFirstPackages()
    adjust.sendFirstPackages()
end

function CommandExecutor:addSessionCallbackParameter()
    if self.command:containsParameter("KeyValue") then
        local keyValuePairs = self.command.parameters["KeyValue"]
        for i=1, #keyValuePairs, 2 do
            local key = keyValuePairs[i]
            local value = keyValuePairs[i + 1]
            adjust.addSessionCallbackParameter(key, value)
        end
    end
end

function CommandExecutor:addSessionPartnerParameter()
    if self.command:containsParameter("KeyValue") then
        local keyValuePairs = self.command.parameters["KeyValue"]
        for i=1, #keyValuePairs, 2 do
            local key = keyValuePairs[i]
            local value = keyValuePairs[i + 1]
            adjust.addSessionPartnerParameter(key, value)
        end
    end
end

function CommandExecutor:removeSessionCallbackParameter()
    if self.command:containsParameter("key") then
        local keys = self.command.parameters["key"]
        for i=1, #keys, 1 do
            local key = keys[i]
            adjust.removeSessionCallbackParameter(key)
        end
    end
end

function CommandExecutor:removeSessionPartnerParameter()
    if self.command:containsParameter("key") then
        local keys = self.command.parameters["key"]
        for i=1, #keys, 1 do
            local key = keys[i]
            adjust.removeSessionPartnerParameter(key)
        end
    end
end

function CommandExecutor:resetSessionCallbackParameters()
    adjust.resetSessionCallbackParameters()
end

function CommandExecutor:resetSessionPartnerParameters()
    adjust.resetSessionPartnerParameters()
end

function CommandExecutor:setPushToken()
    local pushToken = self.command:getFirstParameterValue("pushToken")
    adjust.setPushToken(pushToken)
end

function CommandExecutor:openDeeplink()
    local deeplink = self.command:getFirstParameterValue("deeplink")
    adjust.appWillOpenUrl(deeplink)
end

function CommandExecutor:sendReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function CommandExecutor:gdprForgetMe()
    adjust.gdprForgetMe()
end

function CommandExecutor:disableThirdPartySharing()
    adjust.disableThirdPartySharing()
end

function CommandExecutor:trackAdRevenue()
    local source = self.command:getFirstParameterValue("adRevenueSource")
    local payload = self.command:getFirstParameterValue("adRevenueJsonString")
    adjust.trackAdRevenue(source, payload)
end

function CommandExecutor:trackSubscription()
    if platformInfo == "ios" then
        local price = self.command:getFirstParameterValue("revenue")
        local currency = self.command:getFirstParameterValue("currency")
        local transactionId = self.command:getFirstParameterValue("transactionId")
        local receipt = self.command:getFirstParameterValue("receipt")
        local transactionDate = self.command:getFirstParameterValue("transactionDate")
        local salesRegion = self.command:getFirstParameterValue("salesRegion")
        
        local subscription = {}
        subscription.price = price
        subscription.currency = currency
        subscription.transactionId = transactionId
        subscription.receipt = receipt
        subscription.transactionDate = transactionDate
        subscription.salesRegion = salesRegion

        if self.command:containsParameter("callbackParams") then
            local callbackParams = self.command.parameters["callbackParams"]
            subscription.callbackParameters = {}
            local k = 1
            for i=1, #callbackParams, 2 do
                subscription.callbackParameters[k] = { 
                    key = callbackParams[i], 
                    value = callbackParams[i + 1] 
                }
                k = k + 1
            end
        end
        
        if self.command:containsParameter("partnerParams") then
            local partnerParams = self.command.parameters["partnerParams"]
            subscription.partnerParameters = {}
            local k = 1
            for i=1, #partnerParams, 2 do
                subscription.partnerParameters[k] = { 
                    key = partnerParams[i], 
                    value = partnerParams[i + 1] 
                }
                k = k + 1
            end
        end

        adjust.trackAppStoreSubscription(subscription)
    else
        local price = self.command:getFirstParameterValue("revenue")
        local currency = self.command:getFirstParameterValue("currency")
        local sku = self.command:getFirstParameterValue("productId")
        local signature = self.command:getFirstParameterValue("receipt")
        local purchaseToken = self.command:getFirstParameterValue("purchaseToken")
        local orderId = self.command:getFirstParameterValue("transactionId")
        local purchaseTime = self.command:getFirstParameterValue("transactionDate")

        local subscription = {}
        subscription.price = price
        subscription.currency = currency
        subscription.sku = sku
        subscription.signature = signature
        subscription.purchaseToken = purchaseToken
        subscription.orderId = orderId
        subscription.purchaseTime = purchaseTime

        if self.command:containsParameter("callbackParams") then
            local callbackParams = self.command.parameters["callbackParams"]
            subscription.callbackParameters = {}
            local k = 1
            for i=1, #callbackParams, 2 do
                subscription.callbackParameters[k] = { 
                    key = callbackParams[i], 
                    value = callbackParams[i + 1] 
                }
                k = k + 1
            end
        end
        
        if self.command:containsParameter("partnerParams") then
            local partnerParams = self.command.parameters["partnerParams"]
            subscription.partnerParameters = {}
            local k = 1
            for i=1, #partnerParams, 2 do
                subscription.partnerParameters[k] = { 
                    key = partnerParams[i], 
                    value = partnerParams[i + 1] 
                }
                k = k + 1
            end
        end

        adjust.trackPlayStoreSubscription(subscription)
    end
end
   
function CommandExecutor:clearSavedConfigsAndEvents()
    for k in pairs(self.savedConfigs) do
        self.savedConfigs[k] = nil
    end
    for k in pairs(self.savedEvents) do
        self.savedEvents[k] = nil
    end
end

module.CommandExecutor = CommandExecutor
return module