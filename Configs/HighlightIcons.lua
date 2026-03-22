local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "HighlightIcons"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    IconSize = 50,
    TimeFontScale = 1,
    X = 0,
    Y = 290,
    Grow = "UP",
    IconZoom = 0.07,
    FrameStrata = "MEDIUM",
    FontSize = 12,
    Font = "",
    FontYOffset = 0,
	FontXOffset = 0,
    TextGrow = "RIGHT",
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.HighlightIcons = {}
function GUI.TagPanels.HighlightIcons:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateInformationTag(frame, L["HighlightIconsSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["HighlightIconsSettings"] .. "|r", addon.db.HighlightIcons.Enabled, function(value)
		addon.db.HighlightIcons.Enabled = value
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
			"|cffC41E3A" .. L["HighlightIconsSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    -- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.HighlightIcons.FrameStrata, function(value)
		addon.db.HighlightIcons.FrameStrata = value
		update()
	end)
	GUI:CreateDropdown(styleGroup, L["GrowDirection"], addon.Utilities.Grows, nil, addon.db.HighlightIcons.Grow, function(key)
		addon.db.HighlightIcons.Grow = key
		update()
	end)

	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.HighlightIcons.IconSize, function(value)
		addon.db.HighlightIcons.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.HighlightIcons.IconZoom, function(value)
		addon.db.HighlightIcons.IconZoom = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.HighlightIcons.X, function(value)
		addon.db.HighlightIcons.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.HighlightIcons.Y, function(value)
		addon.db.HighlightIcons.Y = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.HighlightIcons.Font, function(value)
		addon.db.HighlightIcons.Font = value
		update()
	end)
	GUI:CreateDropdown(fontGroup, L["TextGrow"], addon.Utilities.Grows, nil, addon.db.HighlightIcons.TextGrow, function(key)
		addon.db.HighlightIcons.TextGrow = key
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.HighlightIcons.FontSize, function(value)
		addon.db.HighlightIcons.FontSize = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontYOffset"], -100, 100, 1, addon.db.HighlightIcons.FontYOffset, function(value)
		addon.db.HighlightIcons.FontYOffset = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontXOffset"], -100, 100, 1, addon.db.HighlightIcons.FontXOffset, function(value)
		addon.db.HighlightIcons.FontXOffset = value
		update()
	end)

	GUI:CreateSlider(fontGroup, L["TimeFontScale"], 0.1, 5, 0.01, addon.db.HighlightIcons.TimeFontScale, function(value)
		addon.db.HighlightIcons.TimeFontScale = value
		update()
	end)

	return frame
end