local json = require "json"

local module = {}

Command = {className = "", methodName = "", parameters}

function Command:new (o, className, methodName, parametersJson)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.className = className
    self.methodName = methodName

    -- parse json parameters
    self.parameters = json.decode(parametersJson)
    
    return o
end

function Command:containsParameter(paramKey)
    if self.parameters == nil then
        return false
    end
    
    return self.parameters[paramKey] ~= nil
end

function Command:getFirstParameterValue(paramKey)
    if Command:containsParameter(paramKey) == false then
        return nil
    end
    
    local parameterValues = self.parameters[paramKey];
    if parameterValues == nil or tablelength(parameterValues) == 0 then
       return nil 
    end
    
    return parameterValues[0]
end

function Command:printCommand()
    print("[Command]: " .. self.className .. "." .. self.methodName .. " -> " .. json.encode(self.parameters) .. ", len: " .. tostring(tablelength(self.parameters)))
end
    
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

module.Command = Command
return module