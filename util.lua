local _M = {}
function _M.ser_function(v)
    local info = debug.getinfo(v)
    local src = info.short_src
    local name = info.name
    local line = info.linedefined
    return string.format("\"%s\"--[[%s:%d func: %s]]", v, src, line, name)
end

function _M.ser_table(t, flag)
    local mark = {}
    local assign = {}
    local function _ser(tbl, parent, dep)
        dep = dep or 1
        mark[tbl] = parent
        local tmp = {}
        for k, v in pairs(tbl) do
            local key = k
            if type(k) == "number" then
                key = "[" .. k .. "]"
            elseif tonumber(k) then
                key = "[\"" .. k .. "\"]"
            elseif type(k) == "string" then
                key = k
            elseif type(k) == "function" then
                key = "[\"" .. _M.ser_function(k) .. "\"]"
            else
                key = string.format("[\"%s:%p\"]", k, type(k))
            end
            local space = "\n" .. string.rep("\t", dep)
            if type(v) == "table" then
                local dotkey = parent .. "." .. key
                if mark[v] then
                    table.insert(assign, dotkey .. "=" .. mark[v])
                else
                    table.insert(tmp, space .. key .. "=" .. _ser(v, dotkey, dep + 1))
                end
            elseif type(v) == "function" then
                table.insert(tmp, space .. key .. "=" .. _M.ser_function(v))
            elseif type(v) == "string" then
                table.insert(tmp, space .. key .. "='" .. tostring(v) .. "'")
            else
                table.insert(tmp, space .. key .. "=" .. tostring(v))
            end
        end
        return "{" .. table.concat(tmp, ",") .. "\n" .. string.rep("\t", dep - 1) .. "}"
    end
    flag = flag and (" -> " .. flag) or ""
    return _ser(t, "r") .. flag
end

function _M.table_dump(t)
    return _M.ser_table(t)
end

function _M.dump(o, flag)
    local t = type(o)
    if t == "table" then
        return _M.ser_table(o, flag)
    elseif t == "function" then
        return _M.ser_function(o)
    elseif t == "string" then
        return string.format("\"%s\"", string.gsub(o, "\"", "\\\""))
    elseif t == "number" then
        return tostring(o)
    elseif t == "nil" then
        return "nil"
    else
        return string.format("not type:%s", t)
    end
end

function _M.pdump(o, flag)
    print(_M.dump(o, flag))
end

return _M
