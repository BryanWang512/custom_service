GetNumFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tonumber(tb[key]:get_value());
            if ret == nil then
                ret = default;
            end
        end
    end
    return ret;
end

GetStrFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if string.len(ret)  == 0 then
                ret = default;
            end
        end
    end
    return ret;
end

GetBlooeanFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
        end
    end
    return ret;
end

GetTableFromJsonTable = function(tb, key, default)
    local ret = default;
    if tb and tb[key] ~= nil then
        if tb[key]:get_value() ~= nil then
            ret = tb[key]:get_value();
            if type(ret) ~= "table" then
                ret = default;
            end
        end
    end
    return ret;
end