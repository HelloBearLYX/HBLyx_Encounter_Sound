local ADDON_NAME, addon = ...
local AceGUI = LibStub("AceGUI-3.0")
local GUI = addon.GUI

---@class DeveloperTools
---@field displayFrame frame|nil a frame to display developer tool's outputs
addon.DeveloperTools = {
    displayFrame = nil,
    isOpened = false,
}

-- MARK: Constants
local TABS = {
    {text = "Copy Info", value = "CopyInfo"},
    {text = "Modules Info", value = "ModulesInfo"},
    {text = "States Info", value = "StatesInfo"},
}

-- private methods

-- MARK: Render
local function RenderDisplayFrame(self, info)
    self.isOpened = true
    self.displayFrame = AceGUI:Create("Frame")
    self.displayFrame:SetTitle("|cFF8788EEHBLyx Tools|r - Developer Tools")
    self.displayFrame:SetLayout("Flow")
    self.displayFrame:SetWidth(900)
    self.displayFrame:SetHeight(600)
    self.displayFrame:SetStatusText("|cff8788ee"..  ADDON_NAME .. "|r v" .. addon:GetVersion() .. " " .. "Developer Tools")
    self.displayFrame:SetCallback("OnClose", function(widget)
        if widget then
            widget:Release()
        end

        self.isOpened = false
    end)

    local tabs = AceGUI:Create("TabGroup")
    tabs:SetLayout("Flow")
    tabs:SetFullWidth(true)
    tabs:SetFullHeight(true)
    tabs:SetTabs(TABS)
    self.displayFrame:AddChild(tabs)
    tabs:SetCallback("OnGroupSelected", function (container, _, tab)
        container:ReleaseChildren()

        if tab == "CopyInfo" then
            local panel = GUI:CreateScrollFrame(container)
            
            local addonInfo = ""
            for _, value in pairs(info) do
                addonInfo = addonInfo .. value .. "\n------\n\n"
            end
            GUI:CreateMultiLineEditBox(panel, "Copy the addon info below:", addonInfo)
            GUI:CreateMultiLineEditBox(panel, "Copy the data below:", info["Data"] or "")

            panel:DoLayout()
        elseif tab == "ModulesInfo" then
            local panel = GUI:CreateScrollFrame(container)
            GUI:CreateInformationTag(panel, info["ModulesInfo"], "LEFT")
            panel:DoLayout()
        elseif tab == "StatesInfo" then
            local panel = GUI:CreateScrollFrame(container)
            GUI:CreateInformationTag(panel, info["StatesInfo"], "LEFT")
            panel:DoLayout()
        end
    end)
    
    tabs:SelectTab("CopyInfo")
end

-- MARK: Events Info
local function GetEventsInfo()
    local events = {}
    for event, _ in pairs(addon.core.eventMap) do
        table.insert(events, event)
    end
    table.sort(events, function (a, b)
        if #addon.core.eventMap[a] == #addon.core.eventMap[b] then
            return a < b
        end

        return #addon.core.eventMap[a] > #addon.core.eventMap[b]
    end)

    local output = "|cff8788EEEvents Info|r:\n"
    local total = 0
    
    for _, event in ipairs(events) do
        output = output .. "|cff00ff00" .. event .. "|r|cffC41E3A(" .. tostring(#addon.core.eventMap[event]) .. ")|r: "
        total = total + #addon.core.eventMap[event]
        for _, mod in ipairs(addon.core.eventMap[event]) do
            output = output .. mod .. ", "
        end
        output = output .. "\n"
    end

    output = output .. string.format("*|cff00ff00Total Events: %d|r *|cffC41E3ATotal Registers: %d|r\n", #events, total)

    return output
end

-- MARK: States Info
local function GetStatesInfo()
    local vars = {}
    for var, _ in pairs(addon.states) do
        table.insert(vars, var)
    end
    table.sort(vars)

    local output = "|cff8788EEStates Info|r:\n"

    for _, var in ipairs(vars) do
        if type(addon.states[var]) == "table" then
            for name, value in pairs(addon.states[var]) do
                output = output .. string.format("|cff0070DD%s|r.|cffffff00%s|r|cffC41E3A(%s)|r: %s\n", var, name, type(value), tostring(value))
            end
        else
            output = output .. string.format("|cff0070DD%s|r|cffC41E3A(%s)|r: %s\n", var, type(addon.states[var]), tostring(addon.states[var]))
        end
    end

    local eventKeys = {}
    for event, _ in pairs(addon.core.statesUpdate) do
        table.insert(eventKeys, event)
    end
    table.sort(eventKeys)

    for _, event in ipairs(eventKeys) do
        local states = addon.core.statesUpdate[event]
        output = output .. string.format("|cff00ff00%s|r: ", event)
        for state, _ in pairs(states) do
                output = output .. string.format("|cff0070DD%s|r, ", state)
        end
        output = output .. "\n"
    end

    return output
end

-- MARK: Modules Info
local function GetModulesInfo()
    local output = "|cff8788EEModules Info|r:\n"

    output = output .. string.format("|cffFF7C0ARegistered Modules|r|cffC41E3A(%d)|r: ", addon.core.totalMods)
    for mod, _ in pairs(addon.core.registeredMods) do
        output = output .. mod .. ", "
    end
    output = output .. "\n"

    output = output .. string.format("|cff00ff00Loaded Modules|r|cffC41E3A(%d)|r: ", addon.core.loadedMods)
    for mod, _ in pairs(addon.core.modules) do
        output = output .. mod .. ", "
    end
    output = output .. "\n"

    return output
end

-- MARK: State Monitors Info
local function GetStateMonitorsInfo()
    local output = "|cff8788EEState Monitors Info|r:\n"

    local states = {}
    local statesCount = {}
    for state, monitors in pairs(addon.core.statesMonitor) do
        table.insert(states, state)
        statesCount[state] = 0
        for _, _ in pairs(monitors) do
            statesCount[state] = statesCount[state] + 1
        end
    end

    table.sort(states, function (a, b)
        if statesCount[a] == statesCount[b] then
            return a < b
        end

        return statesCount[a] > statesCount[b]
    end)

    for _, state in ipairs(states) do
        local str = ""
        for monitor, _ in pairs(addon.core.statesMonitor[state]) do
            str = str .. monitor .. ", "
        end
        output = output .. string.format("|cff00ff00%s|r|cffC41E3A(%d)|r: %s\n", state, statesCount[state], str)
    end

    return output
end

function addon.DeveloperTools:DisplayAddonInfo()
    local output = {}
    output["ModulesInfo"] = GetModulesInfo() .. "\n" .. GetEventsInfo()
    output["StatesInfo"] = GetStatesInfo() .. "\n" .. GetStateMonitorsInfo()
    -- Fetch data
    -- local ScanPrivateAuras = function()
    --     local output = "SpellID,Result,SpellName\n"
    --     local data = {386201, 391977, 388544, 389033, 396716, 376760, 376997, 377009, 389007, 389011, 244588, 244599, 245742, 246026, 1263523, 1263542, 1268733, 1265426, 1265650, 1251626, 1251772, 1264042, 1276485, 1247975, 1249020, 1252828, 1255310, 1255335, 1255503, 1243741, 1243752, 1249478, 1260643, 1266488, 1251568, 1251775, 1251813, 1251833, 1252130, 1266706, 1251023, 1252675, 1252777, 1252816, 1253779, 1253844, 1254043, 1254175, 1255629, 1266188, 153757, 1252733, 154150, 1253511, 1253520, 153954, 1253541, 466091, 466559, 470212, 472118, 472777, 472793, 472888, 474129, 1253834, 1215803, 1219491, 1282272, 467620, 468659, 470966, 1283247, 1253030, 468442, 472662, 474528, 1282911, 1216042, 1253979, 1282955, 1214038, 1214089, 1243905, 1225015, 1225205, 1225792, 1246446, 1224104, 1224401, 1284958, 1224299, 1253709, 1215157, 1215161, 1215897, 1269631, 1261286, 1261799, 1262772, 1262596, 1264186, 1264453, 1264299, 1234802, 1235574, 1235828, 1235865, 1237091, 1237267, 1272290, 1239825, 1239919, 1241058, 1251345, 1257094, 1246751, 1246753, 1247746, 1228198, 474515, 474545, 1214352, 473898, 474234, 1214650, 1234846, 1235125, 1235549, 1235829, 1235841, 1235641, 1236289, 1242869, 1243590, 1255577, 1262253, 1261781, 1222103, 1262283, 1222484, 1222642, 1226031, 1263971, 1227197, 1248130, 1264188, 1245698, 1262020, 1250953, 1253744, 1264756, 1272726, 1246653, 1257087, 1275059, 1280075, 1284786, 1265540, 1283069, 1259186, 1272527, 1243270, 1241844, 1250828, 1245960, 1250991, 1245592, 1251213, 1248697, 1248709, 1250686, 1244672, 1252157, 1264467, 1245554, 1270852, 1245175, 1265152, 1255763, 1276982, 1272324, 1246736, 1251857, 1249130, 1258514, 1233602, 1242553, 1233865, 1243753, 1238206, 1237038, 1232470, 1238708, 1245698, 1262020, 1250953, 1253744, 1264756, 1272726, 1246653, 1257087, 1282027, 1249609, 1249584, 1251789, 1284699, 1265842, 1262055, 1281184, 1266113, 1253104}

    --     for _, spellID in ipairs(data) do
    --         local result = C_UnitAuras.AuraIsPrivate(spellID)
    --         output = output .. string.format("%d,%s,%s\n", spellID, tostring(result), C_Spell.GetSpellInfo(spellID) and C_Spell.GetSpellInfo(spellID).name or "None")
    --     end

    --     return output
    -- end
    -- output["Data"] = ScanPrivateAuras()
    -- output["Data"] = self:FecthAllEncounterSections(2795, 15) -- get encounter spellIDs
    -- output["Data"] = self:AttemptsFetchAllEEInfo() -- get encounter events info

    if self.isOpened and self.displayFrame then
        self.displayFrame:Hide()
        self.isOpened = false
    else
        RenderDisplayFrame(self, output)
    end
end

-- MARK: Fetch Data
function addon.DeveloperTools:FetchEncounterEventInfo(encounterEventID)
    local encounterEventInfo = C_EncounterEvents.GetEventInfo(encounterEventID)
    local data = {
        encounterEventID = encounterEventID,
        severity = nil,
        spellID = nil,
        spellName = nil,
    }

    if encounterEventInfo then
        data.spellID = encounterEventInfo.spellID or nil
        data.severity = encounterEventInfo.severity or nil
        data.spellName = encounterEventInfo.spellID and C_Spell.GetSpellInfo(encounterEventInfo.spellID).name or nil
    else
        data.encounterEventID = nil
    end

    return data
end

function addon.DeveloperTools:AttemptsFetchAllEEInfo()
    local output = "EncounterEventID, Severity, SpellID, SpellName\n"
    for i = 1, 1000 do
        local data = self:FetchEncounterEventInfo(i)
        output = output .. string.format("%d, %s, %s, %s\n",
            data.encounterEventID or -1,
            data.severity or "nil",
            tostring(data.spellID),
            data.spellName or "nil"
        )
    end

    return output
end

local function FetchSection(currentSectionID, output)
    local info = C_EncounterJournal.GetSectionInfo(currentSectionID)
    local spellID = info.spellID or -1
    if spellID == 0 then spellID = -1 end
    output = output .. string.format("%d,%s,%s\n", spellID, info.title or "nil", tostring(info.filteredByDifficulty))

    -- child sections first
    if info.firstChildSectionID then
        output = FetchSection(info.firstChildSectionID, output)
    end

    -- then, same level sections
    if info.siblingSectionID then
        output = FetchSection(info.siblingSectionID, output)
    end

    return output
end

function addon.DeveloperTools:FecthAllEncounterSections(encounterID, difficultyID)
    EJ_SetDifficulty(difficultyID)
    local output = "SpellID,SpellName,FilteredByDifficulty\n"
    local currentSectionID = select(4, EJ_GetEncounterInfo(encounterID))

    output = FetchSection(currentSectionID, output)
    return output
end