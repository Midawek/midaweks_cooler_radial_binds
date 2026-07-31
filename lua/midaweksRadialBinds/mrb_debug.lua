MCRB = MCRB or {}

CreateConVar("mcrb_debug", 0, 128, "take a guess", 0, 1)

MCRB.Debug = GetConVar("mcrb_debug"):GetBool()

function MCRB:log(message)
    if MCRB.Debug then
        print("[MCRB] " .. message)
    end
end

function MCRB:logError(message)
    if MCRB.Debug then
        ErrorNoHaltWithStack("[MCRB] Error logged, Info:" .. message)
    end
end

-- hook.add("OnLuaError", "MCRB_Blame", function(errorMessage)

-- end)
