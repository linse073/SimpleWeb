local skynet_m = require "skynet_m"

local assert = assert
local string = string
local date = os.date
local floor = math.floor
local open = io.open

local logpath = skynet_m.getenv("logpath")

local f

local function print_file(msg)
	if f then
		f:write(msg .. "\n")
		f:flush()
	end
	print(msg)
end

skynet_m.register_protocol {
	name = "text",
	id = skynet_m.PTYPE_TEXT,
	unpack = skynet_m.tostring,
	dispatch = function(_, address, msg)
		print_file(string.format("[%s][%s]: %s", skynet_m.address(address), date("%m/%d/%Y %X", floor(skynet_m.time())), msg))
    end,
}

local function change_log()
    if f then
        f:close()
    end
    local name = logpath .. "/" .. date("%m_%d_%Y.log", floor(skynet_m.time()))
    f = assert(open(name, "a"), string.format("Can't open log file %s.", name))
    skynet_m.timeout(8640000, change_log) -- one day
end

skynet_m.start(function()
    change_log()
end)