local skynet_m = require "skynet_m"
local sharedata = require "skynet.sharedata"

local ipairs = ipairs

skynet_m.start(function()
    -- share data
    local quality_data = require("quality_data")
    sharedata.new("quality_data", quality_data)

    local quality_map = {}
    for k, v in ipairs(quality_data) do
        for k1, v1 in ipairs(v) do
            quality_map[v1:lower()] = k
        end
    end
    sharedata.new("quality_map", quality_map)
end)
