local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class PrivateAuraAnchor
local PrivateAuraAnchor = {
    modName = "PrivateAuraAnchor",
}

-- MARK: Constants
local TEST_ICON_TEXTURE = 134400
local AURA_FRAME_SIZE = 45
local MAX_AURA_COUNT = 3
local FILTER_STRING = "HARMFUL|!PLAYER|CROWD_CONTROL|RAID|RAID_IN_COMBAT"
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

local function ToggleTestRegion(container, on, label)
    if not container.testOverlay then
        local testOverlay = CreateFrame("Frame", nil, container)
        testOverlay:SetAllPoints()
        testOverlay.texture = testOverlay:CreateTexture(nil, "ARTWORK")
        testOverlay.texture:SetAllPoints()
        testOverlay.texture:SetColorTexture(0, 0, 1, 0.5)
        testOverlay.title = testOverlay:CreateFontString(nil, "OVERLAY")
        testOverlay.title:SetPoint("CENTER", testOverlay, "TOP", 0, 0)
        testOverlay.title:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        testOverlay.title:SetText(label)
        container.testOverlay = testOverlay
    end

    if on then
        container.testOverlay:Show()
        -- addon.Utilities:MakeFrameDragPosition(container.testOverlay, PrivateAuraAnchor.modName, "X", "Y", function()
        --     local anchorFrom, relativeTo, anchorTo, _, _  = container:GetPoint()
        --     container:ClearAllPoints()
        --     container:SetPoint(anchorFrom, relativeTo, anchorTo, addon.db[PrivateAuraAnchor.modName]["X"] or 0, addon.db[PrivateAuraAnchor.modName]["Y"] or 0)
        -- end)
    else
        container.testOverlay:Hide()
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
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function PrivateAuraAnchor:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        -- make psedo auras for testing
        if self.player then
            -- re-apply position and size to the container to show the test overlay
            local anchorFrom = addon.db.PrivateAuraAnchor.Grow == "RIGHT" and "LEFT" or "RIGHT"
            self.player:ClearAllPoints()
            self.player:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)
            local width = (addon.db[self.modName]["IconSize"] or 45) * (addon.db[self.modName]["MaxAuras"] or 3)
            local height = addon.db[self.modName]["CoTankIconSize"] or 45
            self.player:SetSize(width, height)

            ToggleTestRegion(self.player, true, L["PrivateAuraAnchorSettings"])
        end
        if self.coTank then
            -- re-apply position and size to the container to show the test overlay
            local anchorFrom = addon.db.PrivateAuraAnchor.Grow == "RIGHT" and "LEFT" or "RIGHT"
            self.coTank:ClearAllPoints()
            self.coTank:SetPoint(anchorFrom, UIParent, "CENTER", addon.db[self.modName]["CoTankX"] or 0, addon.db[self.modName]["CoTankY"] or 0)
            local width = (addon.db[self.modName]["CoTankIconSize"] or 45) * (addon.db[self.modName]["MaxAuras"] or 3)
            local height = addon.db[self.modName]["CoTankIconSize"] or 45
            self.coTank:SetSize(width, height)

            ToggleTestRegion(self.coTank, true, L["CoTankAuras"])
        end
    else
        if self.player then
            ToggleTestRegion(self.player, false, L["PrivateAuraAnchorSettings"])
        end
        if self.coTank then
            ToggleTestRegion(self.coTank, false, L["CoTankAuras"])
        end
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