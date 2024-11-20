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
    purchaseVerificationUrl = "",
    extraPath = "",
    basePath = "",
    gdprPath = "",
    subscriptionPath = "",
    purchaseVerificationPath = "",
    extraPath = "",
    savedEvents = {},
    savedConfigs = {},
    command = nil
}

function CommandExecutor:new (o, overwriteUrl)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.baseUrl = overwriteUrl
    self.gdprUrl = overwriteUrl
    self.subscriptionUrl = overwriteUrl
    self.purchaseVerificationUrl = overwriteUrl
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
    elseif method == "addGlobalCallbackParameter" then self:addGlobalCallbackParameter()
    elseif method == "addGlobalPartnerParameter" then self:addGlobalPartnerParameter()
    elseif method == "removeGlobalCallbackParameter" then self:removeGlobalCallbackParameter()
    elseif method == "removeGlobalPartnerParameter" then self:removeGlobalPartnerParameter()
    elseif method == "removeGlobalCallbackParameters" then self:removeGlobalCallbackParameters()
    elseif method == "removeGlobalPartnerParameters" then self:removeGlobalPartnerParameters()
    elseif method == "setPushToken" then self:setPushToken()
    elseif method == "openDeeplink" then self:openDeeplink()
    elseif method == "sendReferrer" then self:sendReferrer()
    elseif method == "gdprForgetMe" then self:gdprForgetMe()
    elseif method == "trackSubscription" then self:trackSubscription()
    elseif method == "trackAdRevenue" then self:trackAdRevenue()
    elseif method == "thirdPartySharing" then self:thirdPartySharing()
    elseif method == "measurementConsent" then self:trackMeasurementConsent()
    elseif method == "verifyPurchase" then self:verifyPurchase()
    elseif method == "verifyTrack" then self:verifyTrack()
    elseif method == "processDeeplink" then self:processDeeplink()
    elseif method == "attributionGetter" then self:attributionGetter()
    elseif method == "getLastDeeplink" then self:getLastDeeplink()

    else print("CommandExecutor: unknown method name: " .. method)
    end
end

function CommandExecutor:testOptions()
    local testOptions = {}
    testOptions.baseUrl = self.baseUrl
    testOptions.gdprUrl = self.gdprUrl
    testOptions.subscriptionUrl = self.subscriptionUrl
    testOptions.purchaseVerificationUrl = self.purchaseVerificationUrl
    testOptions.urlOverwrite = self.baseUrl

    if self.command:containsParameter("basePath") then
        self.basePath = self.command:getFirstParameterValue("basePath")
        self.gdprPath = self.command:getFirstParameterValue("basePath")
        self.subscriptionPath = self.command:getFirstParameterValue("basePath")
        self.purchaseVerificationPath = self.command:getFirstParameterValue("basePath")
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

    if self.command:containsParameter("doNotIgnoreSystemLifecycleBootstrap") then
        local doNotIgnoreSystemLifecycleBootstrap = self.command:getFirstParameterValue("doNotIgnoreSystemLifecycleBootstrap")
        if doNotIgnoreSystemLifecycleBootstrap == "true" then
            print("testoption ignoreSystemLifecycleBootstrap = false")
            testOptions.ignoreSystemLifecycleBootstrap = false
        end
    end

    if self.command:containsParameter("adServicesFrameworkEnabled") then
        local adServicesFrameworkEnabled = self.command:getFirstParameterValue("adServicesFrameworkEnabled")
        if adServicesFrameworkEnabled == "true" then
            testOptions.adServicesFrameworkEnabled = true
        else
            testOptions.adServicesFrameworkEnabled = false
        end
    end

    if self.command:containsParameter("attStatus") then
        testOptions.attStatus = tonumber(self.command:getFirstParameterValue("attStatus"))
    end

    if self.command:containsParameter("idfa") then
        testOptions.idfa = self.command:getFirstParameterValue("idfa")
    end

    if self.command:containsParameter("noBackoffWait") then
        local noBackoffWait = self.command:getFirstParameterValue("noBackoffWait")
        if noBackoffWait == "true" then
            testOptions.noBackoffWait = true
        else
            testOptions.noBackoffWait = false
        end
    end

    local useTestConnectionOptions = false;
    if self.command:containsParameter("teardown") then
        print("tearDown called")
        local teardownOptions = self.command.parameters["teardown"]
        for k in pairs(teardownOptions) do
            local option = teardownOptions[k]
            if option == "resetSdk" then
                print("resetSDK called")
                testOptions.teardown = true
                testOptions.basePath = self.basePath
                testOptions.gdprPath = self.gdprPath
                testOptions.subscriptionPath = self.subscriptionPath
                testOptions.purchaseVerificationPath = self.purchaseVerificationPath
                testOptions.extraPath = self.extraPath
                testOptions.useTestConnectionOptions = true
                testOptions.tryInstallReferrer = false
                useTestConnectionOptions = true
            elseif option == "deleteState" then
                print("deleteState called")
                testOptions.setContext = true
                testOptions.deleteState = true
            elseif option == "resetTest" then

                print("resetTest called")
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
                testOptions.purchaseVerificationPath = nil
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
    if useTestConnectionOptions then
        if platformInfo == "android" then
            testLib.setTestConnectionOptions();
        end
    end
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

    if self.command:containsParameter("delayStart") then
        adjustConfig.delayStart = tonumber(self.command:getFirstParameterValue("delayStart"))
    end

    if self.command:containsParameter("deviceKnown") then
        adjustConfig.isDeviceKnown = (self.command:getFirstParameterValue("deviceKnown") == "true")
    end

    if self.command:containsParameter("isCostDataInAttributionEnabled") then
        adjustConfig.needsCost = (self.command:getFirstParameterValue("isCostDataInAttributionEnabled") == "true")
    end

    if self.command:containsParameter("eventBufferingEnabled") then
        adjustConfig.eventBufferingEnabled = (self.command:getFirstParameterValue("eventBufferingEnabled") == "true")
    end

    if self.command:containsParameter("allowAdServicesInfoReading") then
        adjustConfig.allowAdServicesInfoReading = (self.command:getFirstParameterValue("allowAdServicesInfoReading") == "true")
    end

    if self.command:containsParameter("allowiAdInfoReading") then
        adjustConfig.allowiAdInfoReading = (self.command:getFirstParameterValue("allowiAdInfoReading") == "true")
    end

    if self.command:containsParameter("allowSkAdNetworkHandling") then
        adjustConfig.allowSkAdNetworkHandling = (self.command:getFirstParameterValue("allowSkAdNetworkHandling") == "true")
    end

    if self.command:containsParameter("allowIdfaReading") then
        adjustConfig.allowIdfaReading = (self.command:getFirstParameterValue("allowIdfaReading") == "true")
    end

    if self.command:containsParameter("attConsentWaitingSeconds") then
        adjustConfig.attConsentWaitingSeconds = tonumber(self.command:getFirstParameterValue("attConsentWaitingSeconds"))
    end

    if self.command:containsParameter("sendInBackground") then
        adjustConfig.sendInBackground = (self.command:getFirstParameterValue("sendInBackground") == "true")
    end

    if self.command:containsParameter("userAgent") then
        adjustConfig.userAgent = self.command:getFirstParameterValue("userAgent")
    end

    if self.command:containsParameter("coppaCompliant") then
        adjustConfig.coppaCompliant = (self.command:getFirstParameterValue("coppaCompliant") == "true")
    end


    if self.command:containsParameter("playStoreKids") then
        adjustConfig.playStoreKids = (self.command:getFirstParameterValue("playStoreKids") == "true")
    end


    --[[if (command.containsParameter("coppaCompliant")) {
    --            String coppaCompliantS = command.getFirstParameterValue("coppaCompliant");
    --            boolean coppaCompliant = "true".equals(coppaCompliantS);
    --            if (coppaCompliant) {
    --                adjustConfig.enableCoppaCompliance();
    --            }
    --        }
    --
    --        if (command.containsParameter("playStoreKids")) {
    --            String playStoreKidsS = command.getFirstParameterValue("playStoreKids");
    --            boolean playStoreKids = "true".equals(playStoreKidsS);
    --            if (playStoreKids) {
    --                adjustConfig.enablePlayStoreKidsCompliance();
    --            }
    --        }]]

    -- first, clear all callback
    adjust.setDeferredDeeplinkListener(deferredDeeplinkListenerEmpty)
    adjust.setAttributionListener(attributionListenerEmpty)
    adjust.setSessionTrackingSuccessListener(sessionTrackingSuccessListenerEmpty)
    adjust.setSessionTrackingFailureListener(sessionTrackingFailureListenerEmpty)
    adjust.setEventTrackingSuccessListener(eventTrackingSuccessListenerEmpty)
    adjust.setEventTrackingFailureListener(eventTrackingFailureListenerEmpty)
    adjust.setUpdateSkanListener(skanUpdateCallbackListenerEmpty)

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

    if self.command:containsParameter("skanCallback") then
        localBasePath = self.basePath
        print("[CommandExecutor]: Setting skan callback... local-base-path=" .. localBasePath)
        adjust.setUpdateSkanListener(skanUpdateCallbackListener)
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
function skanUpdateCallbackListenerEmpty(event)
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
    testLib.addInfoToSend("tracker_token", json_attribution.trackerToken)
    testLib.addInfoToSend("tracker_name", json_attribution.trackerName)
    testLib.addInfoToSend("network", json_attribution.network)
    testLib.addInfoToSend("campaign", json_attribution.campaign)
    testLib.addInfoToSend("adgroup", json_attribution.adgroup)
    testLib.addInfoToSend("creative", json_attribution.creative)
    testLib.addInfoToSend("click_label", json_attribution.clickLabel)
    testLib.addInfoToSend("cost_type", json_attribution.costType)
    testLib.addInfoToSend("cost_amount", json_attribution.costAmount)
    testLib.addInfoToSend("cost_currency", json_attribution.costCurrency)
    if json_attribution.fbInstallReferrer ~= nil and json_attribution.fbInstallReferrer ~= "" then
        testLib.addInfoToSend("fb_install_referrer", json_attribution.fbInstallReferrer)
    end
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

function skanUpdateCallbackListener(event)
    print("skanUpdateCallbackListener triggered")
    local json_skan_update = json.decode(event.message)
    testLib.addInfoToSend('conversion_value', json_skan_update.conversionValue);
    testLib.addInfoToSend('coarse_value', json_skan_update.coarseValue);
    testLib.addInfoToSend('lock_window', json_skan_update.lockWindow);
    testLib.sendInfoToServer(localBasePath);
    print(json_skan_update)
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
    adjust.initSdk(adjustConfig)
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
        adjustEvent.orderId = self.command:getFirstParameterValue("orderId")
    end

    if self.command:containsParameter("deduplicationId") then
        adjustEvent.deduplicationId = self.command:getFirstParameterValue("deduplicationId")
    end

    if self.command:containsParameter("productId") then
        adjustEvent.productId = self.command:getFirstParameterValue("productId")
    end

    if self.command:containsParameter("purchaseToken") then
        adjustEvent.purchaseToken = self.command:getFirstParameterValue("purchaseToken")
    end

    if self.command:containsParameter("transactionId") then
        adjustEvent.transactionId = self.command:getFirstParameterValue("transactionId")
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
    if enabled then
        adjust.enable()
    else
        adjust.disable()
    end
end

function CommandExecutor:setReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function CommandExecutor:setOfflineMode()
    local enabled = (self.command:getFirstParameterValue("enabled") == "true")
    if enabled then
        adjust.switchToOfflineMode()
    else
        adjust.switchBackToOnlineMode()
    end
end

function CommandExecutor:sendFirstPackages()
    adjust.sendFirstPackages()
end

function CommandExecutor:addGlobalCallbackParameter()
    if self.command:containsParameter("KeyValue") then
        local keyValuePairs = self.command.parameters["KeyValue"]
        for i=1, #keyValuePairs, 2 do
            local key = keyValuePairs[i]
            local value = keyValuePairs[i + 1]
            adjust.addGlobalCallbackParameter(key, value)
        end
    end
end

function CommandExecutor:addGlobalPartnerParameter()
    if self.command:containsParameter("KeyValue") then
        local keyValuePairs = self.command.parameters["KeyValue"]
        for i=1, #keyValuePairs, 2 do
            local key = keyValuePairs[i]
            local value = keyValuePairs[i + 1]
            adjust.addGlobalPartnerParameter(key, value)
        end
    end
end

function CommandExecutor:removeGlobalCallbackParameter()
    if self.command:containsParameter("key") then
        local keys = self.command.parameters["key"]
        for i=1, #keys, 1 do
            local key = keys[i]
            adjust.removeGlobalCallbackParameter(key)
        end
    end
end

function CommandExecutor:removeGlobalPartnerParameter()
    if self.command:containsParameter("key") then
        local keys = self.command.parameters["key"]
        for i=1, #keys, 1 do
            local key = keys[i]
            adjust.removeGlobalPartnerParameter(key)
        end
    end
end

function CommandExecutor:removeGlobalCallbackParameters()
    adjust.removeGlobalCallbackParameters()
end

function CommandExecutor:removeGlobalPartnerParameters()
    adjust.removeGlobalPartnerParameters()
end

function CommandExecutor:setPushToken()
    local pushToken = self.command:getFirstParameterValue("pushToken")
    adjust.setPushToken(pushToken)
end

function CommandExecutor:openDeeplink()
    local deeplink = self.command:getFirstParameterValue("deeplink")
    adjust.processDeeplink(deeplink)
end

function CommandExecutor:sendReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function CommandExecutor:gdprForgetMe()
    adjust.gdprForgetMe()
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

function CommandExecutor:thirdPartySharing()
    local enabled = nil;
    if self.command:containsParameter("isEnabled") then
        enabled = (self.command:getFirstParameterValue("isEnabled") == "true");
    end
    local thirdPartySharing = {}
    thirdPartySharing.enabled = enabled

    if self.command:containsParameter("granularOptions") then
        local granularOptions = self.command.parameters["granularOptions"]
        thirdPartySharing.granularOptions = {}
        local k = 0
        for i=1, #granularOptions, 3 do
            thirdPartySharing.granularOptions[k] = {
                partnerName = granularOptions[i],
                key = granularOptions[i + 1],
                value = granularOptions[i + 2]
            }
            k = k + 1
        end
    end

    if self.command:containsParameter("partnerSharingSettings") then
        local partnerSharingSettings = self.command.parameters["partnerSharingSettings"]
        thirdPartySharing.partnerSharingSettings = {}
        local k = 0
        for i=1, #partnerSharingSettings, 3 do
            thirdPartySharing.partnerSharingSettings[k] = {
                partnerName = partnerSharingSettings[i],
                key = partnerSharingSettings[i + 1],
                value = partnerSharingSettings[i + 2]
            }
            k = k + 1
        end
    end

    adjust.trackThirdPartySharing(thirdPartySharing)
end

function CommandExecutor:trackMeasurementConsent()
    local measurementConsent = (self.command:getFirstParameterValue("isEnabled") == "true")
    adjust.trackMeasurementConsent(measurementConsent)
end

function CommandExecutor:verifyPurchase()
    if platformInfo == "ios" then
        local receipt = self.command:getFirstParameterValue("receipt")
        local transactionId = self.command:getFirstParameterValue("transactionId")
        local productId = self.command:getFirstParameterValue("productId")
        local localBasePath = self.basePath
        adjust.verifyAppStorePurchase(
                receipt,
                transactionId,
                productId,
                function(result)
                    local json_verificationResult = json.decode(result.message)
                    if json_verificationResult.verificationStatus ~= nil then
                        testLib.addInfoToSend("verification_status", json_verificationResult.verificationStatus);
                    end
                    if json_verificationResult.code ~= nil then
                        testLib.addInfoToSend("code", tostring(json_verificationResult.code));
                    end
                    if json_verificationResult.message ~= nil then
                        testLib.addInfoToSend("message", json_verificationResult.message);
                    end
                    testLib.sendInfoToServer(localBasePath)
                end
        )
    else
        local sku = self.command:getFirstParameterValue("productId")
        local purchaseToken = self.command:getFirstParameterValue("purchaseToken")
        local localBasePath = self.basePath
        adjust.verifyPlayStorePurchase(
                sku,
                purchaseToken,
                function(result)
                    local json_verificationResult = json.decode(result.message)
                    testLib.addInfoToSend("verification_status", json_verificationResult.verificationStatus);
                    testLib.addInfoToSend("code", tostring(json_verificationResult.code));
                    testLib.addInfoToSend("message", json_verificationResult.message);
                    testLib.sendInfoToServer(localBasePath)
                end
        )

    end
end

function CommandExecutor:verifyTrack()

    self:event()
    local eventNumber = 0
    local localBasePath = self.basePath
    if platformInfo == "ios" then
        if self.command:containsParameter("eventName") then
            local eventName = self.command:getFirstParameterValue("eventName")
            local eventNumberStr = string.sub(eventName, string.len(eventName) - 1)
            eventNumber = tonumber(eventNumberStr)
        end

        local myAdjustEvent = self.savedEvents[eventNumber]
        myAdjustEvent.listener = function(result)
            print("result got")
            local json_verificationResult = json.decode(result.message)
            testLib.addInfoToSend("verification_status", json_verificationResult.verificationStatus);
            testLib.addInfoToSend("code", tostring(json_verificationResult.code));
            testLib.addInfoToSend("message", json_verificationResult.message);
            testLib.sendInfoToServer(localBasePath)
        end
        adjust.verifyAndTrackAppStorePurchase(myAdjustEvent)
        self.savedEvents[eventNumber] = nil

    else
        if self.command:containsParameter("eventName") then
            local eventName = self.command:getFirstParameterValue("eventName")
            local eventNumberStr = string.sub(eventName, string.len(eventName) - 1)
            eventNumber = tonumber(eventNumberStr)
        end

        local myAdjustEvent = self.savedEvents[eventNumber]
        myAdjustEvent.listener = function(result)
            print("result got")
            local json_verificationResult = json.decode(result.message)
            testLib.addInfoToSend("verification_status", json_verificationResult.verificationStatus);
            testLib.addInfoToSend("code", tostring(json_verificationResult.code));
            testLib.addInfoToSend("message", json_verificationResult.message);
            testLib.sendInfoToServer(localBasePath)
        end
        adjust.verifyAndTrackPlayStorePurchase(myAdjustEvent)
        self.savedEvents[eventNumber] = nil
    end
end

function CommandExecutor:getLastDeeplink()
    local localBasePath = self.basePath
    adjust.getLastDeeplink(function(lastDeeplink)
        if lastDeeplink.message ~=nil and lastDeeplink.message ~= "" then
            testLib.addInfoToSend("last_deeplink", tostring(lastDeeplink.message));
        end
        testLib.sendInfoToServer(localBasePath)
    end)
end

function CommandExecutor:processDeeplink()
    local deeplink = self.command:getFirstParameterValue("deeplink")
    local localBasePath = self.basePath

    adjust.processAndResolveDeeplink(deeplink,function(resolvedLink)
        testLib.addInfoToSend("resolved_link", tostring(resolvedLink.message));
        testLib.sendInfoToServer(localBasePath)
    end)
end

function CommandExecutor:attributionGetter()
    adjust.getAttribution(function(event)
        local json_attribution = json.decode(event.message)
        local map = {}
        if json_attribution.trackerToken ~= nil then
            testLib.addInfoToSend("tracker_token",json_attribution.trackerToken)
        end
        if json_attribution.trackerName ~= nil then
            testLib.addInfoToSend("tracker_name",json_attribution.trackerName)
        end
        if json_attribution.network ~= nil then
            testLib.addInfoToSend("network",  json_attribution.network)
        end
        if json_attribution.campaign ~= nil then
            testLib.addInfoToSend("campaign",  json_attribution.campaign)
        end
        if json_attribution.adgroup ~= nil then
            testLib.addInfoToSend("adgroup",  json_attribution.adgroup)
        end
        if json_attribution.creative ~= nil then
            testLib.addInfoToSend("creative",  json_attribution.creative)
        end
        if json_attribution.clickLabel ~= nil then
            testLib.addInfoToSend("click_label",  json_attribution.clickLabel)
        end
        if json_attribution.costType ~= nil then
            testLib.addInfoToSend("cost_type",  json_attribution.costType)
        end
        if json_attribution.costAmount ~= nil then
            testLib.addInfoToSend("cost_amount",  tostring(json_attribution.costAmount))
        end
        if json_attribution.costCurrency ~= nil then
            testLib.addInfoToSend("cost_currency",  json_attribution.costCurrency)
        end
        if json_attribution.fbInstallReferrer ~= nil and json_attribution.fbInstallReferrer ~="" then
            testLib.addInfoToSend("fb_install_referrer", json_attribution.fbInstallReferrer)
        end

        --for key,value in next,map,nil do
        --    if key ~= nil and value ~= nil then
        --        testLib.addInfoToSend(key,value)
        --    end
        --end

        testLib.sendInfoToServer(self.basePath);
    end);

end

function CommandExecutor:trackAdRevenue()
    local source = nil;
    if self.command:containsParameter("adRevenueSource") then
        source = self.command:getFirstParameterValue("adRevenueSource");
    end

    local adRevenue = {}
    adRevenue.source = source

    if self.command:containsParameter("revenue") then
        local revenueParams = self.command.parameters["revenue"]
        adRevenue.currency = revenueParams[1]
        adRevenue.revenue = tonumber(revenueParams[2])
    end

    if self.command:containsParameter("adImpressionsCount") then
        adRevenue.adImpressionsCount = self.command:getFirstParameterValue("adImpressionsCount");
    end

    if self.command:containsParameter("adRevenueUnit") then
        adRevenue.adRevenueUnit = self.command:getFirstParameterValue("adRevenueUnit");
    end

    if self.command:containsParameter("adRevenueNetwork") then
        adRevenue.adRevenueNetwork = self.command:getFirstParameterValue("adRevenueNetwork");
    end

    if self.command:containsParameter("adRevenuePlacement") then
        adRevenue.adRevenuePlacement = self.command:getFirstParameterValue("adRevenuePlacement");
    end

    if self.command:containsParameter("callbackParams") then
        local callbackParams = self.command.parameters["callbackParams"]
        adRevenue.callbackParameters = {}
        local k = 1
        for i=1, #callbackParams, 2 do
            adRevenue.callbackParameters[k] = {
                key = callbackParams[i],
                value = callbackParams[i + 1]
            }
            k = k + 1
        end
    end

    if self.command:containsParameter("partnerParams") then
        local partnerParams = self.command.parameters["partnerParams"]
        adRevenue.partnerParameters = {}
        local k = 1
        for i=1, #partnerParams, 2 do
            adRevenue.partnerParameters[k] = {
                key = partnerParams[i],
                value = partnerParams[i + 1]
            }
            k = k + 1
        end
    end

    adjust.trackAdRevenue(adRevenue)
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