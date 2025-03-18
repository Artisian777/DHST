local HavocAPL = {
    -- Precombat (run once before combat starts)
    { spell = "Immolation Aura", condition = function() return not UnitAffectingCombat("player") and GetSpellCooldown("Immolation Aura") == 0 end },
    { spell = "Fel Rush", condition = function() return not UnitAffectingCombat("player") and GetSpellCooldown("Fel Rush") == 0 end },

    -- Combat Rotation
    { spell = "Metamorphosis", condition = function() return GetSpellCooldown("Metamorphosis") == 0 end }, -- Use Meta on cooldown
    { spell = "Blade Dance", condition = function() return HasBuff("Metamorphosis") and UnitPower("player", Enum.PowerType.Fury) >= 35 and GetSpellCooldown("Blade Dance") == 0 end }, -- First Blood in Meta
    { spell = "Chaos Strike", condition = function() return HasBuff("Metamorphosis") and UnitPower("player", Enum.PowerType.Fury) >= 40 end }, -- Chaos Strike spam in Meta
    { spell = "Felblade", condition = function() return HasBuff("Metamorphosis") and GetSpellCharges("Felblade") > 0 end }, -- Fury gen in Meta
    { spell = "Fel Rush", condition = function() return HasBuff("Metamorphosis") and GetSpellCooldown("Fel Rush") == 0 end }, -- Exergy in Meta
    { spell = "Demon's Bite", condition = function() return HasBuff("Metamorphosis") end }, -- Fallback in Meta

    { spell = "Eye Beam", condition = function() return GetSpellCooldown("Eye Beam") == 0 and UnitPower("player", Enum.PowerType.Fury) >= 30 and HasBuff("Unbound Chaos") end }, -- Eye Beam with Unbound Chaos
    { spell = "Fel Rush", condition = function() return GetSpellCooldown("Eye Beam") <= 2 and GetSpellCooldown("Fel Rush") == 0 and not HasBuff("Unbound Chaos") end }, -- Proc Unbound Chaos
    { spell = "Eye Beam", condition = function() return GetSpellCooldown("Eye Beam") == 0 and UnitPower("player", Enum.PowerType.Fury) >= 30 end }, -- Eye Beam without Unbound Chaos

    { spell = "Blade Dance", condition = function() return UnitPower("player", Enum.PowerType.Fury) >= 35 and GetSpellCooldown("Blade Dance") == 0 end }, -- First Blood priority
    { spell = "Throw Glaive", condition = function() return GetSpellCooldown("Throw Glaive") == 0 end }, -- Aldrachi Reaver proc
    { spell = "Immolation Aura", condition = function() return GetSpellCharges("Immolation Aura") >= 1 end }, -- Don’t cap charges
    { spell = "Chaos Strike", condition = function() return UnitPower("player", Enum.PowerType.Fury) >= 40 end }, -- Main spender
    { spell = "Fel Rush", condition = function() return GetSpellCooldown("Fel Rush") == 0 and not HasBuff("Exergy") end }, -- Maintain Exergy
    { spell = "Felblade", condition = function() return GetSpellCharges("Felblade") > 0 end }, -- Fury generation
    { spell = "Demon's Bite", condition = function() return true end }, -- Fallback (Demon Blades assumed off)
}

-- Utility functions (ensure these are defined in your addon)
local function HasBuff(buffName)
    return UnitBuff("player", buffName) ~= nil
end

-- Example integration into an addon frame
local HavocFrame = CreateFrame("Frame")
HavocFrame:RegisterEvent("PLAYER_LOGIN")
HavocFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
HavocFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

local function GetNextAction()
    if not UnitAffectingCombat("player") and not UnitExists("target") or UnitIsDead("target") then
        return nil
    end
    for _, action in ipairs(HavocAPL) do
        if action.condition() then
            return action.spell
        end
    end
    return nil
end

HavocFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        print("Havoc DH ST APL loaded!")
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" or event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local nextAction = GetNextAction()
        if nextAction then
            print("Next action: " .. nextAction) -- Replace with addon-specific logic
        end
    end
end)

-- Slash command for manual check
SLASH_HAVOCAPL1 = "/havocapl"
SlashCmdList["HAVOCAPL"] = function()
    local nextAction = GetNextAction()
    if nextAction then
        print("Next action: " .. nextAction)
    else
        print("No valid target or not in combat.")
    end
end