local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")
local prefix = "!HBLyx_Tools_EncounterSound_"


GUI.TagPanels.Profile = {}
function GUI.TagPanels.Profile:CreateTabPanel(parent)
    local frame = GUI:CreateScrollFrame(parent)
    frame:SetLayout("Flow")

    -- MARK: General Profile
    local generalProfileGroup = GUI:CreateInlineGroup(frame, L["Profile"])
    GUI:CreateInformationTag(generalProfileGroup, L["ProfileSettingsDesc"], "LEFT")
    local exportBox = GUI:CreateMultiLineEditBox(nil, L["Export"], addon:ExportProfile(), nil)
    local editBox = GUI:CreateEditBox(generalProfileGroup, L["CurrentProfile"], addon.db["EncounterSound"].ProfileName or "None", function(value)
        addon.db["EncounterSound"].ProfileName = value
        exportBox:SetText(addon:ExportProfile() or "")
    end)
    GUI:CreateButton(generalProfileGroup, L["DataMigration"], function()
        local mod = addon.core:GetModule("EncounterSound")
        if mod then
            mod:DataMigration(true)
        end
    end)
    generalProfileGroup:AddChild(exportBox)
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Import"], "", function(value)
        addon:ImportProfile(value)
        editBox:SetText(addon.db["EncounterSound"].ProfileName or "None")
    end)
    GUI:CreateInformationTag(generalProfileGroup, L["MergeDesc"], "LEFT")
    GUI:CreateMultiLineEditBox(generalProfileGroup, nil, "", function(value)
        addon:MergeProfile(value)
    end)

    return frame
end

-- MARK: Profile Export

---Export all profiles
---@return string|nil export profile string or nil if no profile data
function addon:ExportProfile()
    local profile = addon.db
    if not profile then
        addon.Utilities:print("No profile data to export.")
        return nil
    end

    local profileData = { profile = profile, }

    local serializedData = Serialize:Serialize(profileData)
    local compressedData = Compress:CompressDeflate(serializedData)
    local encodedData = Compress:EncodeForPrint(compressedData)
    return prefix .. encodedData
end

-- MARK: Profile Import

---Import all profiles
---@param data string profile string to import
---@return boolean success if the import was successful
function addon:ImportProfile(data)
    local decodedData = Compress:DecodeForPrint(data:sub(#prefix + 1))
    local decompressedData = Compress:DecompressDeflate(decodedData)
    local success, profileData = Serialize:Deserialize(decompressedData)

    if not success or type(profileData) ~= "table" or data:sub(1, #prefix) ~= prefix then
        addon.Utilities:print("Invalid profile data.")
        return false
    end

    HBLyx_Encounter_Sound_DB = profileData.profile
    addon.db = HBLyx_Encounter_Sound_DB
    addon.Utilities:print(L["ImportSuccess"])

    addon.Utilities:SetPopupDialog(
        "HB_Import_Success",
        L["CurrentProfile"] .. "|cffff0d01" .. (addon.db["EncounterSound"].ProfileName or "Default") .. "|r\n" .. L["ImportSuccess"],
        true
    )

    return true
end

-- MARK: Profile Merge

--- Print a summary of the merge results
---@param countEvents integer total number of events in the new profile
---@param newEventsCount integer number of new events added to the current profile
---@param countPA integer total number of private auras in the new profile
---@param newPAcount integer number of new private auras added to the current profile
local function PrintMergeSummary(countEvents, newEventsCount, countPA, newPAcount)
    local printMsg = string.format(
        L["MergeSummary"] .. ":\n%d " .. L["Events"] .. " (|cff79aa38%d " .. L["New"] .. "|r + |cffffdd99%d " .. L["Overwritten"] .. "|r)\n%d " .. L["PrivateAuras"] .. " (|cff79aa38%d " .. L["New"] .. "|r + |cffffdd99%d " .. L["Overwritten"] .. "|r)",
        countEvents,
        newEventsCount,
        countEvents - newEventsCount,
        countPA,
        newPAcount,
        countPA - newPAcount
    )
    addon.Utilities:print(printMsg)
end

---Normalize private aura trigger list to addon-supported trigger IDs.
---@param triggerData any
---@return table<number> normalizedTriggers
local function NormalizePATriggers(triggerData)
    local normalized = {}
    local seen = {}

    if type(triggerData) == "table" then
        for _, trigger in ipairs(triggerData) do
            local value = tonumber(trigger)
            if value and value >= 0 and value <= 2 and not seen[value] then
                seen[value] = true
                table.insert(normalized, value)
            end
        end
    end

    if #normalized == 0 then
        normalized = { 0 }
    else
        table.sort(normalized)
    end

    return normalized
end

---Normalize one private aura entry to {trigger = {...}, sound = "..."} format.
---@param paEntry any
---@return table|nil
local function NormalizePAEntry(paEntry)
    if type(paEntry) == "string" then
        return { trigger = { 0 }, sound = paEntry }
    end

    if type(paEntry) == "table" and type(paEntry.sound) == "string" then
        return {
            trigger = NormalizePATriggers(paEntry.trigger),
            sound = paEntry.sound,
        }
    end

    return nil
end

---Merge a profile into the current profile
---@param data string profile string to merge
---@return boolean success if the merge was successful
function addon:MergeProfile(data)
    local decodedData = Compress:DecodeForPrint(data:sub(#prefix + 1))
    local decompressedData = Compress:DecompressDeflate(decodedData)
    local success, profileData = Serialize:Deserialize(decompressedData)

    if not success or type(profileData) ~= "table" or data:sub(1, #prefix) ~= prefix then
        addon.Utilities:print("Invalid profile data.")
        return false
    end

    local currentProfile = addon.db["EncounterSound"] or {}
    local newProfile = profileData.profile["EncounterSound"] or {}

    -- Merge the new profile into the current profile
    local countEvents, countPA = 0, 0
    local newEventsCount, newPAcount = 0, 0

    -- handle events
    for encounterID, eventsData in pairs(newProfile.data or {}) do
        for eventID, configData in pairs(eventsData) do
            if not currentProfile.data then currentProfile.data = {} end
            if not currentProfile.data[encounterID] then currentProfile.data[encounterID] = {} end

            if not currentProfile.data[encounterID][eventID] then
                newEventsCount = newEventsCount + 1
            end

            currentProfile.data[encounterID][eventID] = configData
            countEvents = countEvents + 1
        end
    end

    -- handle private auras (new schema: [mapID][spellID] = {trigger = {...}, sound = "..."})
    for mapID, paData in pairs(newProfile.dataPA or {}) do
        if type(paData) == "table" then
            if not currentProfile.dataPA then currentProfile.dataPA = {} end
            if not currentProfile.dataPA[mapID] then currentProfile.dataPA[mapID] = {} end

            for spellID, paEntry in pairs(paData) do
                local normalizedPAEntry = NormalizePAEntry(paEntry)
                if normalizedPAEntry then
                    if not currentProfile.dataPA[mapID][spellID] then
                        newPAcount = newPAcount + 1
                    end

                    currentProfile.dataPA[mapID][spellID] = normalizedPAEntry
                    countPA = countPA + 1
                end
            end
        end
    end

    PrintMergeSummary(countEvents, newEventsCount, countPA, newPAcount)

    addon.db["EncounterSound"] = currentProfile
    addon.Utilities:print(L["MergeSuccess"])

    addon.Utilities:SetPopupDialog(
        "HB_Import_Success",
        "|cffff0d01" .. (newProfile.ProfileName or "Default") .. "|r " .. L["MergedInto"] .. " |cffff0d01" .. (currentProfile.ProfileName or "nil") .. "|r",
        true
    )

    return true
end
