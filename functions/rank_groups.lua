YARM = YARM or {}

local odd_ranks = {
    ["3"] = true,
    ["5"] = true,
    ["7"] = true,
    ["9"] = true,
    ["Ace"] = true,
}

local even_ranks = {
    ["2"] = true,
    ["4"] = true,
    ["6"] = true,
    ["8"] = true,
    ["10"] = true,
}

local function get_intrinsic_rank(value)
    if type(SMODS) ~= "table" or type(SMODS.Ranks) ~= "table" then
        return nil
    end

    if type(value) == "string" then
        return SMODS.Ranks[value]
    end

    if type(value) ~= "table" then
        return nil
    end

    local base = value.base

    if type(base) == "table" then
        if type(value.get_id) ~= "function"
            or type(value.ability) ~= "table"
            or type(value.config) ~= "table"
            or type(value.config.center) ~= "table"
            or type(value.config.center.key) ~= "string" then
            return nil
        end

        if type(SMODS.has_no_rank) == "function"
            and SMODS.has_no_rank(value) then
            return nil
        end

        if type(base.value) ~= "string" then
            return nil
        end

        return SMODS.Ranks[base.value]
    end

    if type(value.key) == "string" then
        return SMODS.Ranks[value.key]
    end

    return nil
end

local function get_parity(value)
    local rank = get_intrinsic_rank(value)

    if not rank then
        return nil
    end

    if odd_ranks[rank.key] then
        return "odd"
    end

    if even_ranks[rank.key] then
        return "even"
    end

    return nil
end

function YARM.is_intrinsic_face(value)
    local rank = get_intrinsic_rank(value)
    return rank ~= nil and rank.face == true
end

function YARM.is_odd(value)
    local parity = get_parity(value)

    if parity ~= nil then
        return parity == "odd"
    end

    return nil
end

function YARM.is_even(value)
    local parity = get_parity(value)

    if parity ~= nil then
        return parity == "even"
    end

    return nil
end