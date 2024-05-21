local string_gmatch = string.gmatch
local table_insert = table.insert
local ngx_var = ngx.var
local ngx_say = ngx.say
local ngx_req_get_headers = ngx.req.get_headers

local number_of_proxies = os.getenv('NUMBER_OF_PROXIES') or 0

local _M = {}

local get_ip = function()
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

_M.main = function()
    ngx_say(get_ip())
end

_M.headers = function()
    local headers, err = ngx_req_get_headers(nil, true)
    if err and err ~= 'truncated' then
        ngx.status = 500
    end
    for header, value_or_values in pairs(headers) do
        if type(value_or_values) == 'table' then
            for _, value in ipairs(value_or_values) do
                ngx_say(header, ': ', value)
            end
        else
            ngx_say(header, ': ', value_or_values)
        end
    end

end

return _M
