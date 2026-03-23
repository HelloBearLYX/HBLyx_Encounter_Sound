local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class PrivateAuraAnchor
local PrivateAuraAnchor = {
    modName = "PrivateAuraAnchor",
}

-- MARK: Initialize

---Initialize (Constructor)
---@return PrivateAuraAnchor PrivateAuraAnchor a PrivateAuraAnchor object
function PrivateAuraAnchor:Initialize()
    self.head = CreateFrame("Frame", ADDON_NAME .. "_" .. self.modName, UIParent)
    self.head:SetFrameStrata("HIGH")
    self.maxAuras = addon.db[self.modName]["MaxAuras"]
    self.playerAuras = {}

    if addon.db[self.modName]["ShowCoTankAuras"] then
        self.coTankHead = CreateFrame("Frame", nil, UIParent)
        self.coTankHead:SetFrameStrata("HIGH")
        self.coTankMaxAuras = addon.db[self.modName]["CoTankMaxAuras"]
        self.coTankAuras = {}
    end

    self.head:Show()
    self:CreatePrivateAnchors("player")

    return self
end

-- MARK: GetGroupMembers

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

-- MARK: GetStyleArgs

local function GetStyleArgs(self, iconSize, grow)
    local offsetX, offsetY
    if grow == "UP" then
        offsetX, offsetY = 0, 1
    elseif grow == "DOWN" then
        offsetX, offsetY = 0, -1
    elseif grow == "LEFT" then
        offsetX, offsetY = -1, 0
    elseif grow == "RIGHT" then
        offsetX, offsetY = 1, 0
    end

    return offsetX, offsetY, iconSize
end

-- MARK: Get PAAnchorArgs

local function GetPAAnchorArgs(self, unit, index, isCoTank)
    local iconSize
    if isCoTank then
        iconSize = addon.db[self.modName]["CoTankIconSize"]
    else
        iconSize = addon.db[self.modName]["IconSize"]
    end

    local PAAnchorArgs = {
        unitToken = unit,
        auraIndex = index,
        parent = isCoTank and self.coTankAuras[index] or self.playerAuras[index],
        showCountdownFrame = true,
        showCountdownNumbers = addon.db[self.modName]["ShowCountdownNumbers"],
        iconInfo = {
            iconAnchor = {
                point = "CENTER",
                relativeTo = isCoTank and self.coTankAuras[index] or self.playerAuras[index],
                relativePoint = "CENTER",
                offsetX = 0,
                offsetY = 0,
            },
            borderScale = addon.db[self.modName]["BorderScale"],
            iconWidth = iconSize,
            iconHeight = iconSize,
        },
        durationAnchor = {
            point = "CENTER",
            relativeTo = isCoTank and self.coTankAuras[index] or self.playerAuras[index],
            relativePoint = "CENTER",
            offsetX = 0,
            offsetY = 0,
        },
    }

    return PAAnchorArgs
end

-- MARK: UpdateAuraStyle

local function UpdateAuraStyle(self, frame, index, isCoTank)
    local iconSize
    local offsetX, offsetY
    if isCoTank then
        iconSize = addon.db[self.modName]["CoTankIconSize"]
        offsetX, offsetY = GetStyleArgs(self, iconSize, addon.db[self.modName]["CoTankGrow"])
    else
        iconSize = addon.db[self.modName]["IconSize"]
        offsetX, offsetY = GetStyleArgs(self, iconSize, addon.db[self.modName]["Grow"])
    end

    frame:SetSize(iconSize, iconSize)
    frame:ClearAllPoints()
    if isCoTank then
        frame:SetPoint("CENTER", self.coTankHead, "CENTER", (index - 1) * offsetX * iconSize, (index - 1) * offsetY * iconSize)
    else
        frame:SetPoint("CENTER", self.head, "CENTER", (index - 1) * offsetX * iconSize, (index - 1) * offsetY * iconSize)
    end

    return iconSize
end

-- MARK: Create Anchors

function PrivateAuraAnchor:CreatePrivateAnchors(unit)
    if unit == "player" then
        for i = 1, self.maxAuras do
            local frame = self.playerAuras[i]
            if not frame then
                frame = CreateFrame("Frame", nil, self.head)
                frame:Show()
                self.playerAuras[i] = frame
            end

            UpdateAuraStyle(self, frame, i)

            local AddPrivateAuraAnchorArgs = GetPAAnchorArgs(self, "player", i)

            -- remove existing anchor if exists before creating new one to avoid memory leak
            if self.playerAuras[i].anchorID then
                C_UnitAuras.RemovePrivateAuraAnchor(self.playerAuras[i].anchorID)
            end
            self.playerAuras[i].anchorID = C_UnitAuras.AddPrivateAuraAnchor(AddPrivateAuraAnchorArgs)
        end
    elseif unit == "co-tank" and addon.db[self.modName]["ShowCoTankAuras"] and self.coTankHead then
        if self.coTankToken then -- and UnitGroupRolesAssigned("player") == "TANK"
            for i = 1, self.maxAuras do
                local frame = self.coTankAuras[i]
                if not frame then
                    frame = CreateFrame("Frame", nil, self.coTankHead)
                    frame:Show()
                    self.coTankAuras[i] = frame
                end

                UpdateAuraStyle(self, frame, i, true)

                -- remove existing anchor if exists before creating new one to avoid memory leak
                if self.coTankAuras[i].anchorID then
                    C_UnitAuras.RemovePrivateAuraAnchor(self.coTankAuras[i].anchorID)
                end
                local AddPrivateAuraAnchorArgs = GetPAAnchorArgs(self, self.coTankToken, i, true)

                self.coTankAuras[i].anchorID = C_UnitAuras.AddPrivateAuraAnchor(AddPrivateAuraAnchorArgs)
                frame:Show()
            end
        else
            -- if co-tank is not found, hide the co-tank head and show a message in chat
            for _, frame in pairs(self.coTankAuras) do
                C_UnitAuras.RemovePrivateAuraAnchor(frame.anchorID)
                frame.anchorID = nil
                frame:Hide()
            end
        end
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function PrivateAuraAnchor:UpdateStyle()
    local iconSize = addon.db[self.modName]["IconSize"]
    local offsetX, offsetY = GetStyleArgs(self, iconSize, addon.db[self.modName]["Grow"])

    self.maxAuras = addon.db[self.modName]["MaxAuras"]
    self.head:ClearAllPoints()
    self.head:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"], addon.db[self.modName]["Y"])
    self.head:SetSize(iconSize + (self.maxAuras - 1) * iconSize * math.abs(offsetX), iconSize + (self.maxAuras - 1) * iconSize * math.abs(offsetY))
    for i, frame in pairs(self.playerAuras) do
        UpdateAuraStyle(self, frame, i)
    end

    if addon.db[self.modName]["ShowCoTankAuras"] and self.coTankHead then
        local coTankIconSize = addon.db[self.modName]["CoTankIconSize"]
        local coTankOffsetX, coTankOffsetY = GetStyleArgs(self, coTankIconSize, addon.db[self.modName]["CoTankGrow"])

        self.coTankHead:ClearAllPoints()
        self.coTankHead:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["CoTankX"], addon.db[self.modName]["CoTankY"])
        self.coTankHead:SetSize(coTankIconSize + (self.coTankMaxAuras - 1) * coTankIconSize * math.abs(coTankOffsetX), coTankIconSize + (self.coTankMaxAuras - 1) * coTankIconSize * math.abs(coTankOffsetY))
        for i, frame in pairs(self.coTankAuras) do
            UpdateAuraStyle(self, frame, i, true)
        end
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
        addon.Utilities:ShowDragRegion(self.head, L["PrivateAuraAnchorSettings"])
        addon.Utilities:MakeFrameDragPosition(self.head, self.modName, "X", "Y")

        addon.Utilities:ShowDragRegion(self.coTankHead, L["CoTankAuras"])
        addon.Utilities:MakeFrameDragPosition(self.coTankHead, self.modName, "CoTankX", "CoTankY")
    else
        addon.Utilities:HideDragRegion(self.head)
        addon.Utilities:HideDragRegion(self.coTankHead)
    end
end

-- MARK: RegisterEvents

---Register events
function PrivateAuraAnchor:RegisterEvents()
    if addon.db[self.modName]["ShowCoTankAuras"] and self.coTankHead then
        addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.coTankHead, self.modName)

        self.coTankHead:SetScript("OnEvent", function(_, event)
            if event == "GROUP_ROSTER_UPDATE" then
                self.coTankToken = SearchCoTank()
                self:CreatePrivateAnchors("co-tank")
            end
        end)
    end
end

-- MARK: Register Module
addon.core:RegisterModule(PrivateAuraAnchor.modName, function() return PrivateAuraAnchor:Initialize() end)