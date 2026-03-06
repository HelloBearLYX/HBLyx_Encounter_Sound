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
    GUI:CreateEditBox(generalProfileGroup, L["CurrentProfile"], addon.db["EncounterSound"].ProfileName or "None", function(value)
        addon.db["EncounterSound"].ProfileName = value
    end)
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Export"], addon:ExportProfile(), nil)
    GUI:CreateMultiLineEditBox(generalProfileGroup, L["Import"], "", function(value)
        addon:ImportProfile(value)
    end)

    return frame
end

-- MARK: Profile Export

---Export all profiles
---@return string|nil export profile string or nil if no profile data
function addon:ExportProfile()
    local profile = addon.db["EncounterSound"]
    if not profile then
        addon.Utilities:print("No profile data to export.")
        return nil
    end

    local profileData = { ["EncounterSound"] = profile, }

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

    addon.db["EncounterSound"] = profileData["EncounterSound"]
    addon.Utilities:print(L["ImportSuccess"])

    addon.Utilities:SetPopupDialog(
        "HB_Import_Success",
        L["CurrentProfile"] .. "|cffff0d01" .. addon.db["EncounterSound"].ProfileName .. "|r\n" .. L["ImportSuccess"],
        true
    )

    return true
end