local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class PrivateAuraAnchor
local PrivateAuraAnchor = {
    modName = "PrivateAuraAnchor",
}

-- MARK: Constants
local TEST_ICON_TEXTURE = 134400

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
        self.coTankAuras = {}
    end

    self.head:Show()
    self:CreatePrivateAnchors()

     -- Register events
     self:RegisterEvents()

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

-- MARK: GetStyleArgs

---Get the X/Y offset multipliers for the given grow direction
---@param self PrivateAuraAnchor self
---@param iconSize number the icon size
---@param grow string the grow direction ("UP", "DOWN", "LEFT", "RIGHT")
---@return number offsetX the X offset multiplier
---@return number offsetY the Y offset multiplier
---@return number iconSize the icon size (passed through)
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

---Build the argument table for C_UnitAuras.AddPrivateAuraAnchor
---@param self PrivateAuraAnchor self
---@param unit string the unit token
---@param index integer the aura slot index
---@param isCoTank boolean whether this anchor is for the co-tank
---@return table PAAnchorArgs the argument table for AddPrivateAuraAnchor
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
        isContainer = false,
        iconInfo = {
            iconAnchor = {
                point = "CENTER",
                relativeTo = isCoTank and self.coTankAuras[index] or self.playerAuras[index],
                relativePoint = "CENTER",
                offsetX = 0,
                offsetY = 0,
            },
            borderScale = addon.db[self.modName]["HideBorder"] and -100 or iconSize / 16,
            iconWidth = iconSize,
            iconHeight = iconSize,
        },
    }

    return PAAnchorArgs
end

-- MARK: UpdateAuraStyle

---Update the size and position of an aura frame
---@param self PrivateAuraAnchor self
---@param frame Frame the aura frame to update
---@param index integer the aura slot index
---@param isCoTank boolean|nil whether this frame is for the co-tank
---@return number iconSize the icon size applied
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
-- MARK: Test Auras

---Create a test overlay frame with an icon and index label on the given aura frame
---@param self PrivateAuraAnchor self
---@param frame Frame the aura frame to attach the test overlay to
---@param index integer the aura slot index to display
local function CreateTestAuras(self, frame, index)
    if not frame.testFrame then
        frame.testFrame = CreateFrame("Frame", nil, frame)
        frame.testFrame:SetAllPoints(frame)
        frame.testFrame.icon = frame.testFrame:CreateTexture(nil, "BACKGROUND")
        frame.testFrame.icon:SetAllPoints()
        frame.testFrame.icon:SetTexture(TEST_ICON_TEXTURE)
        
        frame.testFrame.text = frame.testFrame:CreateFontString(nil, "OVERLAY")
        frame.testFrame.text:SetPoint("CENTER", frame.testFrame, "CENTER", 0, 0)
        frame.testFrame.text:SetFont(addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
        frame.testFrame.text:SetText(tostring(index))
    end
end

---Create a label text frame on the anchor head frame for test mode
---@param self PrivateAuraAnchor self
---@param head Frame the head frame to attach the label to
---@param isCoTank boolean whether this label is for the co-tank anchor
local function CreateTestAnchorText(self, head, isCoTank)
    if not head.testTextFrame then
        head.testTextFrame = CreateFrame("Frame", nil, head)
        head.testTextFrame:SetAllPoints()
        head.testTextFrame:SetFrameStrata("DIALOG")
        head.testTextFrame.text = head.testTextFrame:CreateFontString(nil, "OVERLAY")
        head.testTextFrame.text:SetPoint("CENTER", head.testTextFrame, "TOP", 0, 0)
        head.testTextFrame.text:SetFont(addon.LSM:Fetch("font", addon.db[self.modName]["Font"]) or "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        head.testTextFrame.text:SetText(isCoTank and L["CoTankAuras"] or L["PrivateAuraAnchorSettings"])
    end
end

---Show or hide the test overlay for all aura frames
---@param self PrivateAuraAnchor self
---@param onTest boolean whether to show or hide the test overlay
local function TestAuras(self, onTest)
    if self.head then
        CreateTestAnchorText(self, self.head, false)

        if onTest then
            self.head.testTextFrame:Show()
        else
            self.head.testTextFrame:Hide()
        end
    end

    if self.coTankHead then
        CreateTestAnchorText(self, self.coTankHead, true)

        if onTest then
            self.coTankHead.testTextFrame:Show()
        else
            self.coTankHead.testTextFrame:Hide()
        end
    end

    for i = 1, self.maxAuras do
        local frame = self.playerAuras[i]
        if frame then
            CreateTestAuras(self, frame, i)

            if onTest then
                frame.testFrame:Show()
            else
                frame.testFrame:Hide()
            end
        end

        local coTankFrame = self.coTankAuras[i]
        if coTankFrame then
            CreateTestAuras(self, coTankFrame, i)

            if onTest then
                coTankFrame.testFrame:Show()
            else
                coTankFrame.testFrame:Hide()
            end
        end
    end
end

-- MARK: Load Anchor

---Register a private aura anchor for the given frame slot
---@param self PrivateAuraAnchor self
---@param frame Frame the aura frame to register the anchor on
---@param index integer the aura slot index
---@param isCoTank boolean whether this anchor is for the co-tank
local function LoadAnchor(self, frame, index, isCoTank)
    if InCombatLockdown() or (isCoTank and (not self.coTankToken or UnitGroupRolesAssigned("player") ~= "TANK" or not IsInRaid())) then
        return
    end

    local args = GetPAAnchorArgs(self, isCoTank and self.coTankToken or "player", index, isCoTank)

    if frame.anchorID then
        C_UnitAuras.RemovePrivateAuraAnchor(frame.anchorID)
    end
    frame.anchorID = C_UnitAuras.AddPrivateAuraAnchor(args)
end

---Register private aura anchors for all aura slots
---@param self PrivateAuraAnchor self
---@param isCoTank boolean whether to load anchors for co-tank frames
local function LoadAllAnchor(self, isCoTank)
    for i = 1, self.maxAuras do
        local frame = isCoTank and self.coTankAuras[i] or self.playerAuras[i]
        if frame then
            LoadAnchor(self, frame, i, isCoTank)
        end
    end
end

-- MARK: Create Anchors

---Create and initialize all private aura anchor frames
function PrivateAuraAnchor:CreatePrivateAnchors()
    for i = 1, self.maxAuras do
        local frame = self.playerAuras[i]
        if not frame then
            frame = CreateFrame("Frame", nil, self.head)
            frame:Show()
            self.playerAuras[i] = frame
        end

        UpdateAuraStyle(self, frame, i)
        LoadAnchor(self, frame, i, false)

        if addon.db[self.modName]["ShowCoTankAuras"] and self.coTankHead then
            local cotankFrame = self.coTankAuras[i]
            if not cotankFrame then
                cotankFrame = CreateFrame("Frame", nil, self.coTankHead)
                cotankFrame:Show()
                self.coTankAuras[i] = cotankFrame
            end
            
            UpdateAuraStyle(self, cotankFrame, i, true)

            if self.coTankToken and UnitGroupRolesAssigned("player") == "TANK" then
                LoadAnchor(self, cotankFrame, i, true)
            else
                -- if co-tank is not found/player is not a tank
                for _, emptyFrame in ipairs(self.coTankAuras) do
                    if emptyFrame.anchorID and not InCombatLockdown() then -- remove existing anchors if any
                        C_UnitAuras.RemovePrivateAuraAnchor(emptyFrame.anchorID)
                        emptyFrame.anchorID = nil
                    end
                end
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
    self.head:SetSize(iconSize, iconSize)
    for i, frame in pairs(self.playerAuras) do
        UpdateAuraStyle(self, frame, i)
    end

    if addon.db[self.modName]["ShowCoTankAuras"] and self.coTankHead then
        local coTankIconSize = addon.db[self.modName]["CoTankIconSize"]

        self.coTankHead:ClearAllPoints()
        self.coTankHead:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["CoTankX"], addon.db[self.modName]["CoTankY"])
        self.coTankHead:SetSize(coTankIconSize, coTankIconSize)
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
        TestAuras(self, true)
        addon.Utilities:MakeFrameDragPosition(self.head, self.modName, "X", "Y")
        addon.Utilities:MakeFrameDragPosition(self.coTankHead, self.modName, "CoTankX", "CoTankY")
    else
        TestAuras(self, false)
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
                LoadAllAnchor(self, true)
            end
        end)
    end
end

-- MARK: Register Module
addon.core:RegisterModule(PrivateAuraAnchor.modName, function() return PrivateAuraAnchor:Initialize() end)