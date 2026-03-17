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
    {text = "Data Fetch", value = "DataFetch"},
}

-- private methods

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
            if var == "soundList" then
                output = output .. string.format("|cff0070DD%s|r.|cffffff00%s|r|cffC41E3A(%s)|r: %s\n", var, "soundList", "table", "soundList")
            else
                for name, value in pairs(addon.states[var]) do
                    output = output .. string.format("|cff0070DD%s|r.|cffffff00%s|r|cffC41E3A(%s)|r: %s\n", var, name, type(value), tostring(value))
                end
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

-- MARK: Encounter Events
local function FetchEncounterEventInfo(encounterEventID)
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

local function AttemptsFetchAllEEInfo()
    local output = "EncounterEventID,Severity,SpellID,SpellName\n"
    local allEventIDs = C_EncounterEvents.GetEventList()

    for _, eventID in ipairs(allEventIDs) do
        local data = FetchEncounterEventInfo(eventID)
        if data.encounterEventID then
            output = output .. string.format("%d,%s,%s,%s\n",
                data.encounterEventID,
                data.severity or "nil",
                tostring(data.spellID),
                data.spellName or "nil"
            )
        end
    end

    return output
end

-- MARK: Encounter Journal Sections
local function FetchSection(currentSectionID, output, encounterID)
    local info = C_EncounterJournal.GetSectionInfo(currentSectionID)
    local spellID = info.spellID or -1
    local iconFlags = C_EncounterJournal.GetSectionIconFlags(currentSectionID)
    local iconFlagsStr = "\"["
    for _, flag in ipairs(iconFlags or {}) do
        iconFlagsStr = iconFlagsStr .. flag .. ","
    end
    iconFlagsStr = iconFlagsStr .. "]\""
    if spellID ~= 0 and spellID ~= -1 then
        output = output .. string.format("%d,%s,%s,%d\n", spellID, info.title or "nil", iconFlagsStr, encounterID)
    end

    -- child sections first
    if info.firstChildSectionID then
        output = FetchSection(info.firstChildSectionID, output, encounterID)
    end

    -- then, same level sections
    if info.siblingSectionID then
        output = FetchSection(info.siblingSectionID, output, encounterID)
    end

    return output
end

local function FecthAllEncounterSections(journalID, difficultyID, encounterID)
    EJ_SetDifficulty(difficultyID)
    local output = ""
    local currentSectionID = select(4, EJ_GetEncounterInfo(journalID))

    output = FetchSection(currentSectionID, output, encounterID)
    return output
end

local function FetchAllEncounterInfo()
    local output = "SpellID,SpellName,Flags,EncounterID\n"
    for mapID, mapInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS) do
        local isRaid = select(12, EJ_GetInstanceInfo(mapID))
        local difficultyID = isRaid and 16 or 23 -- Mythic for both raids and dungeons
        for encounterID, encounterInfo in pairs(mapInfo.encounters) do
            output = output .. FecthAllEncounterSections(encounterInfo.journalID, difficultyID, encounterID)
        end
    end

    return output
end

-- MARK: Private Auras
local function ScanAllPrivateAuras()
    local output = "SpellID,Result,SpellName,EncounterID\n"
    for _, mapData in pairs(addon.data.MAP_ENCOUNTER_EVENTS) do
        for encounterID, encounterData in pairs(mapData.encounters) do
            for _, privateAuraID in ipairs(encounterData.privateAuras or {}) do
                local result = C_UnitAuras.AuraIsPrivate(privateAuraID)
                output = output .. string.format("%d,%s,%s,%d\n", privateAuraID, tostring(result), C_Spell.GetSpellInfo(privateAuraID) and C_Spell.GetSpellInfo(privateAuraID).name or "None", encounterID)
            end
        end
    end

    return output
end

-- MARK: Render
local function RenderDisplayFrame(self, info)
    self.isOpened = true
    self.displayFrame = AceGUI:Create("Frame")
    self.displayFrame:SetTitle("|cFF8788EEHBES|r - Developer Tools")
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

            panel:DoLayout()
        elseif tab == "ModulesInfo" then
            local panel = GUI:CreateScrollFrame(container)
            GUI:CreateInformationTag(panel, info["ModulesInfo"], "LEFT")
            panel:DoLayout()
        elseif tab == "StatesInfo" then
            local panel = GUI:CreateScrollFrame(container)
            GUI:CreateInformationTag(panel, info["StatesInfo"], "LEFT")
            panel:DoLayout()
        elseif tab == "DataFetch" then
            local panel = GUI:CreateScrollFrame(container)
            local dataOutput = GUI:CreateMultiLineEditBox(panel, "Data Output:", "")
            GUI:CreateButton(panel, "Fetch Encounter Events Info", function()
                local data = AttemptsFetchAllEEInfo()
                dataOutput:SetText(data)
            end):SetRelativeWidth(0.32)
            GUI:CreateButton(panel, "Fetch Encounter Sections Info", function()
                local data = FetchAllEncounterInfo()
                dataOutput:SetText(data)
            end):SetRelativeWidth(0.32)
            GUI:CreateButton(panel, "Scan Private Auras", function()
                local data = ScanAllPrivateAuras()
                dataOutput:SetText(data)
            end):SetRelativeWidth(0.32)
            panel:DoLayout()
        end
    end)
    
    tabs:SelectTab("CopyInfo")
end

-- MARK: DisplayAddonInfo
function addon.DeveloperTools:DisplayAddonInfo()
    local output = {}
    output["ModulesInfo"] = GetModulesInfo() .. "\n" .. GetEventsInfo()
    output["StatesInfo"] = GetStatesInfo() .. "\n" .. GetStateMonitorsInfo()

    if self.isOpened and self.displayFrame then
        self.displayFrame:Hide()
        self.isOpened = false
    else
        RenderDisplayFrame(self, output)
    end
end