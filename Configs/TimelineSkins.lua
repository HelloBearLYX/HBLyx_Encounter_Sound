local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "TimelineSkins"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
    ShowOnlyActive = false,
    IconSize = 35,
    TimeFontScale = 1,
    X = -30,
    Y = 290,
    Grow = "LEFT",
    IconZoom = 0.07,
    Length = 400,
    isVertical = false,
    FrameStrata = "BACKGROUND",
    FontSize = 12,
    Font = "",
    BackgroundAlpha = 0.5,
    TickAlpha = 1,
    TextGrow = "UP",
}

-- MARK: Safe update

local function update()
	return addon.core:GetSafeUpdate(MOD_KEY)()
end

-- GUI
GUI.TagPanels.TimelineSkins = {}
function GUI.TagPanels.TimelineSkins:CreateTabPanel(parent)
	-- MARK: General
	local frame = GUI:CreateScrollFrame(parent)
	frame:SetLayout("Flow")
	frame:SetFullWidth(true)

	GUI:CreateInformationTag(frame, L["TimelineSkinsSettingsDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. "|cff0070DD" .. L["TimelineSkinsSettings"] .. "|r", addon.db.TimelineSkins.Enabled, function(value)
		addon.db.TimelineSkins.Enabled = value
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
			"|cffC41E3A" .. L["TimelineSkinsSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

	-- MARK: Style
	local styleGroup = GUI:CreateInlineGroup(frame, L["StyleSettings"])
	GUI:CreateFrameStrataDropdown(styleGroup, addon.db.TimelineSkins.FrameStrata, function(value)
		addon.db.TimelineSkins.FrameStrata = value
		update()
	end)
	GUI:CreateDropdown(styleGroup, L["GrowDirection"], addon.Utilities.Grows, nil, addon.db.TimelineSkins.Grow, function(key)
		addon.db.TimelineSkins.Grow = key
        if key == "UP" or key == "DOWN" then
            addon.db.TimelineSkins.isVertical = true
        else
            addon.db.TimelineSkins.isVertical = false
        end
		update()
	end)
	GUI:CreateDropdown(styleGroup, L["TextGrowDirection"], addon.Utilities.Grows, nil, addon.db.TimelineSkins.TextGrow, function(key)
		addon.db.TimelineSkins.TextGrow = key
		update()
	end)
	GUI:CreateSlider(styleGroup, L["Length"], 10, 2000, 1, addon.db.TimelineSkins.Length, function(value)
		addon.db.TimelineSkins.Length = value
		update()
	end)
	GUI:CreateSlider(styleGroup, L["BackgroundAlpha"], 0, 1, 0.01, addon.db.TimelineSkins.BackgroundAlpha, function(value)
		addon.db.TimelineSkins.BackgroundAlpha = value
		update()
	end)
	GUI:CreateSlider(styleGroup, L["TickAlpha"], 0, 1, 0.01, addon.db.TimelineSkins.TickAlpha, function(value)
		addon.db.TimelineSkins.TickAlpha = value
		update()
	end)

	-- MARK: Icon
	local iconGroup = GUI:CreateInlineGroup(styleGroup, L["IconSettings"])
	GUI:CreateSlider(iconGroup, L["IconSize"], 10, 200, 1, addon.db.TimelineSkins.IconSize, function(value)
		addon.db.TimelineSkins.IconSize = value
		update()
	end)
	GUI:CreateSlider(iconGroup, L["IconZoom"], 0.01, 0.5, 0.01, addon.db.TimelineSkins.IconZoom, function(value)
		addon.db.TimelineSkins.IconZoom = value
		update()
	end)

	-- MARK: Position
	local positionGroup = GUI:CreateInlineGroup(styleGroup, L["PositionSettings"])
	GUI:CreateSlider(positionGroup, L["X"], -2000, 2000, 1, addon.db.TimelineSkins.X, function(value)
		addon.db.TimelineSkins.X = value
		update()
	end)
	GUI:CreateSlider(positionGroup, L["Y"], -1000, 1000, 1, addon.db.TimelineSkins.Y, function(value)
		addon.db.TimelineSkins.Y = value
		update()
	end)

	-- MARK: Font
	local fontGroup = GUI:CreateInlineGroup(styleGroup, L["FontSettings"])
	GUI:CreateFontSelect(fontGroup, L["Font"], addon.db.TimelineSkins.Font, function(value)
		addon.db.TimelineSkins.Font = value
		update()
	end)
	GUI:CreateSlider(fontGroup, L["FontSize"], 6, 40, 1, addon.db.TimelineSkins.FontSize, function(value)
		addon.db.TimelineSkins.FontSize = value
		update()
	end)

	return frame
end