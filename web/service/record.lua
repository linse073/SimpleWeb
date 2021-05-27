local skynet_m = require "skynet_m"

local assert = assert
local string = string
local date = os.date
local floor = math.floor
local open = io.open
local ipairs = ipairs

local recordpath = skynet_m.getenv("recordpath")

local f

local CMD = {}

function CMD.save(msg)
    if f then
        for k, v in ipairs(msg) do
            f:write(v .. "\n")
            f:flush()
            print(v)
        end
	end
end

local function change_record()
    if f then
        f:close()
    end
    local name = recordpath .. "/" .. date("%m_%d_%Y.log", floor(skynet_m.time()))
    f = assert(open(name, "a"), string.format("Can't open log file %s.", name))
    skynet_m.timeout(8640000, change_record) -- one day
end

skynet_m.start(function()
    change_record()

    skynet_m.dispatch_lua_queue(CMD)
end)