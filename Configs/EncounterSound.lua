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
	HideEncounterPrint = true,
	data = {}, -- data structure: { [encounterID] = { [eventID] = { [trigger] = {sound = sound, role = {role = true}}, color = color} } }
	dataPA = {}, -- data structure: { [mapID] = { [spellID] = { [trigger] = sound, ... } } }, trigger is 0-2, each trigger has its own independent sound
}

-- MARK: Constants
local EVENT_TRIGGERS = {
	["0"] = L["OnTextWarningShown"],
	["1"] = L["OnTimelineEventFinished"],
	["2"] = L["OnTimelineEventHighlight"],
}
local TRIGGER_ORDER = {"0", "1", "2"} -- keep a separate order table since the trigger keys are string type
local PATriggers = {
	[1] = L["AuraSoundTrigger0"],
	[2] = L["AuraSoundTrigger1"],
	[3] = L["AuraSoundTrigger2"],
}

local function GetSelectedEncounterData(mapID, encounterID)
	if not mapID or not encounterID then
		return nil
	end

	local mapData = addon.data.MAP_ENCOUNTER_EVENTS[mapID]
	if not mapData or not mapData.encounters then
		return nil
	end

	return mapData.encounters[encounterID]
end

local function GetPrivateAuraSourceData(mapID, encounterID)
	local encounterData = GetSelectedEncounterData(mapID, encounterID)
	if encounterData and type(encounterData.privateAuras) == "table" then
		return encounterData
	end

	return nil
end

-- MARK: Get Trigger Desc

---Get trigger description for current trigger type
---@param trigger string trigger type
---@return string trigger description
local function GetTriggerDesc(trigger)
	if trigger == "0" then
		return L["OnTextWarningShownDesc"]
	elseif trigger == "1" then
		return L["OnTimelineEventFinishedDesc"]
	elseif trigger == "2" then
		return L["OnTimelineEventHighlightDesc"]
	else
		return ""
	end
end

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

-- MARK: IO Print

--- Get display label for the sound/event based on its ID and type (event or private aura)
--- @param trigger string|nil trigger type for event sound, nil for private aura sound
--- @param ID integer eventID for event or spellID for private aura
--- @return string display label with icon and name
local function GetIOLabel(trigger, ID)
	local info, output
	if trigger then
		local encounterSpellID = C_EncounterEvents.GetEventInfo(ID).spellID
		info = C_Spell.GetSpellInfo(encounterSpellID or 134400)
		local triggerLabel = EVENT_TRIGGERS[trigger] or trigger
		local name = encounterSpellID and string.format("%s(%d)", info.name, encounterSpellID) or info.name
		output = string.format((trigger ~= "" and "%s%s-%s" or "%s%s%s"), "|T" .. (info.iconID or "") .. ":0|t", name, triggerLabel)
	else
		info = C_Spell.GetSpellInfo(ID or 134400)
		local name = ID and string.format("%s(%d)", info.name, ID) or info.name
		output = string.format("%s%s", "|T" .. (info.iconID or "") .. ":0|t", name)
	end

	return output
end

---Print whether the I/O operation is successful
---@param isSuccess boolean true if the operation is successful, otherwise false
---@param isAdd boolean true for add/update operation, false for remove operation
---@param trigger string|nil trigger type for event sound, nil for private aura sound
---@param ID number eventID for events or spellID for private auras
---@param isUpdate boolean|nil true when add operation is actually an update
local function PrintIOResult(isSuccess, isAdd, trigger, ID, isUpdate)
	local label = GetIOLabel(trigger, ID)
	if isSuccess then
		if isAdd and isUpdate then
			addon.Utilities:print(string.format("%s: %s", label, L["UpdateSuccess"]))
		else
			addon.Utilities:print(string.format("%s: %s", label, isAdd and L["AddSuccess"] or L["RemoveSuccess"]))
		end
	else
		addon.Utilities:print(string.format("%s: %s", label, isAdd and L["AddFailed"] or L["RemoveFailed"]))
	end
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

	PrintIOResult(true, true, trigger, eventID, not isNew)
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

---Add a private aura sound mapping to DB for a single trigger, each trigger keeps its own sound.
---@param mapID integer instance mapID
---@param spellID integer private aura spellID
---@param trigger integer trigger index, 0-2
---@param sound string sound file path or sound kit ID
local function AddPASound(mapID, spellID, trigger, sound)
	if not mapID or not spellID or not trigger or not sound then
		return
	end

	if not addon.db.EncounterSound.dataPA then
		addon.db.EncounterSound.dataPA = {}
	end
	if not addon.db.EncounterSound.dataPA[mapID] then
		addon.db.EncounterSound.dataPA[mapID] = {}
	end
	if not addon.db.EncounterSound.dataPA[mapID][spellID] then
		addon.db.EncounterSound.dataPA[mapID][spellID] = {}
	end

	local isNew = addon.db.EncounterSound.dataPA[mapID][spellID][trigger] == nil
	addon.db.EncounterSound.dataPA[mapID][spellID][trigger] = sound

	PrintIOResult(true, true, nil, spellID, not isNew)
end

-- MARK: Remove - Sound

---Remove one trigger sound from DB.
---@param encounterID integer encounterID
---@param eventID integer eventID
---@param trigger string trigger type
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

		PrintIOResult(true, false, trigger, eventID)
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

		PrintIOResult(true, false, "color", eventID)
		return true
	else
		PrintIOResult(false, false, "color", eventID)
		return false
	end
end

-- MARK: Remove - PA Sound

---Remove a single trigger's sound mapping from DB.
---@param mapID integer instance mapID
---@param spellID integer private aura spellID
---@param trigger integer trigger index, 0-2
---@return boolean removed true if removed
local function RemovePASound(mapID, spellID, trigger)
	if not mapID or not spellID or not trigger then
		return false
	end

	local auraData = addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[mapID] and addon.db.EncounterSound.dataPA[mapID][spellID]
	if not auraData or auraData[trigger] == nil then
		PrintIOResult(false, false, nil, spellID)
		return false
	end

	auraData[trigger] = nil
	if not next(auraData) then
		addon.db.EncounterSound.dataPA[mapID][spellID] = nil
		if not next(addon.db.EncounterSound.dataPA[mapID]) then
			addon.db.EncounterSound.dataPA[mapID] = nil
		end
	end

	PrintIOResult(true, false, nil, spellID)
	return true
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
---@return table<string|integer, string> output encounterID to encounter name
---@return table order encounterIDs sorted by their configured order field
local function GetEncountersList(mapID)
	local output = {}
	local order = {}
	if addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters then
		for encounterID, encounterInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters) do
			if encounterID == "trash" then
				output[encounterID] = L["EncounterTrash"]
			elseif encounterID == "aura" then
				output[encounterID] = L["EncounterTrash"]
			elseif type(encounterInfo.journalID) == "number" and encounterInfo.journalID > 0 then
				local encounterName = EJ_GetEncounterInfo(encounterInfo.journalID)
				if type(encounterName) == "string" and encounterName ~= "" then
					output[encounterID] = encounterName .. "(" .. tostring(encounterID) .. ")"
				else
					output[encounterID] = tostring(encounterID)
				end
			else
				output[encounterID] = tostring(encounterID)
			end
			table.insert(order, encounterID)
		end

		table.sort(order, function(a, b)
			local orderA = addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[a].order or math.huge
			local orderB = addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[b].order or math.huge
			if orderA == orderB then
				return tostring(a) < tostring(b)
			end
			return orderA < orderB
		end)
	end

	return output, order
end

-- MARK: Flag Handlers

local function GetFlagIcon(spellID)
	local output = ""
	for flag, _ in pairs(addon.data.SPELL_INFO[spellID] or {}) do
		output = output .. addon.data.SPELL_FLAGS[flag].flag
	end

	return output
end

-- MARK: Get Encounter Events List

---Build the event dropdown list for the selected encounter.
---@param mapID integer instance mapID
---@param encounterID integer|string|nil encounterID
---@return table<integer, string> list eventID to display label
---@return table order eventIDs in their original event order
local function GetEncounterEventsList(mapID, encounterID)
	local encounterData = GetSelectedEncounterData(mapID, encounterID)
	local list, order = {}, {}
	if encounterData and type(encounterData.events) == "table" then
		for _, eventID in ipairs(encounterData.events) do
			local encounterSpellID = C_EncounterEvents.GetEventInfo(eventID).spellID
			local info = C_Spell.GetSpellInfo(encounterSpellID or 134400)
			local name = encounterSpellID and string.format("%s(%d)", info.name, encounterSpellID) or info.name
			list[eventID] = string.format("%s%s%s", "|T" .. (info.iconID or "") .. ":0|t", GetFlagIcon(encounterSpellID), name)
			table.insert(order, eventID)
		end
	end

	return list, order
end

-- MARK: Get Private Aura Items List

---Build the private aura dropdown list for the selected encounter.
---@param mapID integer instance mapID
---@param encounterID integer|string|nil encounterID
---@return table<integer, string> list displayID to display label
---@return table order displayIDs in their original order
---@return table<integer, integer|table> entries displayID to the original privateAuras entry (may be a table of equivalent spellIDs)
local function GetPrivateAuraItemsList(mapID, encounterID)
	local encounterData = GetPrivateAuraSourceData(mapID, encounterID)
	local list, order, entries = {}, {}, {}
	if encounterData and type(encounterData.privateAuras) == "table" then
		for _, spellID in ipairs(encounterData.privateAuras) do
			-- some private auras share the same name and description but different id, so only display one
			local displayID = type(spellID) == "table" and spellID[1] or spellID
			local info = C_Spell.GetSpellInfo(displayID)
			list[displayID] = string.format("|T%s:0|t %s(%d)", info.iconID or 134400, info.name or "UNKNOWN", displayID)
			table.insert(order, displayID)
			entries[displayID] = spellID
		end
	end

	return list, order, entries
end

---Update every trigger/color widget to reflect the selected event, or clear them when nil.
---@param self table encounter sound panel instance
---@param eventID integer|nil
local function SelectEvent(self, eventID)
	self.inputEvent = eventID

	if not eventID or not CheckDataExist(self.inputEncounter, eventID, "color") then
		self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
	else
		self.eventColor:SetColor(addon.Utilities:HexToRGB(addon.db.EncounterSound.data[self.inputEncounter][eventID].color))
	end

	for trigger, _ in pairs(EVENT_TRIGGERS) do
		if eventID and CheckDataExist(self.inputEncounter, eventID, trigger) then
			local sound = addon.db.EncounterSound.data[self.inputEncounter][eventID][trigger].sound
			local role = addon.db.EncounterSound.data[self.inputEncounter][eventID][trigger].role
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

-- MARK: Render - triggers

---Create trigger setting widgets for each event trigger type, built once and reused.
---@param self table encounter sound panel instance
---@param parent table the container the trigger groups attach to
local function SetTriggersSetting(self, parent)
	self.triggers = {}
	for _, trigger in ipairs(TRIGGER_ORDER) do
		local triggerName = EVENT_TRIGGERS[trigger] .. GetTriggerDesc(trigger)
		local triggerGroup = GUI:CreateInlineGroup(parent, triggerName)
		self.triggers[trigger] = { sound = nil }

		self.triggers[trigger].role = GUI:CreateMultiDropdown(triggerGroup, L["SelectGroupRole"], addon.Utilities.GroupRoles, nil, nil)
		self.triggers[trigger].soundDropdown = GUI:CreateSoundSelect(triggerGroup, L["SoundSettings"], nil, function(value)
			self.triggers[trigger].sound = value
		end)
		GUI:CreateLinebreaker(triggerGroup)
		-- Add
		GUI:CreateButton(triggerGroup, L["Add"], function()
			AddSound(self.inputEncounter, self.inputEvent, trigger, self.triggers[trigger].sound, self.triggers[trigger].role:GetSelectedKeys())
		end)
		-- Remove
		GUI:CreateButton(triggerGroup, L["Remove"], function()
			if RemoveSound(self.inputEncounter, self.inputEvent, trigger) then
				self.triggers[trigger].sound = nil
				self.triggers[trigger].soundDropdown:SetValue(nil)
				self.triggers[trigger].role:ClearSelections()
			end
		end)
	end
end

-- MARK: Render - general

---Create event color picker and remove button, built once and reused.
---@param self table encounter sound panel instance
---@param parent table the container the widgets attach to
local function SetGeneralSettings(self, parent)
	self.eventColor = GUI:CreateColorPicker(parent, L["EventColor"], false, "ffffffff", function(hex)
		AddColor(self.inputEncounter, self.inputEvent, hex)
	end)
	GUI:CreateLinebreaker(parent)
	GUI:CreateButton(parent, L["Remove"], function()
		if RemoveColor(self.inputEncounter, self.inputEvent) then
			self.eventColor:SetColor(addon.Utilities:HexToRGB("ffffffff"))
		end
	end)
end

---Update every private aura widget to reflect the selected entry, or clear them when nil.
---@param self table encounter sound panel instance
---@param key integer|nil the selected displayID
local function SelectPA(self, key)
	self.inputPAKey = key
	self.inputPA = key and self.paEntriesByKey[key] or nil

	self.PATriggerDropdown:SetValue(nil)
	self.PASoundDropdown:SetValue(nil)
end

---Update the sound dropdown to reflect the sound stored for the selected aura and trigger.
---@param self table encounter sound panel instance
---@param triggerKey integer|nil the selected 1-based PATriggers key
local function SelectPATrigger(self, triggerKey)
	local sound = nil
	if self.inputPAKey and triggerKey then
		local mapData = addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[self.inputMap]
		local auraData = mapData and mapData[self.inputPAKey]
		sound = auraData and auraData[triggerKey - 1]
	end
	self.PASoundDropdown:SetValue(sound)
end

-- MARK: Render - PA

---Create private aura sound setting widgets, built once and reused.
---@param self table encounter sound panel instance
---@param parent table the container the widgets attach to
local function SetPASettings(self, parent)
	-- each aura can have up to 3 triggers, each keeping its own independent sound
	self.PATriggerDropdown = GUI:CreateDropdown(parent, L["AuraSoundTriggers"], PATriggers, nil, nil, function(value)
		SelectPATrigger(self, value)
	end)
	self.PASoundDropdown = GUI:CreateSoundSelect(parent, L["SoundSettings"], nil, function() end)
	GUI:CreateLinebreaker(parent)
	GUI:CreateButton(parent, L["Add"], function()
		local triggerKey = self.PATriggerDropdown:GetValue()
		local sound = self.PASoundDropdown:GetValue()
		if self.inputPA and triggerKey and sound then
			local trigger = triggerKey - 1
			if type(self.inputPA) == "table" then
				for _, spellID in ipairs(self.inputPA) do
					AddPASound(self.inputMap, spellID, trigger, sound)
				end
			else
				AddPASound(self.inputMap, self.inputPA, trigger, sound)
			end
		end
	end)
	GUI:CreateButton(parent, L["Remove"], function()
		local triggerKey = self.PATriggerDropdown:GetValue()
		if not triggerKey then
			return
		end

		local trigger = triggerKey - 1
		local result
		if type(self.inputPA) == "table" then
			result = true
			for _, spellID in ipairs(self.inputPA) do
				if not RemovePASound(self.inputMap, spellID, trigger) then
					result = false
				end
			end
		else
			result = RemovePASound(self.inputMap, self.inputPA, trigger)
		end

		if result then
			self.PASoundDropdown:SetValue(nil)
		end
	end)
end

---Refresh the event/private-aura dropdown lists for the selected encounter and clear their selection.
---@param self table encounter sound panel instance
local function RefreshEncounterSelection(self)
	local eventList, eventOrder = GetEncounterEventsList(self.inputMap, self.inputEncounter)
	self.eventSelectDropdown:SetList(eventList, eventOrder)
	self.eventSelectDropdown:SetValue(nil)
	SelectEvent(self, nil)

	local paList, paOrder, paEntries = GetPrivateAuraItemsList(self.inputMap, self.inputEncounter)
	self.paEntriesByKey = paEntries
	self.paSelectDropdown:SetList(paList, paOrder)
	self.paSelectDropdown:SetValue(nil)
	SelectPA(self, nil)
end

-- MARK:  GUI
GUI.TagPanels.EncounterSound = {
	frame = nil,
	inputMap = nil,
	inputEncounter = nil,
	inputEvent = nil,
	inputPA = nil,
	inputPAKey = nil,
	paEntriesByKey = {},
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
	self.inputPAKey = nil
	self.paEntriesByKey = {}
	self.frame = GUI:CreateScrollFrame(parent)
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
	GUI:CreateLinebreaker(self.frame)
	GUI:CreateDropdown(self.frame, L["SoundChannelSettings"], addon.Utilities.SoundChannels, nil, addon.db.EncounterSound.SoundChannel, function(key)
        addon.db.EncounterSound.SoundChannel = key
    end)

    -- MARK: Panel - Select
	local selectGroup = GUI:CreateInlineGroup(self.frame, L["Select"])
	GUI:CreateInformationTag(selectGroup, L["EncounterSoundInstruction"], "LEFT")

	local encounterDropdown = GUI:CreateDropdown(nil, L["SelectEncounter"], {}, nil, nil, function(value)
		self.inputEncounter = value
		RefreshEncounterSelection(self)
	end)
	GUI:CreateDropdown(selectGroup, L["SelectInstance"], GetMapsList(isRaid), nil, nil, function(value)
		self.inputMap = value
		self.inputEncounter = nil
		local list, order = GetEncountersList(value)
		encounterDropdown:SetList(list, order)
		encounterDropdown:SetValue(nil)
		RefreshEncounterSelection(self)
	end)
	selectGroup:AddChild(encounterDropdown)
	GUI:CreateLinebreaker(selectGroup)
	GUI:CreateButton(selectGroup, L["TestTimeline"], function()
		if type(self.inputEncounter) == "number" then
			addon.core:GetModule(MOD_KEY):TestSound(self.inputEncounter)
		end
	end)

	-- MARK: Panel - Event settings, widgets are built once and refreshed in place
	local generalGroup = GUI:CreateInlineGroup(self.frame, L["GeneralSettings"])
	GUI:CreateInformationTag(generalGroup, L["EncounterEventsInstruction"], "LEFT")
	self.eventSelectDropdown = GUI:CreateDropdown(generalGroup, L["EncounterEvent"], {}, nil, nil, function(value)
		SelectEvent(self, value)
	end)
	SetGeneralSettings(self, generalGroup)

	local eventSettingsGroup = GUI:CreateInlineGroup(self.frame, "")
	SetTriggersSetting(self, eventSettingsGroup)

	-- MARK: Panel - Private aura settings, widgets are built once and refreshed in place
	local paGroup = GUI:CreateInlineGroup(self.frame, L["PrivateAuraSettings"])
	GUI:CreateInformationTag(paGroup, L["PrivateAuraInstruction"], "LEFT")
	self.paSelectDropdown = GUI:CreateDropdown(paGroup, L["PrivateAura"], {}, nil, nil, function(value)
		SelectPA(self, value)
	end)
	SetPASettings(self, paGroup)

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
	GUI:CreateInformationTag(frame, "\n")
	GUI:CreateToggleCheckBox(frame, L["HideEncounterPrint"], addon.db.EncounterSound.HideEncounterPrint, function(value)
		addon.db.EncounterSound.HideEncounterPrint = value
	end)

	return frame
end