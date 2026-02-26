local RUNEFORGES = {
    [3368] = "Rune of the Fallen Crusader",
    [3847] = "Rune of the Stoneskin Gargoyle",
    [6245] = "Rune of the Apocalypse",
    [3370] = "Rune of Razorice",
}

local DEBUG = false
local currentSpec = nil
local frostbaneActive = false

local function ValidateRuneforge(slot, runeforgeId)
    if DEBUG then print("Checking slot", slot, "with runeforge", runeforgeId) end
    if DEBUG then print("Current spec:", currentSpec, "Frostbane active:", frostbaneActive) end
    if currentSpec == "Frost" then
        if slot == 16 then
            if frostbaneActive then
                return runeforgeId == 3370
            else 
                return runeforgeId == 3847 or runeforgeId == 3368
            end
        elseif slot == 17 then
            return runeforgeId == 3368 or runeforgeId == 3847
        end
    end
    if currentSpec == "Unholy" then
        return runeforgeId == 6245
    end
    if currentSpec == "Blood" then
        return runeforgeId == 3368
    end
    return false
end

local frame = CreateFrame("Frame", "RuneforgeReminderFrame", UIParent)
frame:Hide()
frame:SetSize(100, 40)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local icon = frame:CreateTexture(nil, "ARTWORK")
icon:SetSize(40, 40)
icon:SetPoint("LEFT", frame, "LEFT", 5, 0)
icon:SetTexture(237523)

local label = frame:CreateFontString(nil, "OVERLAY", "SystemFont_OutlineThick_Huge2")
label:SetTextColor(.76862, .11764, .22745, 1)
label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
label:SetText("Check Runeforge")

local closeBtn = CreateFrame("Button", nil, frame)
closeBtn:SetSize(16, 16)
closeBtn:SetPoint("LEFT", label, "RIGHT", 6, 0)
closeBtn:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
closeBtn:SetScript("OnClick", function() frame:Hide() end)



frame:SetMovable(true)
frame:SetScript("OnMouseDown", function(self, button)
	self:StartMoving()
end)
frame:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
end)

local function CheckRuneforgeForSlot(slot)
    local itemLink = GetInventoryItemLink("player", slot)
    if itemLink then
        local enchantID = select(3, string.find(itemLink, "item:%d+:(%d+):"))
        if enchantID then
            return ValidateRuneforge(slot, tonumber(enchantID))
        end
    else
        return true -- no link, no warning
    end
end

local function CheckRuneforge()
    local mhCheck = CheckRuneforgeForSlot(16)
    local ohCheck = CheckRuneforgeForSlot(17)
    if DEBUG then print("MH valid:", mhCheck, "OH valid:", ohCheck) end
    local validRuneforges = mhCheck and ohCheck
    if DEBUG then print(validRuneforges) end

    if not validRuneforges then
        frame:Show()
    else
        frame:Hide()
    end
end

local class, _, _ = UnitClass("player")
if class == "Death Knight" then
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:RegisterEvent("SPELLS_CHANGED")
end

frame:SetScript("OnEvent", function(self, event)
    if DEBUG then print(event) end

    local class, _, _ = UnitClass("player")

    if class ~= "Death Knight" then return end

    local _, currentSpecName = GetSpecializationInfo(GetSpecialization())
    currentSpec = currentSpecName
    frostbaneActive = C_SpellBook.IsSpellKnown(455993)
    CheckRuneforge()
end)
