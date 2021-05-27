local skynet_m = require "skynet_m"

skynet_m.start(function()
    skynet_m.log("Server start.")

    -- debug service
    if not skynet_m.getenv("daemon") then
        skynet_m.newservice("console")
    end
    skynet_m.newservice("debug_console", skynet_m.getenv("debug_port"))

    -- service
    skynet_m.uniqueservice("record")
    skynet_m.uniqueservice("simpleweb")

    skynet_m.log("Server start finish.")

    skynet_m.exit()
end)