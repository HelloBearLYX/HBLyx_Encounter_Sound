local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class LuraHelper
local LuraHelper = {
    modName = "LuraHelper",
    timer = nil,
    lastMsg = 0,
}

-- MARK: Constants
local BASE_CANVAS_SIZE = 210
local BASE_ICON_SIZE = 50
local BASE_CENTER_SIZE = {50, 75} -- width, height
local BASE_BUTTON_HEIGHT = 20
local BASE_BUTTON_RUNE = 42 -- 30
local FADE_TIME = 15
local MESSAGE_INTERVAL = 1.0
local BASE_ICON_ORDERS = {"TOPRIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "TOPLEFT"}
local RUNE_PREFIX_PATH = "Interface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Lura\\"
---@enum RUNES
local RUNES = {
        CIRCLE = "rune_circle.png",
        DIAMOND = "rune_diamond.png",
        TRIANGLE = "rune_triangle.png",
        T = "rune_t.png",
        X = "rune_x.png",
    }
---@enum MESSAGE_PARSE
local MESSAGE_PARSE = {
    CHAT_MSG_SAY = "CIRCLE",
    CHAT_MSG_RAID = "DIAMOND",
    CHAT_MSG_RAID_LEADER = "DIAMOND",
    CHAT_MSG_YELL = "TRIANGLE",
    CHAT_MSG_RAID_WARNING = "T",
    CHAT_MSG_PING = "X",
}

local MACROS = {
    CIRCLE = "/s Lura Circle",
    DIAMOND = "/ra Lura Diamond",
    TRIANGLE = "/yell Lura Triangle",
    T = "/rw Lura T",
    X = "/ping assist",
}

-- MARK: Initialize

---Initialize (Constructor)
---@return LuraHelper LuraHelper a LuraHelper object
function LuraHelper:Initialize()
    self.reverse = false -- whether the order of icons is reversed
    self.index = 1
    self.assigned = 0 -- number of assigned runes
    self.macros = {}

    SetCVar("showPingsInChat", 1) -- force showPingsInChat

    self.eventFrame = CreateFrame("Frame", ADDON_NAME.. "_" .. self.modName, UIParent)

    return self
end

-- MARK: Toggle Combat Events

local function ToggleCombatEvents(self, on)
    if on then
        self.eventFrame:RegisterEvent("CHAT_MSG_SAY")
        self.eventFrame:RegisterEvent("CHAT_MSG_YELL")
        self.eventFrame:RegisterEvent("CHAT_MSG_PING")
        self.eventFrame:RegisterEvent("CHAT_MSG_RAID")
        self.eventFrame:RegisterEvent("CHAT_MSG_RAID_LEADER")
        self.eventFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
    else
        self.eventFrame:UnregisterEvent("CHAT_MSG_SAY")
        self.eventFrame:UnregisterEvent("CHAT_MSG_YELL")
        self.eventFrame:UnregisterEvent("CHAT_MSG_PING")
        self.eventFrame:UnregisterEvent("CHAT_MSG_RAID")
        self.eventFrame:UnregisterEvent("CHAT_MSG_RAID_LEADER")
        self.eventFrame:UnregisterEvent("CHAT_MSG_RAID_WARNING")
    end
end

-- MARK: Rune I/O

local function RemoveRune(self, index)
    if self.assigned <= 0 then
        return
    end

    local icon = self.icons[BASE_ICON_ORDERS[index]]
    if icon then
        icon.texture:SetTexture(nil)
        icon.rune = nil
        self.assigned = self.assigned - 1
        self.index = self.reverse and math.max(self.index, index) or math.min(self.index, index)
    end
end

local function ClearRunes(self)
    self.assigned = #BASE_ICON_ORDERS
    for i, _ in pairs(BASE_ICON_ORDERS) do
        RemoveRune(self, i)
    end
end

local function AssignRune(self, rune)
    if self.assigned >= #BASE_ICON_ORDERS or not rune then
        return
    end

    local icon = self.icons[BASE_ICON_ORDERS[self.index]]
    if icon then
        icon.texture:SetTexture(RUNE_PREFIX_PATH .. RUNES[rune])
        icon.rune = rune

        self.assigned = self.assigned + 1
        self.index = self.reverse and self.index - 1 or self.index + 1

        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
        self.timer = C_Timer.NewTimer(FADE_TIME, function()
            ClearRunes(self)
        end)
    end
end

-- MARK: Parse Message

---Parse event type for runes
local function ParseEvent(self,event)
    local rune = MESSAGE_PARSE[event]
    
    -- to prevent spamming messages
    -- local now = GetTime()
    -- if self.lastMsg + MESSAGE_INTERVAL > now then
    --     -- RemoveRune(self, self.reverse and self.index + 1 or self.index - 1) -- remove the last assigned rune
    --     return nil
    -- end
    -- self.lastMsg = now

    return rune
end

local function Reverse(self)
    self.reverse = not self.reverse
    -- switch index to the opposite side based on the current index
    self.index = self.reverse and math.max(#BASE_ICON_ORDERS - (self.index - 1), 1) or math.min(math.abs(#BASE_ICON_ORDERS - (self.index - 1)), #BASE_ICON_ORDERS)

    local order = self.reverse and 5 or 1
    if self.icons then
        -- reverse text number and reverse BOTTOMLEFT and TOPLEFT with BOTTOMRIGHT and TOPRIGHT
        for _, index in pairs(BASE_ICON_ORDERS) do
            local icon = self.icons[index]
            if icon then
                icon.text:SetText(tostring(order))
                order = self.reverse and order - 1 or order + 1
            end

            if index == "TOPRIGHT" then
                local tempTexture = icon.texture:GetTexture()
                local tempRune = icon.rune
                icon.texture:SetTexture(self.icons["TOPLEFT"].texture:GetTexture())
                icon.rune = self.icons["TOPLEFT"].rune
                self.icons["TOPLEFT"].texture:SetTexture(tempTexture)
                self.icons["TOPLEFT"].rune = tempRune
            elseif index == "BOTTOMRIGHT" then
                local tempTexture = icon.texture:GetTexture()
                local tempRune = icon.rune
                icon.texture:SetTexture(self.icons["BOTTOMLEFT"].texture:GetTexture())
                icon.rune = self.icons["BOTTOMLEFT"].rune
                self.icons["BOTTOMLEFT"].texture:SetTexture(tempTexture)
                self.icons["BOTTOMLEFT"].rune = tempRune
            end
        end
    end
end

-- MARK: Get Anchors
---Get anchors for icons
local function GetAnchors(self, anchor)
    local offset = 5 * (addon.db[self.modName]["Scale"] or 1)
    if anchor == "TOP" then
        return "BOTTOM", "TOP", 0, 0
    elseif anchor == "TOPRIGHT" then
        return "BOTTOMLEFT", "RIGHT", 0, offset
    elseif anchor == "BOTTOMRIGHT" then
        return "TOPLEFT", "RIGHT", 0, -offset
    elseif anchor == "BOTTOM" then
        return "TOP", "BOTTOM", 0, 0
    elseif anchor == "BOTTOMLEFT" then
        return "TOPRIGHT", "LEFT", 0, -offset
    elseif anchor == "TOPLEFT" then
        return "BOTTOMRIGHT", "LEFT", 0, offset
    end
end

local function GetTextAnchors(self, anchor)
    if anchor == "TOP" then
        return "BOTTOM", "TOP"
    elseif anchor == "TOPRIGHT" then
        return "BOTTOMLEFT", "TOPRIGHT"
    elseif anchor == "BOTTOMRIGHT" then
        return "TOPLEFT", "BOTTOMRIGHT"
    elseif anchor == "BOTTOM" then
        return "TOP", "BOTTOM"
    elseif anchor == "BOTTOMLEFT" then
        return "TOPRIGHT", "BOTTOMLEFT"
    elseif anchor == "TOPLEFT" then
        return "BOTTOMRIGHT", "TOPLEFT"
    end
end

-- MARK: Main Frame

local function CreateMainFrame(self)
    self.frame = CreateFrame("Frame", ADDON_NAME.. "_" .. self.modName, UIParent)
    self.frame.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.background:SetAllPoints()
    self.frame.border = CreateFrame("Frame", nil, self.frame, "BackdropTemplate")
    self.frame.border:SetAllPoints()
    self.frame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.frame.border:SetBackdropBorderColor(0, 0, 0, 1)
end

-- MARK: Icons

local function CreateIcons(self)
    self.centerIcon = self.frame:CreateTexture(nil, "ARTWORK")
    self.centerIcon:SetSize(BASE_CENTER_SIZE[1], BASE_CENTER_SIZE[2])
    self.centerIcon:SetTexture(RUNE_PREFIX_PATH .. "lura.png")
    self.centerIcon:SetPoint("CENTER", self.frame, "CENTER", 0, 0)

    self.icons = self.icons or {}
    local tankIcon = self.frame:CreateTexture(nil, "ARTWORK")
    tankIcon:SetTexture("Interface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Flags\\Tank.png")
    self.icons["TOP"] = tankIcon

    for i, key in pairs(BASE_ICON_ORDERS) do
        local icon = CreateFrame("Frame", nil, self.frame)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.text = icon:CreateFontString(nil, "OVERLAY")
        icon.text:SetPoint("CENTER", icon, "CENTER", 0, 0)
        icon.text:SetFont(
            "Fonts\\FRIZQT__.TTF",
            14,
            "OUTLINE"
        )
        icon.text:SetTextColor(1, 1, 1, 1)
        icon.text:SetText(tostring(i))
        local textAnchorFrom, textAnchorTo = GetTextAnchors(self, key)
        icon.text:SetPoint(textAnchorFrom, icon, textAnchorTo, 0, 0)
        icon.rune = nil

        self.icons[key] = icon
    end
end

-- MARK: General Button

local function CreateGeneralButton(self)
    -- hidden button
    self.hideButton = CreateFrame("Button", nil, UIParent)
    self.hideButton:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT", 0, 0)
    self.hideButton.background = self.hideButton:CreateTexture(nil, "BACKGROUND")
    self.hideButton.background:SetAllPoints()
    self.hideButton.border = CreateFrame("Frame", nil, self.hideButton, "BackdropTemplate")
    self.hideButton.border:SetAllPoints()
    self.hideButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.hideButton.border:SetBackdropBorderColor(0, 0, 0, 1)
    self.hideButton.hide = false
    self.hideButton:SetScript("OnClick", function()
        if not self.hideButton.hide then
            self.frame:Show()
            self.hideButton.text:SetText(L["Hide"])
        else
            self.frame:Hide()
            self.hideButton.text:SetText(L["Show"])
        end
        self.hideButton.hide = not self.hideButton.hide
    end)
    self.hideButton.text = self.hideButton:CreateFontString(nil, "OVERLAY")
    self.hideButton.text:SetPoint("CENTER", self.hideButton, "CENTER", 0, 0)
    self.hideButton.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        10,
        "OUTLINE"
    )
    self.hideButton.text:SetTextColor(1, 1, 1, 1)
    self.hideButton.text:SetText(L["Hide"])

    -- clear button
    local clearButton = CreateFrame("Button", nil, self.frame)
    clearButton:SetPoint("LEFT", self.hideButton, "RIGHT", 0, 0)
    clearButton.background = clearButton:CreateTexture(nil, "BACKGROUND")
    clearButton.background:SetAllPoints()
    clearButton.border = CreateFrame("Frame", nil, clearButton, "BackdropTemplate")
    clearButton.border:SetAllPoints()
    clearButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    clearButton.border:SetBackdropBorderColor(0, 0, 0, 1)
    clearButton.text = clearButton:CreateFontString(nil, "OVERLAY")
    clearButton.text:SetPoint("CENTER", clearButton, "CENTER", 0, 0)
    clearButton.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        10,
        "OUTLINE"
    )
    clearButton.text:SetTextColor(1, 1, 1, 1)
    clearButton.text:SetText(L["Clear"])
    clearButton:SetScript("OnClick", function(_, _)
        ClearRunes(self)
    end)
    clearButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(clearButton, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["ClearAllRunes"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    clearButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.clearButton = clearButton

    -- reverse button
    local reverseButton = CreateFrame("Button", nil, self.frame)
    reverseButton:SetPoint("LEFT", clearButton, "RIGHT", 0, 0)
    reverseButton.background = reverseButton:CreateTexture(nil, "BACKGROUND")
    reverseButton.background:SetAllPoints()
    reverseButton.border = CreateFrame("Frame", nil, reverseButton, "BackdropTemplate")
    reverseButton.border:SetAllPoints()
    reverseButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    reverseButton.border:SetBackdropBorderColor(0, 0, 0, 1)
    reverseButton.text = reverseButton:CreateFontString(nil, "OVERLAY")
    reverseButton.text:SetPoint("CENTER", reverseButton, "CENTER", 0, 0)
    reverseButton.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        10,
        "OUTLINE"
    )
    reverseButton.text:SetTextColor(1, 1, 1, 1)
    reverseButton.text:SetText(L["Reverse"])
    reverseButton:SetScript("OnClick", function()
        Reverse(self)
    end)
    reverseButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(reverseButton, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["ReverseOrder"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    reverseButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.reverseButton = reverseButton
end

-- MARK: Rune Button

local function CreateRuneButton(self, parent)
    self.runeButtons = self.runeButtons or {}
    for runeKey, runeFile in pairs(RUNES) do
        local runeButton = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
        runeButton.border = CreateFrame("Frame", nil, runeButton, "BackdropTemplate")
        runeButton.border:SetAllPoints()
        runeButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
        runeButton.border:SetBackdropBorderColor(0, 0, 0, 1)

        runeButton.texture = runeButton:CreateTexture(nil, "ARTWORK")
        runeButton.texture:SetAllPoints()
        runeButton.texture:SetTexture("Interface\\AddOns\\HBLyx_Encounter_Sound\\Media\\Lura\\" .. runeFile)
        runeButton.name = runeKey
        runeButton:SetAttribute("type", "macro")
        runeButton:SetAttribute("macrotext", MACROS[runeKey] or "")
        runeButton:RegisterForClicks("AnyDown")

        table.insert(self.runeButtons, runeButton)
    end
end

-- MARK: Side Bar

local function CreateSideBar(self)
    self.sideBar = CreateFrame("Frame", nil, self.frame)
    self.sideBar:SetPoint("LEFT", self.frame, "RIGHT", 0, 0)
    self.sideBar.background = self.sideBar:CreateTexture(nil, "BACKGROUND")
    self.sideBar.background:SetAllPoints()
    self.sideBar.border = CreateFrame("Frame", nil, self.sideBar, "BackdropTemplate")
    self.sideBar.border:SetAllPoints()
    self.sideBar.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    self.sideBar.border:SetBackdropBorderColor(0, 0, 0, 1)
end

-- MARK: Create Helpers

local function CreateHelper(self)
    CreateMainFrame(self)
    CreateIcons(self)
    CreateSideBar(self)
    CreateGeneralButton(self)
    CreateRuneButton(self, self.sideBar)

    ToggleCombatEvents(self, true)
    self.frame:HookScript("OnShow", function()
        ToggleCombatEvents(self, true)
        if self.hideButton then self.hideButton:Show() end
    end)
    self.frame:HookScript("OnHide", function()
        ToggleCombatEvents(self, false)
    end)
end

-- MARK: Assign Icon Position
local function AssignIconPosition(self, iconKey)
    local icon = self.icons[iconKey]
    if icon then
        local anchorFrom, anchorTo, xOffset, yOffset = GetAnchors(self, iconKey)
        icon:ClearAllPoints()
        icon:SetPoint(anchorFrom, self.centerIcon, anchorTo, xOffset, yOffset)
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function LuraHelper:UpdateStyle()
    if self.frame then
        local scale = addon.db[self.modName]["Scale"] or 1
        self.frame:SetFrameStrata(addon.db[self.modName]["FrameStrata"] or "LOW")
        local size = scale * BASE_CANVAS_SIZE
        self.frame:SetSize(size, size) -- keep rectangle shape and use scale to adjust
        self.frame:SetPoint("CENTER", UIParent, "CENTER", addon.db[self.modName]["X"] or 0, addon.db[self.modName]["Y"] or 0)

        if self.frame.background then
            self.frame.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
        end

        if self.centerIcon then
            self.centerIcon:SetSize(scale * BASE_CENTER_SIZE[1], scale * BASE_CENTER_SIZE[2])
        end

        local iconSize = scale * BASE_ICON_SIZE
        for key, icon in pairs(self.icons) do
            icon:SetSize(iconSize, iconSize)
            AssignIconPosition(self, key)
        end

        local sideIconSize = scale * BASE_BUTTON_RUNE
        if self.sideBar then
            self.sideBar:SetSize(sideIconSize, size)
            self.sideBar.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
        
            for i, runeButton in ipairs(self.runeButtons or {}) do
                runeButton:SetSize(sideIconSize, sideIconSize)
                runeButton:SetPoint("TOPLEFT", self.sideBar, "TOPLEFT", 0, - (i-1) * sideIconSize)
            end
        end

        if self.hideButton then
            self.hideButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
            self.clearButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
            self.reverseButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
            self.hideButton.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
            self.clearButton.background:SetColorTexture(0, 1, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
            self.reverseButton.background:SetColorTexture(0, 0, 1, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
        end
    end

    -- update macros contents
    MACROS = {
        CIRCLE = "/s " .. (addon.db[self.modName]["Rune_CIRCLE"] or "Lura Circle"),
        DIAMOND = "/ra " .. (addon.db[self.modName]["Rune_DIAMOND"] or "Lura Diamond"),
        TRIANGLE = "/yell " .. (addon.db[self.modName]["Rune_TRIANGLE"] or "Lura Triangle"),
        T = "/rw " .. (addon.db[self.modName]["Rune_T"] or "Lura T"),
        X = "/ping assist",
    }
end

-- MARK: IsActivate

function LuraHelper:IsActivate()
    return self.frame and self.frame:IsShown()
end

-- MARK: Activate

function LuraHelper:Activate(on)
    if on then
        if not self.frame then
            CreateHelper(self)
        else
            self.frame:Show()
        end
        self:UpdateStyle()
    else
        if self.frame then
            self.frame:Hide()
            self.hideButton:Hide()
        end
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function LuraHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    self:Activate(on)
    if on then
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    end
end

-- MARK: RegisterEvents

---Register events
function LuraHelper:RegisterEvents()
    -- combat events are registered independenly, to avoid unnecessary triggeres
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        local rune = ParseEvent(self, event)

        AssignRune(self, rune)
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(LuraHelper.modName, function() return LuraHelper:Initialize() end)