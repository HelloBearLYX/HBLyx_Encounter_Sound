local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

---@class LuraHelper
local LuraHelper = {
    modName = "LuraHelper",
    timer = nil,
    lastMsg = 0,
    isTestMode = false,
}

-- MARK: Constants
local BASE_CANVAS_SIZE = 210
local BASE_ICON_SIZE = 50
local BASE_CENTER_SIZE = {50, 75} -- width, height
local BASE_BUTTON_HEIGHT = 20
local BASE_BUTTON_RUNE = 30
local FADE_TIME = 15
local MESSAGE_INTERVAL = 1.0
local BASE_ICON_ORDERS = {"TOPRIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "TOPLEFT"}
local RUNE_PREFIX_PATH = "Interface/AddOns/HBLyx_Encounter_Sound/Media/Lura/"
---@enum RUNES
local RUNES = {
        CIRCLE = "rune_circle.png",
        DIAMOND = "rune_diamond.png",
        TRIANGLE = "rune_triangle.png",
        T = "rune_t.png",
        X = "rune_x.png",
    }

local MACROS = {
    CIRCLE = "/raid rune_circle", -- .. RUNE_PREFIX_PATH .. "rune_circle",-- "/s Lura Circle",
    DIAMOND = "/raid rune_diamond", -- .. RUNE_PREFIX_PATH .. "rune_diamond",-- "/s Lura Diamond",
    TRIANGLE = "/raid rune_triangle", -- .. RUNE_PREFIX_PATH .. "rune_triangle",-- "/s Lura Triangle",
    T = "/raid rune_t", -- .. RUNE_PREFIX_PATH .. "rune_t",-- "/s Lura T",
    X = "/raid rune_x", -- .. RUNE_PREFIX_PATH .. "rune_x",-- "/s Lura X",
}

-- MARK: Initialize

---Initialize (Constructor)
---@return LuraHelper LuraHelper a LuraHelper object
function LuraHelper:Initialize()
    self.reverse = false -- whether the order of icons is reversed
    self.index = 1
    self.assigned = 0 -- number of assigned runes
    self.ShowRLButton = false -- whether to show the RL button, only show when the player is in a raid group, and will be updated on GROUP_ROSTER_UPDATE event
    self.macros = {}

    -- SetCVar("showPingsInChat", 1) -- force showPingsInChat

    self.eventFrame = CreateFrame("Frame", ADDON_NAME.. "_" .. self.modName, UIParent)

    return self
end

-- MARK: Toggle Combat Events

local function ToggleCombatEvents(self, on)
    local events = {
        -- "CHAT_MSG_SAY",
        -- "CHAT_MSG_YELL",
        -- "CHAT_MSG_PING",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
    }

    if on then
        for _, event in pairs(events) do
            self.eventFrame:RegisterEvent(event)
        end
    else
        for _, event in pairs(events) do
            self.eventFrame:UnregisterEvent(event)
        end
    end
end

-- MARK: Rune I/O

local function RemoveRune(self, index)
    if self.assigned <= 0 then
        return
    end

    local icon = self.icons[BASE_ICON_ORDERS[index]]
    if icon then
        -- icon.texture:SetTexture(nil)
        icon.texture:ClearText()
        if self.projectionIcons and self.projectionIcons[BASE_ICON_ORDERS[index]] then
            self.projectionIcons[BASE_ICON_ORDERS[index]].texture:ClearText()
        end
        icon.rune = nil
        self.assigned = self.assigned - 1
        self.index = self.reverse and math.max(self.index, index) or math.min(self.index, index)
    end
end

local function UndoRune(self)
    RemoveRune(self, self.reverse and self.index + 1 or self.index - 1) -- remove the last assigned rune
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
        -- rune = secretwrap(rune) -- for debug
        -- addon:debug("rune secret: " .. tostring(issecretvalue(rune)))
        local scale = addon.db[self.modName]["Scale"] or 1.0
        icon.texture:SetFormattedText("|TInterface/AddOns/HBLyx_Encounter_Sound/Media/Lura/%s:%d:%d|t", rune, 32 * scale, 32 * scale)
        if self.projectionIcons and self.projectionIcons[BASE_ICON_ORDERS[self.index]] then
            self.projectionIcons[BASE_ICON_ORDERS[self.index]].texture:SetFormattedText("|TInterface/AddOns/HBLyx_Encounter_Sound/Media/Lura/%s:%d:%d|t", rune, 32 * scale, 32 * scale)
        end
        icon.rune = rune

        self.assigned = self.assigned + 1
        self.index = self.reverse and self.index - 1 or self.index + 1

        if self.timer then
            self.timer:Cancel()
            self.timer = nil
        end
        self.timer = C_Timer.NewTimer(addon.db[self.modName]["FadeTime"] or FADE_TIME, function()
            ClearRunes(self)
        end)
    end
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
                local tempTexture = icon.texture:GetText()
                local tempRune = icon.rune
                icon.texture:SetText(self.icons["TOPLEFT"].texture:GetText())
                icon.rune = self.icons["TOPLEFT"].rune
                self.icons["TOPLEFT"].texture:SetText(tempTexture)
                self.icons["TOPLEFT"].rune = tempRune

                -- if there is projectionIcons, also switch them
                if self.projectionIcons and self.projectionIcons["TOPRIGHT"] and self.projectionIcons["TOPLEFT"] then
                    local tempProjectionTexture = self.projectionIcons["TOPRIGHT"].texture:GetText()
                    self.projectionIcons["TOPRIGHT"].texture:SetText(self.projectionIcons["TOPLEFT"].texture:GetText())
                    self.projectionIcons["TOPLEFT"].texture:SetText(tempProjectionTexture)
                end
            elseif index == "BOTTOMRIGHT" then
                local tempTexture = icon.texture:GetText()
                local tempRune = icon.rune
                icon.texture:SetText(self.icons["BOTTOMLEFT"].texture:GetText())
                icon.rune = self.icons["BOTTOMLEFT"].rune
                self.icons["BOTTOMLEFT"].texture:SetText(tempTexture)
                self.icons["BOTTOMLEFT"].rune = tempRune

                -- if there is projectionIcons, also switch them
                if self.projectionIcons and self.projectionIcons["BOTTOMRIGHT"] and self.projectionIcons["BOTTOMLEFT"] then
                    local tempProjectionTexture = self.projectionIcons["BOTTOMRIGHT"].texture:GetText()
                    self.projectionIcons["BOTTOMRIGHT"].texture:SetText(self.projectionIcons["BOTTOMLEFT"].texture:GetText())
                    self.projectionIcons["BOTTOMLEFT"].texture:SetText(tempProjectionTexture)
                end
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
        icon.texture = icon:CreateFontString(nil, "OVERLAY")
        icon.texture:SetAllPoints()
        icon.texture:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        icon.texture:SetTextColor(1, 1, 1)
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
    clearButton:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMRIGHT", 0, 0)
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
    reverseButton:SetPoint("BOTTOMLEFT", self.clearButton, "TOPLEFT", 0, 0)
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

    -- undo button
    local undoButton = CreateFrame("Button", nil, self.frame, "SecureActionButtonTemplate")
    undoButton:SetPoint("BOTTOMLEFT", self.reverseButton, "TOPLEFT", 0, 0)
    undoButton.background = undoButton:CreateTexture(nil, "BACKGROUND")
    undoButton.background:SetAllPoints()
    undoButton.border = CreateFrame("Frame", nil, undoButton, "BackdropTemplate")
    undoButton.border:SetAllPoints()
    undoButton.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    undoButton.border:SetBackdropBorderColor(0, 0, 0, 1)
    undoButton.text = undoButton:CreateFontString(nil, "OVERLAY")
    undoButton.text:SetPoint("CENTER", undoButton, "CENTER", 0, 0)
    undoButton.text:SetFont(
        "Fonts\\FRIZQT__.TTF",
        10,
        "OUTLINE"
    )
    undoButton.text:SetTextColor(1, 1, 1, 1)
    undoButton.text:SetText(L["Undo"])
    undoButton:SetAttribute("type", "macro")
    undoButton:SetAttribute("macrotext", "/rw " .. L["Undo"])
    undoButton:RegisterForClicks("AnyDown")
    undoButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(undoButton, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["UndoLastRune"], nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    undoButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    self.undoButton = undoButton
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

-- MARK: ProjectionBar

local function CreateProjectionBar(self)
    local projectionBar = CreateFrame("Frame", nil, self.frame)
    projectionBar.background = projectionBar:CreateTexture(nil, "BACKGROUND")
    projectionBar.background:SetAllPoints()
    projectionBar.border = CreateFrame("Frame", nil, projectionBar, "BackdropTemplate")
    projectionBar.border:SetAllPoints()
    projectionBar.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1, insets = {left = 1, right = 1, top = 1, bottom = 1}})
    projectionBar.border:SetBackdropBorderColor(0, 0, 0, 1)

    self.projectionIcons = {}
    for _, key in pairs(BASE_ICON_ORDERS) do
        local icon = CreateFrame("Frame", nil, projectionBar)
        icon.texture = icon:CreateFontString(nil, "OVERLAY")
        icon.texture:SetAllPoints()
        icon.texture:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
        icon.texture:SetTextColor(1, 1, 1)
        self.projectionIcons[key] = icon
    end

    self.projectionBar = projectionBar
end

-- MARK: Create Helpers

local function CreateHelper(self)
    CreateMainFrame(self)
    CreateIcons(self)
    CreateSideBar(self)
    CreateGeneralButton(self)
    CreateRuneButton(self, self.sideBar)
    -- CreateProjectionBar(self)

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

-- MARK: Toggle RL Buttons

local function ToggleRLButtons(self)
    if self.ShowRLButton then
        self.undoButton:Show()
        for _, runeButton in pairs(self.runeButtons or {}) do
            runeButton:Show()
        end
    else
        self.undoButton:Hide()
        for _, runeButton in pairs(self.runeButtons or {}) do
            runeButton:Hide()
        end
    end
end

-- MARK: UpdateStyle

---Update style settings and render them in-game for CustomTracker
function LuraHelper:UpdateStyle()
    if not self.frame then
        CreateHelper(self)
        self:Activate(false) -- keep it hidden after creating
    end

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
        self.hideButton.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)

        self.undoButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
        self.undoButton.background:SetColorTexture(1, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)

        self.clearButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
        self.clearButton.background:SetColorTexture(0, 1, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)

        self.reverseButton:SetSize(sideIconSize, scale * BASE_BUTTON_HEIGHT)
        self.reverseButton.background:SetColorTexture(0, 0, 1, addon.db[self.modName]["BackgroundOpacity"] or 0.5)
    end

    if self.projectionBar then
        self.projectionBar:SetSize(iconSize * #BASE_ICON_ORDERS, iconSize)
        self.projectionBar:SetPoint("TOP", self.frame, "BOTTOM", 0, 0)
        self.projectionBar.background:SetColorTexture(0, 0, 0, addon.db[self.modName]["BackgroundOpacity"] or 0.5)

        local lastProjectionIcon = nil
        for _, key in pairs(BASE_ICON_ORDERS) do
            local icon = self.projectionIcons[key]
            icon:SetSize(iconSize, iconSize)
            icon:ClearAllPoints()
            icon:SetPoint("RIGHT", lastProjectionIcon or self.projectionBar, lastProjectionIcon and "LEFT" or "RIGHT", 0, 0)
            lastProjectionIcon = icon
        end
    end
end

-- MARK: IsActivate

function LuraHelper:IsActivate()
    return self.frame and self.frame:IsShown() or false
end

-- MARK: Activate

function LuraHelper:Activate(on)
    if not self.frame then return end

    if on then
        self.frame:Show()
        self.hideButton:Show()

        ToggleRLButtons(self)
    else
        self.frame:Hide()
        self.hideButton:Hide()
    end
end

-- MARK: Test

---Test Mode
---@param on boolean turn the Test mode on or off
function LuraHelper:Test(on)
    if not addon.db[self.modName]["Enabled"] then -- if the module is not enabled, do not allow test mode
        return
    end

    if on then
        self.isTestMode = true
        self.ShowRLButton = true
        self:Activate(on)
        addon.Utilities:MakeFrameDragPosition(self.frame, self.modName, "X", "Y")
    else
        if self.isTestMode then
            self:Activate(on)
            self.isTestMode = false
            self.ShowRLButton = IsInRaid() and UnitIsGroupAssistant("player")
        end
    end
end

-- MARK: RegisterEvents

---Register events
function LuraHelper:RegisterEvents()
    addon.core:RegisterStateMonitor("encounterInfo", self.modName, function()
        local currentEncounter = addon.states.encounterInfo.encounterID
        if not currentEncounter then
            return
        elseif currentEncounter == 0 then -- end of encounter
            ClearRunes(self)
            self:Activate(false)
        elseif currentEncounter == 3183 then
            ClearRunes(self)
            self:Activate(true)
        end
    end)

    addon.core:RegisterEvent("GROUP_ROSTER_UPDATE", self.eventFrame, self.modName)

    -- combat events are registered independenly, to avoid unnecessary triggeres
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        -- local rune = ParseEvent(self, event, select(1, ...))
        if event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER" or event == "CHAT_MSG_SAY" then -- say for debug only(active in toggle)
            local rune = select(1, ...)
            AssignRune(self, rune)
        elseif event == "CHAT_MSG_RAID_WARNING" then
            UndoRune(self)
        elseif event == "GROUP_ROSTER_UPDATE" then
            if IsInRaid() and UnitIsGroupAssistant("player") then
                self.ShowRLButton = true
            end
        end
    end)
end

-- MARK: Register Module
addon.core:RegisterModule(LuraHelper.modName, function() return LuraHelper:Initialize() end)