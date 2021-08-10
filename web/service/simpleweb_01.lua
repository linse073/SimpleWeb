local skynet_m = require "skynet_m"
local socket = require "skynet.socket"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"

local string = string
local error = error
local print = print

local mode, protocol = ...
protocol = protocol or "http"

local http_port = skynet_m.getenv_num("http_port_01")

if mode == "agent" then

local record_01

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		-- if err == sockethelper.socket_error , that means socket closed.
		skynet_m.error(string.format("fd = %d, %s", id, err))
	end
end

local SSLCTX_SERVER = nil
local function gen_interface(proto, fd)
	if proto == "http" then
		return {
			init = nil,
			close = nil,
			read = sockethelper.readfunc(fd),
			write = sockethelper.writefunc(fd),
		}
	elseif proto == "https" then
		local tls = require "http.tlshelper"
		if not SSLCTX_SERVER then
			SSLCTX_SERVER = tls.newctx()
			-- gen cert and key
			-- openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout server-key.pem -out server-cert.pem
			local certfile = skynet_m.getenv("certfile") or "./server-cert.pem"
			local keyfile = skynet_m.getenv("keyfile") or "./server-key.pem"
			print(certfile, keyfile)
			SSLCTX_SERVER:set_cert(certfile, keyfile)
		end
		local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
		return {
			init = tls.init_responsefunc(fd, tls_ctx),
			close = tls.closefunc(tls_ctx),
			read = tls.readfunc(fd, tls_ctx),
			write = tls.writefunc(fd, tls_ctx),
		}
	else
		error(string.format("Invalid protocol: %s", proto))
	end
end

skynet_m.start(function()
	record_01 = skynet_m.queryservice("record_01")

	skynet_m.dispatch("lua", function(_, _, id)
		socket.start(id)
		local interface = gen_interface(protocol, id)
		if interface.init then
			interface.init()
		end
		-- limit request body size to 8192 (you can pass nil to unlimit)
		local code, url, method, header, body = httpd.read_request(interface.read, 8192)
		if code then
			if code ~= 200 then
				response(id, interface.write, code)
			else
				local _, query = urllib.parse(url)
				if query then
					skynet_m.send_lua(record_01, "save", query)
				end
				response(id, interface.write, code, "ok")
			end
		else
			if url == sockethelper.socket_error then
				skynet_m.error("socket closed")
			else
				skynet_m.error(url)
			end
		end
		socket.close(id)
		if interface.close then
			interface.close()
		end
	end)
end)

else

skynet_m.start(function()
	local agent = {}
	local proto = "http"
	for i = 1, 20 do
		agent[i] = skynet_m.newservice(SERVICE_NAME, "agent", proto)
	end
	local balance = 1
	local id = socket.listen("0.0.0.0", http_port)
	skynet_m.error(string.format("Listen web port %d protocol:%s", http_port, proto))
	socket.start(id , function(aid, addr)
		skynet_m.error(string.format("%s connected, pass it to agent :%08x", addr, agent[balance]))
		skynet_m.send(agent[balance], "lua", aid)
		balance = balance + 1
		if balance > #agent then
			balance = 1
		end
	end)
end)

end