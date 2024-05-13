local string_gmatch = string.gmatch
local table_insert = table.insert
local ngx_var = ngx.var
local ngx_say = ngx.say

local number_of_proxies = os.getenv('NUMBER_OF_PROXIES') or 0

local _M = {}

local get = function()
    if number_of_proxies == 0 then
        return ngx_var.remote_addr
    end
    local x_forwarded_for = ngx_var.http_x_forwarded_for
    if not x_forwarded_for then
        return ngx_var.remote_addr
    end
    local ips = {}
    for ip in string_gmatch(x_forwarded_for, '([^, ]+)') do
        table_insert(ips, ip)
    end
    local proxy_index = #ips - number_of_proxies + 1
    if proxy_index < 1 then
        proxy_index = 1
    end
    return ips[proxy_index]
end

_M.get = get

_M.print = function()
    ngx_say(get())
end

return _M
