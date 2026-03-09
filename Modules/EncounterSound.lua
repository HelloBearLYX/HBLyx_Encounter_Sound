local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class EncounterSound
local EncounterSound = {
    modName = "EncounterSound",
}

-- MARK: Data Migration

local function DataMigration()
    -- 3.13 data structure change: number keys to string keys for trigger for better stability
    if not addon.db.EncounterSound.version or addon.Utilities:CheckVersion(addon.db.EncounterSound.version, "3.14") then
        for encounterID, eventData in pairs(addon.db.EncounterSound.data or {}) do
            for eventID, attributes in pairs(eventData) do
                local migratedAttributes = {}

                for trigger, data in pairs(attributes) do
                    if trigger == "color" then
                        migratedAttributes.color = data
                    elseif type(data) == "table" then
                        -- Convert trigger into string format for stability, e.g. "1" for trigger 1, "2" for trigger 2.
                        -- Build a new table instead of mutating while iterating to avoid data loss.
                        local newTrigger = tostring(trigger)
                        migratedAttributes[newTrigger] = {
                            sound = data.sound,
                            role = data.role,
                        }
                    end
                end

                addon.db.EncounterSound.data[encounterID][eventID] = migratedAttributes
            end
        end

        -- 3.14 delete private auras which has been removed on 03/02/2026
        for encounterID, eventData in pairs(addon.data.CHANGED_PRIVATEAURAS) do
            for eventID, change in pairs(eventData) do
                if addon.db.EncounterSound.dataPA[encounterID] and addon.db.EncounterSound.dataPA[encounterID][eventID] then
                    addon.db.EncounterSound.dataPA[encounterID][eventID] = change
                end
            end
        end

        addon.db.EncounterSound.version = addon.version -- update version after migration
        addon.Utilities:print("EncounterSound data has been migrated to the new format")
    end
end

-- MARK: Initialize

---Initialize (Constructor)
---@return EncounterSound EncounterSound a EncounterSound object
function EncounterSound:Initialize()
    self.privateAuras = {}
    self.role = nil
    self.lastEncounterID = nil

    -- 3.13 data change migration
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
                    C_EncounterEvents.SetEventColor(eventID, CreateColorFromHexString(addon.db.EncounterSound.data[encounterID][eventID].color))
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
        addon.Utilities:print(L["EncounterSoundSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
    end
end

-- MARK: Clear Event Sounds

local function ClearEventSounds(self, encounterID)
    if addon.db.EncounterSound.data and addon.db.EncounterSound.data[encounterID] then
        local encounterData = addon.db.EncounterSound.data[encounterID]
        for eventID, eventData in pairs(encounterData) do
            -- do not reset color if not needed(still considering)
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

        addon.Utilities:print(L["ClearEventSound"] .. "|cffffff00" .. self.lastEncounterID .. "|r")
    end
end

-- MARK: Load PA Sounds

---Load private aura sounds for the given encounter ID
---@param self EncounterSound self
---@param encounterID integer the encounter ID to load private aura sounds for
local function LoadPrivateAuraSounds(self, encounterID)
    if addon.db.EncounterSound.EnablePrivateAuras and addon.db.EncounterSound.dataPA and addon.db.EncounterSound.dataPA[encounterID] then
        local privateAuraData = addon.db.EncounterSound.dataPA[encounterID]
        for spellID, soundName in pairs(privateAuraData) do
            local sound = addon.LSM:Fetch("sound", soundName)
            if sound then
                local pa = C_UnitAuras.AddPrivateAuraAppliedSound({
                    spellID = spellID,
                    unitToken = "player",
                    soundFileName = sound,
                    outputChannel = addon.db.EncounterSound.SoundChannel or "Master",
                })
                table.insert(self.privateAuras, pa)
            end
        end
        addon.Utilities:print(L["PrivateAuraSettings"] .. ": |cffffff00" .. addon.states["encounterInfo"].encounterName .. "|r")
    end
end

-- MARK: Clear PA Sounds

---Clear private aura sounds loaded
---@param self EncounterSound self
local function ClearPrivateAuraSounds(self)
    if self.privateAuras and #self.privateAuras > 0 then
        for _, pa in ipairs(self.privateAuras) do
            C_UnitAuras.RemovePrivateAuraAppliedSound(pa)
        end
        self.privateAuras = {}
        addon.Utilities:print(L["ClearPrivateAurasData"] .. "|cffffff00" .. self.lastEncounterID .. "|r")
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

-- MARK: RegisterEvents

---Register events
function EncounterSound:RegisterEvents()
    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function ()
        local currentEncounter = addon.states["encounterInfo"].encounterID
        if not currentEncounter then -- not an encounter error
            return
        elseif currentEncounter == 0 then -- encounter ended
            -- only clear private aura sounds
            ClearPrivateAuraSounds(self)
            ClearEventSounds(self, self.lastEncounterID)

            if addon.states["encounterInfo"].success == 1 then
                PlayVictorySound()
            end

            return
        end

        self.lastEncounterID = currentEncounter
        self.role = UnitGroupRolesAssigned("player") or nil -- update current role
        LoadEventSounds(self, currentEncounter)
        LoadPrivateAuraSounds(self, currentEncounter)
        PlayStartSound()
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(EncounterSound.modName, function() return EncounterSound:Initialize() end)