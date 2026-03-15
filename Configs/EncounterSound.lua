local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)
local GUI = addon.GUI
local MOD_KEY = "EncounterSound"

-- MARK: Defaults
addon.configurationList[MOD_KEY] = {
	Enabled = true,
	SoundChannel = "Master",
	EnablePrivateAuras = true,
	EnableVictorySound = false,
	VictorySound = "",
	EnableStartSound = false,
	StartSound = "",
	ProfileName = "Default",
	HighPerformanceSoundSelect = false,
	data = {}, -- data structure: { [encounterID] = { [eventID] = { [trigger] = {sound = sound, role = {role = true}}, color = color} } }
	dataPA = {}, -- data structure: { [encounterID] = { [spellID] = sound } }
	templates = {}, -- data structure: { [templateName] = { [trigger] = {sound = sound, role = {role = true}}, color = color} } }
}

-- MARK: Constants
local EVENT_TRIGGERS = {
	["0"] = L["OnTextWarningShown"],
	["1"] = L["OnTimelineEventFinished"],
	["2"] = L["OnTimelineEventHighlight"],
}
local TRIGGER_ORDER = {"0", "1", "2"} -- keep a separate order table since the trigger keys are string type

-- MARK: Check data exist

---Check whether encounter sound data exists at selected path.
---@param encounterID integer encounterID
---@param eventID integer|nil eventID
---@param field string|integer|nil field key under event
---@return table|boolean result nested table/value if exists, otherwise false
local function CheckDataExist(encounterID, eventID, field)
	local result = addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] or false
	if result and eventID then
		result = addon.db.EncounterSound.data[encounterID][eventID] or false
	end

	if result and field then
		result = addon.db.EncounterSound.data[encounterID][eventID][field] or false
	end

	return result
end

-- MARK: Add - Sound

---Add Sounds to DB
---@param encounterID integer encounterID
---@param eventID integer eventID
---@param trigger string trigger type, 0 for text warning shown, 1 for timeline event finished, 2 for timeline event highlighted
---@param sound string sound file path or sound kit ID
---@param role table<string, boolean>|nil role table for group roles
local function AddSound(encounterID, eventID, trigger, sound, role)
	if not encounterID or not eventID or not trigger or not sound then
		return
	end

	local isNew = false
	if not addon.db.EncounterSound.data then
		addon.db.EncounterSound.data = {}
	end

	if not addon.db.EncounterSound.data[encounterID] then
		addon.db.EncounterSound.data[encounterID] = {}
	end

	if not addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID] = {}
	end

	isNew = not addon.db.EncounterSound.data[encounterID][eventID][trigger]
	addon.db.EncounterSound.data[encounterID][eventID][trigger] = { sound = sound, role = role and {} or nil}
	if role then -- make a deep copy since other trigger may use the same role table reference
		for role, _ in pairs(role or {}) do
			addon.db.EncounterSound.data[encounterID][eventID][trigger].role[role] = true
		end
	end

	if isNew then
		addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, eventID, sound, L["AddSuccess"]))
	else
		addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, eventID, sound, L["UpdateSuccess"]))
	end
end

-- MARK: Add - Color

---Set color for an encounter event.
---@param encounterID integer encounterID
---@param eventID integer eventID
---@param color string hex color string
local function AddColor(encounterID, eventID, color)
	if not encounterID or not eventID or not color then
		return
	end

	if not addon.db.EncounterSound.data then
		addon.db.EncounterSound.data = {}
	end

	if not addon.db.EncounterSound.data[encounterID] then
		addon.db.EncounterSound.data[encounterID] = {}
	end

	if not addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID] = {}
	end

	addon.db.EncounterSound.data[encounterID][eventID].color = color
end

-- MARK: Add - PA Sound

---Add private aura sound mapping to DB.
---@param encounterID integer encounterID
---@param spellID integer private aura spellID
---@param sound string sound file path or sound kit ID
local function AddPASound(encounterID, spellID, sound)
	if not encounterID or not spellID or not sound then
		return
	end

	if not addon.db.EncounterSound.dataPA then
		addon.db.EncounterSound.dataPA = {}
	end

	if not addon.db.EncounterSound.dataPA[encounterID] then
		addon.db.EncounterSound.dataPA[encounterID] = {}
	end

	addon.db.EncounterSound.dataPA[encounterID][spellID] = sound

	addon.Utilities:print(string.format("%d-%d-%s: %s", encounterID, spellID, sound, L["AddSuccess"]))
end

-- MARK: Add - Template

--- Create a template with name
--- @param templateName string name of the template to be created
--- @param attribute string the setting field to be added to the template, e.g. "0", "color", etc.
--- @param value table|string|integer the setting value to be added to the template, e.g. {sound = "path/to/sound", role = {TANK = true}}, or a hex color string, etc.
local function UpdateTemplate(templateName, attribute, value)
	if not templateName or templateName == "" or attribute == nil then
		addon.Utilities:print("Invalid template name or attribute.")
		return
	end

	if not addon.db.EncounterSound.templates then
		addon.db.EncounterSound.templates = {}
	end

	if not addon.db.EncounterSound.templates[templateName] then
		addon.db.EncounterSound.templates[templateName] = {}
	end

	if attribute == "color" then
		if value == "None" then
			addon.db.EncounterSound.templates[templateName].color = nil
			addon.Utilities:print(string.format("Color removed from template %s", templateName))
		else
			addon.db.EncounterSound.templates[templateName].color = value
			-- no print for color update since the color pick update it too frequently
		end
	else
		addon.db.EncounterSound.templates[templateName][attribute] = value
		addon.Utilities:print(string.format("Template %s updated: trigger %s", templateName, attribute))
	end
end

-- MARK: Apply - Template

---Apply selected template to current selected event
---@param self table encounter sound panel instance
---@param templateName string template name
local function ApplyTemplate(self, templateName)
	if not self.inputEncounter or not self.inputEvent then
		return
	end

	if not addon.db.EncounterSound.templates or not addon.db.EncounterSound.templates[templateName] then
		addon.Utilities:print(string.format("Template %s not found", templateName))
		return
	end

	local template = addon.db.EncounterSound.templates[templateName]
	for attribute, value in pairs(template) do
		if attribute == "color" then
			AddColor(self.inputEncounter, self.inputEvent, value)
			self.eventColor:SetColor(addon.Utilities:HexToRGB(value))
		else
			AddSound(self.inputEncounter, self.inputEvent, attribute, value.sound, value.role)
			self.triggers[attribute].soundDropdown:SetValue(value.sound)
			if value.role then
				self.triggers[attribute].role:SetSelectedKeys(value.role)
			else
				self.triggers[attribute].role:ClearSelections()
			end
		end
	end

	if self.eventColor and CheckDataExist(self.inputEncounter, self.inputEvent, "color") then
		self.eventColor:SetColor(addon.Utilities:HexToRGB(addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent].color))
	end
	if self.triggers then
		for trigger, _ in pairs(EVENT_TRIGGERS) do
			if CheckDataExist(self.inputEncounter, self.inputEvent, trigger) then
				local sound = addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent][trigger].sound
				local role = addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent][trigger].role
				self.triggers[trigger].soundDropdown:SetValue(sound)
				self.triggers[trigger].sound = sound
				if role then
					self.triggers[trigger].role:SetSelectedKeys(role)
				else
					self.triggers[trigger].role:ClearSelections()
				end
			else
				self.triggers[trigger].soundDropdown:SetValue(nil)
				self.triggers[trigger].sound = nil
				self.triggers[trigger].role:ClearSelections()
			end
		end
	end

	addon.Utilities:print(string.format("%s applied to: %d-%d", templateName, self.inputEncounter, self.inputEvent))
end

-- MARK: Remove - Sound

---Remove one trigger sound from DB.
---@param encounterID integer encounterID
---@param eventID integer eventID
---@param trigger integer trigger type
---@return boolean removed true if removed
local function RemoveSound(encounterID, eventID, trigger)
	if not encounterID or not eventID or not trigger then
		return false
	end

	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] and addon.db.EncounterSound.data[encounterID][eventID][trigger] then
		addon.db.EncounterSound.data[encounterID][eventID][trigger] = nil
		if not next(addon.db.EncounterSound.data[encounterID][eventID]) then
			addon.db.EncounterSound.data[encounterID][eventID] = nil
		end
		if not next(addon.db.EncounterSound.data[encounterID]) then
			addon.db.EncounterSound.data[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d: %s", encounterID, eventID, L["RemoveSuccess"]))
		return true
	end

	return false
end

-- MARK: Remove - Color

---Remove event color from DB.
---@param encounterID integer encounterID
---@param eventID integer eventID
---@return boolean removed true if removed
local function RemoveColor(encounterID, eventID)
	if not encounterID or not eventID then
		return false
	end

	if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] and addon.db.EncounterSound.data[encounterID][eventID] then
		addon.db.EncounterSound.data[encounterID][eventID].color = nil
		if not next(addon.db.EncounterSound.data[encounterID][eventID]) then
			addon.db.EncounterSound.data[encounterID][eventID] = nil
		end
		if not next(addon.db.EncounterSound.data[encounterID]) then
			addon.db.EncounterSound.data[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveSuccess"]))
		return true
	else
		addon.Utilities:print(string.format("%d-%d-Color: %s", encounterID, eventID, L["RemoveFailed"]))
		return false
	end
end

-- MARK: Remove - PA Sound

---Remove private aura sound mapping from DB.
---@param encounterID integer encounterID
---@param spellID integer private aura spellID
---@return boolean removed true if removed
local function RemovePASound(encounterID, spellID)
	if not encounterID or not spellID then
		return false
	end

	if addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] and addon.db.EncounterSound.dataPA[encounterID][spellID] then
		addon.db.EncounterSound.dataPA[encounterID][spellID] = nil
		if not next(addon.db.EncounterSound.dataPA[encounterID]) then
			addon.db.EncounterSound.dataPA[encounterID] = nil
		end
		addon.Utilities:print(string.format("%d-%d: %s", encounterID, spellID, L["RemoveSuccess"]))
		return true
	else
		addon.Utilities:print(string.format("%d-%d: %s", encounterID, spellID, L["RemoveFailed"]))
		return false
	end
end

-- MARK: Get Maps List

---Get instance map list filtered by raid or dungeon.
---@param isRaid boolean true to return raid maps, false to return dungeon maps
---@return table<integer, string> output mapID to display name
local function GetMapsList(isRaid)
    local output = {}
    for mapID, mapInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS) do
		local icon = select(6, EJ_GetInstanceInfo(mapID)) or 134400 -- fallback to a default icon
        if mapInfo.name and (isRaid == select(12, EJ_GetInstanceInfo(mapID))) then
            output[mapID] =  "|T" .. icon .. ":0|t " .. mapInfo.name
        end
    end
    return output
end

-- MARK: Get Encounters List
---Get encounter list for one instance map.
---@param mapID integer instance mapID
---@return table<integer, string|integer> output encounterID to encounter name
local function GetEncountersList(mapID)
	local output = {}
	if addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters then
		for encounterID, encounterInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters) do
			output[encounterID] = encounterInfo.journalID and EJ_GetEncounterInfo(encounterInfo.journalID) or encounterID
			if type(output[encounterID]) == "string" then
				output[encounterID] = output[encounterID] .. "(" .. tostring(encounterID) .. ")"
			end
		end
	end

	return output
end

-- MARK: Get Template List

---Get template list
---@return table<integer, string> output templateName to display name
local function GetTemplateList()
	local output = {}
	for templateName, _ in pairs(addon.db.EncounterSound.templates or {}) do
		output[templateName] = templateName
	end

	return output
end

-- MARK: Reset - EE

---Reset event controls and clear current event selection state.
---@param self table encounter sound panel instance
local function ResetEventSettings(self)
	self.eventSelectGroup:ReleaseChildren()
	self.eventDescription:SetText("|T134400:0|t" .. L["SelectAnEvent"])
	self.templateApply:SetValue(nil)
	self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
	for trigger, _ in pairs(EVENT_TRIGGERS) do
		self.triggers[trigger].sound = nil
		self.triggers[trigger].soundDropdown:SetValue(nil)
		self.triggers[trigger].role:ClearSelections()
	end
end

-- MARK: Render - triggers

---Create trigger setting widgets for each event trigger type.
---@param self table encounter sound panel instance
local function SetTriggersSetting(self)
	self.triggers = {}
	for _, trigger in ipairs(TRIGGER_ORDER) do
		local triggerName = EVENT_TRIGGERS[trigger]
		self.triggers[trigger] = GUI:CreateInlineGroup(self.eventSettingsGroup, triggerName)
		self.triggers[trigger].sound = nil
		
		self.triggers[trigger].role = GUI:CreateMultiDropdown(nil, L["SelectGroupRole"], addon.Utilities.GroupRoles, nil, nil)
		self.triggers[trigger].soundDropdown = GUI:CreateSoundSelect(nil, L["SoundSettings"], nil, function(value)
			self.triggers[trigger].sound = value
		end)
		self.triggers[trigger].soundDropdown:SetRelativeWidth(0.5)

		self.triggers[trigger]:AddChild(self.triggers[trigger].role:GetWidget())
		self.triggers[trigger]:AddChild(self.triggers[trigger].soundDropdown)

		-- Add
		GUI:CreateButton(self.triggers[trigger], L["Add"], function()
			AddSound(self.inputEncounter, self.inputEvent, trigger, self.triggers[trigger].sound, self.triggers[trigger].role:GetSelectedKeys())
		end)
		-- Remove
		GUI:CreateButton(self.triggers[trigger], L["Remove"], function()
			if RemoveSound(self.inputEncounter, self.inputEvent, trigger) then
				self.triggers[trigger].sound = nil
				self.triggers[trigger].soundDropdown:SetValue(nil)
				self.triggers[trigger].role:ClearSelections()
			end
		end)
	end
end

-- MARK: Render - general

---Create event color picker and remove button.
---@param self table encounter sound panel instance
local function SetGeneralSettings(self)
	self.templateApply = GUI:CreateDropdown(self.generalGroup, L["ApplyTemplate"], GetTemplateList(), nil, nil, function(key)
		ApplyTemplate(self, key)
	end)

	GUI:CreateInformationTag(self.generalGroup, "\n")

	self.eventColor = GUI:CreateColorPicker(self.generalGroup, L["EventColor"], false, "ffffffff", function(hex)
		AddColor(self.inputEncounter, self.inputEvent, hex)
	end)

	GUI:CreateButton(self.generalGroup, L["Remove"], function()
		if RemoveColor(self.inputEncounter, self.inputEvent) then
			self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
		end
	end)
end

-- MARK: Flag Handlers

local function GetFlagIcon(spellID)
	local output = ""
	for flag, _ in pairs(addon.data.SPELL_INFO[spellID] or {}) do
		output = output .. addon.data.SPELL_FLAGS[flag].flag
	end

	return output
end

local function GetFlagText(spellID)
	local output = ""
	for flag, _ in pairs(addon.data.SPELL_INFO[spellID] or {}) do
		if flag == 3 or flag == 12 then
			output = output .. addon.data.SPELL_FLAGS[flag].text .. ", "
		else
			output = output .. addon.data.SPELL_FLAGS[flag].flag .. addon.data.SPELL_FLAGS[flag].text .. ", "
		end
	end
	output = output:sub(1, -3) -- remove the trailing ", "

	return output
end

-- MARK: Render - EE

---Render event buttons for selected encounter and bind event detail loading.
---@param self table encounter sound panel instance
local function RenderEncounterSettings(self)
	for _, eventID in ipairs(addon.data.MAP_ENCOUNTER_EVENTS[self.inputMap].encounters[self.inputEncounter].events) do
		local encounterSpellID = C_EncounterEvents.GetEventInfo(eventID).spellID
		local name = "UNKNOWN"
		local spell = nil
		local icon = ""
		
		if encounterSpellID then
			spell = Spell:CreateFromSpellID(encounterSpellID)
			icon = ("|T" .. (spell:GetSpellTexture() or 134400) .. ":20:20|t")
			name = spell:GetSpellName()
		end
		
		GUI:CreateButton(self.eventSelectGroup, string.format("%s%s%s", icon, GetFlagIcon(encounterSpellID), name), function()
			self.inputEvent = eventID
			self.templateApply:SetValue(nil)

			if CheckDataExist(self.inputEncounter, self.inputEvent, "color") then
				self.eventColor:SetColor(addon.Utilities:HexToRGB(addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent].color))
			else
				self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
			end

			for trigger, _ in pairs(EVENT_TRIGGERS) do
				if CheckDataExist(self.inputEncounter, self.inputEvent, trigger) then
					local sound = addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent][trigger].sound
					local role = addon.db.EncounterSound.data[self.inputEncounter][self.inputEvent][trigger].role
					self.triggers[trigger].soundDropdown:SetValue(sound)
					self.triggers[trigger].sound = sound
					if role then
						self.triggers[trigger].role:SetSelectedKeys(role)
					else
						self.triggers[trigger].role:ClearSelections()
					end
				else
					self.triggers[trigger].soundDropdown:SetValue(nil)
					self.triggers[trigger].sound = nil
					self.triggers[trigger].role:ClearSelections()
				end
			end

			if spell then
				spell:ContinueOnSpellLoad(function()
					self.eventDescription:SetText(string.format("%s%s: %s", icon, name, GetFlagText(encounterSpellID)) .. "\n" .. (spell:GetSpellDescription() or "UNKNOWN") .. "\n")
					self.frame:DoLayout()
				end)
			end
		end):SetRelativeWidth(0.24)

		self.frame:DoLayout()
	end
end

-- MARK: Reset - PA

---Reset private aura controls and clear current aura selection state.
---@param self table encounter sound panel instance
local function ResetPASettings(self)
	self.PASelectGroup:ReleaseChildren()
	self.PADescription:SetText("|T134400:0|t" .. L["SelectPA"])
	self.inputPA = nil
	self.PASoundDropdown:SetValue(nil)
end

-- MARK: Render - PA

---Create private aura sound setting widgets.
---@param self table encounter sound panel instance
local function SetPASettings(self)
	self.PASoundDropdown = GUI:CreateSoundSelect(self.PASettingsGroup, L["SoundSettings"], nil, function(value)
		if value then
			AddPASound(self.inputEncounter, self.inputPA, value)
		end
	end)
	self.PASoundDropdown:SetRelativeWidth(0.5)
	GUI:CreateButton(self.PASettingsGroup, L["Remove"], function()
		if RemovePASound(self.inputEncounter, self.inputPA) then
			self.PASoundDropdown:SetValue(nil)
		end
	end)
end

---Render private aura buttons for selected encounter.
---@param self table encounter sound panel instance
local function RenderPrivateAuraSettings(self)
	for _, spellID in ipairs(addon.data.MAP_ENCOUNTER_EVENTS[self.inputMap].encounters[self.inputEncounter].privateAuras) do
		local spell = Spell:CreateFromSpellID(spellID) or nil
		local name = "UNKNOWN"
		if spell then
			name = string.format("|T%s:20:20|t %s", spell:GetSpellTexture(), spell:GetSpellName())
		end
		
		GUI:CreateButton(self.PASelectGroup, name, function()
			self.inputPA = spellID

			if addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[self.inputEncounter] and addon.db.EncounterSound.dataPA[self.inputEncounter][self.inputPA] then
				self.PASoundDropdown:SetValue(addon.db.EncounterSound.dataPA[self.inputEncounter][self.inputPA])
			else
				self.PASoundDropdown:SetValue(nil)
			end

			if spell then
				spell:ContinueOnSpellLoad(function()
					self.PADescription:SetText(name.. "\n" .. (spell:GetSpellDescription() or "UNKNOWN") .. "\n")
					self.frame:DoLayout()
				end)
			end
		end):SetRelativeWidth(0.24)
	end
end

-- MARK: Render - Templates

---Create trigger setting widgets for each template trigger type.
---@param self table encounter sound panel instance
local function SetTemplateSettings(self, settingsGroup)
	self.generalGroup = GUI:CreateInlineGroup(settingsGroup, L["ColorSettings"])
	self.eventColor = GUI:CreateColorPicker(self.generalGroup, L["EventColor"], false, "ffffffff", function(hex)
		UpdateTemplate(self.inputTemplate, "color", hex)
	end)
	self.eventColor:SetRelativeWidth(0.24)

	GUI:CreateButton(self.generalGroup, L["Remove"], function()
		UpdateTemplate(self.inputTemplate, "color", "None")
		self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
	end):SetRelativeWidth(0.24)

	self.triggers = {}
	local eventSettingsGroup = GUI:CreateInlineGroup(settingsGroup, "")
	for _, trigger in ipairs(TRIGGER_ORDER) do
		local triggerName = EVENT_TRIGGERS[trigger]
		self.triggers[trigger] = GUI:CreateInlineGroup(eventSettingsGroup, triggerName)
		self.triggers[trigger].sound = nil
		
		self.triggers[trigger].role = GUI:CreateMultiDropdown(nil, L["SelectGroupRole"], addon.Utilities.GroupRoles, nil, nil)
		self.triggers[trigger].soundDropdown = GUI:CreateSoundSelect(nil, L["SoundSettings"], nil, function(value)
			UpdateTemplate(self.inputTemplate, trigger, {sound = value, role = self.triggers[trigger].role:GetSelectedKeys()})
		end)
		self.triggers[trigger].soundDropdown:SetRelativeWidth(0.5)

		self.triggers[trigger]:AddChild(self.triggers[trigger].role:GetWidget())
		self.triggers[trigger]:AddChild(self.triggers[trigger].soundDropdown)
	end
end

-- MARK:  GUI
GUI.TagPanels.EncounterSound = {
	frame = nil,
	inputMap = nil,
	inputEncounter = nil,
	inputEvent = nil,
	inputPA = nil,
}

-- MARK: Create Tab Panel

---Create the Encounter Sound tab panel.
---@param parent table parent GUI container
---@param isRaid boolean true for raid tab, false for dungeon tab
---@return table frame created scroll frame
function GUI.TagPanels.EncounterSound:CreateTabPanel(parent, isRaid)
	self.inputMap = nil
	self.inputEncounter = nil
	self.inputEvent = nil
	self.inputPA = nil
	self.frame = GUI:CreateScrollFrame(parent)
    GUI:CreateInformationTag(self.frame, L["EncounterSoundSettingsDesc"], "LEFT")
	local togglePA = GUI:CreateToggleCheckBox(nil, L["Enable"] .. "|cffffff00" .. L["PrivateAuraSettings"] .. "|r", addon.db.EncounterSound.EnablePrivateAuras, function(value)
		addon.db.EncounterSound.EnablePrivateAuras = value
	end)
	togglePA:SetDisabled(not addon.db.EncounterSound.Enabled)
	GUI:CreateToggleCheckBox(self.frame, L["Enable"] .. "|cff0070DD" .. L["EncounterSoundSettings"] .. "|r", addon.db.EncounterSound.Enabled, function(value)
		addon.db.EncounterSound.Enabled = value
		togglePA:SetDisabled(not value)
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
	self.frame:AddChild(togglePA)
	GUI:CreateDropdown(self.frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.EncounterSound.SoundChannel, function(key)
        addon.db.EncounterSound.SoundChannel = key
    end)
	GUI:CreateButton(self.frame, L["ResetMod"], function ()
		addon.Utilities:SetPopupDialog(
			ADDON_NAME .. "ResetMod",
			"|cffC41E3A" .. L["EncounterSoundSettings"] .. "|r: " .. L["ComfirmResetMod"],
			true,
			{button1 = YES, button2 = NO, OnButton1 = function ()
		    	addon.Utilities:ResetModule(MOD_KEY)
				ReloadUI()
			end}
		)
	end)

    -- MARK: Panel - Settings
	local selectGroup = GUI:CreateInlineGroup(self.frame, L["Select"])
	GUI:CreateInformationTag(selectGroup, L["EncounterSoundInstruction"], "LEFT")
	local settingsGroup = GUI:CreateInlineGroup(nil, L["EncounterSettings"])
	GUI:CreateInformationTag(settingsGroup, L["EncounterEventsInstruction"], "LEFT")
	GUI:CreateButton(settingsGroup, L["TestTimeline"], function()
		if self.inputEncounter then
			addon.core:GetModule(MOD_KEY):TestSound(self.inputEncounter)
		end
	end)

	-- event setting group
	self.eventSelectGroup = GUI:CreateInlineGroup(settingsGroup, L["EncounterEvent"])
	self.eventSettingsGroup = GUI:CreateInlineGroup(settingsGroup, "")
	self.eventDescription = GUI:CreateInformationTag(self.eventSettingsGroup, "|T134400:0|t" .. L["SelectAnEvent"], "LEFT")
	self.generalGroup = GUI:CreateInlineGroup(self.eventSettingsGroup, L["GeneralSettings"])
	SetGeneralSettings(self)
	SetTriggersSetting(self)

	-- PA setting group
	self.PAGroup = GUI:CreateInlineGroup(settingsGroup, L["PrivateAuraSettings"])
	GUI:CreateInformationTag(self.PAGroup, L["PrivateAuraInstruction"], "LEFT")
	self.PASelectGroup = GUI:CreateInlineGroup(self.PAGroup, L["PrivateAura"])
	self.PASettingsGroup = GUI:CreateInlineGroup(self.PAGroup, "")
	self.PADescription = GUI:CreateInformationTag(self.PASettingsGroup, "|T134400:0|t" .. L["SelectPA"], "LEFT")
	SetPASettings(self)
	
	local encounterGroup = 	GUI:CreateDropdown(nil, L["SelectEncounter"], {}, nil, nil, function (value)
		ResetEventSettings(self)
		ResetPASettings(self)

		self.inputEncounter = value
		self.inputEvent = nil
		RenderEncounterSettings(self)

		RenderPrivateAuraSettings(self)

		self.frame:DoLayout()
	end)
	GUI:CreateDropdown(selectGroup, L["SelectInstance"], GetMapsList(isRaid), nil, nil, function (value)
		ResetEventSettings(self)
		ResetPASettings(self)
		
		self.inputMap = value
		self.inputEncounter = nil
		self.inputEvent = nil
		local list = GetEncountersList(value)
		encounterGroup:SetList(list)
		encounterGroup:SetValue(nil)

		self.frame:DoLayout()
	end)
	selectGroup:AddChild(encounterGroup)
	selectGroup:AddChild(settingsGroup)

	return self.frame
end

-- MARK: Panel - General Sound

---Create the general sound settings panel.
---@param parent table parent GUI container
---@return table frame created scroll frame
function GUI.TagPanels.EncounterSound:CreateGeneralPanel(parent)
	local frame = GUI:CreateScrollFrame(parent)

	GUI:CreateToggleCheckBox(frame, L["Enable"] .. " |cffffff00" .. L["VictorySound"] .. "|r", addon.db.EncounterSound.EnableVictorySound, function(value)
		addon.db.EncounterSound.EnableVictorySound = value
	end)
	GUI:CreateSoundSelect(frame, L["VictorySound"], addon.db.EncounterSound.VictorySound, function(value)
		addon.db.EncounterSound.VictorySound = value
	end)
	GUI:CreateInformationTag(frame, "\n")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. " |cffffff00" .. L["StartSound"] .. "|r", addon.db.EncounterSound.EnableStartSound, function(value)
		addon.db.EncounterSound.EnableStartSound = value
	end)
	GUI:CreateSoundSelect(frame, L["StartSound"], addon.db.EncounterSound.StartSound, function(value)
		addon.db.EncounterSound.StartSound = value
	end)
	GUI:CreateInformationTag(frame, "\n" .. L["HighPerformanceSoundDesc"], "LEFT")
	GUI:CreateToggleCheckBox(frame, L["Enable"] .. " |cffffff00" .. L["HighPerformanceSoundSelect"] .. "|r", addon.db.EncounterSound.HighPerformanceSoundSelect, function(value)
		addon.db.EncounterSound.HighPerformanceSoundSelect = value
		addon:ShowDialog(ADDON_NAME.."RLNeeded")
	end):SetRelativeWidth(1)

	return frame
end

-- MARK: Panel - Templates

function GUI.TagPanels.EncounterSound:CreateTemplatePanel(parent)
	self.inputMap = nil
	self.inputEncounter = nil
	self.inputEvent = nil
	self.inputPA = nil
	self.inputTemplate = nil
	local frame = GUI:CreateScrollFrame(parent)
	GUI:CreateInformationTag(frame, L["TemplateDesc"], "LEFT")
	local templateDropdown = GUI:CreateDropdown(nil, L["SelectTemplate"], GetTemplateList(), nil, nil, function(value)
		self.inputTemplate = value

		if self.triggers then
			for trigger, _ in pairs(EVENT_TRIGGERS) do
				self.triggers[trigger].soundDropdown:SetValue(addon.db.EncounterSound.templates[value][trigger] and addon.db.EncounterSound.templates[value][trigger].sound or nil)
				self.triggers[trigger].role:SetSelectedKeys(addon.db.EncounterSound.templates[value][trigger] and addon.db.EncounterSound.templates[value][trigger].role or {})
			end
		end

		if self.eventColor then
			self.eventColor:SetColor(addon.Utilities:HexToRGB(addon.db.EncounterSound.templates[value].color or "ffffffff"))
		end
	end)
	GUI:CreateEditBox(frame, L["TemplateNameNew"], nil, function(text)
		if addon.db.EncounterSound.templates and addon.db.EncounterSound.templates[text] then
			addon.Utilities:print(string.format("Template %s already exists. Please choose another name or delete the existing template first.", text))
			return
		elseif text == "" then
			addon.Utilities:print("Template name cannot be empty.")
			return
		else -- create new template with empty settings
			if not addon.db.EncounterSound.templates then
				addon.db.EncounterSound.templates = {}
			end

			addon.db.EncounterSound.templates[text] = {}
		end
		
		self.inputTemplate = text
		templateDropdown:SetList(GetTemplateList())
		templateDropdown:SetValue(text)
	end)
	GUI:CreateInformationTag(frame, "\n")
	frame:AddChild(templateDropdown)
	GUI:CreateButton(frame, L["Remove"], function()
		if self.inputTemplate and addon.db.EncounterSound.templates and addon.db.EncounterSound.templates[self.inputTemplate] then
			addon.db.EncounterSound.templates[self.inputTemplate] = nil
			self.inputTemplate = nil
			templateDropdown:SetValue(nil)
			templateDropdown:SetList(GetTemplateList())

			if self.triggers then
				for trigger, _ in pairs(EVENT_TRIGGERS) do
					self.triggers[trigger].soundDropdown:SetValue(nil)
					self.triggers[trigger].role:ClearSelections()
				end
			end

			if self.eventColor then
				self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
			end
		end
	end)

	local settingsGroup = GUI:CreateInlineGroup(frame, L["EncounterSettings"])
	SetTemplateSettings(self, settingsGroup)

	return frame
end