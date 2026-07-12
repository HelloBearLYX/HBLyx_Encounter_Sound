local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class PrivateAuraAnchor
local PrivateAuraAnchor = {
    modName = "PrivateAuraAnchor",
}

-- MARK: Constants
local TEST_ICON_TEXTURE = 134400
local AURA_FRAME_SIZE = 40
local MAX_AURA_COUNT = 3

-- MARK: Initialize Aura
local function InitializeAuraButtonFrame(frame)
    frame:SetSize(AURA_FRAME_SIZE, AURA_FRAME_SIZE)

    if not frame.texture then
        local icon = frame:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        frame.texture = icon
        frame:SetIcon(icon)
    end

    if not frame.cooldown then
        local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawEdge(false)
        cooldown:SetReverse(true)
        cooldown:SetScale(0.75)
        frame.cooldown = cooldown
        frame:SetDurationCooldown(cooldown)
    end

    if not frame.border then
        local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        border:SetBackdropBorderColor(0, 0, 0, 1)
        frame.border = border
    end
end

-- MARK: Create Container
local function CreateAuraContainer(name, spellIDs)
    local container = CreateFrame("AuraContainer", ADDON_NAME .. "_" .. name, UIParent, "CustomAuraContainerTemplate")
    container:SetAuraLayoutAnchorPoint("LEFT")

    container:AddAuraGroup("defaultGroup", "HARMFUL", {
        maxFrameCount = addon.db.PrivateAuraAnchor.MaxAuraCount or MAX_AURA_COUNT,
        candidateFilters = { excludeSpellIDs = spellIDs },
        initializeFrame = function(frame)
            InitializeAuraButtonFrame(frame)
        end,
        layout = {
            elementSpacingX = 0,
            elementSpacingY = 0,
            gapX = 0,
            gapY = 0,
            forceNewRow = false,
            elementWidth = addon.db.PrivateAuraAnchor.AuraFrameSize or AURA_FRAME_SIZE,
            elementHeight = addon.db.PrivateAuraAnchor.AuraFrameSize or AURA_FRAME_SIZE,
        },
    })

    return container
end

-- MARK: Fetch Include Spell IDs
local function FetchIncludeSpellIDs()
	-- data template
	-- [mapID] = {
		-- seasonMapID	= 0,
		-- name = select(1, EJ_GetInstanceInfo(mapID)) or "instance name",
		-- encounters = {
			-- [encounterID] = {
				-- events = {eventID1, eventID2, eventID3, ...},
				-- journalID = 0,
				-- privateAuras = {spellID1, spellID2, spellID3, ...}
			-- },
			-- ["trash"] = {	
				-- privateAuras = {spellID1, spellID2, ...}
			-- },
	-- }

    -- iterate through all map and encounter data to collect include spell IDs
    local output = {}
    for _, mapInfo in pairs(addon.data.MAP_ENCOUNTER_EVENTS) do
        for _, encounterInfo in pairs(mapInfo.encounters) do
            for _, spellID in ipairs(encounterInfo.privateAuras or {}) do
                if type(spellID) == "table" then
                    -- insert all spell IDs from the table
                    for _, id in ipairs(spellID) do
                        output[id] = true
                    end
                elseif type(spellID) == "number" then
                    output[spellID] = true
                end
            end
        end
    end

    return output
end

-- MARK: FetchExcludeSpellIDs
local function FetchExcludeSpellIDs()
    local output = {382912, 57723, 57724, 80354, 264689}

    return output
end

-- MARK: Initialize

---Initialize (Constructor)
---@return PrivateAuraAnchor PrivateAuraAnchor a PrivateAuraAnchor object
function PrivateAuraAnchor:Initialize()
    self.eventFrame = CreateFrame("Frame")
    -- get includeSpellIDs
    local includeSpellIDs = FetchExcludeSpellIDs()

    -- use 12.1 new aura system instead of the old private aura system
    self.player = CreateAuraContainer("player", includeSpellIDs)
    self.player:SetUnit("player")

    if addon.db[self.modName]["ShowCoTankAuras"] then
        -- do the same things as player but do not set unit yet
        self.coTank = CreateAuraContainer("coTank", includeSpellIDs)
    end

    return self
end

-- MARK: GetGroupMembers

---Get an array of all raid member unit tokens
---@return table|nil output an array of raid unit tokens, or nil if not in raid
local function GetRaidIterator()
    if IsInRaid() then -- only search co-tank in raid
        local numMembers = GetNumGroupMembers()
        local output = {}
        if numMembers > 0 then
            for i = 1, numMembers do
                table.insert(output, "raid" .. tostring(i))
            end
        end

        return #output > 0 and output or nil
    else
        return nil
    end
end

-- MARK: Search Co-Tank

---Search for a co-tank in the current raid group
---@return string|nil unit the unit token of the co-tank, or nil if not found
local function SearchCoTank()
    local raidIterator = GetRaidIterator()
    if raidIterator then
        for _, unit in ipairs(raidIterator) do
            if not UnitIsUnit(unit, "player") and UnitGroupRolesAssigned(unit) == "TANK" then
                return unit
            end
        end
    end

    return nil
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function PrivateAuraAnchor:UpdateStyle()
    self.player:ClearAllPoints()
    self.player:SetPoint("LEFT", UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
    if self.coTank then
        self.coTank:ClearAllPoints()
        self.coTank:SetPoint("LEFT", self.player, "RIGHT", addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0)
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function PrivateAuraAnchor:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- TODO: implement test mode logic for PrivateAuraAnchor
    else
        -- TODO: implement test mode logic for PrivateAuraAnchor
    end
end

-- MARK: RegisterEvents

---Register events
function PrivateAuraAnchor:RegisterEvents()
    if addon.db[self.modName]["ShowCoTankAuras"] and self.coTank then
        addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.eventFrame, self.modName)

        self.eventFrame:SetScript("OnEvent", function(_, event)
            if event == "GROUP_ROSTER_UPDATE" then
                self.coTankToken = SearchCoTank()
                if self.coTankToken then
                    self.coTank:SetUnit(self.coTankToken)
                end
            end
        end)
    end
end

-- MARK: Register Module
addon.core:RegisterModule(PrivateAuraAnchor.modName, function() return PrivateAuraAnchor:Initialize() end)