local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class PrivateAuraAnchor
local PrivateAuraAnchor = {
    modName = "PrivateAuraAnchor",
    testOverlay = {},
}

-- MARK: Constants
local TEST_ICON_TEXTURE = 134400
local AURA_FRAME_SIZE = 45
local MAX_AURA_COUNT = 3
local FILTER_STRING = "HARMFUL"
local CANDIDATE_FILTER = {isFromPlayerOrPlayerPet = false}
local ANCHOR = {
    ["LEFT"] = AnchorUtil.FlowDirection.Left,
    ["RIGHT"] = AnchorUtil.FlowDirection.Right,
    ["UP"] = AnchorUtil.FlowDirection.Up,
    ["DOWN"] = AnchorUtil.FlowDirection.Down,
}

-- MARK: Initialize Aura
local function InitializeAuraButtonFrame(frame)
    local iconSize = addon.db.PrivateAuraAnchor.IconSize or AURA_FRAME_SIZE
    frame:SetSize(iconSize, iconSize)

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    frame.texture = icon
    frame:SetIcon(icon)

    local cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetDrawEdge(false)
    cooldown:SetReverse(true)
    cooldown:SetScale(0.75)
    frame.cooldown = cooldown
    frame:SetDurationCooldown(cooldown)

    -- bottomright stack count text
    local stack = frame:CreateFontString(nil, "OVERLAY")
    stack:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    stack:SetFont("Fonts\\FRIZQT__.TTF", addon.db.PrivateAuraAnchor.StackTextSize or 12, "OUTLINE")
    stack:SetTextColor(1, 1, 1, 1)
    frame.stack = stack
    frame:SetApplicationCount(stack)

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
local function CreateAuraContainer(name)
    local maxCount = addon.db.PrivateAuraAnchor.MaxAuras or MAX_AURA_COUNT
    local width = (addon.db.PrivateAuraAnchor.IconSize or AURA_FRAME_SIZE) * maxCount
    local height = addon.db.PrivateAuraAnchor.IconSize or AURA_FRAME_SIZE

    local container = CreateFrame("AuraContainer", ADDON_NAME .. "_" .. name, UIParent, "CustomAuraContainerTemplate")
    -- decide grow direction first, and then set the position based on the grow direction
    local horizontalDirection = addon.db.PrivateAuraAnchor.Grow or "RIGHT"
    container:SetFlowLayoutGrowthDirection(ANCHOR[horizontalDirection], ANCHOR["UP"])
    local anchorFrom = horizontalDirection == "RIGHT" and "LEFT" or "RIGHT" -- if RIGHT then LEFT, if LEFT then RIGHT
    container:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[PrivateAuraAnchor.modName]["X"] or 0, addon.db[PrivateAuraAnchor.modName]["Y"] or 0)
    container:SetSize(width, height)

    container:AddAuraGroup(name, FILTER_STRING, {
        maxFrameCount = maxCount,
        initializeFrame = function(frame)
            InitializeAuraButtonFrame(frame)
        end,
        layout = {
            elementSpacing = 0,
            lineSpacing = 0,
            groupSpacing = 0,
            groupLineSpacing = 0,
            forceNewLine = false,
            elementWidth = addon.db.PrivateAuraAnchor.IconSize or height,
            elementHeight = addon.db.PrivateAuraAnchor.IconSize or height,
        },
        candidateFilters = CANDIDATE_FILTER,
    })

    return container
end

-- MARK: Initialize

---Initialize (Constructor)
---@return PrivateAuraAnchor PrivateAuraAnchor a PrivateAuraAnchor object
function PrivateAuraAnchor:Initialize()
    self.eventFrame = CreateFrame("Frame")

    -- use 12.1 new aura system instead of the old private aura system
    self.player = CreateAuraContainer("player")
    self.player:SetUnit("player")

    -- if addon.db[self.modName]["ShowCoTankAuras"] then
    --     -- do the same things as player but do not set unit yet
    --     self.coTank = CreateAuraContainer("coTank")
    -- end

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

-- MARK: CreateTestRegion

local function ToggleTestRegion(self, on)
    -- instead of create the test overlay according to the container, just use the DB data to create the test overlay, so that the test overlay can be shown even if the container is not created yet
    local buildTestOverlay = function (name, label, x, y, width, height)
        if not self.testOverlay[name] then
            local overlay = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            overlay:SetSize(width, height)
            -- handle anchor as same as the container
            local horizontalDirection = addon.db.PrivateAuraAnchor.Grow or "RIGHT"
            local anchorFrom = horizontalDirection == "RIGHT" and "LEFT" or "RIGHT"
            overlay:SetPoint(anchorFrom, UIParent, "CENTER", x, y)
            overlay:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
            })
            overlay:SetBackdropColor(0, 0, 1, 0.5)

            local text = overlay:CreateFontString(nil, "OVERLAY")
            text:SetPoint("CENTER", overlay, "TOP", 0, 0)
            text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
            text:SetText(label)

            overlay.text = text
            self.testOverlay[name] = overlay
        end
    end

    if not self.testOverlay["player"] then
        local width = (addon.db[self.modName]["IconSize"] or 45) * (addon.db[self.modName]["MaxAuras"] or 3)
        local height = addon.db[self.modName]["IconSize"] or 45
        buildTestOverlay("player", L["PrivateAuraAnchorSettings"], addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0, width, height)
    end
    if not self.testOverlay["coTank"] then
        local width = (addon.db[self.modName]["CoTankIconSize"] or 45) * (addon.db[self.modName]["MaxAuras"] or 3)
        local height = addon.db[self.modName]["CoTankIconSize"] or 45
        buildTestOverlay("coTank", L["CoTankAuras"], addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0, width, height)
    end

    if on then
        -- player
        self.testOverlay["player"]:Show()
        addon.Utilities:MakeFrameDragPosition(self.testOverlay["player"], self.modName, "X", "Y")
        -- coTank
        self.testOverlay["coTank"]:Show()
        addon.Utilities:MakeFrameDragPosition(self.testOverlay["coTank"], self.modName, "CoTankX", "CoTankY")
    else
        -- since the test overlay may not change the position of created containers
        -- change the position of the container after the test overlay is hidden

        -- player
        self.testOverlay["player"]:Hide()
        self.player:ClearAllPoints()
        local horizontalDirection = addon.db.PrivateAuraAnchor.Grow or "RIGHT"
        local anchorFrom = horizontalDirection == "RIGHT" and "LEFT" or "RIGHT"
        self.player:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
        -- coTank
        self.testOverlay["coTank"]:Hide()
        if self.coTank then
            self.coTank:ClearAllPoints()
            self.coTank:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0)
        end
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function PrivateAuraAnchor:UpdateStyle()
    self.player:SetAuraGroupMaxFrameCount("player", addon.db[self.modName]["MaxAuras"] or 3)
    local maxCount = addon.db.PrivateAuraAnchor.MaxAuras or MAX_AURA_COUNT
    local width = (addon.db.PrivateAuraAnchor.IconSize or AURA_FRAME_SIZE) * maxCount
    local height = addon.db.PrivateAuraAnchor.IconSize or AURA_FRAME_SIZE

    self.player:ClearAllPoints()
    local horizontalDirection = addon.db.PrivateAuraAnchor.Grow or "RIGHT"
    self.player:SetFlowLayoutGrowthDirection(ANCHOR[horizontalDirection], ANCHOR["UP"])
    local anchorFrom = horizontalDirection == "RIGHT" and "LEFT" or "RIGHT" -- if RIGHT then LEFT, if LEFT then RIGHT
    self.player:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
    self.player:SetSize(width, height)
    self.player:SetFlowLayoutGrowthDirection(ANCHOR[addon.db.PrivateAuraAnchor.Grow or "RIGHT"], ANCHOR["UP"])
    if self.coTank then
        self.coTank:SetAuraGroupMaxFrameCount("coTank", addon.db[self.modName]["MaxAuras"] or 3)
        self.coTank:ClearAllPoints()
        self.coTank:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0)
        self.coTank:SetSize(width, height)
        self.coTank:SetFlowLayoutGrowthDirection(ANCHOR[addon.db.PrivateAuraAnchor.Grow or "RIGHT"], ANCHOR["UP"])
    end

    if self.testOverlay["player"] then
        self.testOverlay["player"]:SetSize(width, height)
        self.testOverlay["player"]:ClearAllPoints()
        self.testOverlay["player"]:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
    end
    if self.testOverlay["coTank"] then
        self.testOverlay["coTank"]:SetSize(width, height)
        self.testOverlay["coTank"]:ClearAllPoints()
        self.testOverlay["coTank"]:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0)
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
        ToggleTestRegion(self, true)
    else
        ToggleTestRegion(self, false)
    end
end

-- MARK: RegisterEvents

---Register events
function PrivateAuraAnchor:RegisterEvents()
    if addon.db[self.modName]["ShowCoTankAuras"] then
        addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.eventFrame, self.modName)

        self.eventFrame:SetScript("OnEvent", function(_, event)
            if event == "GROUP_ROSTER_UPDATE" then
                self.coTankToken = SearchCoTank()
                if self.coTankToken then
                    if not self.coTank then
                        self.coTank = CreateAuraContainer("coTank")
                    end
                    self.coTank:SetUnit(self.coTankToken)
                else
                    if self.coTankToken then
                        self.coTank:SetUnit(self.coTankToken)
                        self.coTank:Hide()
                    end
                end
            end
        end)
    end
end

-- MARK: Register Module
addon.core:RegisterModule(PrivateAuraAnchor.modName, function() return PrivateAuraAnchor:Initialize() end)