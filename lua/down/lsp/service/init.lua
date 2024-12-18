local e = require "/nix/store/6qk1rdc2lnk8yc6bvnnda70crcx5jysp-luarocks_bootstrap-3.11.1/lib/luarocks/rocks-5.2/luasocket/3.1.0-1"
local e = require "/nix/store/6qk1rdc2lnk8yc6bvnnda70crcx5jysp-luarocks_bootstrap-3.11.1/lib/lua/5.2"
e
local S  = {}

S.send   = function()
  print("Sending message")
end

S.start  = function()
  print("Server started")
end

S.req    = function(name, params, cb)
  local id = l
  local m = {
    id = 1,
    method = name,
    params = params,
  }
  print("Request received")
end
S.listen = function()
  print("Listening")
end
S.reply  = function()
  local m = {
    id = 1,
    result = "ok",
  }
end

return S
