local skynet_m = require "skynet_m"
local sharedata = require "skynet.sharedata"

local share = {}

skynet_m.init(function()
    -- share with all agent
    share.quality_data = sharedata.query("quality_data")
    share.quality_map = sharedata.query("quality_map")
end)

return share
