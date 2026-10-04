local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local Serialize = LibStub:GetLibrary("AceSerializer-3.0")
local Compress = LibStub:GetLibrary("LibDeflate")
local prefix = "!HBLyx_Tools_EncounterSound_"


local function RenderPanel(parent)
    local frame = GUI:CreateScrollFrame(parent)

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
            exportBox:SetText(addon:ExportProfile() or "")
        end
    end)
    GUI:CreateLinebreaker(generalProfileGroup)
    generalProfileGroup:AddChild(exportBox)
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Import"], "", function(value)
        if addon:ImportProfile(value) then
            editBox:SetText(addon.db["EncounterSound"].ProfileName or "None")
            exportBox:SetText(addon:ExportProfile() or "")
        end
    end)
    GUI:CreateInformationTag(generalProfileGroup, L["MergeDesc"], "LEFT")
    GUI:CreateMultiLineEditBox(generalProfileGroup, nil, "", function(value)
        if addon:MergeProfile(value) then
            editBox:SetText(addon.db["EncounterSound"].ProfileName or "None")
            exportBox:SetText(addon:ExportProfile() or "")
        end
    end)

    return frame
end

GUI:RegisterModule("Profile", RenderPanel)

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

local function NormalizeTrigger(trigger)
    local value = tonumber(trigger)
    if value and value >= 0 and value <= 2 and value == math.floor(value) then
        return value
    end
    return nil
end

---Normalize current and legacy private aura entries to {[trigger] = sound}.
local function NormalizePAEntry(entry)
    if type(entry) == "string" then
        return { [0] = entry }
    end
    if type(entry) ~= "table" then
        return nil
    end

    local normalized = {}
    if entry.sound ~= nil or entry.trigger ~= nil then
        if type(entry.sound) ~= "string"
            or (entry.trigger ~= nil and type(entry.trigger) ~= "table") then
            return nil
        end
        for _, trigger in ipairs(entry.trigger or {}) do
            local value = NormalizeTrigger(trigger)
            if value == nil then return nil end
            normalized[value] = entry.sound
        end
        if not next(normalized) then normalized[0] = entry.sound end
    else
        for trigger, sound in pairs(entry) do
            local value = NormalizeTrigger(trigger)
            if value == nil or type(sound) ~= "string" then return nil end
            normalized[value] = sound
        end
    end
    return normalized
end

local function NormalizePrivateAuras(data)
    if data == nil then return {} end
    if type(data) ~= "table" then return nil end

    local normalized = {}
    for mapID, auras in pairs(data) do
        if type(mapID) ~= "number" or type(auras) ~= "table" then return nil end
        normalized[mapID] = {}
        for spellID, entry in pairs(auras) do
            if type(spellID) ~= "number" then return nil end
            local aura = NormalizePAEntry(entry)
            if not aura then return nil end
            normalized[mapID][spellID] = aura
        end
    end
    return normalized
end

local function ValidateEncounterProfile(profile)
    if type(profile) ~= "table"
        or (profile.ProfileName ~= nil and type(profile.ProfileName) ~= "string")
        or (profile.version ~= nil and type(profile.version) ~= "string")
        or (profile.data ~= nil and type(profile.data) ~= "table") then
        return false
    end

    for _, events in pairs(profile.data or {}) do
        if type(events) ~= "table" then return false end
        for eventID, event in pairs(events) do
            if type(eventID) ~= "number" or type(event) ~= "table" then return false end
            for trigger, config in pairs(event) do
                if trigger == "color" then
                    if type(config) ~= "string" or #config ~= 8 or not config:match("^%x+$") then
                        return false
                    end
                else
                    if (trigger ~= "0" and trigger ~= "1" and trigger ~= "2")
                        or type(config) ~= "table" or type(config.sound) ~= "string"
                        or (config.role ~= nil and type(config.role) ~= "table") then
                        return false
                    end
                    for role, enabled in pairs(config.role or {}) do
                        if (role ~= "TANK" and role ~= "HEALER" and role ~= "DAMAGER")
                            or type(enabled) ~= "boolean" then
                            return false
                        end
                    end
                end
            end
        end
    end

    local privateAuras = NormalizePrivateAuras(profile.dataPA)
    if not privateAuras then return false end
    profile.dataPA = privateAuras
    return true
end

local function ReadProfile(data)
    local function InvalidProfile()
        addon.Utilities:print("Invalid profile data.")
        return nil
    end

    if type(data) ~= "string" or data:sub(1, #prefix) ~= prefix then
        return InvalidProfile()
    end
    local decodedData = Compress:DecodeForPrint(data:sub(#prefix + 1))
    if not decodedData then return InvalidProfile() end
    local decompressedData = Compress:DecompressDeflate(decodedData)
    if not decompressedData then return InvalidProfile() end
    local success, profileData = Serialize:Deserialize(decompressedData)
    if not success or type(profileData) ~= "table" or type(profileData.profile) ~= "table"
        or not ValidateEncounterProfile(profileData.profile.EncounterSound) then
        return InvalidProfile()
    end

    for mod, defaults in pairs(addon.configurationList) do
        local settings = profileData.profile[mod]
        if settings ~= nil then
            if type(settings) ~= "table" then return InvalidProfile() end
            for key, default in pairs(defaults) do
                if settings[key] ~= nil and type(settings[key]) ~= type(default) then
                    return InvalidProfile()
                end
            end
        end
    end
    return profileData.profile
end

---Import all profiles
---@param data string profile string to import
---@return boolean success if the import was successful
function addon:ImportProfile(data)
    local profile = ReadProfile(data)
    if not profile then return false end

    for mod, defaults in pairs(addon.configurationList) do
        profile[mod] = profile[mod] or {}
        for key, default in pairs(defaults) do
            if profile[mod][key] == nil then
                if type(default) == "table" then
                    profile[mod][key] = {}
                    for field, value in pairs(default) do
                        profile[mod][key][field] = value
                    end
                else
                    profile[mod][key] = default
                end
            end
        end
    end
    profile.Version = addon.version
    profile.EncounterSound.version = addon.version

    HBLyx_Encounter_Sound_DB = profile
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

---Merge a profile into the current profile, using the incoming profile name
---@param data string profile string to merge
---@return boolean success if the merge was successful
function addon:MergeProfile(data)
    local profile = ReadProfile(data)
    if not profile then return false end

    local currentProfile = addon.db["EncounterSound"] or {}
    local newProfile = profile["EncounterSound"]
    local currentProfileName = currentProfile.ProfileName
    local currentPrivateAuras = NormalizePrivateAuras(currentProfile.dataPA)
    if not currentPrivateAuras then
        addon.Utilities:print("Invalid current private aura data. Please check your profile before merging.")
        return false
    end
    currentProfile.dataPA = currentPrivateAuras

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

    -- Each incoming aura replaces the existing spell's trigger mappings.
    for mapID, paData in pairs(newProfile.dataPA) do
        if not currentProfile.dataPA[mapID] then currentProfile.dataPA[mapID] = {} end
        for spellID, paEntry in pairs(paData) do
            if not currentProfile.dataPA[mapID][spellID] then
                newPAcount = newPAcount + 1
            end
            currentProfile.dataPA[mapID][spellID] = paEntry
            countPA = countPA + 1
        end
    end

    PrintMergeSummary(countEvents, newEventsCount, countPA, newPAcount)

    currentProfile.ProfileName = newProfile.ProfileName
    currentProfile.version = addon.version
    addon.db["EncounterSound"] = currentProfile
    addon.Utilities:print(L["MergeSuccess"])

    addon.Utilities:SetPopupDialog(
        "HB_Import_Success",
        "|cffff0d01" .. (newProfile.ProfileName or "Default") .. "|r " .. L["MergedInto"] .. " |cffff0d01" .. (currentProfileName or "nil") .. "|r",
        true
    )

    return true
end
