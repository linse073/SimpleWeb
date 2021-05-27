local skynet = require "skynet"
local datacenter = require "skynet.datacenter"
local queue = require "skynet.queue"

local assert = assert
local tonumber = tonumber
-- local print = print
local os = os
local string = string

local mail = skynet.getenv("mail")

local skynet_m = {}
setmetatable(skynet_m, {__index=skynet})

function skynet_m.dispatch_lua_f(func)
    return skynet.dispatch("lua", function(session, _, ...)
        if session == 0 then
            func(...)
        else
            skynet.retpack(func(...))
        end
	end)
end

function skynet_m.send_lua(addr, ...)
    return skynet.send(addr, "lua", ...)
end

function skynet_m.call_lua(addr, ...)
    return skynet.call(addr, "lua", ...)
end

function skynet_m.redirect_lua(addr, source, ...)
    return skynet.redirect(addr, source, "lua", ...)
end

function skynet_m.dispatch_lua(CMD)
    return skynet.dispatch("lua", function(session, _, command, ...)
		local f = assert(CMD[command], string.format("Service %s without command %s.", SERVICE_NAME, command))
        if session == 0 then
            f(...)
        else
            skynet.retpack(f(...))
        end
	end)
end

function skynet_m.dispatch_lua_queue(CMD)
    local lock = queue()
    return skynet.dispatch("lua", function(session, _, command, ...)
		local f = assert(CMD[command], string.format("Service %s without command %s.", SERVICE_NAME, command))
        if session == 0 then
            lock(f, ...)
        else
            skynet.retpack(lock(f, ...))
        end
	end)
end

function skynet_m.getenv_num(key)
    return tonumber(skynet.getenv(key))
end

function skynet_m.log(...)
    skynet.error(...)
    -- print(...)
end

function skynet_m.warn(err)
    if mail and not datacenter.get("haswarn") then
        os.execute(string.format("shell/warn.sh %s '%s'", mail, err))
        datacenter.set("haswarn", true)
    end
end

return skynet_m