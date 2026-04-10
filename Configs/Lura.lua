local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "LuraHelper"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	X = 400,
	Y = 0,
	Scale = 1,
	BackgroundOpacity = 0.5,
	FrameStrata = "LOW",
    FadeTime = 15,
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
    GUI:CreateButton(frame, L["Activate"], function ()
        if not addon.core:HasModuleLoaded(MOD_KEY) or InCombatLockdown() then
            return
        end

        local isActive = addon.core:GetModule(MOD_KEY):IsActivate()
        addon.core:GetModule(MOD_KEY):Activate(not isActive)
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
    GUI:CreateSlider(coreSettingsGroup, L["FadeTime"], 3, 30, 1, addon.db.LuraHelper.FadeTime, function(value)
        addon.db.LuraHelper.FadeTime = value
    end)

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
	GUI:CreateSlider(styleGroup, L["BackgroundOpacity"], 0, 1, 0.01, addon.db.LuraHelper.BackgroundOpacity, function(value)
		addon.db.LuraHelper.BackgroundOpacity = value
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