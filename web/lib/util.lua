local skynet_m = require "skynet_m"

local string = string
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local table = table
local type = type
local traceback = debug.traceback
local math = math

local util = {}

function util.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function util.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function util.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function util.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == '') then return false end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function util.dump(val, desc, nesting)
    if type(nesting) ~= "number" then nesting = 8 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local tb = util.split(traceback("", 2), "\n")
    skynet_m.log("dump from: " .. util.trim(tb[3]))

    local function _dump(value, desciption, indent, nest, kl)
        desciption = desciption or "<var>"
        local spc = ""
        if type(kl) == "number" then
            spc = string.rep(" ", kl - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result + 1] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result + 1] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result + 1] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result + 1] = string.format("%s}", indent)
            end
        end
    end
    _dump(val, desc, "- ", 1)

    for i, line in ipairs(result) do
        skynet_m.log(line)
    end
end

function util.shuffle(card)
    local len = #card
    for i = 1, len - 1 do
        local r = math.random(i, len)
        card[i], card[r] = card[r], card[i]
    end
end

function util.empty(t)
    for k, v in pairs(t) do
        return false
    end
    return true
end

function util.rand_offset(min, max)
    if min >= max then
        return min
    end
    local r = (max - min + 1) * math.random() + min
    if r > max then
        r = max
    end
    return r
end

return util