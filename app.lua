local string_find = string.find
local string_gmatch = string.gmatch
local string_lower = string.lower
local table_insert = table.insert
local ngx_var = ngx.var
local ngx_say = ngx.say
local ngx_req_get_headers = ngx.req.get_headers

local number_of_proxies
do
    local number = os.getenv('NUMBER_OF_PROXIES')
    if not number or number == '' then
        number_of_proxies = 0
    else
        number_of_proxies = tonumber(number)
        if not number_of_proxies then
            error('invalid NUMBER_OF_PROXIES value: ' .. number)
        end
    end
end

local hide_proxy_headers
do
    local hide = os.getenv('HIDE_PROXY_HEADERS')
    if not hide or hide == '' then
        hide_proxy_headers = number_of_proxies > 0
    else
        hide = string_lower(hide)
        if hide == '0' or hide == 'false' then
            hide_proxy_headers = false
        elseif hide == '1' or hide == 'true' then
            hide_proxy_headers = true
        else
            error('invalid HIDE_PROXY_HEADERS value: ' .. os.getenv('HIDE_PROXY_HEADERS'))
        end
    end
end

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

local print_header = function(header, value)
    if hide_proxy_headers then
        local header_lower = string_lower(header)
        if header_lower == 'x-real-ip' then
            return
        end
        if string_find(header_lower, '^x%-forwarded%-.+') then
            return
        end
    end
    ngx_say(header, ': ', value)
end

_M.headers = function()
    local headers, err = ngx_req_get_headers(nil, true)
    if err and err ~= 'truncated' then
        ngx.status = 500
    end
    for header, value_or_values in pairs(headers) do
        if type(value_or_values) == 'table' then
            for _, value in ipairs(value_or_values) do
                print_header(header, value)
            end
        else
            print_header(header, value_or_values)
        end
    end
end

return _M
