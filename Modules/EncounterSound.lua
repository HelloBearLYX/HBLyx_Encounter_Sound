local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class EncounterSound
local EncounterSound = {
    modName = "EncounterSound",
}

-- MARK: Constants

local AURA_ENCOUNTER_KEY = "trash"
local LEGACY_AURA_ENCOUNTER_KEY = "aura"

-- MARK: Data Migration

--- used to make data migration, may change due to different patch changes
local function DataMigrationHelper()
    addon.db.EncounterSound.dataPA = addon.db.EncounterSound.dataPA or {}
    -- 3.21.0 data migration

    -- make all the dataPA to [mapID] = {[spellID] = {trigger = {triggers}, sound = soundName}} format, and replaced the old [mapID] = {[spellID] = soundName} format
    -- also since old data has no trigger, add the default trigger 0 for all the old data
    for mapID, spellData in pairs(addon.db.EncounterSound.dataPA) do
        if type(spellData) == "table" then
            for spellID, soundName in pairs(spellData) do
                if type(soundName) == "string" then
                    addon.db.EncounterSound.dataPA[mapID][spellID] = {trigger = {0}, sound = soundName} -- convert to new format
                elseif type(soundName) == "table" and soundName.sound then
                    addon.db.EncounterSound.dataPA[mapID][spellID] = {trigger = {0}, sound = soundName.sound} -- convert to new format
                end
            end
        end
    end

    -- update version after migration
    addon.db.EncounterSound.version = addon.version -- update version after migration
end

--- used to apply the data migration if needed, and update the version after change the data migration
local function DataMigration(force)
    if force or not addon.db.EncounterSound.version or addon.Utilities:CheckVersion(addon.db.EncounterSound.version, "3.21.0") then
        if pcall(DataMigrationHelper) then
            -- addon.db.EncounterSound.version = addon.version .. ".2" -- update version after migration
            addon.Utilities:print(L["DataMigration"] .. " |cffff0000succeeded|r: |cffffff00" .. addon.db.EncounterSound.version .. "|r")
        else
            addon.Utilities:print(L["DataMigration"] .. " |cffff0000failed|r: |cffffff00" .. addon.db.EncounterSound.version .. "|r. You may re-try data migration with reload or you can contact author to report this.")
        end
    end
end

-- MARK: Initialize

---Initialize (Constructor)
---@return EncounterSound EncounterSound a EncounterSound object
function EncounterSound:Initialize()
    self.privateAuras = {}
    self.pendingPrivateAuraClear = false
    self.role = nil
    self.lastEncounterID = nil
    self.lastInstanceID = nil
    self.eventFrame = CreateFrame("Frame", self.modName .. "EventFrame", UIParent)

    -- force enable encounter timeline to make sure the events can be triggered correctly
    SetCVar("encounterTimelineEnabled", "1")

    -- 3.14.1 data change migration
    DataMigration()

    return self
end

-- MARK: Check Role

---Check whether the role condition is satisfied
---@param self EncounterSound self
---@param eventRole table|nil the role requirement for the event, can be nil for no role requirement
---@return boolean true if the role condition is satisfied, false otherwise
local function CheckRole(self, eventRole)
    if not eventRole or not self.role then
        return true
    end

    -- eventRole is a hash set, e.g. {TANK = true, HEALER = true}
    return eventRole[self.role] or false
end

-- MARK: Load Event Sounds

---Load event sounds for the given encounter ID
---@param encounterID integer the encounter ID to load sounds for
local function LoadEventSounds(self, encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        local encounterData = addon.db.EncounterSound.data[encounterID]
        for eventID, eventData in pairs(encounterData) do
            for attribute, value in pairs(eventData) do
                if attribute == "color" then
                    -- Handle color
                    local colorObj = CreateColorFromHexString(value)
                    -- 12.07 added some meaningless parameter trigger at 2nd position
                    -- so, just add all triggers with the color 
                    for t = 0, 2 do
                        local result = pcall(C_EncounterEvents.SetEventColor, eventID, t, colorObj)
                        -- if not result then
                        --     addon:debug("Failed to set color for eventID " .. eventID .. " trigger " .. t)
                        --     addon:debug("Color value was: " .. value .. "colorObj was: " .. colorObj:GenerateHexColor())
                        -- end
                    end
                else
                    if CheckRole(self, value.role) then -- handle role, role can be nil
                        -- Handle sound trigger
                        local sound = addon.LSM:Fetch("sound", value.sound)
                        local trigger = tonumber(attribute)
                        if sound and trigger then
                            C_EncounterEvents.SetEventSound(
                                eventID,
                                trigger,
                                {file = sound, channel = addon.db.EncounterSound.SoundChannel or "Master", volume = 1}
                            )
                        end
                    end
                end
            end
        end

        if not addon.db.EncounterSound.HideEncounterPrint then
            addon.Utilities:print(L["EncounterSoundSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
        end
    end
end

-- MARK: Clear Event Sounds

local function ClearEventSounds(self, encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        local encounterData = addon.db.EncounterSound.data[encounterID]
        for eventID, eventData in pairs(encounterData) do
            -- do not reset color yet(still considering)
            -- C_EncounterEvents.SetEventColor(eventID, CreateColor(1, 1, 1, 1)) -- reset to white
            for attribute, value in pairs(eventData) do
                if attribute ~= "color" then
                    local trigger = tonumber(attribute)
                    if trigger then
                        C_EncounterEvents.SetEventSound(eventID, trigger, nil) -- clear sound
                    end
                end
            end
        end

        if not addon.db.EncounterSound.HideEncounterPrint then
            addon.Utilities:print(L["ClearEventSound"] .. "|cffffff00" .. self.lastEncounterID .. "|r")
        end
    end
end

-- MARK: Load PA Sounds

---Load private aura sounds for the given map ID
---@param self EncounterSound self
---@param mapID integer the map ID to load private aura sounds for
local function LoadPrivateAuraSounds(self, mapID)
    if addon.db.EncounterSound.EnablePrivateAuras and addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[mapID] then
        local privateAuraData = addon.db.EncounterSound.dataPA[mapID]
        for spellID, soundData in pairs(privateAuraData) do
            local sound = addon.LSM:Fetch("sound", soundData.sound)
            if sound and not InCombatLockdown() then
                -- 07/21 API change C_UnitAuras.AddAuraAppliedSound to AddAuraSound with triggers
                -- local pa = C_UnitAuras.AddAuraAppliedSound({
                --     spellID = spellID,
                --     unitToken = "player",
                --     soundFileName = sound,
                --     outputChannel = addon.db.EncounterSound.SoundChannel or "Master",
                -- })
                local soundInfo = {
                    spellID = spellID,
                    unitToken = "player",
                    soundFileName = sound,
                    outputChannel = addon.db.EncounterSound.SoundChannel or "Master",
                }
                -- register for all triggers with the sound
                for attribute, _ in pairs(privateAuraData[spellID]) do
                    if attribute == "trigger" then
                        for _, trigger in ipairs(privateAuraData[spellID].trigger) do
                            if trigger and sound then
                                soundInfo.soundFileName = sound
                                local pa = C_UnitAuras.AddAuraSound(trigger, soundInfo)
                                table.insert(self.privateAuras, pa)
                            end
                        end
                    end
                end
            end
        end

        if not addon.db.EncounterSound.HideEncounterPrint then
            local mapName = (addon.data.MAP_ENCOUNTER_EVENTS[mapID] and addon.data.MAP_ENCOUNTER_EVENTS[mapID].name) or tostring(mapID)
            addon.Utilities:print(L["PrivateAuraSettings"] .. ": |cffffff00" .. mapName .. "|r")
        end
    end
end

-- MARK: Load Instance PA

local function LoadInstancePrivateAuraSounds(self, instanceID)
    local mapID = addon.data.INSTANCE_JOURNAL[instanceID]
    if not mapID then
        return
    end

    -- Keep dataPA aligned with the new map-scoped aura model.
    -- If dataPA is empty for the map but static aura definitions exist, seed defaults.
    if addon.db.EncounterSound.dataPA and not addon.db.EncounterSound.dataPA[mapID] then
        local auraEncounter = addon.data.MAP_ENCOUNTER_EVENTS[mapID]
            and addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters
            and (
                addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[AURA_ENCOUNTER_KEY]
                or addon.data.MAP_ENCOUNTER_EVENTS[mapID].encounters[LEGACY_AURA_ENCOUNTER_KEY]
            )
        if auraEncounter and type(auraEncounter.privateAuras) == "table" then
            addon.db.EncounterSound.dataPA[mapID] = addon.db.EncounterSound.dataPA[mapID] or {}
        end
    end

    LoadPrivateAuraSounds(self, mapID)
end

-- MARK: Clear PA Sounds

---Clear private aura sounds loaded
---@param self EncounterSound self
local function ClearPrivateAuraSounds(self)
    if self.privateAuras and #self.privateAuras > 0 then
        if InCombatLockdown() then
            self.pendingPrivateAuraClear = true
            return
        end

        for _, pa in ipairs(self.privateAuras) do
            C_UnitAuras.RemoveAuraSound(pa)
        end
        self.privateAuras = {}
        self.pendingPrivateAuraClear = false

        if not addon.db.EncounterSound.HideEncounterPrint then
            addon.Utilities:print(L["ClearPrivateAurasData"])
        end
    end
end

-- MARK: Victory Sound

--- Play victory sound if enabled
local function PlayVictorySound()
    if addon.db.EncounterSound.EnableVictorySound and addon.db.EncounterSound.VictorySound then
        local sound = addon.LSM:Fetch("sound", addon.db.EncounterSound.VictorySound)
        if sound then
            PlaySoundFile(sound, addon.db.EncounterSound.SoundChannel or "Master")
        end
    end
end

-- MARK: Start Sound

--- Play start sound if enabled
local function PlayStartSound()
    if addon.db.EncounterSound.EnableStartSound and addon.db.EncounterSound.StartSound then
        local sound = addon.LSM:Fetch("sound", addon.db.EncounterSound.StartSound)
        if sound then
            PlaySoundFile(sound, addon.db.EncounterSound.SoundChannel or "Master")
        end
    end
end

-- MARK: Test Sound

local function TestHelper(encounterID, eventID, timeOffset)
    local info = C_EncounterEvents.GetEventInfo(eventID)
    local color = addon.db.EncounterSound.data[encounterID][eventID].color or "ffffffff"
    local timelineID = C_EncounterTimeline.AddScriptEvent({
        spellID = info.spellID,
        duration = 10 + (timeOffset or 0),
        severity = info.severity,
        iconFileID = info.iconFileID,
        overrideName = "|c" .. color .. C_Spell.GetSpellInfo(info.spellID).name .. "|r(Test)",
    })
    

    for trigger, data in pairs(addon.db.EncounterSound.data[encounterID][eventID]) do
        if trigger ~= "color" then
            if trigger == "1" then
                C_Timer.After(10 + (timeOffset or 0), function()
                    PlaySoundFile(addon.LSM:Fetch("sound", data.sound), addon.db.EncounterSound.SoundChannel or "Master")
                end)
            elseif trigger == "2" then
                C_Timer.After(5 + (timeOffset or 0), function()
                    PlaySoundFile(addon.LSM:Fetch("sound", data.sound), addon.db.EncounterSound.SoundChannel or "Master")
                end)
            end
        end
    end
end

function EncounterSound:TestSound(encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        addon.Utilities:print(L["TestLoadSuccess"] .. "|cffffff00" .. encounterID .. "|r")
        local timeOffset = 0
        for eventID, _ in pairs(addon.db.EncounterSound.data[encounterID]) do
            TestHelper(encounterID, eventID, timeOffset)
            timeOffset = timeOffset + 6
        end
    else
        addon.Utilities:print(L["TestLoadFailed"] .. "|cffffff00" .. encounterID .. "|r")
    end
end

-- MARK: Force Data Migration
function EncounterSound:DataMigration(force)
    DataMigration(force)
end

-- MARK: RegisterEvents

---Register events
function EncounterSound:RegisterEvents()
    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function ()
        local currentEncounter = addon.states["encounterInfo"].encounterID
        if not currentEncounter then -- not an encounter error
            return
        elseif currentEncounter == 0 then -- encounter ended
            ClearEventSounds(self, self.lastEncounterID)

            if addon.states["encounterInfo"].success == 1 then
                PlayVictorySound()
            end

            return
        end

        self.lastEncounterID = currentEncounter
        self.role = UnitGroupRolesAssigned("player") or nil -- update current role
        LoadEventSounds(self, currentEncounter)
        PlayStartSound()
    end)

    addon.core:RegisterStateMonitor("instanceInfo", self.modName, function ()
        local instanceID = addon.states["instanceInfo"].instanceID
        if instanceID and addon.data.INSTANCE_JOURNAL[instanceID] then
            LoadInstancePrivateAuraSounds(self, instanceID)
            self.lastInstanceID = instanceID
        elseif instanceID == 0 or (self.lastInstanceID and instanceID ~= self.lastInstanceID) then
            -- if not in instance or switched instance, clear private aura sounds loaded
            ClearPrivateAuraSounds(self)
            self.lastInstanceID = nil
        end
    end)

    addon.core:RegisterEvent("PLAYER_REGEN_ENABLED", self.eventFrame, self.modName)

    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_ENABLED" then
            if self.pendingPrivateAuraClear then
                ClearPrivateAuraSounds(self)
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)