local adjust = require "plugin.adjust"
local json = require "json"

local module = {}

AdjustCommandExecutor = {
    baseUrl = "",
    gdprUrl = "",
    basePath = "", 
    gdprPath = "", 
    savedEvents = {}, 
    savedConfigs = {},
    command = nil
}

function AdjustCommandExecutor:new (o, baseUrl, gdprUrl)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.baseUrl = baseUrl
    self.gdprUrl = gdprUrl
    return o
end

function AdjustCommandExecutor:executeCommand(command)
    self.command = command;
    local method = command.methodName;
    
    if     method == "testOptions" then self:testOptions()
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
        
    else print("AdjustCommandExecutor: unknown method name: " .. method)
    end
end

function AdjustCommandExecutor:testOptions()
    local testOptions = {}
    testOptions.baseUrl = self.baseUrl
    testOptions.gdprUrl = self.gdprUrl
    
    if self.command:containsParameter("basePath") then
        self.basePath = self.command:getFirstParameterValue("basePath")
        self.gdprPath = self.command:getFirstParameterValue("gdprPath")
    end
    
    if self.command:containsParameter("timerInterval") then
        local timerInterval = tonumber(self.command:getFirstParameterValue("timerInterval"))
        testOptions.timerIntervalInMilliseconds = timerInterval;
    end
    
    if self.command:containsParameter("timerStart") then
        local timerStart = tonumber(self.command:getFirstParameterValue("timerStart"))
        testOptions.timerStartInMilliseconds = timerStart;
    end
    
    if self.command:containsParameter("sessionInterval") then
        local sessionInterval = tonumber(self.command:getFirstParameterValue("sessionInterval"))
        testOptions.sessionIntervalInMilliseconds = sessionInterval;
    end
    
    if self.command:containsParameter("subsessionInterval") then
        local subsessionInterval = tonumber(self.command:getFirstParameterValue("subsessionInterval"))
        testOptions.subsessionIntervalInMilliseconds = subsessionInterval;
    end
    
    if self.command:containsParameter("tryInstallReferrer") then
        local tryInstallReferrer = self.command:getFirstParameterValue("basePath")
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
    
    if self.command:containsParameter("teardown") then
        local teardownOptions = self.command.parameters["teardown"]
        for k in pairs(teardownOptions) do
            local option = teardownOptions[k]
            if     option == "resetSdk" then
                testOptions.teardown = true;
                testOptions.basePath = self.basePath;
                testOptions.gdprPath = self.gdprPath;
                testOptions.useTestConnectionOptions = true;
                testOptions.tryInstallReferrer = false;
            elseif option == "deleteState" then 
                testOptions.setContext = true;
            elseif option == "resetTest" then 
                self:clearSavedConfigsAndEvents()
                testOptions.timerIntervalInMilliseconds = -1;
                testOptions.timerStartInMilliseconds = -1;
                testOptions.sessionIntervalInMilliseconds = -1;
                testOptions.subsessionIntervalInMilliseconds = -1;
            elseif option == "sdk" then 
                testOptions.teardown = true;
                testOptions.basePath = nil;
                testOptions.gdprPath = nil;
                testOptions.useTestConnectionOptions = false;
            elseif option == "test" then 
                self:clearSavedConfigsAndEvents()
                testOptions.timerIntervalInMilliseconds = -1;
                testOptions.timerStartInMilliseconds = -1;
                testOptions.sessionIntervalInMilliseconds = -1;
                testOptions.subsessionIntervalInMilliseconds = -1;
            end
        end
    end
    
    adjust.setTestOptions(testOptions)
end

function AdjustCommandExecutor:config()
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
        -- not needed ...
    end
    
    if self.command:containsParameter("defaultTracker") then
        adjustConfig.defaultTracker = self.command:getFirstParameterValue("defaultTracker")
    end
    
    if self.command:containsParameter("appSecret") then
        local appSecretArray = self.command.parameters["appSecret"]
        adjustConfig.secretId = tonumber(appSecretArray[0]);
        adjustConfig.info1 = tonumber(appSecretArray[1]);
        adjustConfig.info2 = tonumber(appSecretArray[2]);
        adjustConfig.info3 = tonumber(appSecretArray[3]);
        adjustConfig.info4 = tonumber(appSecretArray[4]);
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
    
    if self.command:containsParameter("sendInBackground") then
        adjustConfig.sendInBackground = (self.command:getFirstParameterValue("sendInBackground") == "true")
    end
    
    if self.command:containsParameter("userAgent") then
        adjustConfig.userAgent = self.command:getFirstParameterValue("userAgent")
    end
    
    -- TODO: callbacks
    
    
end

function AdjustCommandExecutor:start()
    self:config()
    
    local configNumber = 0
    if self.command:containsParameter("configName") then
        local configName = self.command:getFirstParameterValue("configName")
        local configNumberStr = string.sub(configName, string.len(configName) - 1)
        configNumber = tonumber(configNumberStr)
    end
   
    local adjustConfig = self.savedConfigs[configNumber]
    print(" ----> sending adjust config to adjust.create: " .. json.encode(adjustConfig))
    adjust.create(adjustConfig)
    
    self.savedConfigs[configNumber] = nil
end

function AdjustCommandExecutor:event()
    
end

function AdjustCommandExecutor:trackEvent()
    
end

function AdjustCommandExecutor:resume()
    -- missing from Adjust API, has to be added
    
end

function AdjustCommandExecutor:pause()
    -- missing from Adjust API, has to be added
    
end

function AdjustCommandExecutor:setEnabled()
    local enabled = (self.command:getFirstParameterValue("enabled") == "true")
    adjust.setEnabled(enabled);
end

function AdjustCommandExecutor:setReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function AdjustCommandExecutor:setOfflineMode()
    local enabled = (self.command:getFirstParameterValue("enabled") == "true")
    adjust.setOfflineMode(enabled);
end

function AdjustCommandExecutor:sendFirstPackages()
    adjust.sendFirstPackage()
end

function AdjustCommandExecutor:addSessionCallbackParameter()
    
end

function AdjustCommandExecutor:addSessionPartnerParameter()
    
end

function AdjustCommandExecutor:removeSessionCallbackParameter()
    
end

function AdjustCommandExecutor:removeSessionPartnerParameter()
    
end

function AdjustCommandExecutor:resetSessionCallbackParameters()
    adjust.resetSessionCallbackParameters()
end

function AdjustCommandExecutor:resetSessionPartnerParameters()
    adjust.resetSessionPartnerParameters()
end

function AdjustCommandExecutor:setPushToken()
    local pushToken = self.command:getFirstParameterValue("pushToken")
    adjust.setPushToken(pushToken)
end

function AdjustCommandExecutor:openDeeplink()
    local deeplink = self.command:getFirstParameterValue("deeplink")
    adjust.appWillOpenUrl(deeplink)
    
end

function AdjustCommandExecutor:sendReferrer()
    local referrer = self.command:getFirstParameterValue("referrer")
    adjust.setReferrer(referrer)
end

function AdjustCommandExecutor:gdprForgetMe()
    adjust.gdprForgetMe()
end
   
function AdjustCommandExecutor:clearSavedConfigsAndEvents()
    for k in pairs(self.savedConfigs) do
        self.savedConfigs[k] = nil
    end
    for k in pairs(self.savedEvents) do
        self.savedEvents[k] = nil
    end
end

module.AdjustCommandExecutor = AdjustCommandExecutor;
return module;