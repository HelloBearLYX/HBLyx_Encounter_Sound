local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "LuraHelper"
local MOD_LABEL = "LuraHelper"

local RUNE_PREFIX_PATH = "Interface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Lura\\"
local RUNES = {
    CIRCLE = "|T" .. RUNE_PREFIX_PATH .. "rune_circle.png" .. ":20:20|t",
    DIAMOND = "|T" .. RUNE_PREFIX_PATH .. "rune_diamond.png" .. ":20:20|t",
    TRIANGLE = "|T" .. RUNE_PREFIX_PATH .. "rune_triangle.png" .. ":20:20|t",
    T = "|T" .. RUNE_PREFIX_PATH .. "rune_t.png" .. ":20:20|t",
    X = "|T" .. RUNE_PREFIX_PATH .. "rune_x.png" .. ":20:20|t",
}

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	X = 255,
	Y = 115,
	Scale = 1,
	FrameStrata = "LOW",
    ChatChannel = "SAY",
    AssisstantToBroadcast = true,

    -- Runes
    Rune_CIRCLE = L["CIRCLE"],
    Rune_DIAMOND = L["DIAMOND"],
    Rune_TRIANGLE = L["TRIANGLE"],
    Rune_T = L["T"],
    Rune_X = L["X"],
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.LuraHelper = {}
function GUI.TagPanels.LuraHelper:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

    GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["LuraHelperSettings"] .. "|r", addon.db.LuraHelper.Enabled, function(value)
		addon.db.LuraHelper.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then -- if module is loaded
            if not value then -- user try to disable the module
                addon:ShowDialog(ADDON_NAME.."RLNeeded")
            end
        else -- if the module is not loaded yet
            if value then -- user try to enable the module, just load it without asking for reload, since it will be loaded immediately
                addon.core:LoadModule(MOD_KEY)
                addon.core:TestModule(MOD_KEY) -- the test mode will be on if the addon is in test mode
            end
        end
	end)
    GUI:CreateButton(frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. "LuraHelperSettings" .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    local coreSettingsGroup = GUI:CreateInlineGroup(frame, L["CoreSettings"])
    GUI:CreateInformationTag(coreSettingsGroup, L["LuraHelperInstruction"], "LEFT")
    GUI:CreateDropdown(coreSettingsGroup, L["BroadcastChannel"], addon.Utilities.ChatChannels, nil, addon.db.LuraHelper.ChatChannel, function(value)
        addon.db.LuraHelper.ChatChannel = value
    end)
    local authorizedBroadcastCheckBox = GUI:CreateToggleCheckBox(coreSettingsGroup, L["AssisstantToBroadcast"], addon.db.LuraHelper.AssisstantToBroadcast, function(value)
        addon.db.LuraHelper.AssisstantToBroadcast = value
    end)
    authorizedBroadcastCheckBox:SetCallback("OnEnter", function()
        GameTooltip:SetOwner(authorizedBroadcastCheckBox.frame, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["AssisstantToBroadcastDesc"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    authorizedBroadcastCheckBox:SetCallback("OnLeave", function()
        GameTooltip:Hide()
    end)
    GUI:CreateInformationTag(coreSettingsGroup, "\n")
    local selectedRune = nil
    local runeNameEditBox = GUI:CreateEditBox(nil, L["RuneName"], nil, function(value)
        if selectedRune then
            addon.db.LuraHelper["Rune_" .. selectedRune] = value
        end
    end)
    GUI:CreateDropdown(coreSettingsGroup, L["SelectRune"], RUNES, nil, nil, function(value)
        selectedRune = value
        runeNameEditBox:SetText(addon.db.LuraHelper["Rune_" .. value] or "")
    end)
    coreSettingsGroup:AddChild(runeNameEditBox)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.LuraHelper.FrameStrata, function(value)
		addon.db.LuraHelper.FrameStrata = value
		update()
	end)
    GUI:CreateDropdown()
	GUI:CreateSlider(styleGroup, L["Scale"], 0.5, 3, 0.01, addon.db.LuraHelper.Scale, function(value)
		addon.db.LuraHelper.Scale = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.LuraHelper.X, function(value)
		addon.db.LuraHelper.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.LuraHelper.Y, function(value)
		addon.db.LuraHelper.Y = value
		update()
	end)

	return frame
end