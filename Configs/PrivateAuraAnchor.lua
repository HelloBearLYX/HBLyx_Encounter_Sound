local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "PrivateAuraAnchor"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = false,
	MaxAuras = 3,
	X = 175,
	Y = -85,
	IconSize = 45,
	Grow = "RIGHT",
	HideBorder = true,
	ShowCountdownNumbers = true,

    ShowCoTankAuras = true,
    CoTankX = 175,
    CoTankY = -25,
    CoTankIconSize = 45,
    CoTankGrow = "RIGHT",
}

-- MARK: Safe update
local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.PrivateAuraAnchor = {}
function GUI.TagPanels.PrivateAuraAnchor:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["PrivateAuraAnchorSettings"] .. "|r", addon.db.PrivateAuraAnchor.Enabled, function(value)
		addon.db.PrivateAuraAnchor.Enabled = value
		if addon.core:HasModuleLoaded(MOD_KEY) then
			if not value then
				addon:ShowDialog(ADDON_NAME .. "RLNeeded")
			end
		else
			if value then
				addon.core:LoadModule(MOD_KEY)
				addon.core:TestModule(MOD_KEY)
			end
		end
	end)
	GUI:CreateButton(frame, L["ResetMod"], function()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["PrivateAuraAnchorSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function()
				addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateToggleCheckBox(styleGroup, L["ShowCountdownNumbers"], addon.db.PrivateAuraAnchor.ShowCountdownNumbers, function(value)
		addon.db.PrivateAuraAnchor.ShowCountdownNumbers = value
		update()
	end)
    GUI:CreateDropdown(styleGroup, L["Grow"], addon.Utilities.Grows, nil, addon.db.PrivateAuraAnchor.Grow, function(key)
		addon.db.PrivateAuraAnchor.Grow = key
		update()
	end)

	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.PrivateAuraAnchor.IconSize, function(value)
		addon.db.PrivateAuraAnchor.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["MaxAuras"], 1, 5, 1, addon.db.PrivateAuraAnchor.MaxAuras, function(value)
		addon.db.PrivateAuraAnchor.MaxAuras = value
		addon:ShowDialog(ADDON_NAME .. "RLNeeded")
	end)
	GUI:CreateToggleCheckBox(iconGroup, L["HideBorder"], addon.db.PrivateAuraAnchor.HideBorder, function(value)
		addon.db.PrivateAuraAnchor.HideBorder = value
		addon.core:GetModule(MOD_KEY):CreatePrivateAnchors("player")
		addon.core:GetModule(MOD_KEY):CreatePrivateAnchors("co-tank")
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.PrivateAuraAnchor.X, function(value)
		addon.db.PrivateAuraAnchor.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.PrivateAuraAnchor.Y, function(value)
		addon.db.PrivateAuraAnchor.Y = value
		update()
	end)

    local coTankGroup = GUI:CreateInlineGroup(frame, L["CoTankAuras"])
    GUI:CreateToggleCheckBox(coTankGroup, L["ShowCoTankAuras"], addon.db.PrivateAuraAnchor.ShowCoTankAuras, function(value)
        addon.db.PrivateAuraAnchor.ShowCoTankAuras = value
        addon:ShowDialog(ADDON_NAME .. "RLNeeded")
    end)

	local coTankStyleGroup = GUI:CreateInlineGroup(coTankGroup, L["StyleSettings"])
	GUI:CreateDropdown(coTankStyleGroup, L["Grow"], addon.Utilities.Grows, nil, addon.db.PrivateAuraAnchor.CoTankGrow, function(key)
		addon.db.PrivateAuraAnchor.CoTankGrow = key
		update()
	end)

	local coTankIconGroup = GUI:CreateInlineGroup(coTankStyleGroup, L["IconSettings"])
	GUI:CreateSlider(coTankIconGroup, L["IconSize"], 10, 200, 1, addon.db.PrivateAuraAnchor.CoTankIconSize, function(value)
		addon.db.PrivateAuraAnchor.CoTankIconSize = value
		update()
	end)

	local coTankPositionGroup = GUI:CreateInlineGroup(coTankStyleGroup, L["PositionSettings"])
	GUI:CreateSlider(coTankPositionGroup, L["X"], -2000, 2000, 1, addon.db.PrivateAuraAnchor.CoTankX, function(value)
		addon.db.PrivateAuraAnchor.CoTankX = value
		update()
	end)
	GUI:CreateSlider(coTankPositionGroup, L["Y"], -1000, 1000, 1, addon.db.PrivateAuraAnchor.CoTankY, function(value)
		addon.db.PrivateAuraAnchor.CoTankY = value
		update()
	end)

	return frame
end